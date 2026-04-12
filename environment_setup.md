This guide outlines how to ensure that AI agents and integrated terminals in **Antigravity** (and other macOS IDEs) correctly access your development environment on Apple Silicon (M3) Macs.

---

## The Problem: "Path Blindness"

On macOS, your `.zshrc` and `.zprofile` are typically only loaded for **interactive login shells** (when you manually open a terminal window).

AI agents often execute commands in **non-interactive shells**. If your paths (Homebrew, PHP, NVM) are only defined in `.zshrc`, the agent will be "blind" to them and return:
`zsh:1: command not found: php`

---

## The Solution: Use `~/.zshenv`

The `.zshenv` file is the "Source of Truth" for Zsh. It is loaded for **every** shell instance, including those triggered by AI agents, IDEs, and background scripts.

### Step 1: Create or Edit `.zshenv`

Open the file in your terminal:

```bash
nano ~/.zshenv
```

### Step 2: Add Your Development Environment

Copy and paste this template. It is optimized for an M3 Mac and includes your specific stack (PHP, Node, Android, and Composer):

```bash
# -------------------------------------------------------------------------
# 1. HOMEBREW (Essential for M3 Macs)
# -------------------------------------------------------------------------
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# -------------------------------------------------------------------------
# 2. PHP & COMPOSER
# -------------------------------------------------------------------------
# Ensures global binaries like Laravel Installer or Pint are accessible
export PATH="$HOME/.composer/vendor/bin:$HOME/.config/composer/vendor/bin:$PATH"

# -------------------------------------------------------------------------
# 3. NODE & NVM
# -------------------------------------------------------------------------
export NVM_DIR="$HOME/.nvm"
# Explicit path to the binary helps agents find Node without full NVM init
export PATH="$HOME/.nvm/versions/node/v22.21.1/bin:$PATH"

# -------------------------------------------------------------------------
# 4. ANDROID SDK
# -------------------------------------------------------------------------
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
export PATH="$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools"
```

### Step 3: Refresh the Environment

1.  Save the file (`Ctrl + O`, then `Enter`, then `Ctrl + X`).
2.  **Restart Antigravity entirely.** (A simple terminal reload is often not enough for the agent background process to pick up the changes).

---

## Step 4: IDE Configuration

Ensure Antigravity is configured to inherit this environment. Open your `settings.json` and verify these keys:

```json
{
  "terminal.integrated.inheritEnv": true,
  "terminal.integrated.shellArgs.osx": ["-l"],
  "terminal.integrated.env.osx": {
    "PATH": "/opt/homebrew/bin:/opt/homebrew/sbin:/Users/[username]/.nvm/versions/node/v22.21.1/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
  }
}
```

- **`-l`**: Forces a login shell, ensuring macOS path helpers are loaded.
- **`env.osx`**: Acts as a hardcoded fallback if the shell fails to load the profile.

---

## Step 5: Verification (The "Agent Check")

To confirm the fix, ask your Antigravity Agent to run the following command:

```bash
printenv PATH && which php && php -v
```

**Successful Output should show:**

1.  A PATH starting with `/opt/homebrew/bin`.
2.  The full path to your PHP binary.
3.  The PHP version (e.g., 8.3.x).

---

## Summary of Best Practices

- **Keep `.zshenv` Lightweight:** Only put `PATH` and `export` variables here. Avoid heavy scripts or `eval` commands, as they run for every process.
- **Use Absolute Paths:** When possible, use `/opt/homebrew/bin/php` instead of just `php` if the environment is still being stubborn.
- **M3 Specifics:** Always remember that on Apple Silicon, Homebrew lives in `/opt/homebrew/`, not `/usr/local/`.
