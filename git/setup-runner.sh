#!/bin/bash

set -e

#######################
# Variables
#######################

RUNNER_USER=githubrunner
RUNNER_HOME="/home/$RUNNER_USER"
RUNNER_DIR="$RUNNER_HOME/actions-runner"

#######################
# System Preparation
#######################

echo "Updating package list..."
sudo apt update

echo "Installing prerequisites for Docker..."
for pkg in apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release; do
    if dpkg -s $pkg >/dev/null 2>&1; then
        echo "$pkg is already installed. Skipping."
    else
        sudo apt install -y $pkg
    fi
done

echo "Adding Docker’s official GPG key..."
if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
        sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
else
    echo "Docker GPG key already exists. Skipping."
fi

echo "Adding Docker apt repository..."
if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
else
    echo "Docker apt repository already exists. Skipping."
fi

echo "Updating package list for Docker..."
sudo apt update

echo "Installing Docker Engine..."
for pkg in docker-ce docker-ce-cli containerd.io; do
    if dpkg -s $pkg >/dev/null 2>&1; then
        echo "$pkg is already installed. Skipping."
    else
        sudo apt install -y $pkg
    fi
done

echo "Enabling and starting Docker..."
sudo systemctl enable docker
sudo systemctl start docker

#############################
# Create githubrunner User
#############################

if ! id -u "$RUNNER_USER" >/dev/null 2>&1; then
    echo "Creating user: $RUNNER_USER"
    sudo adduser --disabled-password --gecos "" "$RUNNER_USER"
else
    echo "User $RUNNER_USER already exists. Skipping user creation."
fi

echo "Adding $RUNNER_USER to docker group..."
sudo usermod -aG docker "$RUNNER_USER"

echo "Adding $RUNNER_USER to sudo group..."
sudo usermod -aG sudo "$RUNNER_USER"

#######################
# Database & Languages
#######################

echo "Installing MySQL Server..."
if dpkg -s mysql-server >/dev/null 2>&1; then
    echo "mysql-server is already installed. Skipping."
else
    sudo apt install -y mysql-server
fi
sudo systemctl enable mysql
sudo systemctl start mysql

echo "Installing Redis Server..."
if dpkg -s redis-server >/dev/null 2>&1; then
    echo "redis-server is already installed. Skipping."
else
    sudo apt install -y redis-server
fi
sudo systemctl enable redis-server
sudo systemctl start redis-server

echo "Installing SQLite..."
for pkg in sqlite3 libsqlite3-dev; do
    if dpkg -s $pkg >/dev/null 2>&1; then
        echo "$pkg is already installed. Skipping."
    else
        sudo apt install -y $pkg
    fi
done

echo "Installing Python 3 and pip..."
for pkg in python3 python3-pip python3-venv; do
    if dpkg -s $pkg >/dev/null 2>&1; then
        echo "$pkg is already installed. Skipping."
    else
        sudo apt install -y $pkg
    fi
done

echo "Installing Node.js (LTS) and npm..."
if command -v node >/dev/null 2>&1; then
    echo "Node.js is already installed. Skipping."
else
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt install -y nodejs
fi

#########################
# Setup Actions Runner Dir
#########################

echo "Creating runner directory: $RUNNER_DIR"
sudo mkdir -p "$RUNNER_DIR"
sudo chown -R $RUNNER_USER:$RUNNER_USER "$RUNNER_DIR"

#######################
# Set Password (Prompt)
#######################

echo
echo "To set a password for $RUNNER_USER, run:"
echo "    sudo passwd $RUNNER_USER"
echo "(This allows login as $RUNNER_USER for runner setup and management.)"
echo

#######################
# Final Instructions
#######################

echo "Setup complete!"
echo "To configure and start your GitHub Actions runner:"
echo "1. Switch to the runner user:"
echo "       sudo su - $RUNNER_USER"
echo "2. Download the runner package to ~/actions-runner:"
echo "       cd ~/actions-runner"
echo "       wget https://github.com/actions/runner/releases/download/v2.328.0/actions-runner-linux-x64-2.328.0.tar.gz"
echo "       tar xzf actions-runner-linux-x64-2.328.0.tar.gz"
echo "3. Configure the runner (replace <url> and <token> appropriately):"
echo "       ./config.sh --url <your_repo_url> --token <your_runner_token>"
echo "4. Install the runner as a service:"
echo "       sudo ./svc.sh install"
echo "       sudo ./svc.sh start"
echo
echo "The runner will now start automatically on boot!"
