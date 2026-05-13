---
titleTemplate: Mailzor
---

# Senders & Domains

Manage your verified sender identities and domain-level authentication to ensure maximum deliverability and protect your IP reputation.

## Verified Domains

Domain verification is the process of proving you own the domain you are sending from. This enables features like DKIM (DomainKeys Identified Mail) and custom Return-Path headers.

### Adding a Domain
1. Navigate to **Settings > Senders & Domains**.
2. Click **Add Domain**.
3. Enter your domain name (e.g., `example.com`).
4. Click **Verify**.

### DNS Configuration
Once added, Mailzor will provide a set of DNS records (CNAME or TXT) that you must add to your domain registrar (e.g., Cloudflare, GoDaddy).
- **DKIM Records**: These sign your emails and prove they haven't been tampered with.
- **Verification Token**: Used to confirm ownership of the domain.

### SES Domain Identity
If you are using Amazon SES, you can initiate domain verification directly through the interface:
1. Click the **SES Initiate** button on your domain.
2. Mailzor will attempt to register the domain in your configured AWS region.
3. Once verified in AWS, the status will update automatically in Mailzor.

---

## Verified Senders

A Sender is the specific "From" identity used in your campaigns. While a domain verification covers the entire `@example.com` domain, Senders represent individual mailboxes (e.g., `support@example.com`).

### Adding a Sender
1. Navigate to the **Senders** tab.
2. Click **Add Sender**.
3. Enter the **Name** (e.g., `Mailzor Support`) and the **Email Address**.
4. A verification email will be sent to that address. You must click the link in that email to activate the sender identity.

### Managing Senders
- **Update Sender**: You can change the display name of a sender at any time.
- **Delete Sender**: Removing a sender will prevent it from being selected as the "From" address in future campaigns.

---

## Best Practices
- **Use Subdomains for Sending**: It is recommended to use a subdomain like `mail.example.com` for high-volume sending to protect your root domain's reputation.
- **Monitor Verification Status**: Periodically check that your DNS records remain valid. If a record is removed, your deliverability may drop significantly.
