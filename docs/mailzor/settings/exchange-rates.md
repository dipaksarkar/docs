---
titleTemplate: Mailzor
---

# Exchange Rates

Mailzor supports multi-currency billing, allowing you to charge customers in their local currency while managing your finances in your base currency.

## Manual vs. Automatic Rates

You can manage how currencies are converted in your platform:

- **Base Currency**: Defined in [General Settings](./general.md). All other rates are relative to this currency.
- **Target Currency**: The currency you wish to support (e.g., EUR, GBP, INR).
- **Exchange Rate**: The conversion factor from your base currency to the target currency.

## Syncing Rates

To keep your pricing accurate, Mailzor can automatically sync with global exchange rate providers.

**Steps to Sync:**

1. Navigate to **Settings > Exchange Rates**.
2. Click the **Sync Rates** button.
3. The system will fetch the latest mid-market rates and update all active currencies.

## Adding a New Currency

1. Click **Add Exchange Rate**.
2. Select the **Currency Code** from the list.
3. Enter the current **Rate** manually or wait for the next sync.
4. Set to **Active** to allow this currency to be selected during plan creation or checkout.

## Deleting Rates

Deleting an exchange rate will prevent future transactions in that currency.

::: warning
Ensure no active subscriptions are using a currency before deleting its exchange rate.
:::
