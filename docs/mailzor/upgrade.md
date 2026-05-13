---
titleTemplate: Mailzor
---

# Upgrade Guide

This section will guide you through upgrading your Mailzor application to the latest version.

::: danger WARNING
Before proceeding, it's crucial to take a backup of your database and files. This precautionary measure helps prevent any potential data loss during the upgrade process.
:::

::: danger WARNING
Please note that these steps will replace any customizations you have made, including logo, frontend view files, and other modifications. If you are a developer, we recommend using version control (e.g., Git) to track your changes.
:::

## Upgrade Steps

1. **Check for Updates**

   Mailzor automatically checks for updates once per day. However, you can manually check for updates at any time by running the following command in your terminal:

   ```bash
   php artisan app:update
   ```

2. **Review Update Information**

   When you run the command, the system will check for available updates. If an update is found, it will display detailed information about the new version:
   - The new version number (e.g., v2.1.0)
   - Release date
   - Update size
   - Comprehensive release notes with new features and improvements

3. **Prepare for Upgrade**

   Before proceeding with the installation:
   - **Back up your database** - This is critical to prevent data loss.
   - **Back up your files** - Especially any customized templates or configurations.
   - **Inform your users** - The system will be temporarily unavailable during the upgrade.
   - **Schedule the update** - Choose a low-traffic time to minimize disruption.

4. **Initiate the Upgrade**

   To begin the upgrade, simply follow the prompts in the terminal after running the `app:update` command. The command will:
   - Download the latest update package.
   - Extract files and replace existing ones.
   - Run necessary migrations and seeders.
   - Clear and optimize application cache.

   ::: warning
   **Do not interrupt the process** until it completes successfully.
   :::

5. **Complete the Upgrade**

   Once the upgrade finishes:
   - You will see a success message in your terminal.
   - You may need to restart your queue workers (Supervisor) to apply changes to background processes.
   - Log in to your admin dashboard to verify everything is working correctly.
   - Explore any new functionality mentioned in the release notes.

## Troubleshooting

If the upgrade process fails:

1. Review the error message displayed in the terminal.
2. Ensure your server has enough disk space and correct file permissions.
3. If problems persist, restore from your backup and contact support.

::: tip
Always keep your application updated to benefit from the latest features, security fixes, and performance improvements.
:::
