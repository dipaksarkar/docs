---
titleTemplate: Bouncify
---

# CSV Import Troubleshooting

Having trouble uploading your CSV file to **Bouncify**? Follow this step-by-step guide to resolve common email verification import issues.

## How to Fix CSV Import Errors

### 1. Export Your CSV in UTF-8 Format

Make sure your file is saved as a `.csv` file with **UTF-8 encoding**. Improper encoding can cause Bouncify to misread data and fail during import.

::: tip
Most spreadsheet applications like Excel, Google Sheets, and LibreOffice allow you to specify the encoding when saving as CSV. Always choose UTF-8 for maximum compatibility.
:::

### 2. Include a Proper Header Row

Your CSV's **first row must be a header**, not actual email data. Use labels like _Email_, _Email Address_, etc.

_Tip:_ Even if the column isn't named "Email", the system reads any labeled column — just don't leave the first row blank or filled with emails.

Example of a properly formatted CSV:
```
Email Address,Name,Company
john@example.com,John Smith,Acme Inc.
jane@example.com,Jane Doe,XYZ Corp.
```

### 3. Column Order Doesn't Matter

The _Email_ column doesn't need to be the first, but it must be present. You can include other columns, but keep them clean and organized.

Bouncify will automatically detect which column contains email addresses based on the header names and content format.

### 4. Clean Your File

Remove the following from your CSV file:
- Empty rows
- Irrelevant columns
- Invalid or malformed email addresses
- Special characters or formatting

### 5. Re-Save and Re-Try Uploading

If issues persist, try saving your file again and re-uploading it. A simple re-save in UTF-8 format often resolves hidden formatting issues.

### 6. Check File Size Limits

Ensure your CSV file doesn't exceed the maximum allowed file size:
- Standard upload limit: 50MB
- For larger files, consider splitting into multiple smaller files

### 7. Still Facing Issues?

If you continue to experience problems after following these steps, reach out to our [support team](https://coderstm.com/user/enquiries) and share your CSV file. We'll help you troubleshoot it quickly.

## Common CSV Error Messages and Solutions

| Error Message | Likely Cause | Solution |
|---------------|--------------|----------|
| "No valid email column found" | Missing or incorrectly formatted header row | Add a header row with "Email" or "Email Address" as one of the column names |
| "Invalid file format" | File is not a proper CSV or has incorrect encoding | Re-save as CSV with UTF-8 encoding |
| "File too large" | CSV exceeds size limit | Split into smaller files or compress before uploading |
| "Empty file detected" | CSV has no data or only contains headers | Ensure your file contains actual email data below the header row |
| "Invalid characters detected" | Special formatting or non-UTF-8 characters | Clean your file and remove special characters |

## Pro Tips for Efficient CSV Imports

1. **Pre-validate your data**: Remove obviously invalid emails before importing
2. **Batch processing**: For very large lists, process in batches of 50,000 emails
3. **Regular maintenance**: Clean your email lists regularly to maintain high deliverability rates

Remember, the quality of your import data directly affects the accuracy and efficiency of Bouncify's email verification process.
