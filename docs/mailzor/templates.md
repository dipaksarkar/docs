---
titleTemplate: Mailzor
---

# Email Templates

Mailzor includes a powerful drag-and-drop email designer that allows users to create stunning, responsive email templates without writing code.

## Visual Builder

The builder is powered by a JSON-driven section and block system.

### Core Components
- **Sections**: High-level layout containers (e.g., Hero, 2-Column, Footer).
- **Blocks**: Individual content elements (e.g., Text, Image, Button, Divider).
- **Shortcodes**: Dynamic placeholders for personalization (e.g., `{first_name}`, `{unsubscribe_url}`).

## Template Management

### Template Gallery
Users can choose from a library of pre-designed templates or save their own designs for future use.

### Statuses
- **Draft**: Work in progress, not available for campaigns.
- **Published**: Finalized and ready to be used in campaign sends.

## Technical Architecture

### Storage
Templates are stored as JSON structures in the database, representing the hierarchy of sections and blocks.
- **Table**: `email_templates`
- **Field**: `content` (JSON)

### Rendering Pipeline
When a template is used in a campaign:
1. The JSON is parsed.
2. Blade-based sections are rendered with the provided block data.
3. CSS is inlined to ensure maximum compatibility with email clients (Outlook, Gmail).
4. Shortcodes are replaced with recipient-specific data.

## Asset Management
The builder includes an integrated file manager for uploading and managing images used in templates.
- **Route**: `admin.email-templates.assets`
- **Controller**: `App\Http\Controllers\Admin\PageBuilder\AssetController`

## Developer Notes
- **Library**: `coderstm/laravel-page-builder`
- **Controller**: `App\Http\Controllers\EmailTemplateController`
- **Editor Controller**: `App\Http\Controllers\EmailTemplateEditorController`

::: warning
Always ensure that the `public` storage disk is correctly configured for template images to be accessible in emails.
:::
