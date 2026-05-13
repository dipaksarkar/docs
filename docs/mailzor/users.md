---
titleTemplate: Mailzor
---

# User Management

The User module allows admins to manage the customers (users) who use the platform to send campaigns.

## Managing Users

### User Profiles
Detailed view of each customer:
- **Account Info**: Email, Status (Active/Suspended/Pending).
- **Billing Details**: Current plan, credit balance, and transaction history.
- **Engagement**: Total campaigns sent, total contacts stored.

### Admin Actions
Admins have several tools to assist and manage users:
- **Login As**: Instantly log into a user's account to troubleshoot issues (without knowing their password).
- **Manual Credit Adjustment**: Add or remove validation/sending credits.
- **Subscription Override**: Manually change a user's plan or expiration date.
- **Status Toggle**: Suspend users for Terms of Service violations.

## User Lifecycle

### Registration
Users sign up via the frontend and must verify their email address before accessing the dashboard (if enabled).

### Onboarding
The system tracks the user's progress, including:
- Email verification status.
- First campaign sent.
- Primary domain verified.

## Data Privacy & Security

### 2FA (Two-Factor Authentication)
Users can enable TOTP-based authentication for their accounts. Admins can see if 2FA is enabled but cannot disable it without proper authorization.

### Audit Trail
All significant actions taken by a user (e.g., deleting a contact group, changing a password) are logged and visible to admins in the **Activity Logs**.

## Developer Notes
- **Model**: `App\Models\User`
- **Controller**: `App\Http\Controllers\Admin\UserController`
- **Middleware**: `auth:user` (for frontend) and `auth:admin` (for admin view).

::: info
When using "Login As", the system creates a temporary session. To return to the admin panel, simply logout from the user account or use the "Back to Admin" banner.
:::
