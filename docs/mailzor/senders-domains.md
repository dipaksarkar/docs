---
titleTemplate: Mailzor
---

# Senders & Domains

To achieve high deliverability, you must verify the domains you send emails from. Mailzor provides a streamlined workflow for domain authentication and sender management.

## Senders

A **Sender** is a combination of a "From Name" and a "From Email" (e.g., `Support <support@mailzor.com>`).

### Configuring Senders
- Users can create multiple senders for different purposes (e.g., Marketing, Support, Billing).
- Every sender must be associated with a verified domain.
- **Default Sender**: Each user can designate one sender as the default for new campaigns.

## Domain Verification

Verification is required to prove ownership and authorize Mailzor to send emails on your behalf.

### 1. Manual DNS Verification
This is the standard method for any domain.
- **SPF Record**: Add a TXT record to authorize Mailzor's sending IPs.
- **DKIM Record**: Add a TXT record containing the public key for email signing.
- **Verification Token**: Add a specific TXT record to verify ownership.

### 2. Amazon SES Verification (Enhanced)
If you are using the Amazon SES delivery engine, Mailzor provides an automated verification workflow.
- The system generates 3 CNAME records for Easy DKIM.
- Once added to your DNS, you can click "Refresh Status" to fetch the verification state directly from AWS.

## Hybrid Delivery Configuration

Mailzor's sending engine evaluates senders and domains in real-time:

1. **SES Check**: If the domain is SES-verified and AWS credentials are valid, the email is routed through Amazon SES.
2. **SMTP Fallback**: If SES is unavailable or the domain is not verified for SES, the system falls back to the custom SMTP configuration.

## Admin Oversight

Admins can monitor all domains and senders across the platform:
- **Global Domains**: View a list of all domains and their verification statuses.
- **DKIM/SPF Audit**: Check if user domains have correct DNS records.
- **Provider Status**: See which domains are primarily using SES vs. SMTP.

## Developer Notes
- **Models**: `App\Models\Sender`, `App\Models\SenderDomain`
- **Controller**: `App\Http\Controllers\SenderManagementController`
- **Service**: `App\Services\SenderService`

::: important
Proper DKIM and SPF configuration is the #1 factor in preventing your emails from landing in the Spam folder.
:::
