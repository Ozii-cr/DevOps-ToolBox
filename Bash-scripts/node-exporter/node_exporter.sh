#!/bin/bash

# Define variables
NODE_EXPORTER_VERSION="1.8.2"
DOWNLOAD_URL="https://github.com/prometheus/node_exporter/releases/download/v$NODE_EXPORTER_VERSION/node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz"
INSTALL_DIR="/usr/local/bin"
SERVICE_FILE="/etc/systemd/system/node_exporter.service"

# Update the system and install necessary packages
echo "Updating system and installing required packages..."
sudo apt update && sudo apt install -y wget tar || true

# Create a node_exporter user without login shell
echo "Creating node_exporter user..."
sudo useradd --no-create-home --shell /bin/false node_exporter || true

# Download the node exporter tar.gz file
echo "Downloading Node Exporter version $NODE_EXPORTER_VERSION..."
wget $DOWNLOAD_URL -O /tmp/node_exporter.tar.gz

# Extract the downloaded tar.gz file
echo "Extracting Node Exporter..."
tar -xvzf /tmp/node_exporter.tar.gz -C /tmp

# Move the node_exporter binary to /usr/local/bin
echo "Installing Node Exporter to $INSTALL_DIR..."
sudo mv /tmp/node_exporter-$NODE_EXPORTER_VERSION.linux-amd64/node_exporter $INSTALL_DIR/

# Create a systemd service file for Node Exporter
echo "Creating Node Exporter systemd service file..."
sudo tee $SERVICE_FILE > /dev/null <<EOL
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
ExecStart=$INSTALL_DIR/node_exporter
Restart=always

[Install]
WantedBy=default.target
EOL

# Reload systemd to recognize the new service
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

# Enable and start the Node Exporter service
echo "Enabling and starting Node Exporter service..."
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

# Check the status of the Node Exporter service
echo "Node Exporter service status:"
sudo systemctl status node_exporter --no-pager