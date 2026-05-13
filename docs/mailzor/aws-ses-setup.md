---
titleTemplate: Mailzor
---

# AWS SES & SNS Setup Guide

This guide explains how to configure AWS Simple Email Service (SES) and Simple Notification Service (SNS) to work with Mailzor.

## 1. Create an SNS Topic

1.  Log in to the [AWS SNS Console](https://console.aws.amazon.com/sns/v3/home).
2.  Navigate to **Topics** and click **Create topic**.
3.  Select **Standard** type.
4.  Enter a Name (e.g., `mailzor-notifications`). Note: Names cannot contain spaces.
5.  Click **Create topic**.

## 2. Create IAM User & Policy

To allow Mailzor to send emails and manage domain identities, you must create an IAM user with specific permissions.

1.  Log in to the [AWS IAM Console](https://console.aws.amazon.com/iam/home).
2.  Navigate to **Users** and click **Create user**.
3.  Enter a Name (e.g., `mailzor-app`).
4.  In the **Set permissions** step, select **Attach policies directly** and click **Create policy**.
5.  Select the **JSON** tab and paste the following policy:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ses:SendEmail",
                "ses:SendRawEmail",
                "ses:GetSendQuota",
                "ses:GetSendStatistics",
                "ses:CreateEmailIdentity",
                "ses:GetEmailIdentity",
                "ses:ListEmailIdentities",
                "ses:DeleteEmailIdentity"
            ],
            "Resource": "*"
        }
    ]
}
```

6.  Click **Next**, give the policy a name (e.g., `MailzorSESPolicy`), and click **Create policy**.
7.  Go back to the **Create user** tab, refresh the policies list, search for `MailzorSESPolicy`, select it, and click **Next**.
8.  Review and click **Create user**.
9.  Select the new user, go to the **Security credentials** tab, and click **Create access key**.
10. Select **Application running outside AWS**, click **Next**, and **Create access key**.
11. **Save the Access Key ID and Secret Access Key**; you will need these for the Mailzor dashboard.

## 3. Configure Global Notifications (Configuration Sets)

Instead of configuring each identity individually, use a **Configuration Set** to apply notification settings to all emails sent by Mailzor.

1.  Log in to the [AWS SES Console](https://console.aws.amazon.com/ses/home).
2.  Navigate to **Configuration Sets** and click **Create set**.
3.  Enter a Name (e.g., `mailzor-main`). Note: Names cannot contain spaces.
4.  Once created, click on the set and go to the **Event destinations** tab.
5.  Click **Add destination** and select **SNS**.
6.  Select the **Event types** for tracking:
    - **Sends**
    - **Rejects**
    - **Deliveries**
    - **Hard Bounces**
    - **Complaints**
    - **Opens**
7.  Select the **SNS topic** you created in Step 1.
8.  Click **Add destination**.

## 4. Configure Mailzor Dashboard

To activate the tracking and sending for your campaigns:

1.  Log in to your Mailzor Admin Dashboard.
2.  Navigate to **Settings > Mail Settings**.
3.  Scroll to the **Amazon SES Configuration** section.
4.  Enter your **Access Key ID**, **Secret Access Key**, and **Region** (from Step 2).
5.  Enter the name of your configuration set in the **Configuration Set** field (e.g., `mailzor-main`).
6.  Save the settings.

Mailzor will now automatically attach the `X-SES-CONFIGURATION-SET` header and a `message_id` tag to every outgoing campaign email.

## 5. Webhook Identification

Mailzor uses a dual-identification strategy to ensure event correlation:

1.  **SES Tags**: Extracted from `mail.tags.message_id`.
2.  **Custom Headers**: Extracted from `X-Mailzor-Message-ID` (fallback).

This ensures that bounces, complaints, and engagement events are always correctly mapped to the specific message in your database.

## 6. Create SNS Subscription (Webhook)

1.  Go to the [AWS SNS Console](https://console.aws.amazon.com/sns/v3/home).
2.  Select your topic and click **Create subscription**.
3.  **Protocol**: Select `HTTPS`.
4.  **Endpoint**: Enter your Mailzor webhook URL (e.g., `https://your-domain.com/webhooks/ses`).
5.  Click **Create subscription**.
6.  Mailzor will automatically confirm the subscription.

## Troubleshooting

### User not authorized to perform `ses:SendRawEmail`

If you see this error in your logs, it means your IAM user doesn't have the required permissions or is restricted to specific identities. Ensure you have attached the policy defined in **Step 2** to your IAM user and that the `Resource` is set to `*` (or includes all the identities you intend to send from).

### messageId is null in Logs

Check if "Include original headers" is enabled in your Configuration Set's SNS destination. If it is, verify that the `X-SES-CONFIGURATION-SET` header is actually being sent in your email headers.

### Webhook 401 Unauthorized

Ensure your site is accessible from the internet. AWS needs to reach your endpoint. Use `valet share` or `ngrok` for local development.
