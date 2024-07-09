---
titleTemplate: NitroFIT28
---

# Reports

This documentation outlines the columns present in the reports module, providing definitions and examples to help understand the data being tracked and presented.

![Yearly Reports](/nitrofit28/reports.jpg)

### Columns and Definitions

1. **Year**
   - **Definition**: The calendar year for the data being reported.
   - **Example**: 2024

2. **Total**
   - **Definition**: The number of users who subscribed during the year.
   - **Example**: 299.86

3. **Rolling (USD)**
   - **Definition**: The total amount paid by users who have active subscriptions.
   - **Example**: $299.86

4. **Rolling**
   - **Definition**: The total number of users with active subscriptions.
   - **Example**: 6

5. **End Date (USD)**
   - **Definition**: The total amount paid by users whose subscriptions have ended.
   - **Example**: $0.00

6. **End Date**
   - **Definition**: The total number of users whose subscriptions have ended.
   - **Example**: 0

7. **Free**
   - **Definition**: The total number of users on a free subscription plan.
   - **Example**: 1

8. **Cancelled (USD)**
   - **Definition**: The total amount paid by users who have cancelled their subscriptions.
   - **Example**: $0.00

9. **Cancelled**
   - **Definition**: The total number of users who have cancelled their subscriptions.
   - **Example**: 0

10. **Total Spend (USD)**
    - **Definition**: The total amount paid by all users.
    - **Example**: $299.86

### Example Data

| Year          | Total | Rolling (USD) | Rolling | End Date (USD) | End Date | Free | Cancelled (USD) | Cancelled | Total Spend (USD) |
|---------------|-------|----------------|---------|----------------|----------|------|-----------------|-----------|-------------------|
| Current Year  | $299.86 | 6            | $0.00   | 0             | 1        | $0.00| 0               | $299.86  |

### Detailed Definitions

1. **Year**
   - **2024**: Represents the year for which the data is being reported.

2. **Total**
   - **Number of users subscribed in the year**: The count of users who have started a subscription in the given year.

3. **Rolling (USD)**
   - **Total amount paid by users with active subscriptions**: Sum of payments made by users whose subscriptions are currently active.

4. **Rolling**
   - **Total number of users with active subscriptions**: Count of users who have ongoing subscriptions.

5. **End Date (USD)**
   - **Total amount paid by users whose subscriptions have ended**: Sum of payments made by users whose subscriptions have terminated.

6. **End Date**
   - **Total number of users whose subscriptions have ended**: Count of users who no longer have active subscriptions.

7. **Free**
   - **Total number of users on a free plan**: Count of users who are subscribed to the free tier.

8. **Cancelled (USD)**
   - **Total amount paid by users who have cancelled their subscriptions**: Sum of payments made by users who have terminated their subscriptions before the end of the subscription period.

9. **Cancelled**
   - **Total number of users who have cancelled their subscriptions**: Count of users who have opted to cancel their subscriptions.

10. **Total Spend (USD)**
    - **Total amount paid by all users**: Cumulative sum of all payments made by users during the reported year.
