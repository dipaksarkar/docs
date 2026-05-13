---
titleTemplate: Mailzor
---

# Configuration

After installing Mailzor, you need to configure your environment and email delivery providers.

## Environment Variables

The `.env` file contains critical settings for your application.

### App Settings
- `APP_NAME`: Your platform name.
- `APP_URL`: The full URL of your installation (e.g., `https://mailzor.com`).
- `APP_ENV`: Set to `production` in live environments.
- `APP_DEBUG`: Set to `false` in production.

### Database
- `DB_CONNECTION`: Usually `mysql`.
- `DB_HOST`, `DB_PORT`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`.

### Redis (Required)
- `REDIS_HOST`, `REDIS_PASSWORD`, `REDIS_PORT`.

## Email Delivery (Hybrid Engine)

Mailzor uses a hybrid engine that prioritizes Amazon SES and falls back to SMTP.

### 1. Amazon SES Setup
To use SES, you need an AWS IAM user with `AmazonSESFullAccess` permissions.

- `AWS_ACCESS_KEY_ID`: Your AWS access key.
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret key.
- `AWS_DEFAULT_REGION`: Your SES region (e.g., `us-east-1`).

#### SES Webhooks (Bounce/Complaint Handling)
Mailzor automatically handles bounces and complaints via AWS SNS.
1. In AWS SES, go to **Verified Identities**.
2. Select your domain.
3. Under **Notifications**, configure an SNS Topic for Bounces and Complaints.
4. Create an HTTP/S subscription for that SNS Topic pointing to:
   `https://your-domain.com/webhooks/ses`

### 2. SMTP Fallback
Configure your global SMTP fallback in the `.env` or via the Admin Settings.

- `MAIL_MAILER`: `smtp`
- `MAIL_HOST`: Your SMTP host.
- `MAIL_PORT`: `587` or `465`.
- `MAIL_USERNAME`, `MAIL_PASSWORD`.
- `MAIL_ENCRYPTION`: `tls` or `ssl`.

## Domain Verification

For every domain you want to send emails from, you must verify it in the **Senders & Domains** section.

### DNS Records
Mailzor will provide you with the following records to add to your DNS provider:
- **DKIM**: 3 CNAME records (for SES).
- **SPF**: TXT record.
- **Verification Token**: TXT record (for manual verification).

## Queue Management
Mailzor uses **Laravel Horizon** to manage background jobs.
- Access the Horizon dashboard at `/admin/horizon` (Super Admin only).
- Ensure the `horizon` command is running via Supervisor.
