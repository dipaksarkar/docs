---
titleTemplate: BouncifyPro
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

- `invoice.payment_succeeded` - Triggered when an invoice payment succeeds.
- `payment_intent.requires_action` - Triggered when a payment intent requires further action.
- `setup_intent.succeeded` - Triggered when a setup intent succeeds.
- `charge.succeeded` - Triggered when a charge is successful.
- `payment_intent.succeeded` - Triggered when a payment intent succeeds.
- `customer.subscription.created` - Triggered when a customer subscription is created.
- `customer.subscription.updated` - Triggered when a customer subscription is updated.
- `customer.subscription.deleted` - Triggered when a customer subscription is deleted.
- `customer.updated` - Triggered when a customer is updated.
- `customer.deleted` - Triggered when a customer is deleted.
- `payment_method.automatically_updated` - Triggered when a payment method is automatically updated.
- `payment_method.card_automatically_updated` - Triggered when a card payment method is automatically updated.
- `invoice.payment_action_required` - Triggered when an invoice requires a payment action.

For more details on each event, refer to the [Stripe Webhook Documentation](https://stripe.com/docs/webhooks).

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
