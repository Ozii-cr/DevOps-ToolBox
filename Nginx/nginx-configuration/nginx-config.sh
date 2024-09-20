#!/bin/bash

# Function to generate Nginx configuration
generate_nginx_config() {
    local domain=$1
    local port=$2
    local name=$3

    cat <<EOF
server {
    listen 80;
    server_name $domain;

    location / {
        proxy_pass http://localhost:$port;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF
}

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <domain> <port> <name>"
    exit 1
fi

# Get the domain and port from the command-line arguments
domain=$1
port=$2
name=$3

# Generate Nginx configuration
config=$(generate_nginx_config "$domain" "$port" "name")

# Save configuration to a file
config_file="/etc/nginx/conf.d/$name.conf"
echo "$config" > "$config_file"