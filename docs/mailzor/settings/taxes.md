---
titleTemplate: Mailzor
---

# Adding and updating taxes

You can add or update information about a tax such as its country, state, and rate from the `Settings > Taxes` page in your admin.

- **Country**: You have to specify a country from the dropdown.
- **State**: Similar to the country, you need to enter the two-digit codes for states wherever applicable. If you don't want to specify a single state, you can use `*` as a wildcard for all states.
- **Rate**: This is where you specify the applicable tax rate with up to 2 decimal places. For example, to set a tax rate of 10%, enter `10.00`; for 12.5%, enter `12.50`.
- **Label**: You can enter a name for the tax rate, such as Sales Tax, VAT, GST, etc.
- **Priority**: Choose a priority for the tax rate. You should only have one matching rate per priority level. If you are defining multiple tax rates for the same area, set a different priority for each.
- **Compounded**: Check this if you want the rate to be applied on top of all other applicable taxes. For example, if you have a local tax on top of a state tax, the compounded option determines if the local tax is calculated on the product price alone or on the (product price + state tax) total.

## Add a tax
Follow these steps to set up a new tax rate.

**Steps:**

1.  From your admin, go to `Settings > Taxes`.
2.  Click the `Add tax` button.
3.  Fill in the tax **details** (Country, Rate, Label, etc.).
4.  Click `Done`.

## Delete a tax

::: danger
Deleted taxes cannot be restored.
:::

1.  From your admin, go to **Settings > Taxes**.
2.  Click the **Delete** icon next to the tax.
3.  Click **Confirm**.


## Example Scenarios

### Standard Rate
Suppose you want to charge a flat 6% tax across the entire United States.

```bash
Country - United States
State - *
Label - VAT
Rate - 6
Priority - 0
```

### State-Specific Overrides
Now, if you want a different rate for Arkansas (7.5%) while keeping the rest of the US at 6%, add another rate with a different priority.

```bash
Country - United States
State - AR
Label - VAT
Rate - 7.5
Priority - 1
```
When a customer enters an Arkansas address, the 7.5% rate will be applied instead of the 6% fallback.

### Compound Tax Calculation
To understand how complex taxes are charged, consider a scenario with a 7.5% state tax and a 2% local compound tax.

**General State Tax (Priority 1)**
```bash
Country - United States
State - AR
Label - State Tax
Rate - 7.5
Priority - 1
```

**Local Compound Tax (Priority 2)**
```bash
Country - United States
State - AR
Label - Local Tax
Rate - 2
Priority - 2
Compounded - checked
```

**Calculation Example**:
For a product priced at $1,500:
1. **State Tax**: 7.5% of $1,500 = **$112.50**
2. **Local Tax (Compounded)**: 2% of ($1,500 + $112.50) = **$32.25**
3. **Total Tax**: $144.75
