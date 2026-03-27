#!/bin/bash
set -e

# ==============================================================================
# HolyClaude — First-Boot Bootstrap
# Runs once on first container start, then creates a sentinel to skip next time.
# Delete ~/.claude/.holyclaude-bootstrapped to re-trigger.
# ==============================================================================

CLAUDE_HOME="/home/claude"
CLAUDE_USER="claude"
PUID="${PUID:-1000}"
PGID="${PGID:-1000}"
SOURCE_DIR="/usr/local/share/holyclaude"

echo "[bootstrap] Running first-boot initialization..."

# ---------- Create directory structure ----------
mkdir -p "$CLAUDE_HOME/.claude"

# ---------- Copy settings.json ----------
[ -f "$CLAUDE_HOME/.claude/settings.json" ] && cp "$CLAUDE_HOME/.claude/settings.json" "$CLAUDE_HOME/.claude/settings.json.bak"
cp "$SOURCE_DIR/settings.json" "$CLAUDE_HOME/.claude/settings.json"
echo "[bootstrap] Copied settings.json"

# ---------- Copy memory template (variant-aware) ----------
VARIANT="full"
if [ -f /etc/holyclaude-variant ]; then
    VARIANT=$(cat /etc/holyclaude-variant)
fi
[ -f "$CLAUDE_HOME/.claude/CLAUDE.md" ] && cp "$CLAUDE_HOME/.claude/CLAUDE.md" "$CLAUDE_HOME/.claude/CLAUDE.md.bak"
cp "$SOURCE_DIR/claude-memory-${VARIANT}.md" "$CLAUDE_HOME/.claude/CLAUDE.md"
echo "[bootstrap] Copied CLAUDE.md (${VARIANT} variant)"

# ---------- Pre-create ~/.claude.json ----------
cat > "$CLAUDE_HOME/.claude.json" <<'EOF'
{
  "hasCompletedOnboarding": true,
  "installMethod": "native"
}
EOF
echo "[bootstrap] Created ~/.claude.json"

# ---------- Git configuration ----------
GIT_USER_NAME="${GIT_USER_NAME:-HolyClaude User}"
GIT_USER_EMAIL="${GIT_USER_EMAIL:-noreply@holyclaude.local}"
runuser -u "$CLAUDE_USER" -- git config --global safe.directory /workspace
runuser -u "$CLAUDE_USER" -- git config --global user.name "$GIT_USER_NAME"
runuser -u "$CLAUDE_USER" -- git config --global user.email "$GIT_USER_EMAIL"
echo "[bootstrap] Configured git as '$GIT_USER_NAME <$GIT_USER_EMAIL>'"

# ---------- Fix ownership ----------
chown -R "$PUID:$PGID" "$CLAUDE_HOME/.claude"
chown "$PUID:$PGID" "$CLAUDE_HOME/.claude.json"

# ---------- Create sentinel ----------
touch "$CLAUDE_HOME/.claude/.holyclaude-bootstrapped"
chown "$PUID:$PGID" "$CLAUDE_HOME/.claude/.holyclaude-bootstrapped"

echo "[bootstrap] First-boot initialization complete."
