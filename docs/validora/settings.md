---
titleTemplate: Validora
---

# Settings

Here you can configure your timezone and date formatting that will apply to all of the control panel.

**Available Fields**

- `Company name` - Appears on your website
- `Email` - This is the default email address that will appear as the sender on all of the email that sends to you and your customers.
- `Phone` - Contact number associated with your business.
- `Country` - Location of your business.
- `Timezone` - Time zone setting for your control panel.
- `Language` - Language preference for your control panel.
- `Currency` - Currency used for transactions and invoices. Cannot be changed after the first sale.
- `Logo` - Appears on your website and invoices

## Billing Information

The Billing Information section serves as the hub for managing crucial details regarding your business's legal identity. Here, you can input and update the legal business name and address, which are essential components for generating accurate and professional invoices. Additionally, this information seamlessly integrates into email footers, ensuring that all communications maintain a polished and legally compliant appearance. Keeping this information up-to-date in the Billing Information section guarantees accuracy in financial transactions and reinforces your business's commitment to transparency and professionalism.

**Available Fields**

- `Legal business name` - Will be appear on Invoice.
- `Address line 1` - Primary address line.
- `Address line 2` - Secondary address line (optional).
- `Country/region` - Location of the business.
- `City` - City where the business is located.
- `State` - State or province where the business is located.
- `Postal code` - Postal code for the business location.

**Steps to Updating Billing:**

1.  From your admin, go to Settings > Billing Information.
2.  Update Billing Information.
3.  Click on `Save`.

## Payments

Make sure that you understand the payment process. When a customer checks out, they can choose to pay for their order using any of the methods that you've activated in the Payment providers area of your admin. You can activate a variety of payment methods.

There are a few different things to consider when you're choosing which payment methods to offer. If you want to let your customers pay using a credit card, then you can use Stripe Payments or a third-party provider.

There are also several ways for customers to pay online without using a credit card, such as PayPal, Razorpay, Amazon Pay, and Apple Pay.

**In this section**

- [Setting up your payments](/validora/settings/payments)
- [Stripe](/validora/settings/payments.html#setup-stripe)
- [PayPal](/validora/settings/payments.html#setup-paypal)
- [GoCardless](/validora/settings/payments.html#setup-gocardless)
- [Razorpay](/validora/settings/payments.html#setup-razorpay)
- Manual payment methods

## Notification Templates

Notification templates allow you to customise the messages that go out to your customers when actions occur inside `Validora`. You can customize every email that goes out to a customer here.

You can access this feature at Settings > Notification Templates.

[Setting up your notification](/validora/settings/notifications)

## Taxes

You might need to charge taxes on your sales, and then report and remit those taxes to your government. Although tax laws and regulations are complex and can change often, you can set up Validora to automatically handle most common sales tax calculations. You can also set up tax overrides to address unique tax laws and situations.

You can access this feature at Settings > Taxes.

[Setting up your taxes](/validora/settings/taxes)

## Configure Email Validation

The Email Validation section allows you to configure settings for Validora's powerful email validation service. These settings control how email addresses are verified for accuracy, existence, and deliverability, helping you maintain clean mailing lists and improve email campaign performance.

**Available Settings**

### General Settings

- `Worker URL` - The URL of the worker service for email validation
- `Stream Timeout` - Timeout for stream operations in seconds
- `Batch Size` - Number of emails to process in a single batch

### SMTP Settings

- `SMTP Port` - Port number for SMTP connections
- `SMTP From` - The email address to use as sender for SMTP connections
- `SMTP Timeout` - Timeout for SMTP operations in seconds

### Cache Settings

- `Cache Expiry` - Time in seconds before cached results expire
- `Enable Cache` - Toggle to enable or disable result caching

### Limits & Storage

- `Max Bulk Emails` - Maximum number of emails for bulk processing
- `Max Emails Per File` - Maximum emails per file (-1 for unlimited)
- `Store Results` - Option to store email validation results in database

### Domain Management

Access the domain management section to configure filters for disposable domains, public email domains, and catch-all domains.

**Steps to Configure Email Validation:**

1. From your admin, go to Settings > Email Validation Configuration.
2. Update the validation settings according to your requirements.
3. Click `Save` to apply changes.
4. For domain management, click on the `Manage Domains` button.

## Mail Configuration

The Mail Configuration section allows you to set up and manage the email service that powers all communications from your Validora platform. Proper email configuration is essential for ensuring reliable delivery of system notifications, customer communications, and email validation service alerts.

**Available Settings**

### SMTP Configuration

- `Email Send Method` - Currently supports SMTP protocol for email delivery
- `Host` - The SMTP server hostname (e.g., smtp.googlemail.com)
- `Port` - The port number used for SMTP connections (common ports: 25, 465, 587)
- `Encryption` - Security protocol for the connection (SSL, TLS, or None)
- `Username` - Authentication username for the SMTP server (typically your email address)
- `Password` - Authentication password for the SMTP server

### Testing Functionality

The Mail Configuration section includes a "Test Mail" feature that allows you to:

- Send a test email to verify your configuration
- Confirm delivery and inspect formatting
- Troubleshoot connection issues

**Steps to Configure Mail Settings:**

1. From your admin dashboard, go to Settings > Mail Configuration.
2. Enter your SMTP server details.
3. Configure authentication credentials.
4. Select the appropriate encryption method.
5. Click `Test Mail` to verify your configuration.
6. Once tested successfully, click `Save` to apply the settings.

**Important Notes:**

- Some email providers require app-specific passwords for SMTP access
- Check your firewall settings if you encounter connection issues
- For high-volume sending, consider using dedicated SMTP services
- Keep your SMTP credentials secure and updated regularly
