# CLAUDE.md

Ce fichier fournit des instructions à Claude Code (claude.ai/code) lorsqu'il travaille sur du code dans ce dépôt.

## Vue d'ensemble

HolyClaude est un conteneur Docker préconfiguré qui embarque Claude Code CLI, CloudCLI (interface web), 7 CLI IA, un navigateur Chromium headless, et 50+ outils de développement — le tout en une seule image.

## Commandes principales

```bash
# Build de l'image complète
docker build -t holyclaude .

# Build de l'image slim
docker build --build-arg VARIANT=slim -t holyclaude:slim .

# Build multi-arch (ARM)
docker buildx build --platform linux/arm64 -t holyclaude .

# Démarrage rapide (docker compose)
docker compose up -d
```

## Structure du projet

```
holyclaude/
├── Dockerfile              # Build single-stage (full/slim via ARG VARIANT)
├── docker-compose.yaml     # Configuration minimale
├── docker-compose.full.yaml# Configuration complète avec tous les paramètres
├── scripts/
│   ├── entrypoint.sh       # Point d'entrée — remappe UID/GID, bootstrap, handoff s6
│   ├── bootstrap.sh        # Premier démarrage : settings, CLAUDE.md, git, hooks
│   └── notify.py           # Notifications via Apprise (Discord, Telegram, etc.)
├── s6-overlay/s6-rc.d/     # Définitions de services s6-overlay
│   ├── cloudcli/           # CloudCLI (:3001), run sous l'utilisateur claude
│   └── xvfb/               # Xvfb (:99), affichage virtuel pour Chromium
├── config/
│   ├── settings.json       # Settings Claude Code par défaut (allowEdits)
│   ├── claude-memory-full.md   # Template mémoire pour la variante full
│   └── claude-memory-slim.md   # Template mémoire pour la variante slim
├── vendor/artifacts/       # Paquets CloudCLI patchés (vendored)
├── assets/                 # Logo et bannière
├── docs/                   # Documentation : architecture, configuration, ollama, troubleshooting
└── .github/workflows/      # CI/CD : build & push Docker Hub + GHCR (multi-arch, slim+full)
```

## Architecture

Le conteneur suit ce cycle de vie :

1. **`entrypoint.sh`** (root) — remappe UID/GID via PUID/PGID, crée les fichiers nécessaires, synchronise `.claude.json`, lance `bootstrap.sh` au premier démarrage, puis `exec /init` vers s6-overlay
2. **`bootstrap.sh`** (premier démarrage uniquement) — copie settings/CLAUDE.md, configure git, crée les hooks Codex/Gemini/Cursor, crée un sentinel (`.holyclaude-bootstrapped`)
3. **s6-overlay** (PID 1) — supervise CloudCLI et Xvfb, redémarre automatiquement en cas de crash

Services supervisés par s6-overlay :
- **CloudCLI** (`claude-code-ui --port 3001`) — interface web, tourne sous l'utilisateur `claude` avec `WORKSPACES_ROOT=/workspace`
- **Xvfb** (`Xvfb :99 1920x1080x24 -nolisten tcp`) — affichage virtuel pour Chromium headless

Les variables d'environnement Docker Compose ne passent pas automatiquement à travers s6-setuidgid. Les scripts `run` des services définissent explicitement les variables nécessaires.

## Patches CloudCLI

Le Dockerfile applique plusieurs patches au paquet CloudCLI vendored :
- **WebSocket** — préservation du type de frame binaire dans le proxy (Issue #11)
- **Shell** — préservation de la position de défilement (Issue #35)
- **Modèle** — support du modèle Claude personnalisé via SSE/select (Issue #36)

## Variantes d'image

Contrôlées par `ARG VARIANT=full` dans le Dockerfile. La variante est stockée dans `/etc/holyclaude-variant` et utilisée par bootstrap pour choisir le template CLAUDE.md.

| Variante | Paquets supplémentaires |
|----------|------------------------|
| `full` (défaut) | Tous les paquets npm/pip/apt, Azure CLI, Junie, OpenCode |
| `slim` | Noyau uniquement (TypeScript, Python, Playwright, AI CLIs principaux) |

## CI/CD

GitHub Actions (`.github/workflows/docker-publish.yml`):
- Déclenché sur les tags `v*`
- Construit et pousse vers Docker Hub (`coderluii/holyclaude`) et GHCR
- Matrix `slim`/`full` avec plateformes `linux/amd64,linux/arm64`
- Tags semver + `latest` (full) / `slim` (slim)
- Met à jour la description Docker Hub

## Notifications

Les hooks Claude Code (`Stop`, `PostToolUseFailure`) appellent `notify.py`, qui envoie via Apprise si :
1. Le fichier `~/.claude/notify-on` existe
2. Une variable `NOTIFY_*` est configurée (Discord, Telegram, Slack, Email, etc.)

## Persistance des données

| Chemin hôte | Chemin conteneur | Contenu |
|-------------|------------------|---------|
| `./data/claude/` | `/home/claude/.claude/` | Settings, credentials, APIs keys |
| `./workspace/` | `/workspace/` | Code et projets |

Le fichier `.claude.json` est persisté via un mécanisme de copie boot à boot (les symlinks sont écrasés par Claude Code).
