# GitHub Actions Runner Setup Script

This script automates the setup of a dedicated user (`githubrunner`), installs Docker, MySQL, Redis, SQLite, Python, Node.js, and prepares your server for running GitHub Actions self-hosted runners.

## Quick Install

Run the script from any Ubuntu server using:

```bash
bash <(wget -qO- https://raw.githubusercontent.com/dipaksarkar/docs/refs/heads/master/git/setup-runner.sh)
```

## What It Does

- Installs Docker and dependencies
- Sets up MySQL, Redis, SQLite, Python 3, Node.js
- Creates a non-root `githubrunner` user
- Adds `githubrunner` to the `docker` group
- Prepares the runner directory (`/home/githubrunner/actions-runner`)
- Prints instructions for runner configuration

## After Running the Script

1. **Set a password for the runner user:**
   ```bash
   sudo passwd githubrunner
   ```

2. **Switch to the runner user:**
   ```bash
   sudo su - githubrunner
   cd ~/actions-runner
   ```

3. **Download and extract the runner:**
   ```bash
   wget https://github.com/actions/runner/releases/download/v2.328.0/actions-runner-linux-x64-2.328.0.tar.gz
   tar xzf actions-runner-linux-x64-2.328.0.tar.gz
   ```

4. **Configure the runner:**
   ```bash
   ./config.sh --url <your_repo_url> --token <your_runner_token>
   ```

5. **Install and start the runner as a service (so it runs on boot):**
   ```bash
   sudo ./svc.sh install
   sudo ./svc.sh start
   ```

## Notes

- For Docker usage without `sudo`, log out and log in again after running the script.
- The runner will now start automatically on boot.
- You can check the runner service status with:
  ```bash
  sudo ./svc.sh status
  ```

---

**Customize the script as needed for your environment or organization!**
