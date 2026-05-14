---
titleTemplate: Mailzor
---

# Senders & Domains

Before you can send emails, you must verify the domains and individual email addresses you intend to use as "From" addresses. This process ensures high deliverability and protects your domain reputation.

## Domain Management

Verifying a domain allows you to send emails from any address on that domain (e.g., `support@yourdomain.com`, `news@yourdomain.com`).

### Adding a Domain

1.  Navigate to **Settings > Senders & Domains**.
2.  In the **Domains** section, click **Add Domain**.
3.  Enter your root domain (e.g., `example.com`).
4.  Click **Add**.

### Domain Verification (DNS)

Once a domain is added, you must prove ownership by adding a DNS record:

- **TXT Record**: Mailzor will provide a unique TXT record. Add this to your domain's DNS settings (via Cloudflare, Namecheap, etc.).
- **Verify**: After adding the record, click **Verify** in the Mailzor dashboard.

### Amazon SES Identity Verification

If you are using Amazon SES, you need to perform additional DKIM (DomainKeys Identified Mail) verification:

1.  Click **Initiate SES Verification** for your domain.
2.  Mailzor will generate three CNAME records.
3.  Add these records to your DNS settings.
4.  Click **Refresh SES Status** periodically. Once AWS detects the records, the domain will be marked as "Verified" for SES.

## Sender Management

Individual "Senders" are the specific email addresses that will appear in the "From" field of your campaigns.

### Adding a Sender

::: info
You can only add senders for domains that have been successfully verified in the **Domains** section.
:::


1.  Click **Add Sender**.
2.  Select a verified **Domain**.
3.  Enter the **Sender Name** (e.g., "Jane from Mailzor").
4.  Enter the **Sender Email** (e.g., `jane@example.com`).
5.  Click **Save**.

### Default Sender

You can mark one sender as the **Default**. This sender will be pre-selected when creating new campaigns or system notifications.

## Deliverability Tips

- **SPF & DKIM**: Always ensure your DNS records are correctly configured. Verified domains have significantly higher open rates.
- **DMARC**: We recommend setting up a DMARC policy on your domain to prevent spoofing.
- **Warm-up**: If you are using a new domain or IP, start with small volumes to build a positive sender reputation.
