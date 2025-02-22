name: Docker Installation Script
description: >
  This Bash script installs Docker on an Ubuntu system and adds specified users 
  to the `docker` group for permissionless access to Docker commands.

usage: |
  sudo ./install_docker.sh <user1> <user2> ...

arguments:
  - name: "<user1> <user2> ..."
    description: "List of users to be added to the `docker` group (optional)."

features:
  - Installs Docker and its required dependencies.
  - Adds specified users to the `docker` group to allow running Docker commands without `sudo`.
  - Ensures proper repository setup and permissions.
  - Supports adding multiple users in a single command.

example_usage: |
  To install Docker and grant access to users `ayo` and `fade`:
  
  ```bash
  sudo ./install_docker.sh ayo fade
