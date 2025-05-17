---
titleTemplate: NitroFIT28
---

# Setting up your payments

You can manage your payment methods to receive payments for subscriptions and online sales.

## Setup Stripe
Millions of businesses of all sizes—from startups to large enterprises—use Stripe’s software and APIs to accept payments, send payouts, and manage their businesses online.

-   `Publishable Key` - The publishable key provided by Stripe.
-   `Secret Key` - The secret key provided by Stripe.
-   `Webhook Secret` - Secret key for webhook verification.
-   `Webhook Endpoint` - Endpoint URL for Stripe webhook integration. (i.e https://api.your-domain-name.com/stripe/webhook)
-   `Active` - Indicates if the Stripe integration is active.
-   `Test Mode` - Indicates if the integration is in test mode.

## Webhook Events

Stripe sends various webhook events to notify you about changes in your account and transactions. Here are some important events you might want to handle:

### Invoice Events
- `invoice.payment_succeeded` - Triggered when an invoice payment succeeds.
- `invoice.payment_action_required` - Triggered when an invoice requires a payment action.

### Payment Intent Events
- `payment_intent.succeeded` - Triggered when a payment intent succeeds.
- `payment_intent.requires_action` - Triggered when a payment intent requires further action.

### Setup Intent Events
- `setup_intent.succeeded` - Triggered when a setup intent succeeds.

### Charge Events
- `charge.succeeded` - Triggered when a charge is successful.

### Subscription Events
- `customer.subscription.created` - Triggered when a customer subscription is created.
- `customer.subscription.updated` - Triggered when a customer subscription is updated.
- `customer.subscription.deleted` - Triggered when a customer subscription is deleted.

### Customer Events
- `customer.updated` - Triggered when a customer is updated.
- `customer.deleted` - Triggered when a customer is deleted.

### Payment Method Events
- `payment_method.automatically_updated` - Triggered when a payment method is automatically updated.
- `payment_method.card_automatically_updated` - Triggered when a card payment method is automatically updated.

For more details on each event, refer to the [Stripe Webhook Documentation](https://stripe.com/docs/webhooks).

To get those credentials of stripe account [click here](https://stripe.com/docs/keys) or check on Stripe Documentation.

**Steps:**

1.  From your admin, go to `Settings > Payments`.
2.  From the `Payments` page, click on `Edit` icon of Stripe.
3.  Publishable Key, Client Secret Key are needed to configure stripe.
4.  Click `Done`.

## Setup PayPal

PayPal is a widely used online payment system that allows customers to make payments using their PayPal accounts or credit cards without sharing their financial information.

### Required Credentials

-   `Client ID` - The client ID provided by PayPal for API authentication.
-   `Client Secret` - The client secret provided by PayPal for API authentication.
-   `Webhook Endpoint` - Endpoint URL for PayPal webhook integration. (i.e https://api.your-domain-name.com/paypal/webhook)
-   `Active` - Indicates if the PayPal integration is active.
-   `Test Mode` - Indicates if the integration is in test mode (Sandbox).

### Creating a PayPal App and Getting Credentials

Follow these steps to create a PayPal app and obtain the necessary credentials:

1. **Create a PayPal Developer Account**:
   - Go to the [PayPal Developer Dashboard](https://developer.paypal.com/dashboard/).
   - Sign in with your PayPal account or create a new one if necessary.

2. **Create a New App**:
   - Click on "Apps & Credentials" in the dashboard.
   - Select "Create App" button.
   - Enter a name for your application (e.g., "NitroFIT28 Integration").
   - Choose the account type (Business or Personal).
   - Click "Create App".

3. **Get API Credentials**:
   - Once your app is created, you'll see the API credentials section.
   - Here you'll find your Client ID and Secret Key.
   - Make sure to note these down as you'll need them for integration.
   - You can toggle between Sandbox (test) and Live credentials using the tabs at the top.

4. **Configure Webhook**:
   - In your app settings, scroll down to the "Webhooks" section.
   - Click "Add Webhook".
   - Enter your Webhook URL (https://api.your-domain-name.com/paypal/webhook).
   - Select the events you want to receive notifications for (common events include payment capture completed, payment capture denied, etc.).
   - Save the webhook configuration.
   - PayPal will generate a Webhook ID - copy this for your integration.

### Webhook Events

PayPal sends various webhook events to notify you about changes in your account and transactions. Here are some important events you might want to handle:

- `PAYMENT.CAPTURE.COMPLETED` - Payment capture completed successfully.
- `PAYMENT.CAPTURE.DENIED` - Payment capture was denied.
- `PAYMENT.CAPTURE.REFUNDED` - Payment refund was processed.
- `BILLING.SUBSCRIPTION.CREATED` - A subscription was created.
- `BILLING.SUBSCRIPTION.ACTIVATED` - A subscription was activated.
- `BILLING.SUBSCRIPTION.UPDATED` - A subscription was updated.
- `BILLING.SUBSCRIPTION.CANCELLED` - A subscription was cancelled.
- `BILLING.SUBSCRIPTION.SUSPENDED` - A subscription was suspended.
- `BILLING.SUBSCRIPTION.EXPIRED` - A subscription has expired.

For more details on each event, refer to the [PayPal Webhook Documentation](https://developer.paypal.com/api/webhooks/).

### Steps to Configure in NitroFIT28:

1.  From your admin, go to `Settings > Payments`.
2.  From the `Payments` page, click on the `Edit` icon of PayPal.
3.  Enter your Client ID, Client Secret, and Webhook ID.
4.  Choose whether to enable Test Mode (Sandbox) for testing or use Live mode for production.
5.  Check the `Active` box to enable PayPal as a payment method.
6.  Click `Done`.

## Setup GoCardless

GoCardless is a global payment platform specializing in recurring payments and Direct Debit solutions, making it ideal for subscription-based businesses.

### Required Credentials

-   `Access Token` - The access token provided by GoCardless for API authentication.
-   `Webhook Secret` - Secret key for webhook verification.
-   `Webhook Endpoint` - Endpoint URL for GoCardless webhook integration. (i.e https://api.your-domain-name.com/gocardless/webhook)
-   `Active` - Indicates if the GoCardless integration is active.
-   `Test Mode` - Indicates if the integration is in test mode (Sandbox).

### Creating a GoCardless Account and Getting Credentials

Follow these steps to create a GoCardless account and obtain the necessary credentials:

1. **Create a GoCardless Account**:
   - Go to the [GoCardless website](https://gocardless.com/).
   - Click on "Sign up" or "Get started" and follow the registration process.
   - You'll need to provide business information and verify your identity.

2. **Access the Developer Dashboard**:
   - Once your account is approved, log in to your GoCardless dashboard.
   - Navigate to "Developers" > "API keys" section.

3. **Generate API Keys**:
   - In the API keys section, you can choose between Sandbox (test) or Live environment.
   - Click on "Generate new access token".
   - Specify the permissions needed for your integration (usually read/write access to all resources).
   - A new access token will be generated - copy this for your integration.

4. **Configure Webhook**:
   - In the Developers section, navigate to "Webhooks".
   - Click "Create webhook endpoint".
   - Enter your Webhook URL (https://api.your-domain-name.com/gocardless/webhook).
   - Select the events you want to receive notifications for.
   - GoCardless will provide a Webhook Secret - copy this for your integration.

For more details on each event, refer to the [GoCardless API Documentation](https://developer.gocardless.com/api-reference/).

### Steps to Configure in NitroFIT28:

1. From your admin, go to `Settings > Payments`.
2. From the `Payments` page, click on the `Edit` icon of GoCardless.
3. Enter your Access Token and Webhook Secret.
4. Choose whether to enable Test Mode (Sandbox) for testing or use Live mode for production.
5. Check the `Active` box to enable GoCardless as a payment method.
6. Click `Done`.

## Setup Razorpay

Razorpay is a popular payment gateway in India that allows businesses to accept, process, and disburse payments with its suite of products.

### Required Credentials

-   `Key ID` - The API key ID provided by Razorpay.
-   `Key Secret` - The API secret key provided by Razorpay.
-   `Webhook Secret` - Secret key for webhook verification.
-   `Webhook Endpoint` - Endpoint URL for Razorpay webhook integration. (i.e https://api.your-domain-name.com/razorpay/webhook)
-   `Active` - Indicates if the Razorpay integration is active.
-   `Test Mode` - Indicates if the integration is in test mode.

### Creating a Razorpay Account and Getting Credentials

Follow these steps to create a Razorpay account and obtain the necessary credentials:

1. **Create a Razorpay Account**:
   - Go to the [Razorpay website](https://razorpay.com/).
   - Click on "Sign Up" and follow the registration process.
   - You'll need to provide business information and complete the KYC process.

2. **Access API Keys**:
   - Once your account is approved, log in to your Razorpay Dashboard.
   - Navigate to "Settings" > "API Keys" section.
   - Generate a new pair of API keys.
   - You'll receive a Key ID and Key Secret - copy these for your integration.

3. **Configure Webhook**:
   - In your Razorpay Dashboard, go to "Settings" > "Webhooks".
   - Click "Add New Webhook".
   - Enter your Webhook URL (https://api.your-domain-name.com/razorpay/webhook).
   - Create a Webhook Secret.
   - Select the events you want to receive notifications for.
   - Save the webhook configuration.

### Webhook Events

Razorpay sends various webhook events to notify you about changes in your account and transactions. Here are some important events you might want to handle:

- `payment.authorized` - Payment has been authorized but not yet captured.
- `payment.captured` - Payment has been captured successfully.
- `payment.failed` - Payment has failed.
- `refund.created` - A refund has been initiated.
- `refund.processed` - A refund has been processed successfully.
- `refund.failed` - A refund has failed.
- `subscription.created` - A new subscription has been created.
- `subscription.authenticated` - A subscription has been authenticated.
- `subscription.activated` - A subscription has been activated.
- `subscription.charged` - A subscription payment has been charged.
- `subscription.completed` - A subscription has completed its cycle.
- `subscription.cancelled` - A subscription has been cancelled.

For more details on each event, refer to the [Razorpay API Documentation](https://razorpay.com/docs/api/).

### Steps to Configure in NitroFIT28:

1. From your admin, go to `Settings > Payments`.
2. From the `Payments` page, click on the `Edit` icon of Razorpay.
3. Enter your Key ID, Key Secret, and Webhook Secret.
4. Choose whether to enable Test Mode for testing or Live mode for production.
5. Check the `Active` box to enable Razorpay as a payment method.
6. Click `Done`.

## Deactivate a payment

You can deactivate a payment method that you no longer wish to use.

**Steps:**

1. From your admin dashboard, navigate to Settings > Payments.
2. Click on the payment method that you want to deactivate.
3. Uncheck the box labeled `Active`.
4. Click `Done`.

## Reactivate a payment

You can reactivate a previously deactivated payment method.

**Steps:**

1. From your admin dashboard, navigate to Settings > Payments.
2. Click on the payment method that you want to reactivate.
3. Check the box labeled `Active`.
4. Click `Done`.
