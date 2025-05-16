---
titleTemplate: Gympify
---

# Change Log

This document provides a detailed history of changes, improvements, and fixes across various versions of the application, helping track progress and new feature releases.

## v2.6.1 - October 2024
**Latest Release**

### Features
- Improved development environment setup and configuration
- Applied patch fixes for critical issues

## v2.6 - October 2024

### Features
- Added provider column to subscriptions table migration
- Implemented theme deletion functionality
- Updated routes to use Tenant namespace
- Added FilesystemTenancyBootstrapper and tenancy_asset helper function
- Replaced logo images with base-logo component for consistency across layouts

### Improvements & Refactoring
- Refactored gym branding to use dynamic application name and logo across various views
- Improved page layout and styles in 1000013.blade.php for better readability and performance
- Removed file copy operation from tenant migration for improved clarity
- Updated page controller references to use Tenant namespace
- Enhanced loginAs method to use tenant routing for login-as URL

### Fixes
- Updated .bladeignore to include additional directories and optimized blade templates for membership pages
- Used realpath to construct the thumbnail path for accurate file existence check
- Updated home link title to use dynamic application name
- Improved theme cloning logic to correctly set asset paths
- Handled potential null user in attendance logging
- Updated seeder to include missing classes

## v2.4 - February 2024

### Fixes
- Resolved coupon issue in subscription processing
- Fixed theme build issue by removing Node support on server
- Fixed contact form functionality in tenant sites
- Repaired broken signup link in membership page

## v2.3 - January 2024

### Fixes
- Fixed issue where additional details and payment instructions in PaymentMethodDialog weren't saving properly

## v2.2 - January 2024

### Updates
- Improved central domain handling to use dynamic window property

## v2.1 - January 2024

### Features
- Added Translation Manager for both Central and Tenant environments

### Fixes
- Resolved several important bugs affecting core functionality

## v1.0 - Initial Release
- [Created] SaaS version from NitroFit28 `v5.0`