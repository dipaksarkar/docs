### Updated Theme Documentation

This guide explains how to work with themes in your Laravel application, manage shortcodes and templates, create child themes, and use the `@theme` directive.

---

#### 1. **Theme Structure**

Your theme directory should follow this structure:

```
/themes/{theme-name}/
    ├── assets/
    │   ├── css/
    │   ├── js/
    │   └── img/
    ├── views/
    │   ├── layouts/
    │   ├── includes/
    │   ├── shortcodes/
    │   └── templates/
    └── config.json
```

---

#### 2. **Shortcodes**

**Shortcodes** are reusable view components that can be embedded into pages or posts via a page editor. These components perform specific tasks like rendering buttons, forms, or content blocks.

- **Location**: All shortcode views are stored in the `shortcodes/` directory in your theme.
  
- **Editing**: Users can only edit the existing shortcodes in this folder. No new shortcodes can be created by users. The shortcodes available in this folder are system-defined and will automatically be available in the page editor.

- **Availability**: The edited shortcodes will appear in the page editor for quick use in creating content.

**Example**:

Suppose you have a shortcode `button.blade.php` in the `shortcodes/` folder:

```blade
<a href="{{ $url }}" class="btn btn-primary">{{ $text }}</a>
```

In the page editor, this shortcode can be inserted as `[button url="https://example.com" text="Click Me"]`.

---

#### 3. **Templates**

**Templates** provide pre-designed page layouts stored in the `templates/` directory. These templates are useful for rendering different types of content such as blog posts, landing pages, or static pages.

- **Location**: All page templates are stored under the `templates/` directory in your theme.
  
- **Use Case**: When creating or editing a page, users can select a template from the available options to control the layout and design. Each template serves a different page type like blog posts, static pages, etc.

**Common Templates:**

1. **Blog Template**: Displays a single blog post.
2. **Blogs Template**: Displays a list of blog posts.
3. **Page Template**: A generic template for static content pages like "About Us."

**Example**:

If you have a `blog.blade.php` template:

```blade
@extends('layouts.master')

@section('content')
    <article>
        <h1>{{ $title }}</h1>
        <p>{{ $content }}</p>
    </article>
@endsection
```

When creating a new page, selecting the "Blog" template will apply this layout.

---

#### 4. **Creating a Child Theme**

A **child theme** allows you to inherit assets and views from a parent theme while making modifications in the child theme. To create a child theme, follow the same directory structure as a parent theme, but include a reference to the parent theme in the `config.json` file.

**Example `config.json` for Child Theme:**

```json
{
  "name": "My Child Theme",
  "version": "1.0.0",
  "parent": "ParentTheme"
}
```

If a view or asset is missing in the child theme, it will automatically look for it in the parent theme.

---

#### 5. **Using the `@theme` Directive**

The `@theme` Blade directive simplifies the process of including theme assets like stylesheets, scripts, and images. It generates the appropriate HTML tag based on the asset type.

**Usage Examples:**

1. **Include a CSS file:**
   ```blade
   @theme('css/style.css', 'style')
   ```
   This will generate:
   ```html
   <link rel="stylesheet" href="/themes/{theme}/assets/css/style.css">
   ```

2. **Include a JavaScript file:**
   ```blade
   @theme('js/app.js', 'script')
   ```
   This will generate:
   ```html
   <script src="/themes/{theme}/assets/js/app.js"></script>
   ```

3. **Include an Image:**
   ```blade
   @theme('img/logo.png', 'image', ['alt' => 'An Example Alt'])
   ```
   This will generate:
   ```html
   <img src="/themes/{theme}/assets/img/logo.png" alt="An Example Alt">
   ```

**Directive Syntax:**

```blade
@theme($asset, $type, $attributes = [], $absolute = true)
```

- **$asset**: Path to the asset within the `assets/` folder.
- **$type**: The type of asset (`style`, `script`, `image`).
- **$attributes** (optional): Array of HTML attributes like `alt`, `class`, etc.
- **$absolute** (optional): Whether to generate an absolute URL (default: `true`).

---

### Conclusion

This theme architecture offers flexibility for managing assets, views, and templates while enforcing control over shortcode editing. By using the `@theme` directive, you can easily include assets, and the child theme structure enables you to extend and customize themes as needed.
