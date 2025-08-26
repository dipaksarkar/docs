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

echo "Docker, MySQL, Redis, and SQLite have been installed and started."
echo "You may need to log out and log in again for docker group membership to take effect."