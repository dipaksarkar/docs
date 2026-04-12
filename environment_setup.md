# Environment Setup Documentation

This document records the essential environment configuration for the **mailzor** project and other related development work on this system (macOS M3).

## 1. Sub-Agent Authorizations (Gemini CLI)

To ensure sub-agents like **Antigravity** can execute project tools (Artisan, NPM, etc.), permissions must be explicitly declared in the `.gemini/GEMINI.md` file.

**Path:** `~/.gemini/GEMINI.md`

```markdown
# Tool Authorization

To ensure sub-agents can perform development tasks, they are authorized to use the following system tools:

- `php`: Allowed for Laravel Artisan and background scripts.
- `npm`: Allowed for frontend builds and dependency management.
- `composer`: Allowed for PHP dependency management.

# Workspace Permissions

- Allow access to `/opt/homebrew/bin` for system binaries.
- Allow access to `/Volumes/Portable/mailzor` for project execution.
```

## 2. Shell Environment Configuration (.zshenv)

For macOS, paths should be exported in `.zshenv` to ensure they are visible to both interactive and non-interactive shell sessions (including AI agents).

**Path:** `~/.zshenv`

```bash
# 1. Homebrew Paths (Faster than eval shellenv)
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# 2. Android SDK
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
export PATH="$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools"

# 3. PHP / Composer Global Binaries
export PATH="$HOME/.composer/vendor/bin:$HOME/.config/composer/vendor/bin:$PATH"

# 4. NVM (Minimal pathing for the Agent)
export NVM_DIR="$HOME/.nvm"
# If the agent needs a specific node version quickly:
export PATH="$HOME/.nvm/versions/node/v22.21.1/bin:$PATH"

# Only load the full NVM script if it's an interactive shell to save time
if [[ -o interactive ]]; then
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
fi
```

## 3. Project Locations

- **Main Project:** `/Volumes/Portable/mailzor`
- **Documentation:** `/Volumes/Portable/docs`
