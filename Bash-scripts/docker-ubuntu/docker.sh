#!/bin/bash

# Ensure the script runs as root
if [[ $EUID -ne 0 ]]; then
    echo "Please run as root or with sudo."
    exit 1
fi

# Create directory for Docker GPG key
install -m 0755 -d /etc/apt/keyrings

# Download Docker's GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

# Ensure proper permissions for the key
chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository to Apt sources
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package manager repositories
apt-get update

# Install Docker
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Check if at least one username is provided
if [ "$#" -eq 0 ]; then
    echo "Usage: sudo ./install_docker.sh <user1> <user2> ..."
    exit 1
fi

# Loop through each provided username
for USER_TO_ADD in "$@"; do
    if id "$USER_TO_ADD" &>/dev/null; then
        usermod -aG docker "$USER_TO_ADD"
        echo "Added $USER_TO_ADD to the docker group."
    else
        echo "User $USER_TO_ADD does not exist."
    fi
done

# Apply group membership
newgrp docker

echo "Docker installation and user setup complete."
