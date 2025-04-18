---
titleTemplate: BouncifyPro
---

#   Adding and updating taxess

You can add or update information about a tax such as its country, state, and rate from the `Settings > Taxes` page in your admin.

-   `Country` -  You have to specify a country from dropdown.
-   `State` - Similar to the country, you need to enter the two-digit codes for states wherever applicable. And, if you don’t want to specify a single state, you can set `*` as well.
-   `Rate` - Here is where you specify the rate of applicable tax with 2 decimal places. For example, to set a tax rate of 10%, you have to enter 10.00 or for a rate of 12.5%, enter 12.50.
-   `Label` - You can also enter a name for the tax rate. For example, Sales Tax, VAT, etc.
-   `Priority` -  You can also choose a priority for the tax rate. You have specify only one matching rate per priority. If you are defining multiple tax rates for the same area, then you have to set a different priority for each rate.
-   `Compounded` -  If you want the rate you are defining to be applied on top of all the other taxes, you can tick this checkbox. Say for example, you have an additional tax on a specific jurisdiction along with the regular sales tax. The compound tax option determines whether the additional charge is calculated based on the product price alone, or including the product price as well as the regular sales tax.

## Add a tax
Let’s see how you can set up a new tax rate. 

**Steps:**

1.  From your admin, go to `Settings > Taxes`.
2.  Click the `Add tax`.
3.  Modify the tax `details`.
4.  Click `Done`.

##  Delete a tax
Deleted taxes can't be restored.

To permanently delete a tax:

1.  From your admin, go to `Settings > Taxes`.
2.  Click the Delete icon of the tax that you want to delete.
3.  Click `Confirm`.
  
::: warning
Default tax can't be deleted
:::

## Example scenarios

Here is an example scenario on how you can set up different tax rates on your store.

Suppose a store wants to set up different taxes for customers from different regions. For example, if you want to charge a tax rate of 6% across the United States, you can set the tax rate as below.

```bash
Country - United States
State - *
Label - VAT
Rate - 6
Priority - 0
```

On the order page, when a US address is entered, this tax rate will be applied.

Now, let us set a different charge for one state. Say, you want to set a tax of 7.5% for Arkansas. For this, you can add an additional tax rate for Arkansas, and set it as Priority 1.

```bash
Country - United States
State - AR
Label - VAT
Rate - 7.5
Priority - 0
```

Now, when a customer enters the address as Arkansas, this rate will be applied instead of the common US rate of 6%. Customers will be able to see this on the order page. All Arkansas addresses will have 7.125% sales tax, and the rest of the US will be 6%.

### Compound tax
Now, let us try and understand how complex tax is charged.

There are two taxes applicable for the country United States. The regular Arkansas state tax as well as an additional 2% tax. First, we will keep the compound field checked.

**General**
```bash
Country - United States
State - *
Label - VAT
Rate - 7.5
Priority - 1
```

**Compound**
```bash
Country - United States
State - AR
Label - VAT
Rate - 2
Priority - 2
Compounded - checked
```
The additional tax is charged on the compound rate of product price + state tax ($1500 + $112.5) instead of only $1500, which was the case in the first example. So the taxes will be: State Tax: 7.5% of $1500 = $112.5 Additional tax: 2% of 1612.5 = $32.25