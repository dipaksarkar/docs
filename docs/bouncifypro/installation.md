---
titleTemplate: BouncifyPro
---

# Installation

This section will guide you through setting up a basic BouncifyPro documentation site from scratch.

::: info
For upgrading your existing BouncifyPro installation, please refer to the [Upgrade Guide](/bouncifypro/upgrade) for detailed instructions.
:::

## Server Requirements

To run **BouncifyPro** efficiently, ensure that your server meets the following requirements. These include the web server, PHP version, necessary extensions, and database requirements.

#### Web Server
- **Apache**, **nginx**, or any other compatible web server.

#### PHP Requirements
- **PHP Version**: >= 8.3 (Recommended: Latest stable release of PHP 8.3 or 8.4)
- **Required PHP Extensions**:
  - **BCMath**
  - **Ctype**
  - **cURL**
  - **DOM**
  - **Fileinfo**
  - **JSON**
  - **Mbstring**
  - **OpenSSL**
  - **PCRE**
  - **PDO**
  - **SQLite**
  - **Tokenizer**
  - **XML**

#### Database
- **MySQL**: Latest version recommended (minimum MySQL 5.7 or MariaDB 10.2)

#### Recommended Configurations
For optimal performance:
- Use **nginx** as the web server for faster performance and scalability.
- Enable **Opcache** to improve PHP execution speed.
- Allocate sufficient memory (`memory_limit`) in your `php.ini` file (e.g., 1024M or higher).

#### Verify Your Server Setup
Run the following command to check your PHP environment and confirm required extensions are enabled:

```bash
php -m
```

This command will list all installed PHP modules. Cross-check it with the list above to ensure compatibility.

::: warning
This project utilizes the latest Laravel version (currently 11.x). Refer to the [Laravel documentation](https://laravel.com/docs) for more information.

The root folder for Laravel is `/public`. Do not install it in a sub-folder; using a sub-domain is preferable over a sub-folder. We do not support installing our product in a sub-folder.
:::

## How to Get a License

To use BouncifyPro, you need to obtain a valid license. Please refer to the [How to Get a License Guide](/bouncifypro/how-to-get-license) for detailed instructions on acquiring and activating your license.

## Install via GUI

1. **Create Database and Upload Files**
  - Upload all files into the root folder of your hosting (typically `public_html`), excluding the following directories:
    ```
    /dist
    /node_modules
    /src
    /src-capacitor
    /statics
    ```

2. **Rename Configuration Files**
  - Rename the following files:
    ```
    .env.example -> .env
    .htaccess.example -> .htaccess
    ```

3. **Start Installation**
  - Navigate to `[your-domain-name.com/install]` to begin the installation process.

4. **Setup Database and Site Information**
  - Follow the step-by-step instructions to configure your database connection, site information, and administrator account.

5. **Login and Setup Website**
  - Log in and set up your website using the Welcome Board.
    ```
    Admin URL: [your-domain-name.com/admin]
    Email: that you used in the installation
    Password: Pa$$w0rd!
    ```


## Add Cron Jobs

Cron jobs are scheduled tasks that run at predefined times or intervals on your server. They are essential for automating repetitive tasks such as running scripts, performing maintenance, or triggering specific actions at set times.

To set up cron jobs for BouncifyPro, add the following lines to your server's crontab:

```bash
# Find your PHP path using 'which php' command and replace as needed
* * * * * /usr/bin/env php {project-root}/artisan schedule:run >> /dev/null 2>&1
* * * * * /usr/bin/env php {project-root}/artisan horizon:manager
```

Replace `{project-root}` with the actual path to your BouncifyPro project. The `/usr/bin/env php` approach works across most systems, but you can specify the full path to your PHP version if needed (e.g., `/usr/local/bin/php` or `/usr/bin/php8.3`).

## Post Installation

After completing the installation, refer to the [Post Installation Guide](./post-installation.md) for additional setup steps and best practices to ensure your BouncifyPro site runs smoothly.
