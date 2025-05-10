---
titleTemplate: BouncifyPro
---

# Upgrade Guide

This section will guide you through upgrading your BouncifyPro application to the latest version.

::: danger
Before proceeding, it's crucial to take a backup of your database and files. This precautionary measure helps prevent any potential data loss during the upgrade process.
:::

::: danger
Please note that these steps will replace any customizations you have made, including logo, frontend view files, and other modifications. If you are a developer, we recommend using version control (e.g., Git) to track your changes.
:::

## Upgrade Steps

1. **Check for Updates**
   
   BouncifyPro automatically checks for updates once per day. However, you can manually check for updates at any time by visiting:
   ```
   https://your-domain.com/admin/upgrade
   ```
   ![Upgrade BouncifyPro](/bouncifypro/upgrade.png)

2. **Review Update Information**
   
   When an update is available, you'll see:
   - The new version number
   - Release date
   - Update size
   - Release notes with details about new features and fixes

3. **Prepare for Upgrade**
   
   Before starting the upgrade process:
   - Make a backup of your database
   - Make a backup of your files
   - Inform users of scheduled downtime (the system will be temporarily unavailable during the upgrade)

4. **Initiate the Upgrade**
   
   - Read the disclaimer and check the confirmation box
   - Click the "Install Update" button to begin the upgrade process
   - Do NOT close your browser during the upgrade process

5. **Monitor Progress**
   
   The upgrade process includes several steps:
   - Downloading the update package
   - Extracting update files
   - Running database migrations
   - Seeding any new database data
   - Clearing application caches
   - Restarting services

6. **Post-Upgrade**
   
   Once the upgrade is complete:
   - The page will automatically refresh
   - Verify that all features are working correctly
   - Check for any new configuration options that may have been added

## Troubleshooting

If the upgrade process fails:
1. Review the error message displayed on the upgrade page
2. You can attempt to resume the upgrade by clicking the "Resume Update" button
3. If problems persist, restore from your backup and contact support

::: tip
Always keep your application updated to benefit from the latest features, security fixes, and performance improvements.
:::
