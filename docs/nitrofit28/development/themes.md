---
titleTemplate: NitroFIT28
---

# Theme Documentation

This guide provides a detailed breakdown of the theme architecture, covering shortcodes, includes, asset management, and commands for building the theme in both development and production environments. The default theme is **Foundation**.

## **Theme Structure**

The theme structure is organized as follows. The default theme is **Foundation**.

```
/themes/foundation/
    ├── assets/
    │   ├── scss/
    │   │   └── app.scss  // Main CSS file (compiled and used in public assets as css/app.css)
    │   ├── js/
    │   │   └── app.js   // Main JavaScript file (compiled and used in public assets as js/app.js)
    │   └── img/         // Image files
    ├── views/
    │   ├── layouts/
    │   │   └── page.blade.php      // Layout used by all pages
    │   │   └── error.blade.php     // Layout used by all error pages
    │   ├── shortcodes/             // Contains all system-defined shortcodes
    │   │   ├── footers/
    │   │   │   └── default.blade.php
    │   │   ├── headers/
    │   │   │   └── classic.blade.php
    │   │   │   └── overlay.blade.php
    │   │   ├── announcements.blade.php
    │   │   ├── blog-tags.blade.php
    │   │   ├── blog.blade.php
    │   │   ├── blogs.blade.php
    │   │   ├── calendar.blade.php
    │   │   ├── company-address.blade.php
    │   │   ├── contact-form.blade.php
    │   │   ├── email.blade.php
    │   │   ├── menu.blade.php
    │   │   ├── opening-times.blade.php
    │   │   ├── phone.blade.php
    │   │   ├── plans.blade.php
    │   │   ├── product.blade.php
    │   │   ├── products.blade.php
    │   │   ├── recent-blogs.blade.php
    │   │   ├── socials.blade.php
    │   └── includes/                // Contains all default includes
    │   │   ├── example.blade.php    // Example include file
    │   │   ├── footer-script.blade.php // Custom script in the footer
    │   │   ├── pricing.blade.php    // Pricing section include
    │   │   ├── social.blade.php     // Social media links include
    │   │   ├── sub-menu.blade.php   // Sub-menu include
    └── config.js
```

## **Laravel Blade Template Overview**

Laravel's Blade templating engine is used throughout the theme for dynamic content rendering, component creation, and layout structuring. Blade allows you to include reusable sections, extend layouts, and integrate logic seamlessly into your theme.

::: tip
Blade’s simple yet powerful features are designed to make writing views easier. You can read more about Blade and its core features in the [Laravel Blade Introduction](https://laravel.com/docs/11.x/blade#introduction).
:::


### **Blade Directives**

Blade comes with various built-in directives to make templating more flexible:

- `@include`: Used to include Blade views (like partials or includes).
  
  **Example:**
  ```blade
  @include('includes.footer-script')
  ```

- `@yield` and `@section`: Used to define sections that can be overridden in child templates.

  **Example:**
  ```blade
  @section('content')
      <p>This is the content section.</p>
  @endsection
  ```

### **Extending Layouts**

The Blade templates within `/views/layouts/` provide base layouts that can be extended in your theme. This ensures consistency across pages.

**Example of extending the `page.blade.php` layout:**

```blade
@extends('layouts.page')

@section('content')
    <h1>Welcome to NitroFIT28</h1>
    <p>This is a customizable page using the Foundation theme.</p>
@endsection
```

This example will inject the content into the `page.blade.php` layout.

## **Shortcodes in the Theme**

The predefined shortcodes in the **Foundation** theme allow you to easily reuse common components across the site.

**Shortcodes List**:

1. **Footers**
    - `footers/default.blade.php`: A default footer shortcode.

2. **Headers**
    - `headers/classic.blade.php`: A classic header layout.
    - `headers/overlay.blade.php`: An overlay-style header layout.

3. **Miscellaneous Shortcodes**
    - `announcements.blade.php`: For displaying announcements.
    - `blog-tags.blade.php`: Displays blog tags.
    - `blog.blade.php`: Displays an individual blog post.
    - `blogs.blade.php`: Displays a list of blog posts.
    - `calendar.blade.php`: Displays a calendar.
    - `company-address.blade.php`: Shows the company’s address.
    - `contact-form.blade.php`: Displays a contact form.
    - `email.blade.php`: For email-based content.
    - `menu.blade.php`: Displays a menu.
    - `opening-times.blade.php`: Shows business opening hours.
    - `phone.blade.php`: Displays a phone number.
    - `plans.blade.php`: Displays available plans (e.g., subscription plans).
    - `product.blade.php`: Displays an individual product.
    - `products.blade.php`: Displays a list of products.
    - `recent-blogs.blade.php`: Displays recent blog posts.
    - `socials.blade.php`: Displays social media links.

These shortcodes are predefined in the theme and cannot be removed or created, but they can be customized by editing the corresponding Blade files.

## **Includes in the Theme**

The **Foundation** theme also has a set of predefined **includes**, which are reusable content blocks that can be incorporated into different templates. The available includes are stored in the `includes/` directory.

**Includes List**:

1. **Example Include**: `example.blade.php`: A sample include file.
2. **Footer Script**: `footer-script.blade.php`: Contains custom scripts to be loaded in the footer.
3. **Pricing Section**: `pricing.blade.php`: Used to display pricing information.
4. **Social Media Links**: `social.blade.php`: Displays links to social media profiles.
5. **Sub-Menu**: `sub-menu.blade.php`: A submenu for navigating between sections.

These files can be referenced and included in any Blade templates across your theme using Blade's `@include` directive.

## **config.js Structure**

The `config.js` file holds the metadata for the theme and allows the inclusion of custom styles and scripts in the editor.

```json
{
  "name": "Foundation",
  "version": "1.0",
  "description": "A foundational frontend theme designed for flexibility and easy customization",
  "parent": null,
  "editor": {
    "styles": [
      "//cdn.coderstm.com/fontawesome/css/all.min.css",
      "statics/css/styles.min.css"
    ],
    "scripts": []
  }
}
```

- **name**: The name of the theme.
- **version**: The version of the theme.
- **description**: A description of the theme.
- **parent**: Specifies if the theme inherits from another theme.
- **editor.styles**: Defines styles that should be loaded in the editor.
- **editor.scripts**: Defines scripts that should be loaded in the editor.

The `editor` section allows custom CSS and JavaScript to be loaded for editing purposes without affecting the public-facing theme.


## **Variables in Layouts**

Both `page.blade.php` and `error.blade.php` use a set of customizable variables for flexibility in layout and content presentation.

### **`/layouts/page.blade.php`**

| Variable            | Type    | Description                                                                                  | Default Value                              |
|---------------------|---------|----------------------------------------------------------------------------------------------|--------------------------------------------|
| `meta_keywords`      | string  | The meta keywords for SEO purposes.                                                          | Empty string                               |
| `meta_description`   | string  | The meta description for SEO purposes.                                                       | Empty string                               |
| `url`                | string  | The author URL (usually your site URL).                                                       | `config('app.url')`                        |
| `meta_title`         | string  | The page title for SEO purposes.                                                             | `$title . ' | ' . config('app.name')`      |
| `title`              | string  | The specific title of the page (used in the page's `<title>` tag if `meta_title` is missing). | No default value (must be provided)        |
| `styles`             | string  | Custom inline CSS styles specific to the page.                                               | Empty string                               |
| `body`               | string  | The main content of the page.                                                                | Empty string                               |
| `scripts`            | string  | Custom inline JavaScript to be added to the page.                                             | Empty string                               |

### **`/layouts/error.blade.php`**

| Variable            | Type    | Description                                                                                  | Default Value                              |
|---------------------|---------|----------------------------------------------------------------------------------------------|--------------------------------------------|
| `title`              | string  | The error page title (used in the page's `<title>` tag).                                      | No default value (must be provided)        |
| `csrf_token`         | string  | The CSRF token for the error page.                                                           | `csrf_token()`                             |
| `styles`             | string  | Any additional styles or CSS to be used on the error page (via `@yield('style')`).           | None (can be overridden)                   |
| `message`            | string  | The main error message content (via `@yield('message')`).                                    | No default value (must be provided)        |

## **Helper Function: `theme()`**

The `theme()` helper function is used to load assets from the theme's `public/themes/foundation/` directory.

```php
theme($path, $themeName)
```

- **$path**: The relative path of the asset.
- **$themeName**: The name of the theme (e.g., `foundation`).

**Example**:
```blade
<link rel="stylesheet" href="{{ theme('css/app.css', 'foundation') }}">
```

This will load the `app.css` file from the `public/themes/foundation/css/` directory of the **Foundation** theme.

## **Building the Theme**

To build and manage theme assets, use the following commands:

1. **Build for Production**:
    ```
    npm run theme:build --name=foundation
    ```
    Compiles the theme assets for production (minified, optimized).

2. **Build for Development**:
    ```
    npm run theme:dev --name=foundation
    ```
    Compiles the theme assets for development, including source maps for debugging.

Ensure to pass the correct theme name with the `--name` argument.
