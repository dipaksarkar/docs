## Server Requirements

To run **Gympify** efficiently, ensure that your server meets the following requirements. These include the web server, PHP version, necessary extensions, and database requirements.

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
  - **Redis** (for caching and session management)
  - **Tokenizer**
  - **XML**
  - **Imagick** (for image processing and manipulation)
  - **ionCube Loader® v13.0** (Ensure the latest version is installed and compatible with your PHP version)

::: warning 
The ionCube Loader is critical for running encrypted files. Make sure to download and install the appropriate loader for your server's PHP version.
:::

#### Database
- **MySQL**: Latest version recommended (minimum MySQL 5.7 or MariaDB 10.2)

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
This project utilizes the latest Laravel version (currently 12.x). Refer to the [Laravel documentation](https://laravel.com/docs) for more information.

The root folder for Laravel is `/public`. Do not install it in a sub-folder; using a sub-domain is preferable over a sub-folder. We do not support installing our product in a sub-folder.
:::