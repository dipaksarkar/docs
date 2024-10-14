---
titleTemplate: NitroFIT28
---

# Installation

This section will guide you through setting up a basic NitroFIT28 documentation site from scratch.

::: info
For upgrading your existing NitroFIT28 installation, please refer to the [Upgrade Guide](/nitrofit28/upgrade) for detailed instructions.
:::

## Prerequisites

To get started with a Quasar application, you need to ensure you have the following prerequisites:

1. **Node 12+ for Quasar CLI with Webpack**, or **Node 14+ for Quasar CLI with Vite**.
   - To check your Node.js version, run `node -v` in a terminal/console window.
2. **Yarn v1 (strongly recommended)**, PNPM, or NPM.
   - To check your Yarn version, run `yarn -v` in a terminal/console window.

## Server Requirements

NitroFIT28 has specific system requirements. Ensure that your web server meets the following minimum PHP version and extensions:

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

::: tip
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
APP_NAME=NitroFIT28
# (API_URL is optional, it will be generated using your app domain)
API_URL=https://your-domain-name.com/api
```

3. (Optional) Build the application by executing the following commands:

```
yarn install
yarn build:prod
```

## Install via GUI

- Create database and Upload all files into the root folder of your hosting (normally, it is `public_html`). Without followings:
  ```
    /dist
    /node_modules
  ```
- Go to [your-domain-name.com/install] to start installation.
- Step by step to setup your database conntection, site information and administrator.
- Login and setup your website on Welcome Board.

## Add Cron Jobs

Cron jobs are scheduled tasks that run at predefined times or intervals on your server. They are essential for automating repetitive tasks such as running scripts, maintenance tasks, or triggering specific actions at set times.

```bash
# Run Laravel scheduler
* * * * * /usr/bin/php8.2 {project-root}/artisan schedule:run >> /dev/null 2>&1

# Process Laravel queues
*/2 * * * * /usr/bin/php8.2 {project-root}/artisan queue:work --timeout=36000 --stop-when-empty
```

## Remove Dummy Data

1. Open the SSH terminal on your machine and run the following command:

```
ssh your_username@host_ip_address
```

::: warning
Please ask your hsoting provider to getting all the information related to ssh.
:::

2. Type in your password and hit Enter. Then run following commands:

```
cd public_html
php artisan migrate:fresh --force
```
