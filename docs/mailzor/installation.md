---
titleTemplate: Mailzor
---

# Installation

This section will guide you through setting up Mailzor on your server.

::: danger WARNING
Mailzor requires a VPS or dedicated server with root access. It cannot be installed on shared hosting due to its reliance on background workers (Redis/Horizon) and custom PHP configurations.
:::

::: info
For upgrading an existing installation, please refer to the [Upgrade Guide](/mailzor/upgrade).
:::

## Server Requirements

Mailzor is built on Laravel 12 and requires a modern hosting environment.

#### Web Server
- **nginx** (Recommended) or Apache.

#### PHP Requirements
- **PHP Version**: >= 8.3
- **Required PHP Extensions**:
  - BCMath, Ctype, cURL, DOM, Fileinfo, JSON, Mbstring, OpenSSL, PCRE, PDO, SQLite, Tokenizer, XML, Redis, GD.

#### Database & Cache
- **MySQL**: 8.0+ or MariaDB 10.11+
- **Redis**: Required for queue management and Horizon.

#### Recommended Configuration
- **Memory Limit**: 1024M or higher for bulk processing.
- **OPcache**: Enabled for performance.
- **Supervisor**: Required to keep the Horizon process running.

## Installation Steps

### 1. Upload Files
Upload the Mailzor source code to your web directory (e.g., `/var/www/mailzor`).

### 2. Configure Permissions
Ensure the `storage` and `bootstrap/cache` directories are writable by the web server user (`www-data`).

```bash
chmod -R 775 storage bootstrap/cache
chown -R www-data:www-data .
```

### 3. Web Server Configuration
Point your domain's document root to the `/public` folder of the installation.

### 4. Run the Installer
Mailzor features a robust CLI installer that guides you through the entire setup process.

```bash
php artisan app:install
```

Follow the interactive prompts to:
- **Configure Database**: Connect to your MySQL/MariaDB database.
- **Set Up Application**: Generate app key and set basic environment variables.
- **Initialize Data**: Run migrations and seed essential data.
- **Create Admin Account**: Set up your initial super-admin credentials.
- **Configure Services**: Optionally configure Amazon SES or SMTP during the process.

### 5. Finalize Setup
Once the installer finishes, your application is ready to use. You can access the Admin Panel at `/admin` and the User Dashboard at `/dashboard`.

## Background Workers (Critical)

Mailzor relies heavily on background jobs for sending emails and validating lists. You **must** configure Laravel Horizon.

### Install Supervisor
Create a configuration file at `/etc/supervisor/conf.d/mailzor-worker.conf`:

```ini
[program:mailzor-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/mailzor/artisan horizon
autostart=true
autorestart=true
user=www-data
redirect_stderr=true
stdout_logfile=/var/www/mailzor/storage/logs/horizon.log
stopwaitsecs=3600
```

Apply the configuration:
```bash
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start mailzor-worker
```

## Cron Jobs
Add the following entry to your server's crontab (`crontab -e -u www-data`):

```bash
* * * * * php /var/www/mailzor/artisan schedule:run >> /dev/null 2>&1
```

## Post Installation
After installation, proceed to the [Configuration Guide](./configuration.md) to set up AWS SES or SMTP for email delivery.

