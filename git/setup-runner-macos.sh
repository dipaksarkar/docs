#!/bin/bash

set -e

#############################
# Variables
#############################
RUNNER_USER="githubrunner"
RUNNER_HOME="/Users/$RUNNER_USER"
RUNNER_DIR="$RUNNER_HOME/actions-runner"

#############################
# Create githubrunner User
#############################
if ! id "$RUNNER_USER" >/dev/null 2>&1; then
    echo "Creating user: $RUNNER_USER"
    sudo sysadminctl -addUser "$RUNNER_USER" -fullName "GitHub Runner User" -password "-"
    sudo dscl . -create /Users/"$RUNNER_USER" UserShell /bin/bash
    sudo dscl . -create /Users/"$RUNNER_USER" NFSHomeDirectory "$RUNNER_HOME"
    sudo createhomedir -c -u "$RUNNER_USER" > /dev/null
fi

echo "Giving $RUNNER_USER admin rights (sudo privileges)..."
sudo dscl . -append /Groups/admin GroupMembership "$RUNNER_USER"

#############################
# Install Homebrew (if missing)
#############################
if ! command -v brew >/dev/null 2>&1; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

#############################
# Install Dependencies
#############################
echo "Installing dependencies: git, wget, python3, node, sqlite3..."
brew install git wget python3 node sqlite3

echo "Installing MySQL and Redis..."
brew install mysql redis

echo "Starting MySQL and Redis (will auto-start on login)..."
brew services start mysql
brew services start redis

#############################
# Prepare Runner Directory
#############################
echo "Creating runner directory: $RUNNER_DIR"
sudo mkdir -p "$RUNNER_DIR"
sudo chown -R "$RUNNER_USER":"staff" "$RUNNER_DIR"

#############################
# Final Instructions
#############################
echo
echo "Setup complete!"
echo "To configure and start your GitHub Actions runner:"
echo "1. Switch to the runner user:"
echo "       sudo su - $RUNNER_USER"
echo "2. Download and extract the runner to ~/actions-runner:"
echo "       cd ~/actions-runner"
echo "       wget https://github.com/actions/runner/releases/latest/download/actions-runner-osx-x64-2.328.0.tar.gz"
echo "       tar xzf actions-runner-osx-x64-2.328.0.tar.gz"
echo "3. Configure the runner (replace <url> and <token> appropriately):"
echo "       ./config.sh --url <your_repo_url> --token <your_runner_token>"
echo "4. (Optional) Set up auto-start as a Launch Agent. See README for instructions."
echo "5. Start the runner:"
echo "       ./run.sh"
echo
