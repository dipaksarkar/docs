---
titleTemplate: NitroFIT28
---

# Installation

This section will guide you through setting up a basic NitroFIT28 documentation site from scratch.

::: info
For upgrading your existing NitroFIT28 installation, please refer to the [Upgrade Guide](/nitrofit28/upgrade) for detailed instructions.
:::

## Server Requirements

To run **NitroFIT28** efficiently, ensure that your server meets the following requirements. These include the web server, PHP version, necessary extensions, and database requirements.

#### Web Server
- **Apache**, **nginx**, or any other compatible web server.

#### PHP Requirements
- **PHP Version**: >= 8.2 (Recommended: Latest stable release of PHP 8.2 or 8.3)
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
  - **Tokenizer**
  - **XML**
  - **Imagick** (for image processing and manipulation)
  - **ionCube Loader® v13.0** (Ensure the latest version is installed and compatible with your PHP version)

::: warning 
The ionCube Loader is critical for running encrypted files. Make sure to download and install the appropriate loader for your server's PHP version.
:::

#### Database
- **MySQL**: Latest version recommended (minimum MySQL 5.7 or MariaDB 10.2)

#### Additional Software (Optional)
- **Node.js**: Latest LTS version (required for frontend dependencies and build processes). 

::: warning 
If you want to **build or modify themes on the server**, you will need to have **npm** installed to compile assets. Without **npm**, you can still edit template files (`views/**/*.blade.php`), but **you will not be able to modify or build any assets** (such as JavaScript, CSS, or images).
:::

#### Recommended Configurations
For optimal performance:
- Use **nginx** as the web server for faster performance and scalability.
- Enable **Opcache** to improve PHP execution speed.
- Allocate sufficient memory (`memory_limit`) in your `php.ini` file (e.g., 256M or higher).

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


## Add Cron Jobs

Cron jobs are scheduled tasks that run at predefined times or intervals on your server. They are essential for automating repetitive tasks such as running scripts, performing maintenance, or triggering specific actions at set times.

To set up cron jobs for NitroFIT28, add the following lines to your server's crontab:

```bash
* * * * * /usr/bin/php8.2 {project-root}/artisan schedule:run >> /dev/null 2>&1
* * * * * /usr/bin/php8.2 {project-root}/artisan queue:manager start
```

Replace `{project-root}` with the actual path to your NitroFIT28 project.

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
