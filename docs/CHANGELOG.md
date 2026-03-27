# Changelog

All notable changes to HolyClaude will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/), and this project adheres to [Semantic Versioning](https://semver.org/).

## [1.1.2] - 03/26/2026

### Added
- Docker HEALTHCHECK instruction for container health monitoring
- Bootstrap now backs up existing `settings.json` and `CLAUDE.md` before overwriting on re-bootstrap
- Expanded CONTRIBUTING.md with build commands, testing steps, file map, and PR checklist

## [1.1.1] - 03/26/2026

### Fixed
- Workspace bind mount permissions on first run when Docker creates the directory as root
- Workspace directory now tracked via `.gitkeep` to prevent root ownership on fresh clones

### Added
- Configurable host-side port and bind-mount paths via `.env` file (`HOLYCLAUDE_HOST_PORT`, `HOLYCLAUDE_HOST_CLAUDE_DIR`, `HOLYCLAUDE_HOST_WORKSPACE_DIR`)

Thanks to [@Sunwood-ai-labs](https://github.com/Sunwood-ai-labs) for this contribution.

## [1.1.0] - 03/25/2026

### Added
- Apprise notification engine with support for 100+ services (Discord, Telegram, Slack, Email, Gotify, and more)
- Individual `NOTIFY_*` environment variables for easy per-service configuration
- Catch-all `NOTIFY_URLS` for any Apprise-supported service

### Changed
- Notification backend replaced from Pushover to Apprise

### Removed
- **BREAKING:** `PUSHOVER_APP_TOKEN` and `PUSHOVER_USER_KEY` environment variables removed. Migrate to `NOTIFY_PUSHOVER=pover://user_key@app_token`. See [configuration docs](configuration.md#notifications-apprise) for details.

## [1.0.0] - 03/21/2026

Initial public release.
