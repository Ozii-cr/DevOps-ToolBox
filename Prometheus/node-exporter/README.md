# Node Exporter Installation Script

This Bash script automates the installation and setup of Prometheus Node Exporter on a Linux system. Node Exporter is a tool that exposes a wide variety of hardware and kernel-related metrics.

## Features

- Downloads and installs a specific version of Node Exporter
- Creates a dedicated user for running Node Exporter
- Sets up Node Exporter as a systemd service
- Automatically starts and enables the Node Exporter service

## Important Note

**The Node Exporter version can be easily changed by modifying the `NODE_EXPORTER_VERSION` variable at the beginning of the script.** This allows you to install the latest version or any specific version you require.

## Prerequisites

- A Linux system with `systemd`
- `sudo` privileges
- Internet connection for downloading Node Exporter

## Usage

1. Download the script to your system.
2. Make the script executable:
   ```
   chmod +x install_node_exporter.sh
   ```
3. (Optional) Edit the script to change the Node Exporter version:
   ```
   nano install_node_exporter.sh
   ```
   Look for the line `NODE_EXPORTER_VERSION="1.8.2"` and change it to your desired version.
4. Run the script with sudo privileges:
   ```
   sudo ./node_exporter.sh
   ```

## What the Script Does

1. Updates the system and installs necessary packages (`wget` and `tar`).
2. Creates a `node_exporter` user without login privileges.
3. Downloads the specified version of Node Exporter from the official GitHub repository.
4. Extracts the downloaded archive and moves the binary to `/usr/local/bin`.
5. Creates a systemd service file for Node Exporter.
6. Enables and starts the Node Exporter service.
7. Displays the status of the Node Exporter service.

## Configuration

The script uses the following default settings:

- Node Exporter Version: 1.8.2 (configurable)
- Installation Directory: `/usr/local/bin`
- Service File Location: `/etc/systemd/system/node_exporter.service`

To change the Node Exporter version, modify the `NODE_EXPORTER_VERSION` variable at the beginning of the script.

## Verification

After running the script, Node Exporter should be running as a service. You can verify this by:

1. Checking the service status:
   ```
   sudo systemctl status node_exporter
   ```
2. Accessing the Node Exporter metrics endpoint:
   ```
   curl http://localhost:9100/metrics
   ```

## Troubleshooting

- If the script fails to download Node Exporter, check your internet connection and verify the download URL.
- If the service fails to start, check the system logs:
  ```
  sudo journalctl -u node_exporter
  ```

## Security Considerations

- This script creates a system user for Node Exporter, which is a security best practice.
- Ensure that your firewall rules are configured to control access to port 9100, which is the default port for Node Exporter.
