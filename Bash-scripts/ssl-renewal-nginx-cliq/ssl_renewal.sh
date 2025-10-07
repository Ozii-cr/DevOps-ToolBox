#!/bin/bash

# SSL Renewal Script with Logging
# This script renews SSL certificates and restarts nginx

# Configuration
DOMAIN=""
LOG_FILE="/var/log/ssl_renewal.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Zoho Cliq Configuration 
CLIQ_URL=""  


# Function to send message to Zoho Cliq
send_cliq_message() {
    local message="$1"
    
    # Check if CLIQ_URL is set
    if [ -z "$CLIQ_URL" ]; then
        log_message "WARNING: CLIQ_URL not set, skipping Cliq notification"
        return 0
    fi
    
    # Create payload
    local payload="{\"text\": \"$message\"}"
    
    # Send the message to ZOHO api
    if curl -s -X POST "$CLIQ_URL" \
        -H "Content-Type: application/json" \
        -d "$payload" > /dev/null; then
        log_message "Notification sent to Zoho Cliq: $message"
        return 0
    else
        log_message "ERROR: Failed to send notification to Zoho Cliq"
        return 1
    fi
}

# Function to log messages
log_message() {
    echo "[$TIMESTAMP] $1" | tee -a "$LOG_FILE"
}

# Function to check if script is running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root. Use sudo." >&2
        send_cliq_message "SSL Renewal Failed: Script must be run as root"
        exit 1
    fi
}

# Function to stop nginx
stop_nginx() {
    log_message "Stopping nginx service"
    
    if systemctl stop nginx; then
        log_message "Nginx stopped successfully"
        send_cliq_message "Nginx stopped successfully for SSL renewal"
        return 0
    else
        log_message "ERROR: Failed to stop nginx"
        send_cliq_message "Failed to stop nginx - SSL renewal aborted"
        return 1
    fi
}

# Function to check if certificate needs renewal
check_renewal_needed() {
    log_message "Checking if certificate needs renewal for $DOMAIN"
    
    # Check if certificate expires within 30 days
    if certbot certificates --domain "$DOMAIN" | grep -q "VALID: 30 days"; then
        log_message "Certificate will expire within 30 days, renewal needed"
        return 0
    elif certbot certificates --domain "$DOMAIN" | grep -q "INVALID"; then
        log_message "Certificate is invalid, renewal needed"
        return 0
    else
        log_message "Certificate not yet due for renewal"
        send_cliq_message "Certificate for $DOMAIN not yet due for renewal"
        return 1
    fi
}

# Function to renew certificate
renew_certificate() {
    log_message "Starting SSL certificate renewal for $DOMAIN"
    
    # Renew certificate with ECDSA key (using standalone mode since nginx is stopped)
    if certbot certonly --standalone -d "$DOMAIN" --key-type ecdsa --non-interactive --agree-tos --force-renewal; then
        log_message "SSL certificate successfully renewed for $DOMAIN"
        send_cliq_message "SSL certificate successfully renewed for $DOMAIN"
        return 0
    else
        log_message "ERROR: SSL certificate renewal failed for $DOMAIN"
        send_cliq_message "SSL certificate renewal failed for $DOMAIN"
        return 1
    fi
}

# Function to start nginx
start_nginx() {
    log_message "Starting nginx service"
    
    if systemctl start nginx; then
        log_message "Nginx started successfully"
        send_cliq_message "Nginx started successfully after SSL renewal"
        return 0
    else
        log_message "ERROR: Failed to start nginx"
        log_message "Attempting to check nginx status..."
        systemctl status nginx >> "$LOG_FILE" 2>&1
        send_cliq_message "Failed to start nginx after SSL renewal - manual intervention required"
        return 1
    fi
}

# Function to check certificate expiration
check_cert_expiry() {
    local cert_file="/etc/letsencrypt/live/$DOMAIN/cert.pem"
    if [[ -f "$cert_file" ]]; then
        local expiry_date=$(openssl x509 -in "$cert_file" -noout -enddate | cut -d= -f2)
        local days_until_expiry=$(( ($(date -d "$expiry_date" +%s) - $(date +%s)) / 86400 ))
        log_message "Current certificate expires on: $expiry_date (in $days_until_expiry days)"
        
        # Send expiry info to Cliq if URL is set
        if [ -n "$CLIQ_URL" ]; then
            send_cliq_message "Certificate expiry check: $expiry_date (in $days_until_expiry days)"
        fi
    else
        log_message "WARNING: Certificate file not found at $cert_file"
    fi
}

# Main execution
main() {
    log_message "=== SSL Renewal Script Started ==="
    
    # Send start notification
    send_cliq_message "SSL Renewal Process Started for $DOMAIN"
    
    check_root
    check_cert_expiry

    if check_renewal_needed; then
        log_message "Certificate renewal is required, proceeding with renewal process"

        # Stop nginx first
        if stop_nginx; then
            # Renew certificate with nginx stopped
            if renew_certificate; then
                # Start nginx after successful renewal
                if start_nginx; then
                    log_message "SSL renewal process completed successfully"
                    # Verify nginx is running
                    if systemctl is-active --quiet nginx; then
                        log_message "Nginx is running successfully"
                        send_cliq_message "Endpoint probed!"
                    else
                        log_message "ERROR: Nginx is not running after restart"
                        send_cliq_message "SSL renewal completed but Nginx is not running - manual check required"
                        exit 1
                    fi
                else
                    log_message "ERROR: Failed to start nginx after certificate renewal"
                    send_cliq_message "SSL renewal: Failed to start nginx - manual intervention required"
                    exit 1
                fi
            else
                log_message "ERROR: Certificate renewal failed, attempting to start nginx"
                send_cliq_message "SSL certificate renewal failed - attempting to restart nginx"
                # Try to start nginx even if renewal failed
                if start_nginx; then
                    log_message "Nginx restarted after failed certificate renewal"
                    send_cliq_message "Nginx restarted after failed certificate renewal"
                else
                    log_message "CRITICAL: Nginx failed to start after certificate renewal failure"
                    send_cliq_message "CRITICAL: Nginx failed to start after certificate renewal failure - manual intervention required"
                fi
                exit 1
            fi
        else
            log_message "ERROR: Failed to stop nginx, certificate renewal aborted"
            send_cliq_message "SSL renewal aborted: Failed to stop nginx"
            exit 1
        fi
    else
        log_message "Certificate does not need renewal at this time"
        send_cliq_message "Certificate for $DOMAIN does not need renewal at this time"
    fi

    log_message "=== SSL Renewal Script Completed ==="
}

# Run main function
main