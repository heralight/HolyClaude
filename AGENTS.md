
## Codex file access policy

- Do not read, summarize, index, search, modify, or traverse `.git/`, `.claude/`, `data/`, `assets/`, `workspace/`.
- Respect `.gitignore` as the source of truth for ignored files.
- Before listing project files, prefer:
  `git ls-files`
  or:
  `rg --files --hidden --glob '!.git/**'`
- Do not inspect ignored folders such as `node_modules/`, `dist/`, `build/`, `coverage/`, `.venv/`, `venv/`, logs, local databases, or `.env*` files.
- If a task appears to require an ignored file, ask before reading it.
