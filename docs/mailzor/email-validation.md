---
titleTemplate: Mailzor
---

# Email Validation

Mailzor includes a high-fidelity email validation engine that helps maintain list hygiene and improve deliverability by filtering out invalid, disposable, and risky email addresses.

## Validation Levels

The engine performs multiple checks for every email address:

1. **Syntax Check**: Ensures the email follows standard RFC formats.
2. **Domain/MX Check**: Verifies that the domain exists and has valid Mail Exchange (MX) records.
3. **SMTP Verification**: Connects to the recipient's mail server to check if the mailbox actually exists (without sending an email).
4. **Disposable Detection**: Checks against a database of known temporary/disposable email providers.
5. **Catch-all Detection**: Identifies domains that accept all mail, which can be risky for deliverability.

## Usage Modes

### Single Validation
Enter a single email address in the dashboard for instant results. Ideal for manual checks or quick lookups.

### Bulk Validation
Upload a CSV or Excel file containing thousands of emails.
- **Process**: The file is processed asynchronously in the background.
- **Results**: Download a detailed report with validation statuses for every email.

## Status Meanings

| Status | Meaning | Recommendation |
| :--- | :--- | :--- |
| **Valid** | The mailbox exists and is ready to receive mail. | Safe to send. |
| **Invalid** | The email is malformed or the mailbox does not exist. | **Do not send.** |
| **Catch-all** | The server accepts all mail; existence is unconfirmed. | Send with caution. |
| **Disposable** | This is a temporary email address. | **Do not send.** |
| **Unknown** | The mail server did not respond in time. | Try again later. |

## Credit-Based System
Email validation consumes "Validation Credits".
- Each single validation costs 1 credit.
- Bulk validation deducts credits based on the total row count of the uploaded file.
- Credits can be purchased via the **Billing** section.

## Technical Details
- **Module**: `Modules/EmailVerify`
- **Table**: `email_validations` (Cache of validated emails)
- **Table**: `bulk_validations` (Records of batch processing jobs)
- **Job**: `App\Jobs\ProcessBulkValidation`

::: tip
Mailzor caches validation results for 30 days. Validating the same email multiple times within this window will not consume additional credits.
:::
