# Setting up your payments

You can manage your payment methods to receive payments for subscriptions and online sales.

## Setup Stripe
Millions of businesses of all sizes—from startups to large enterprises—use Stripe’s software and APIs to accept payments, send payouts, and manage their businesses online.

::: warning
Configuring your Stripe account is essential to make the subscription system functional. However, if you choose not to accept payments via credit card, you must still configure your Stripe account for other payment methods or functionality.
:::

-   `Publishable Key` - The publishable key provided by Stripe.
-   `Secret Key` - The secret key provided by Stripe.
-   `Webhook Secret` - Secret key for webhook verification.
-   `Webhook Endpoint` - Endpoint URL for Stripe webhook integration. (i.e https://api.your-domain-name.com/stripe/webhook)
-   `Active` - Indicates if the Stripe integration is active.
-   `Test Mode` - Indicates if the integration is in test mode.

To get those credentials of stripe account [click here](https://stripe.com/docs/keys) or check on Stripe Documentation.

**Steps:**

1.  From your admin, go to `Settings > Payments`.
2.  From the `Payments` page, click on `Edit` icon of Stripe.
3.  Publishable Key, Client Secret Key are needed to configure stripe.
4.  Click `Done`.

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
