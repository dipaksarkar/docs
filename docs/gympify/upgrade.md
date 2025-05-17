---
titleTemplate: Gympify
---

# Upgrade Guide

This section will guide you through upgrading your Gympify application to the latest version.

::: danger WARNING
Before proceeding, it's crucial to take a backup of your database and files. This precautionary measure helps prevent any potential data loss during the upgrade process.
:::

::: danger WARNING
Please note that these steps will replace any customizations you have made, including logo, frontend view files, and other modifications. If you are a developer, we recommend using version control (e.g., Git) to track your changes.
:::

## Upgrade Steps

1. **Check for Updates**
   
   BouncifyPro automatically checks for updates once per day. However, you can manually check for updates at any time by visiting:
   ```
   https://app.your-domain.com/upgrade
   ```
   
   When your software is up to date, you'll see a confirmation screen:
   
   ![No Updates Available](/bouncifypro/no-update.png)
   
   You can click the "Check for Updates" button anytime to manually verify if new versions are available.

2. **Review Update Information**
   
   When an update is available, you'll see detailed information about the new version:
   
   ![Update Available](/bouncifypro/upgrade.png)
   
   The update screen provides:
   - The new version number (e.g., v2.6.2)
   - Release date
   - Update size
   - Comprehensive release notes with new features and improvements

3. **Prepare for Upgrade**
   
   Before proceeding with the installation:
   - **Back up your database** - This is critical to prevent data loss
   - **Back up your files** - Especially any customized templates or configurations
   - **Inform your users** - The system will be temporarily unavailable during the upgrade
   - **Schedule the update** - Choose a low-traffic time to minimize disruption

4. **Initiate the Upgrade**
   
   To begin the upgrade:
   - Read the important disclaimer at the bottom of the page
   - Check the confirmation box acknowledging you understand the process
   - Click the "Install Update" button to start the upgrade
   
   ::: warning
   During the upgrade, you'll see a progress indicator showing the current status. **Do not close your browser** until the process completes.
   :::

5. **Complete the Upgrade**
   
   Once the upgrade finishes successfully:
   - A success dialog will appear confirming the update has been completed
   - The page will refresh after you close this dialog
   - You may need to log in again to access your updated dashboard
   - Take a few minutes to verify all features are working correctly
   - Explore any new functionality mentioned in the release notes

## Troubleshooting

If the upgrade process fails:
1. Review the error message displayed on the upgrade page
2. You can attempt to resume the upgrade by clicking the "Resume Update" button
3. If problems persist, restore from your backup and contact support

::: tip
Always keep your application updated to benefit from the latest features, security fixes, and performance improvements.
:::
