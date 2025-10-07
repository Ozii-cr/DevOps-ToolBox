# SSL Certificate Renewal Script

## Overview
This script automates SSL certificate renewal for your domain using **Let's Encrypt Certbot**, with integrated logging and optional **Zoho Cliq notifications**.  

It’s designed to run as a scheduled task (**cron job**) to ensure your SSL certificates remain valid.

---

## Prerequisites

### System Requirements
- Linux server (tested on Amazon Linux 2, Ubuntu, CentOS)  
- Root/sudo access  
- Nginx web server  
- Certbot installed  

### Required Software
```bash
# Install Certbot (Amazon Linux 2 example)
sudo yum install certbot -y

# Install curl (usually pre-installed)
sudo yum install curl -y
```

---

## ⚙️ Installation

Copy the script to your server:

```bash
sudo cp ssl_renewal.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/ssl_renewal.sh
```

Configure your domain:  

```bash
sudo vim /usr/local/bin/ssl_renewal.sh
```

Change:
```bash
DOMAIN="example.com"  # Replace with your domain
```

### Zoho Cliq Notifications (Optional)
- Create a webhook in your Zoho Cliq channel  
- Set the webhook URL as an environment variable  

```bash
# Temporary setting (for current session)
export CLIQ_URL="https://cliq.zoho.com/company/your-company/webhook/your-token"

# Permanent setting (add to ~/.bashrc or /etc/environment)
echo 'export CLIQ_URL="https://cliq.zoho.com/company/your-company/webhook/your-token"' >> ~/.bashrc
source ~/.bashrc
```

---

##  Manual Testing

```bash
# Test with Cliq notifications
sudo CLIQ_URL="your-webhook-url" /usr/local/bin/ssl_renewal.sh

# Test without Cliq notifications
sudo /usr/local/bin/ssl_renewal.sh
```

---

## Automation with Cron

Edit crontab:
```bash
sudo crontab -e
```

Add one of the following cron jobs:  

**Option 1: Basic (weekly on Sunday at 3 AM)**
```bash
0 3 * * 0 /usr/local/bin/ssl_renewal.sh
```

**Option 2: With Cliq notifications and logging**
```bash
0 3 * * 0 CLIQ_URL="your-webhook-url" /usr/local/bin/ssl_renewal.sh
```

**Option 3: With output redirection (recommended)**
```bash
0 3 * * 0 CLIQ_URL="your-webhook-url" /usr/local/bin/ssl_renewal.sh >> /var/log/ssl_renewal_cron.log 2>&1
```

---

## Script Workflow

1. **Initialization**  
   - Check root privileges  
   - Log start time  
   - Send start notification to Cliq  

2. **Certificate Check**  
   - Check certificate expiration  
   - Renew only if within 30 days of expiry  

3. **Renewal Process (if needed)**  
   - Stop nginx service  
   - Renew certificate using Certbot standalone mode  
   - Start nginx service  
   - Verify nginx is running  
   - Probe HTTPS endpoint  

4. **Completion**  
   - Log results  
   - Send success/failure notification  

---

## Log Files
- `/var/log/ssl_renewal.log` → Detailed script execution logs  
- `/var/log/letsencrypt/letsencrypt.log` → Certbot-specific logs  
- `/var/log/ssl_renewal_cron.log` → Optional cron output logs  

---

## Monitoring & Troubleshooting

```bash
# View recent logs
sudo tail -f /var/log/ssl_renewal.log

# Check certificate status
sudo certbot certificates

# Verify nginx status
sudo systemctl status nginx
```

---

## Manual Certificate Renewal

```bash
# Stop nginx first
sudo systemctl stop nginx

# Force certificate renewal
sudo certbot certonly --standalone -d your-domain.com --force-renewal

# Start nginx
sudo systemctl start nginx
```


---

## Maintenance
- Review logs regularly:  
  ```bash
  sudo tail -f /var/log/ssl_renewal.log
  ```  
- Update domain name if changed  
- Test script after system updates  
- Verify cron job functionality  

---
