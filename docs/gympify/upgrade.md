---
titleTemplate: Gympify
---

# Upgrade Guide

This section will guide you through upgrading your Gympify application to the latest version.

::: danger
Before proceeding, it's crucial to take a backup of your database and files. This precautionary measure helps prevent any potential data loss during the upgrade process.
:::

::: danger
Please note that these steps will replace any customizations you have made, including logo, frontend view files, and other modifications. If you are a developer, we recommend using version control (e.g., Git) to track your changes.
:::

## Replace Old Files

1. Download the latest version of Gympify from [GitHub Release](https://github.com/coders-tm/gympify/releases/tag/v2.3).
   
    ![Download Gympify](/gympify/v2.3.jpg)

2. Extract the downloaded zip file to a temporary location on your machine. You will find the following file structure:

```
/gympify_v2.3 // Main files
readme.html
```

3. Move all files from `gympify_v2.3` to your server's `public_html` directory, replacing existing files. Exclude the following folders:
    ```
    /dist
    /node_modules
    /src
    /src-capacitor
    /statics
    ```

::: danger
Please be aware that these steps will overwrite any customizations you have made.
:::

## Migrate Databases & Data

1. Access your server via SSH by opening a terminal and running the following command, replacing `username` with your SSH username and `your-domain.com` with your server's IP address:

```
ssh username@your-domain.com
```

::: warning
If you are unsure about SSH access details, please contact your hosting provider for assistance.
:::

2. Enter your password when prompted and press Enter. Once logged in, navigate to the `public_html` directory by running the following command:

```
cd public_html
```

3. Run the following commands to migrate the database schema and seed necessary data:

```
php artisan optimize:clear
php artisan migrate --force
php artisan db:seed --class=CentralUpgradeSeeder --force
php artisan tenants:migrate --force
php artisan tenants:seed --class=UpgradeSeeder --force
```

4. After running these commanda, you will need to restart your queue worker by running the following command:

::: code-group

```bash [VPS]
sudo systemctl restart gympify-queues
```

```bash [cPanel]
php artisan queue:manager restart
```

:::

::: danger
It's highly recommended to take a backup of your database before proceeding with these commands to prevent any potential data loss.
:::

These commands will update your database schema and populate any required seed data.

By following these steps, you can successfully upgrade your Gympify application to the latest version. If you encounter any issues during the upgrade process, please refer to the documentation or contact support for assistance.