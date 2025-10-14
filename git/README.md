# GitHub Actions Runner Setup Scripts

This repository contains scripts to automate the setup of a dedicated user (`githubrunner`), install Docker, MySQL, Redis, SQLite, Python, Node.js, and prepare your server or Mac for running GitHub Actions self-hosted runners.

---

## Quick Install (Ubuntu/Linux)

Run the script from any Ubuntu server using:

```bash
bash <(wget -qO- https://raw.githubusercontent.com/dipaksarkar/docs/refs/heads/master/git/setup-runner.sh)
```

---

## Quick Install (macOS)

Run the script from any Mac using:

```bash
bash <(wget -qO- https://raw.githubusercontent.com/dipaksarkar/docs/refs/heads/master/git/setup-runner-macos.sh)
```

---

## What It Does

- Installs dependencies for CI/CD
- Sets up MySQL, Redis, SQLite, Python 3, Node.js
- Creates a non-root `githubrunner` user and gives it admin/sudo access
- Prepares the runner directory (`~/actions-runner`)
- Prints instructions for runner configuration

---

## After Running the Script

1. **Switch to the runner user:**
   ```bash
   sudo su - githubrunner
   cd ~/actions-runner
   ```

2. **Download and extract the runner:**
   - On Ubuntu:
     ```bash
     wget https://github.com/actions/runner/releases/download/v2.328.0/actions-runner-linux-x64-2.328.0.tar.gz
     tar xzf actions-runner-linux-x64-2.328.0.tar.gz
     ```
   - On macOS:
     ```bash
     wget https://github.com/actions/runner/releases/latest/download/actions-runner-osx-x64-2.328.0.tar.gz
     tar xzf actions-runner-osx-x64-2.328.0.tar.gz
     ```

3. **Configure the runner:**
   ```bash
   ./config.sh --url <your_repo_url> --token <your_runner_token>
   ```

4. **(Linux Only) Install and start the runner as a service (so it runs on boot):**
   ```bash
   sudo ./svc.sh install
   sudo ./svc.sh start
   ```

5. **(macOS Only) To run the runner on boot:**
   - See [GitHub Docs: macOS runner as a service](https://docs.github.com/en/actions/hosting-your-own-runners/configuring-the-self-hosted-runner-application-as-a-service#macos)
   - Or use [LaunchAgents](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html) to auto-start `run.sh`

---

## Notes

- For Docker usage without `sudo` (Linux), log out and log in again after running the script.
- The runner will now start automatically on boot (Linux) or login (macOS if configured).
- You can check the runner service status with:
  ```bash
  sudo ./svc.sh status
  ```
  (Linux only)

---

**Customize the script as needed for your environment or organization!**
