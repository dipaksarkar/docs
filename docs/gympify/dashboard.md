---
titleTemplate: Gympify
---

# Dashboard KPI

This documentation outlines the KPI metrics displayed on the dashboard and describes how each metric is calculated, along with the comparison logic.

## **New Members This Month**

- **Description**: Displays the number of new members who joined during the current month compared to the previous month.
- **Calculation**:
  - **Current Month**: The count of new members from the 1st of the current month to today.
  - **Previous Month**: The count of new members from the 1st of the previous month to the same day in that month.
  - **Percentage Change**: Calculated as `((current - previous) / previous) * 100`.
  - **Indicator**: If the percentage change is negative, it will be shown as a negative trend.
- **Example**:
  - Current: 50 members (this month)
  - Previous: 40 members (same period last month)
  - **Display**: 25% increase.

## **Visits Today**

- **Description**: Shows the number of successful member check-ins (visits) today compared to the same time yesterday.
- **Calculation**:
  - **Today**: The count of check-ins from midnight today to the current time.
  - **Yesterday's Comparison**: The count of check-ins from midnight yesterday to the same time yesterday.
  - **Percentage Change**: Calculated as `((current - previous) / previous) * 100`.
  - **Indicator**: Shows whether today’s check-ins are trending up or down compared to the same time yesterday.
- **Example**:
  - Current: 100 check-ins (today)
  - Previous: 80 check-ins (same time yesterday)
  - **Display**: 25% increase.

## **Member Visits This Month**

- **Description**: Shows the total number of visits (check-ins) this month compared to the same period in the previous month.
- **Calculation**:
  - **Current Month**: The count of check-ins from the 1st of the current month to today.
  - **Previous Month**: The count of check-ins from the 1st to the same day last month.
  - **Percentage Change**: Calculated as `((current - previous) / previous) * 100`.
  - **Indicator**: Shows whether this month’s visits are increasing or decreasing compared to the previous month.
- **Example**:
  - Current: 500 visits (this month)
  - Previous: 400 visits (same period last month)
  - **Display**: 25% increase.

## **Bookings This Month**

- **Description**: Displays the number of bookings this month compared to the same period last month.
- **Calculation**:
  - **Current Month**: The count of bookings from the 1st of the current month to today.
  - **Previous Month**: The count of bookings from the 1st to the same day last month.
  - **Percentage Change**: Calculated as `((current - previous) / previous) * 100`.
  - **Indicator**: Shows whether bookings are trending up or down compared to the previous month.
- **Example**:
  - Current: 30 bookings (this month)
  - Previous: 25 bookings (same period last month)
  - **Display**: 20% increase.

## **Online Signups This Month**

- **Description**: Displays the number of online signups (members who registered via the website or app) this month compared to the same period in the previous month.
- **Calculation**:
  - **Current Month**: The count of online signups from the 1st of the current month to today.
  - **Previous Month**: The count of online signups from the 1st to the same day in the previous month.
  - **Percentage Change**: Calculated as `((current - previous) / previous) * 100`.
  - **Indicator**: Shows the trend of online signups for the current and previous months.
- **Example**:
  - Current: 15 signups (this month)
  - Previous: 10 signups (same period last month)
  - **Display**: 50% increase.

## **Online Bookings This Month**

- **Description**: Shows the number of online bookings (bookings made through the website or app) this month compared to the same period in the previous month.
- **Calculation**:
  - **Current Month**: The count of online bookings from the 1st of the current month to today.
  - **Previous Month**: The count of online bookings from the 1st to the same day in the previous month.
  - **Percentage Change**: Calculated as `((current - previous) / previous) * 100`.
  - **Indicator**: Shows whether online bookings are increasing or decreasing.
- **Example**:
  - Current: 25 online bookings (this month)
  - Previous: 20 online bookings (same period last month)
  - **Display**: 25% increase.

::: tip

- **Percentage Change Formula**:
  - If the previous period value is greater than 0, the formula is `((current - previous) / previous) * 100`.
  - If the previous period value is 0, the percentage change is set to 0 to avoid division by zero errors.
- **Negative Trends**: A negative trend is highlighted when the current value is less than the previous value, and it will display a downward indicator.
  :::

## **Members Breakdown**

- **Calculation:** It categorizes users based on their status (`Active` or `Inactive`) and counts how many members fall into each category. This is achieved by grouping the `status` field of the user model and returning the count for each group.
- **Data Display:** The dashboard will show two categories: `Active` and `Inactive` members, with the respective counts for each.

## **User Growth**

- **Calculation:** The number of users created in the past 12 months is grouped by month. The `created_at` date is used to count new users each month and is formatted into `MMM YY` format (e.g., Jan 24).
- **Data Display:** The dashboard shows user growth over time, displaying the total number of new users for each month in the last year.

## **Revenue Breakdown**

- **Calculation:** This method sums the `grand_total` of all orders, grouped by `source`. If the `source` is null, it is labeled as "Online." The method does not count the number of orders but instead focuses on the revenue generated from each source.
- **Data Display:** The dashboard shows total revenue for each source (e.g., "Online" and other sources like offline sales).

## **Retention Rate**

- **Calculation:** For each month, it checks how many users were created before the previous month and how many of those are still `Active`. It then calculates the retention rate as the percentage of users who remain active.
- **Data Display:** The dashboard shows the retention rate for each month, highlighting how well user engagement is maintained over time.

## **Attendance Utilization**

- **Calculation:** For the last 12 months, this method calculates two metrics:
  - **Attendance Rate:** The percentage of bookings that were attended, calculated as `(attended bookings / total bookings) * 100`.
  - **Utilization Rate:** The percentage of class capacity utilized, calculated as `(total bookings / expected capacity) * 100`.
- **Data Display:** The dashboard displays attendance and utilization rates for each of the last 12 months, showing how well classes are being attended and utilized.

## **Revenue Trends**

- **Calculation:** It calculates the total revenue per month over the last 12 months, using the `grand_total` field from orders. The data is grouped by month and formatted into `MMM YY` format.
- **Data Display:** The dashboard shows a trendline of total revenue over the past year, helping track the financial performance month-by-month.

## **Revenue Trends by Source**

- **Calculation:** This method groups the revenue by both month and order source, then sums and averages the `grand_total` for each group. It provides two series of data:
  - **Total Revenue per Source:** Displays how much revenue each source generates.
  - **Average Order Value:** Displays the average order value per month.
- **Data Display:** The dashboard visualizes the breakdown of revenue by source as well as the total revenue and average order value trends.

## **Check-Ins (Incomplete)**

- **Calculation (Incomplete in code):** It fetches check-ins for the past 7 days and counts the number of users checking in each day. The logic for completing this calculation isn't fully shown in the provided code.
- **Data Display:** The dashboard likely shows a daily trend of check-ins, helping monitor attendance.

This method-driven explanation ensures that all dashboard metrics are explained similarly to how key performance indicators (KPIs) are presented, focusing on the data each method calculates and how it is displayed.
