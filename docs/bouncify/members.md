---
titleTemplate: Bouncify
---

#   Members
Manage account information, credit balances for email validation, and billing information.

-   `Title` - Prefix or honorific.
-   `First Name` -    Given name of the individual.
-   `Surname` -   Last name or family name.
-   `Email Address` - Contact email for communication.
-   `Phone Number` -  Contact number for communication.
-   `Status` -    For newly created members, the member status is set as `Pending` by default. You can set the following statuses:
    -   `Pending`: the member account is created and needs to be reviewed.
    -   `Active`: the member has credits and can use email validation features.
    -   `Deactive`: the member has no credits or access has been revoked.
    -   `Hold`: temporarily pause the account with an optional release date.
    -   `Lost`: member is no longer active and unlikely to return.
-   `Billing Address` - Address to be added to the invoice.
    -   `Address Line 1`: First line of the billing address.
    -   `Address Line 2`: Second line of the billing address (optional).
    -   `Country`: Country of the billing address.
    -   `State`: State or region of the billing address.
    -   `City`: City of the billing address.
    -   `Postcode/Zip`: Postal code or ZIP code of the billing address.
-   `Security` - Pertains to security-related actions such as changing the member's password.
-   `Special Note` - Additional notes or comments that are hidden from the member's profile.
-   `Avatar` -    Profile picture or visual representation.
-   `Notes` - With note section, you can view detailed histories and write notes for member.
-   `RAG Status` - Colored indicators (Red, Amber, Green, White) for quick visual status of credit usage or account health.

## Managing Members

### Member Profile

The member profile page consists of two main tabs:

1. **Overview Tab** - Contains general information, billing address, security settings, and special notes.
2. **Billing Tab** - Manage credit purchases, payment methods, and view invoice history.

### Add a new member

**Steps:**

1.  From your admin, go to `Members`.
2.  From the `Members` page, click `Add member`.
3.  Enter a name for your member, along with additional `details`.
4.  Click `Save`.

### Edit a member

**Steps:**

1.  From your admin, go to `Members`.
2.  Click on the member's name or click the (`...`) menu and select `Edit`.
3.  Update the member information.
4.  Click `Save`.

### Managing Member Status

You can change a member's status to control their access and email validation credits:

- Set to `Hold` to temporarily pause their account. You can specify a release date.
- Set to `Active` to grant access to email validation features based on available credits.
- Set to `Deactive` when a member has no credits or you want to revoke access.

### Managing Email Validation Credits

To add or adjust a member's credits:

1. Navigate to the member's profile page.
2. Use the "Mark as Paid" feature to add validation credits to a member's account.
3. You can also adjust usage counts through the "Change Usages" option to reflect used or refunded credits.

### Import/Export Members

**Import members:**
1. From the `Members` page, click the import icon.
2. Download the sample CSV file if needed.
3. Upload your prepared CSV file.
4. Choose whether to overwrite existing members with the same email.
5. Complete the import process.

**Export members:**
1. From the `Members` page, click the export icon.
2. The system will generate a CSV file of your member data.

##  Delete a member
You can delete a single member, or delete multiple members at the same time using a bulk action. When you delete a member, it's temporary removed from `Bouncify`. Deleted members can be restored.

**Steps:**

1.  From your admin, go to `Members`.
2.  Click the (`...`) of the member that you want to delete.
3.  Click `Delete`.
4.  Click `Confirm`.

## Restore deleted members

**Steps:**

1.  From your admin, go to `Members`.
2.  Toggle the `Trashed` button to view deleted members.
3.  Click the (`...`) of the member you want to restore.
4.  Click `Restore`.
5.  The member will be restored to their previous status.

## Member Notes & History

You can add notes to keep track of member interactions and view history:

1. Navigate to the member's profile page.
2. Scroll down to the `Notes` section.
3. Enter your note and click `Save` to add it to the member's history.
4. View the chronological history of notes and credit usage for the member.

## Send Messages to Members

To send a message to a member:

1. Navigate to the member's profile page.
2. In the `Special note` section, click `Send Message`.
3. Complete the message form and send it to the member.