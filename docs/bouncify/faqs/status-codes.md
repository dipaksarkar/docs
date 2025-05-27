---
titleTemplate: Bouncify
---

# Status Codes

Bouncify assigns a status to every email address we verify. Each status helps you understand whether you should send emails to that address. Below are the main statuses and their sub-statuses.

---

## **Valid**

These addresses are confirmed as valid and safe to email. Expect a very low bounce rate (under 2%).

> **Note:** If you still receive bounces, it could be due to your sending IP being blacklisted, recipient restrictions (like only accepting emails from contacts), or domain-specific sending limits. Always check SMTP bounce codes for details.

**Sub-statuses:**

- **alias_address** — (valid) Forwarders or aliases, not real inboxes. For example, emailing `forward@example.com` forwards your message to `realinbox@example.com`. These are valid and won’t bounce.
- **leading_period_removed** — (valid) If a valid Gmail address starts with a period (`.`), we remove it for compatibility with all mailing systems.

---

## **Invalid**

These addresses are not deliverable. Remove them from your list. Reasons include non-existent mailboxes, domains that don’t accept mail, or syntax errors.

**Sub-statuses:**

- **does_not_accept_mail** — (invalid) Domains that only send mail, not receive.
- **failed_syntax_check** — (invalid) Fails RFC syntax protocols.
- **possible_typo** — (invalid) Commonly misspelled popular domains.
- **mailbox_not_found** — (invalid) Syntax is valid, but the mailbox doesn’t exist.
- **no_dns_entries** — (invalid) Domain has no or incomplete DNS records, making delivery impossible.
- **mailbox_quota_exceeded** — (invalid) Mailbox is full and temporarily not accepting emails.
- **unroutable_ip_address** — (invalid) Domain points to an unroutable IP address.

---

## **Catch-all**

These domains accept all emails, making it impossible to confirm if an address is truly valid without sending a real message. Some emails may bounce. We recommend segmenting these addresses.

[Learn more about Catch-All Emails](/bouncify/faqs/what-are-catch-all-domains)

---

## **Do Not Mail**

These are addresses you should avoid emailing, even though they are technically valid. They include company, role-based, disposable, or otherwise risky addresses.

**Sub-statuses:**

- **global_suppression** — (do_not_mail) Found on global suppression lists (GSL), including known complainers, purchased addresses, and litigators.
- **possible_trap** — (do_not_mail) May be spam traps (e.g., `spam@` or `@spamtrap.com`). Review before sending.
- **role_based** — (do_not_mail) Addresses like `sales@`, `info@`, or `contact@` that belong to a group or position. These are often reported as spam.
- **disposable** — (do_not_mail) Temporary addresses that become invalid after a short period.
- **toxic** — (do_not_mail) Known for abuse, spam, or bot activity. Avoid emailing.
- **role_based_catch_all** — (do_not_mail) Role-based addresses at catch-all domains.
- **mx_forward** — (do_not_mail) Domains that forward their MX records, similar to disposable domains.

---

## **Unknown**

We couldn’t validate these addresses, often due to offline servers or anti-spam systems. Most unknowns (about 80%) are invalid. You are not charged for unknown results.

**Sub-statuses:**

- **antispam_system** — (unknown) Anti-spam systems block validation.
- **exception_occurred** — (unknown) An error occurred during validation.
- **failed_smtp_connection** — (unknown) SMTP connection not allowed.
- **forcible_disconnect** — (unknown) Server disconnects immediately.
- **greylisted** — (unknown) Temporary block; try resubmitting.
- **mail_server_did_not_respond** — (unknown) No response from mail server.
- **mail_server_temporary_error** — (unknown) Server returns a temporary error.
- **timeout_exceeded** — (unknown) Server response too slow.

> Some unknown and invalid results may not have a sub_status code.

---

## Other Fields

- **free_email** — [true/false] Is the email from a free provider? (Coming soon)
- **mx_record** — The preferred MX record of the domain.
- **smtp_provider** — The SMTP provider or [null]. (Coming soon)

---

## Why Do We Flag "Do Not Mail"?

Protecting your IP/domain reputation is crucial. Avoiding bounces is just the first step. The "Do Not Mail" status helps you avoid addresses that could harm your deliverability or reputation.

[Read our Email Deliverability Guide.](/bouncify/faqs/email-deliverability)

---

## About Role-Based Addresses

Role-based emails (like `sales@`, `info@`, `contact@`) are valid but risky. They often lead to spam complaints and deliverability issues. Many major ESPs recommend avoiding them:

- [MailChimp](https://kb.mailchimp.com/lists/growth/limits-on-role-based-addresses "MailChimp")
- [Constant_Contact](https://knowledgebase.constantcontact.com/articles/KnowledgeBase/5538-about-role-addresses-group-addresses-and-aliases "Constant_Contact")
- [SendGrid](https://sendgrid.com/blog/role-addresses-and-their-effect-on-email-deliverability/ "SendGrid")
- [Nation_Builder](https://support.nationbuilder.com/en/articles/2344129-understanding-spam "Nation_Builder")
- [Benchmark_Email](https://ui.benchmarkemail.com/help-FAQ/answer/what-role-addresses-does-benchmark-email-specifically-block-from-bulk-importing "Benchmark_Email")
- [Port_25](https://www.port25.com/indicators-of-a-poor-list-role-based-accounts-to-discard/ "Port_25")

Depending on your business, you may choose to email role-based addresses, but be aware of the risks.

---

All emails flagged as "role_based" are valid, but use caution when mailing them.