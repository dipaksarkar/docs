---
titleTemplate: Mailzor
---

# Settings

Mailzor provides a comprehensive suite of settings to customize every aspect of your SaaS platform. Settings are divided into several key modules for easier management.

## 1. General Settings
Configure the foundational identity and behavior of your application.
- **App Name**: The name displayed across the platform and in emails.
- **Admin Email**: Default sender email for system notifications.
- **Phone Number**: Business contact number.
- **Timezone**: Default timezone for displaying dates and times.
- **Default Country & Currency**: Set your primary operational region and currency.
- **Primary Language**: Default interface language for users.
- **Site Logo**: Upload your light and dark mode logos.

## 2. Social Links
Manage the social media presence displayed in your email footers and on the public website.
- Supports Facebook, Twitter/X, Instagram, LinkedIn, GitHub, YouTube, and TikTok.
- Uses a repeater system to add multiple profiles with their respective usernames.

## 3. Mail Settings (Hybrid Delivery)
Configure how Mailzor sends your emails.
- **Send Method**: Choose between SMTP, Amazon SES, Postmark, Resend, Mailgun, and others.
- **Amazon SES**: High-performance sending with built-in bounce and complaint tracking. See the [SES Setup Guide](./aws-ses-setup.md) for details.
- **SMTP Configuration**: Support for primary and multiple fallback SMTP providers.
- **Test Mail**: Verify your configuration by sending a real test email to any address.

## 4. Billing Information
Define your business's legal identity for invoice generation.
- **Legal Business Name**: Appears on customer invoices.
- **Business Address**: Line 1, Line 2, City, State, Zip, and Country.
- This information is also used in mandated anti-spam footers in outgoing emails.

## 5. Plans & Pricing
Manage your subscription tiers and feature access.
- **Limits**: Define max contacts, monthly campaigns, and active automations for each plan.
- **Features**: Enable or disable specific modules based on the user's subscription.
- **Billing Intervals**: Support for monthly and yearly recurring billing.

## 6. Coupons & Discounts
Create promotional codes to attract and retain users.
- **Types**: Percentage-based or fixed amount discounts.
- **Duration**: Apply once, for multiple months, or forever.
- **Usage Limits**: Restrict max redemptions and set expiration dates.

## 7. Notification Templates
Customize every automated email sent by the system.
- Includes Welcome emails, Password Resets, Verification notices, and Billing alerts.
- Supports rich-text editing and dynamic variables for personalization.

## 8. Payment Methods
Configure how you receive payments from users.
- Native integration with Stripe, PayPal, Razorpay, Paystack, and more.
- Supports offline manual payment methods for bank transfers.

## 9. Taxes & Compliance
Set up automated tax calculations for your sales.
- Create regional tax rules based on the customer's country and state.
- Support for tax overrides for unique jurisdictional requirements.

## 10. Exchange Rates
Manage multi-currency pricing and automatic conversions.
- Sync real-time exchange rates to keep your global pricing accurate.
- Define custom rates if you prefer fixed currency conversion.

## 11. Translations & Localization
Make Mailzor available in multiple languages.
- Manage translation strings for the entire application interface.
- Add new languages and update existing ones through a simple UI.

## 12. Terms & Privacy
Maintain your legal documents directly within the dashboard.
- **Terms of Service**: Rich-text editor for your user agreement.
- **Privacy Policy**: Document your data handling practices.
- These are displayed during user registration and in page footers.
