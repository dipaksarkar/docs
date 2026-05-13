---
titleTemplate: Mailzor
---

# Logs & Activity

Mailzor maintains a comprehensive audit trail of all system events and user actions to ensure security and accountability.

## Audit Logs

Admins can access platform-wide logs from the **Logs** section of the Admin Panel.

### What is Logged?
- **Authentication**: Successful logins, failed attempts, and password changes.
- **Resources**: Creation, modification, and deletion of Campaigns, Templates, and Contacts.
- **Billing**: Payment successes, failures, and manual credit adjustments.
- **System**: Deployment events, settings changes, and queue worker restarts.

## Log Structure

Every log entry captures the following metadata:
- **Admin/User**: Who performed the action.
- **Action**: A human-readable description (e.g., "Updated Campaign #42").
- **IP Address**: The origin of the request.
- **User Agent**: Browser and OS details.
- **Timestamp**: Exact time of the event.

## Activity Notifications

Admins can configure real-time notifications for critical events:
- **New User Signup**
- **Large Campaign Completion**
- **Low Credit Alerts**
- **AWS SES Configuration Issues**

Notifications appear in the top navigation bar and can optionally be sent via email or Slack.

## Troubleshooting with Logs

If a user reports an issue (e.g., "My campaign stopped sending"), the logs are your first line of defense:
1. **Filter by User**: Search for the user's email to see their recent actions.
2. **Check Status**: Look for `error` or `warning` level logs.
3. **Queue Context**: Cross-reference logs with **Horizon** metrics to see if the issue is processing-related.

## Log Archiving
To maintain database performance, Mailzor automatically archives logs older than 90 days.
- Archived logs are moved to a secondary table or exported to CSV.
- This duration can be configured in `config/audit.php`.

## Developer Notes
- **Table**: `logs`
- **Table**: `activity_notifications`
- **Controller**: `App\Http\Controllers\Admin\LogController`
- **Controller**: `App\Http\Controllers\Admin\ActivityNotificationController`
