---
titleTemplate: Mailzor
---

# Staff & Permissions

Mailzor uses a robust Role-Based Access Control (RBAC) system to manage admin users and their permissions.

## Admin Users (Staff)

Admin users are separate from regular customers. They have access to the Admin Panel (`/admin`) and can manage platform-wide settings.

### Managing Staff
Super-admins can create and manage other staff members:
- **Profile**: Name, Email, Phone.
- **Security**: Enable Two-Factor Authentication (2FA).
- **Status**: Active or Suspended.

## Roles & Groups

Instead of assigning permissions to individuals, permissions are grouped into **Admin Groups** (Roles).

### Permission Matrix
Permissions are granular and module-based. For every module (Campaigns, Contacts, Billing, etc.), you can assign:
- **View**: Ability to see the data.
- **Create**: Ability to add new records.
- **Update**: Ability to edit existing records.
- **Delete**: Ability to remove records.
- **Export**: Ability to download data.

### Super Admin Role
The system includes a hardcoded **Super Admin** role that has unrestricted access to every module and setting. This role cannot be modified or deleted.

## Access Control Logic

Mailzor uses Laravel's built-in `Gate` and `Policy` systems to enforce permissions:

1. **Authentication**: Uses the `admin` guard.
2. **Authorization**: Before any action (e.g., `CampaignController@destroy`), the system checks if the authenticated admin has the required permission (e.g., `campaigns.delete`).
3. **Middleware**: Routes are protected using the `can:` middleware.

## Audit Logs

Every action taken by a staff member is recorded in the system logs:
- **Who**: The admin user.
- **What**: The action (e.g., Updated Settings).
- **When**: Timestamp.
- **Context**: IP address and User Agent.

## Developer Notes
- **Model**: `App\Models\Admin`
- **Table**: `admins`, `admin_groups`
- **Controller**: `App\Http\Controllers\Admin\AdminController`
- **Controller**: `App\Http\Controllers\Admin\GroupController`

::: danger
Exercise caution when granting `Delete` or `Billing` permissions to junior staff members.
:::