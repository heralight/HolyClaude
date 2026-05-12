# HolyClaude Environment — Slim Variant

You are running inside a **HolyClaude Docker container** (slim variant). Core tools are pre-installed. Additional packages can be installed on-demand — see the "Not Pre-installed" sections below. This file is your global memory — customize it with your own preferences, projects, and context.

---

## Environment Overview

- **OS:** Debian Trixie (slim) inside Docker
- **User:** `claude` (UID/GID configurable via PUID/PGID)
- **Working directory:** `/workspace` (bind-mounted from host)
- **Home directory:** `/home/claude`
- **Persistent storage:** `~/.claude/` is bind-mounted — settings, credentials, and this file survive container rebuilds
- **Process manager:** s6-overlay v3 (PID 1) — manages all long-running services
- **Display:** Xvfb virtual display at `:99` for headless browser operations
- **Variant:** SLIM — lighter image, install extras as needed

## Running Services

| Service | What it does | Port |
|---------|-------------|------|
| **CloudCLI** | Web UI for Claude Code | `3001` |
| **Xvfb** | Virtual display for headless Chromium | `:99` (internal) |

Both managed by s6-overlay — they auto-restart on failure.

## Node.js & npm (v22 LTS) + Bun

### Pre-installed global packages (via bun):
- **Languages:** typescript, tsx
- **Package managers:** pnpm, bun (also available), npm (built-in)
- **Build tools:** vite, esbuild
- **Code quality:** eslint, prettier
- **Dev servers:** serve, nodemon
- **Utilities:** concurrently, dotenv-cli

### NOT pre-installed (install when needed):
```bash
# Preferred — user-level (claude), no sudo needed
bun install -g wrangler               # Cloudflare
bun install -g vercel                 # Vercel
bun install -g netlify-cli            # Netlify
bun install -g prisma                 # Prisma ORM
bun install -g drizzle-kit            # Drizzle ORM
bun install -g pm2                    # Process manager
bun install -g lighthouse @lhci/cli   # Performance testing
bun install -g sharp-cli              # Image processing
bun install -g json-server            # Mock REST APIs
bun install -g http-server            # Static file server
bun install -g @marp-team/marp-cli    # Markdown presentations
bun install -g @cloudflare/next-on-pages

# Fallback if bun lacks compatibility
npm i -g <package>
```
Prefer `bun install -g` over `npm i -g` — both produce the same result, but bun runs user-level (no root).

## Python 3 + uv

### Pre-installed packages:
- **HTTP:** requests, httpx
- **Scraping:** beautifulsoup4, lxml
- **Images:** Pillow
- **Data:** pandas, numpy
- **Excel:** openpyxl
- **Documents:** python-docx, markdown, jinja2
- **Config:** pyyaml, python-dotenv
- **CLI:** rich, click, tqdm
- **Browser:** playwright

### Package manager: uv
```bash
uv <command>                # uv replaces pip and venv
uv pip install <package>    # Install packages (alias: `pip` → `uv pip`)
uv run python3 <script>     # Run in uv-managed env (alias: `python` → `uv run python3`)
```

### NOT pre-installed (install when needed — prefer uv over pip):
```bash
# PDF libraries (install the one you need, not all)
uv pip install reportlab      # Generate PDFs
uv pip install weasyprint     # HTML to PDF
uv pip install fpdf2          # Simple PDF creation
uv pip install PyMuPDF        # Read/manipulate PDFs
uv pip install pdfkit         # wkhtmltopdf wrapper
uv pip install img2pdf        # Images to PDF

# Data visualization
uv pip install matplotlib seaborn

# Excel (additional)
uv pip install xlsxwriter xlrd

# Office documents
uv pip install python-pptx    # PowerPoint

# Web framework
uv pip install fastapi uvicorn

# HTTP client
uv pip install httpie
```

### Fallback (system pip):
```bash
pip install --break-system-packages <package>
```
The `--break-system-packages` flag is required for system pip. Prefer `uv pip install` when possible.

### System packages NOT pre-installed:
The slim variant does not include these apt packages. Install if needed:
```bash
sudo apt-get update && sudo apt-get install -y pandoc    # Document conversion
sudo apt-get install -y ffmpeg                            # Video/audio processing
sudo apt-get install -y libvips-dev                       # Image processing library
```
These take longer to install (~1-2 minutes) because they require system dependencies.

## AI CLI Providers

| CLI | Command | Notes |
|-----|---------|-------|
| **Claude Code** | `claude` | Primary — you are running inside this |
| **Gemini CLI** | `gemini` | Requires `GEMINI_API_KEY` env var |
| **OpenAI Codex** | `codex` | Requires `OPENAI_API_KEY` env var |
| **Cursor** | `cursor` | Requires `CURSOR_API_KEY` env var |
| **TaskMaster AI** | `task-master` | Task planning and management |

## System Tools

### Command-line utilities:
- **Search:** ripgrep (`rg`), fd (`fdfind`), fzf, grep, sift
- **Task runner:** task (Taskfile.dev — installed via `bun install -g @go-task/cli`)
- **Files:** tree, bat (`batcat` or `bat`), jq, zip/unzip
- **Network:** curl, wget, openssh-client
- **Process:** htop, lsof, strace, iproute2 (`ip`, `ss`)
- **Terminal:** tmux
- **Version control:** git, gh (GitHub CLI)

### Database CLIs:
- **PostgreSQL:** `psql`
- **Redis:** `redis-cli`
- **SQLite:** `sqlite3`

### Media processing:
- **Images:** imagemagick (`convert`, `identify`, `mogrify`)
- **Video/Audio:** NOT installed — `sudo apt-get install -y ffmpeg` if needed
- **Documents:** NOT installed — `sudo apt-get install -y pandoc` if needed

### Browser:
- **Chromium** at `/usr/bin/chromium` — headless by default
- **Playwright** installed — use for browser automation, screenshots, testing
- Xvfb provides a virtual display so Chromium has a screen to render to
- Flags preset: `--no-sandbox --disable-gpu --disable-dev-shm-usage`

## GitHub CLI (gh)

Pre-installed and ready. Authenticate with:
```bash
gh auth login
```

Common operations:
```bash
gh repo clone owner/repo
gh pr create --title "..." --body "..."
gh issue list
gh pr merge
```

## Notifications (Apprise)

Optional push notifications via [Apprise](https://github.com/caronc/apprise) — supports 100+ services (Discord, Telegram, Slack, Email, Pushover, Gotify, and more). Disabled by default.

**To enable:**
1. Set one or more `NOTIFY_*` environment variables (e.g. `NOTIFY_DISCORD`, `NOTIFY_TELEGRAM`, `NOTIFY_PUSHOVER`)
2. Create the flag file: `touch ~/.claude/notify-on`

**To disable:** `rm ~/.claude/notify-on`

## Workspace

- All projects go in `/workspace` (bind-mounted from host)
- Git is pre-configured with `safe.directory /workspace`
- Git identity is set via `GIT_USER_NAME` and `GIT_USER_EMAIL` env vars
- Create repos, clone projects, build — everything persists on the host

## Permissions

Claude Code runs in `allowEdits` mode by default:
- File edits: allowed without confirmation
- Shell commands: asks for confirmation
- To enable full bypass: change `allowEdits` to `bypassPermissions` in `~/.claude/settings.json`

## Container Lifecycle

- **First boot:** Bootstrap runs once — copies settings, memory, configures git
- **Subsequent boots:** Bootstrap skipped (sentinel file exists)
- **Re-trigger bootstrap:** Delete `~/.claude/.holyclaude-bootstrapped`
- **Credentials survive rebuilds:** `~/.claude/` is bind-mounted
- **CloudCLI account:** NOT persistent (SQLite can't live on network mounts) — re-create after rebuild (~10 seconds)

## Tips

- Use the **Web Terminal** plugin in CloudCLI instead of "Continue in Shell" (known CloudCLI bug)
- Chromium needs `shm_size: 2g` or higher in docker-compose to avoid crashes
- If on SMB/CIFS mounts, enable `CHOKIDAR_USEPOLLING=1` and `WATCHFILES_FORCE_POLLING=true`
- SQLite databases should NOT be stored on network mounts (file locking fails on CIFS)
- **Slim variant:** When you need a tool that's not installed, just install it. npm/pip packages take seconds. apt packages take 1-2 minutes.

---

## Your Preferences

Add your personal preferences below. This section persists across container rebuilds.

```
# Example:
# - Default stack: Astro, Tailwind, pnpm
# - Direct communication, no fluff
# - Always use TypeScript
```
