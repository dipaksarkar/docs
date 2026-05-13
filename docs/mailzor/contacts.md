---
titleTemplate: Mailzor
---

# Contacts & Groups

Efficient audience management is critical for successful email marketing. Mailzor provides robust tools for organizing and segmenting your contacts.

## Contact Management

### Contact Profiles
Each contact record stores essential data:
- **Core Info**: Email, First Name, Last Name.
- **Extended Info**: Gender, Birthday, Phone, Address.
- **Status**: Active, Unsubscribed, Bounced, or Complained.
- **Tags**: Custom labels for quick filtering.

### Contact Statuses
- **Active**: Available for all campaigns.
- **Unsubscribed**: Automatically excluded from future sends when a user clicks the unsubscribe link.
- **Bounced**: Permanently excluded after a hard bounce is detected via SES/SMTP.

## Group Management

Groups (or Lists) allow you to organize contacts into logical segments for targeted campaigns.

### Static Groups
Manually add or remove contacts from a named group.
- **Route**: `admin.contact-groups`

### Bulk Operations
- **Import**: Upload CSV or Excel files to add thousands of contacts at once.
- **Export**: Download your entire audience or specific groups with full metadata.
- **Bulk Assign**: Apply tags or move contacts between groups in batches.

## Technical Flow: CSV Import

1. **Upload**: User uploads a `.csv` file.
2. **Mapping**: User maps CSV columns to Mailzor contact fields.
3. **Queue**: The system dispatches a background job (`App\Jobs\ImportContacts`).
4. **Processing**: Contacts are validated and created in chunks of 500 to optimize database performance.
5. **Notification**: The user is notified when the import is complete.

## Database Usage
- **Table**: `contacts` (Stores the unique email records).
- **Table**: `contact_groups` (Stores the group names).
- **Pivot Table**: `contact_contact_group` (Manages the relationship).

## Developer Notes
- **Models**: `App\Models\Contact`, `App\Models\ContactGroup`
- **Controller**: `App\Http\Controllers\ContactController`
- **Service**: `App\Services\ContactService`

::: tip
Use the `has_permission` flag on contacts to track GDPR compliance and marketing consent.
:::
