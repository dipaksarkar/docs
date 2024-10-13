# Installation

This section will guide you through setting up a basic **Gympify** instance from scratch.

::: danger WARNING
Gympify **cannot be installed on shared hosting**. You will need a **VPS (Virtual Private Server)** or a **dedicated server** to run Gympify, as it requires server-level configuration that shared hosting environments do not provide. If you're unsure how to set up a VPS, contact your hosting provider or use a managed VPS service.
:::

::: tip Info Info
For upgrading your existing Gympify installation, please refer to the [Upgrade Guide](/gympify/upgrade) for detailed instructions.
:::

## Prerequisites

To get started with a Gympify application, ensure you have the following prerequisites:

1. **Node 12+ for Quasar CLI with Webpack**, or **Node 14+ for Quasar CLI with Vite**.
   - To check your Node.js version, run `node -v` in a terminal/console window.
2. **Yarn v1 (strongly recommended)**, PNPM, or NPM.
   - To check your Yarn version, run `yarn -v` in a terminal/console window.

## Server Requirements

Gympify has specific system requirements. Ensure that your web server meets the following minimum PHP version and extensions:

- **Apache**, **nginx**, or another compatible web server.
- **PHP >= 8.1**
- **BCMath** PHP Extension
- **Ctype** PHP Extension
- **cURL** PHP Extension
- **DOM** PHP Extension
- **Fileinfo** PHP Extension
- **JSON** PHP Extension
- **Mbstring** PHP Extension
- **OpenSSL** PHP Extension
- **PCRE** PHP Extension
- **PDO** PHP Extension
- **Tokenizer** PHP Extension
- **XML** PHP Extension
- **Imagick** PHP Extension
- **ionCube Loader® v13.0**

Ensure you have the latest ionCube Loader version for your PHP version.

### Theme Building on Server

If you want to **build or modify themes on the server**, you will need to have **npm** installed to compile assets. Without **npm**, you can still edit template files (`views/**/*.blade.php`), but **you will not be able to modify or build any assets** (such as JavaScript, CSS, or images).

::: tip Info Info
Ensure that your server has the following tools installed for building themes:
- **Node.js >= 14.x** (which includes `npm`)
- **npm** or **yarn**

To install Node.js and npm:
```bash
sudo apt install nodejs npm
```

You can then build or edit themes by running the appropriate build commands (e.g., `npm run theme:build --name={theme-name}`).
:::

::: warning
This project utilizes the latest Laravel version (currently 10.x). Refer to the [Laravel documentation](https://laravel.com/docs) for more information.

The root folder for Laravel is `/public`. Do not install it in a sub-folder; using a sub-domain is preferable over a sub-folder. We do not support installing our product in a sub-folder.
:::

## Installing Quasar CLI

The Quasar CLI is used for project creation, generating application and library code, and various development tasks.

Install the Quasar CLI globally:

```bash
yarn global add @quasar/cli
yarn global add @quasar/icongenie
```

::: warning
On this project, we're using the latest Quasar version (currently 2.x). Please go to [Quasar documentation](https://quasar.dev/start/quasar-cli) page for more information.
:::

## Build Application

1. Execute the following commands in a terminal/console window:

```
cp .env.example .env
cp .htaccess.example .htaccess
```

2. (Optional) Modify `.env.frontend.prod`:

```
APP_ENV=Production
APP_NAME=Gympify
# (API_URL is optional, it will be generated using your app domain)
API_URL=https://your-domain-name.com/api
```

3. (Optional) Build the application by executing the following commands:

```
yarn install
yarn build:prod
```

## Install via GUI

- Create a database and upload all files into the root folder of your hosting (normally, it is `public_html`). Exclude the following folders:
  ```
    /dist
    /node_modules
  ```
- Go to [your-domain-name.com/install] to start the installation process.
- Follow the step-by-step instructions to set up your database connection, site information, and administrator account.
- Login and configure your website using the Welcome Board.

## Add Cron Jobs

Cron jobs are essential for automating tasks like running scripts or triggering specific actions at set times. Add the following cron jobs to your server:

```bash
# Run Laravel scheduler
* * * * * /usr/bin/php8.2 {project-root}/artisan schedule:run >> /dev/null 2>&1
```

## Setting Up a Systemd Service for Laravel Queues

Start by creating a service file in the desired location, for example:

```bash
sudo nano /etc/systemd/system/queues.service
```

### Add the Service Configuration

Add the following configuration to the service file:

```
# This systemd service is responsible for managing the queue workers for the CRM project.

[Unit]
Description=Gympify Queues
After=network.target

[Service]
User=gympify
Group=gympify
Restart=always
ExecStart=/usr/bin/php /home/gympify/gympify.com/artisan queue:work --sleep=3 --tries=3 --max-time=3600
RestartSec=5
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=gympify-queues

[Install]
WantedBy=multi-user.target
```
Save and exit the file.

### Reload Systemd

Reload the systemd daemon to recognize the new service:

```bash
sudo systemctl daemon-reload
```

### Enable the Service

Enable the service so that it starts automatically at boot:

```bash
sudo systemctl enable gympify-queues
```

### Start the Service

Start the service manually:

```bash
sudo systemctl start gympify-queues
```

## Remove Dummy Data

1. Open the SSH terminal on your machine and run the following command: 

```bash
ssh your_username@host_ip_address
```

::: warning
Please ask your hosting provider for details on how to use SSH access.
:::

2. After logging in, run the following commands to remove dummy data:

```bash
cd public_html
php artisan migrate:fresh --force
```