---
titleTemplate: Mailzor
---

# Coupons & Discounts

Attract new users and reward loyalty by creating promotional codes and fixed-amount discounts.

## Coupon Attributes

Configure how your discounts are calculated and applied.

- **Name**: A internal label for the coupon (e.g., `Summer Launch Sale`).
- **Code**: The unique string users enter at checkout (e.g., `SUMMER50`). Codes are case-insensitive.
- **Type**:
  - `Percentage discount`: Subtracts a percentage from the total (e.g., 20% off).
  - `Fixed amount discount`: Subtracts a specific value (e.g., $10 off).
- **Duration**:
  - `Once`: Applies only to the first invoice.
  - `Repeating`: Applies for a specific number of months.
  - `Forever`: Applies to all future recurring invoices for the subscription.
- **Usages Limit**: The total number of times the coupon can be redeemed across your entire platform.
- **Date Limit**: The expiration date after which the coupon code becomes invalid.

## Managing Coupons

### Add a Coupon
1. From your admin, go to **Settings > Coupons**.
2. Click **Add Coupon**.
3. Enter the name, code, and discount details.
4. Click **Save**.

### Deactivating a Coupon
To stop new users from using a code without deleting it, uncheck the **Active** status. Existing users who have already redeemed the coupon will continue to receive their discount if the duration was set to `Repeating` or `Forever`.

### Delete a Coupon
::: danger
Deleting a coupon is permanent for new users. However, it will not remove the discount from users who have already applied it to their active subscriptions.
:::
