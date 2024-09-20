# Nginx Configuration Generator

This Bash script generates Nginx server configurations for reverse proxying to local services. It creates a new configuration file for each domain and port combination specified.

## Usage

```bash
./nginx-config.sh <domain> <port> <name>
```

### Arguments

- `<domain>`: The domain name for which to create the Nginx configuration.
- `<port>`: The local port to which the traffic should be proxied.
- `<name>`: A unique identifier for the configuration file.

## Features

- Generates Nginx server block configuration for reverse proxying.
- Sets up proper headers for proxying (Host, X-Real-IP, X-Forwarded-For, X-Forwarded-Proto).
- Creates a separate configuration file for each domain in `/etc/nginx/conf.d/`.

## Example

To create a configuration for example.com proxying to a local service running on port 3000:

```bash
./nginx-config.sh example.com 3000 myapp
```

This will create a file named `myapp.conf` in `/etc/nginx/conf.d/` with the appropriate Nginx configuration.

## Note

- This script requires root privileges to write to `/etc/nginx/conf.d/`.
- After running this script, you may need to reload or restart Nginx to apply the changes.
- Ensure that the local service is running on the specified port before setting up the Nginx proxy.
