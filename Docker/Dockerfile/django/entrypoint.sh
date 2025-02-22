#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to retry a command
retry() {
    local retries=5
    local count=0
    until "$@"; do
        exit=$?
        count=$((count + 1))
        if [ $count -lt $retries ]; then
            echo "Command failed. Attempt $count/$retries:"
            sleep 5
        else
            echo "The command has failed after $retries attempts."
            return $exit
        fi
    done
    return 0
}

# Run Django migrations
echo "Running migrations..."
retry python manage.py migrate

# Start the application
echo "Starting the application..."
exec "$@"