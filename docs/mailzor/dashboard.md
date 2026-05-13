---
titleTemplate: Mailzor
---

# Admin Dashboard

The Mailzor Admin Dashboard provides a high-level overview of the entire platform's health, user activity, and system performance.

## Overview
The dashboard is designed for system administrators to monitor real-time metrics and quickly access critical modules.

### Key Metrics
- **Total Users**: The number of registered users on the platform.
- **Active Subscriptions**: Total number of users on a paid plan.
- **Campaigns Sent**: Cumulative count of all email campaigns processed.
- **Email Throughput**: Real-time stats on jobs processed per minute via Horizon.

## Dashboard Widgets

### Greeting & Alerts
A personalized greeting at the top, followed by any critical system alerts (e.g., failed jobs, high bounce rates).

### KPI Cards
Four primary cards displaying:
1. **Total Revenue**: (If enabled) Total payments processed.
2. **Active Contacts**: Total unique email addresses across all users.
3. **Queue Status**: Current status of the background workers.
4. **Validation Volume**: Number of emails validated in the last 24 hours.

### Activity Timeline
A chart showing platform activity over the last 30 days, including new user signups and campaign volume.

### Recent Activity Logs
A live feed of the most recent actions taken by users or admins across the platform.

## Background Flow
1. **Metrics Aggregation**: Data is pulled from `users`, `campaigns`, and `subscriptions` tables.
2. **Horizon Integration**: Queue status is fetched directly from Redis via the Horizon API.
3. **Caching**: Dashboard metrics are cached for 5-10 minutes to ensure fast load times.

## Developer Notes
- **Controller**: `App\Http\Controllers\Admin\DashboardController`
- **Frontend Page**: `resources/js/Pages/Admin/Dashboard.vue`
- **Route**: `admin.dashboard` (GET `/admin`)

::: tip
You can customize the dashboard widgets by modifying the `DashboardController` and adding new components to the `Dashboard.vue` page.
:::
