---
titleTemplate: Mailzor
---

# Billing & Plans

Mailzor's monetization system is built on two pillars: **Subscription Plans** for platform access and **Credit Packages** for usage-based features.

## Subscription Plans

Plans define the features and limits available to a user.

### Plan Configuration
- **Name & Description**: Public-facing plan details.
- **Price**: Recurring cost (Monthly/Yearly).
- **Limits**:
  - Max Contacts: Total unique emails allowed.
  - Max Campaigns: Number of sends per month.
  - Max Automations: Active workflows allowed.
- **Features**: Boolean toggles for specific modules.

### Lifecycle Management
- **Trial**: Optional trial period for new signups.
- **Upgrade/Downgrade**: Automatic pro-rating of payments when switching plans.
- **Cancellation**: Graceful handling of expired subscriptions.

## Credit Packages

Credits are used for consumption-based features:
- **Email Validation**: 1 credit per validation.
- **Campaign Sends**: (Optional) 1 credit per email sent.

### Managing Credits
- **Tiers**: Create packages like "1,000 Credits for $10" or "10,000 Credits for $80".
- **One-time Purchase**: Credits never expire and are added to the user's balance immediately upon payment.

## Payments & Gateways

Mailzor integrates with multiple payment processors via the **Foundry** billing engine.

### Supported Gateways
- Stripe (Credit/Debit Cards)
- PayPal
- Razorpay
- Paystack
- Mollie
- Offline Payments (Manual Bank Transfer)

### Order Management
Admins can view and manage all transactions:
- **Invoices**: Automatically generated PDF invoices for every payment.
- **Refunds**: Process full or partial refunds directly from the dashboard.
- **Manual Adjustments**: Admins can manually add credits or extend subscriptions for users.

## Coupons & Discounts

Create promotional codes to attract new users.
- **Type**: Percentage discount or fixed amount.
- **Duration**: One-time use, multi-month, or forever.
- **Limits**: Max redemptions and expiration dates.

## Developer Notes
- **Library**: `coderstm/foundry`
- **Module**: `Modules/CreditBalance`
- **Controller**: `App\Http\Controllers\Admin\SubscriptionController`
- **Controller**: `App\Http\Controllers\Admin\OrderController`

::: tip
Enable **Tax Configuration** in Settings to automatically apply VAT or GST based on the user's country.
:::
