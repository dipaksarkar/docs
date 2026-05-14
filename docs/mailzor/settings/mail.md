---
titleTemplate: Mailzor
---

# Mail Configuration

Mailzor features a hybrid delivery engine that allows you to configure multiple outgoing mail providers for high-volume sending, transactional alerts, and fallback scenarios.

## Email Send Method

Choose your primary delivery vehicle from the **Email Send Method** dropdown:

- **SMTP**: Connect to any standard outgoing mail server.
- **Amazon SES**: Recommended for high-volume campaigns. Requires an AWS account.
- **Postmark / Resend / Mailgun**: Native API integrations for reliable delivery.
- **Sendmail**: Uses your server's local sendmail binary.
- **Log**: Writes all outgoing emails to your application logs (useful for debugging).

## SMTP Configuration

If using SMTP, configure your server details:
- **Host**: The SMTP server hostname (e.g., `smtp.gmail.com`).
- **Port**: Typically `587` (TLS) or `465` (SSL).
- **Encryption**: Select between `TLS`, `SSL`, or `None`.
- **Authentication**: Enter your SMTP username and password.

## Amazon SES Setup

For high-performance sending, Amazon SES is the preferred choice. It provides granular tracking for bounces and complaints.

- **Key & Secret**: Your AWS IAM credentials with SES sending permissions.
- **Region**: The AWS region where your SES identity is verified.
- **Configuration Set**: (Optional) Used to track events and include custom headers for high-volume sending.
- **Enable for Campaigns**: Toggle this to allow this SES configuration to be used for mass email campaigns.

::: tip
For a detailed guide on setting up AWS IAM, Configuration Sets, and Webhooks, see our **[AWS SES & SNS Setup Guide](../aws-ses-setup.md)**.
:::

## API Providers

Mailzor supports several modern API-based email providers. These are often easier to set up than SMTP and offer better deliverability.

- **Postmark**: Requires a **Postmark Token**. Known for excellent transactional delivery.
- **Resend**: Requires a **Key**. A modern, developer-friendly email platform.
- **Mailgun**: Requires your **Domain**, **Secret**, and **Endpoint** (e.g., `api.mailgun.net` or `api.eu.mailgun.net`).

## Sender Details

- **From Address**: The default email address all system notifications will be sent from.
- **From Name**: The name displayed as the sender (e.g., `Mailzor Support`).

## Additional SMTP Providers (Fallbacks)

Mailzor allows you to define a list of secondary SMTP providers. These can be used to distribute load or act as a safety net if your primary provider fails.

- Use the **Repeater** to add multiple providers with their own host, port, and credentials.
- **Provider Name**: A label to identify the service (e.g., "SendGrid Backup").
- Toggle **Enabled** to activate or deactivate providers without deleting their configuration.

## Testing Your Configuration

Before launching a campaign, always verify your settings using the **Send Test Email** action.

1.  Navigate to **Settings > Mail Configuration**.
2.  Click the **Send Test Email** button in the top actions bar.
3.  Enter a recipient email address in the modal.
4.  Click **Send**.
5.  Check the recipient's inbox for the test message. If it doesn't arrive, check your [Application Logs](../logs.md) for connection errors.

