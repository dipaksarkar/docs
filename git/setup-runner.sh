#!/bin/bash

set -e

# Update package list
sudo apt update

# Install prerequisites for Docker
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    gnupg \
    lsb-release

# Add Docker’s official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add Docker apt repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package list again for Docker
sudo apt update

# Install Docker Engine
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Enable and start Docker
sudo systemctl enable docker
sudo systemctl start docker

# Add current user to docker group for non-root usage (optional, requires re-login)
sudo usermod -aG docker $USER

# Install MySQL Server
sudo apt install -y mysql-server

# Enable and start MySQL
sudo systemctl enable mysql
sudo systemctl start mysql

# Install Redis Server
sudo apt install -y redis-server

# Enable and start Redis
sudo systemctl enable redis-server
sudo systemctl start redis-server

# Install SQLite
sudo apt install -y sqlite3 libsqlite3-dev

# Install Python 3 and pip
sudo apt install -y python3 python3-pip python3-venv

# Install Node.js (LTS) and npm using NodeSource
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

echo "Docker, MySQL, Redis, SQLite, Python, and Node.js have been installed and started."
echo "You may need to log out and log in again for docker group membership to take effect."

##############################
# GitHub Actions Runner User #
##############################

RUNNER_USER=githubrunner

# Create the user if it doesn't exist
if ! id -u "$RUNNER_USER" >/dev/null 2>&1; then
    sudo adduser --disabled-password --gecos "" "$RUNNER_USER"
fi

# Add user to docker group for GitHub Actions Docker jobs
sudo usermod -aG docker "$RUNNER_USER"

# Ensure actions-runner directory exists in user home
sudo mkdir -p /home/$RUNNER_USER/actions-runner

# Change owner of the directory to the runner user
sudo chown -R $RUNNER_USER:$RUNNER_USER /home/$RUNNER_USER/actions-runner

echo "User '$RUNNER_USER' created and prepared for GitHub Actions runner."
echo "Switch to this user to configure and run the runner:"
echo ""
echo "    sudo su - $RUNNER_USER"
echo "    cd ~/actions-runner"
echo "    ./config.sh --url <your_repo_url> --token <your_runner_token>"
echo ""
echo "After configuration, start the runner:"
echo "    ./run.sh"
