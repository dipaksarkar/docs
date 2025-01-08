---
titleTemplate: NitroFIT28
---

# Post Installation

Before proceeding with the post-installation steps, ensure that you have completed the initial installation process successfully. You can find the installation instructions [here](./installation.md).

## Changing the Favicon

To update the favicon, replace the following files with your custom icons:

```
public/
├── favicon.ico
└── icons/
    ├── favicon-128x128.png
    ├── favicon-96x96.png
    ├── favicon-32x32.png
    └── favicon-16x16.png
```

## Changing the Theme Variable

To change the theme color, update the page layout file `views/layouts/page.blade.php` by adding the following CSS code after the line that includes the stylesheet:

```html
<style type="text/css">
    :root {
        --blue: #007bff;
        --indigo: #6574cd;
        --purple: #9561e2;
        --pink: #f66d9b;
        --red: #e3342f;
        --orange: #f6993f;
        --yellow: #ffed4a;
        --green: #38c172;
        --teal: #4dc0b5;
        --cyan: #6cb2eb;
        --white: #fff;
        --gray: #6c757d;
        --gray-dark: #343a40;
        --primary: #007bff;
        --secondary: #6c757d;
        --success: #38c172;
        --info: #6cb2eb;
        --warning: #ffed4a;
        --danger: #e3342f;
        --light: #f8f9fa;
        --dark: #343a40;
    }
</style>
```

Your `views/layouts/page.blade.php` file should now look like this:

```html
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">

<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="keywords" content="{{ $meta_keywords ?? '' }}" />
    <meta name="description" content="{{ $meta_description ?? '' }}" />
    <meta name="author" content="{{ $url ?? config('app.url') }}" />
    <meta name="viewport" content=" width=device-width, initial-scale=1" />
    <title>
        {{ $meta_title ?? $title . ' | ' . config('app.name') }}
    </title>

    {{-- Disable Laravel Routes from Being Indexed on Google --}}
    @if (config('app.env') == 'local')
        <meta name="robots" content="noindex">
        <meta name="googlebot" content="noindex">
    @endif

    <link rel="shortcut icon" href="{{ asset('favicon.ico') }}" />
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="preconnect" href="https://cdn.coderstm.com">
    <link rel="stylesheet" type="text/css" href="https://cdn.coderstm.com/fontawesome/css/all.min.css" />
    <link rel="stylesheet" type="text/css" href="{{ asset('statics/css/styles.min.css') }}" />
    <link rel="stylesheet" type="text/css" href="{{ asset('statics/js/fullcalendar/main.min.css') }}" />

    {{-- App Style --}}
    <link rel="stylesheet" type="text/css" href="{{ theme('css/app.css', 'foundation') }}" />

    <!-- theme variables -->
    <style type="text/css">
        :root {
            --blue:#f30b4d;
            --indigo: #6574cd;
            --purple: #9561e2;
            --pink: #f66d9b;
            --red: #e3342f;
            --orange: #f6993f;
            --yellow: #ffed4a;
            --green: #38c172;
            --teal: #4dc0b5;
            --cyan: #6cb2eb;
            --white: #fff;
            --gray: #6c757d;
            --gray-dark: #343a40;
            --primary: #f30b4d;
            --secondary: #6c757d;
            --success: #38c172;
            --info: #6cb2eb;
            --warning: #ffed4a;
            --danger: #e3342f;
            --light: #f8f9fa;
            --dark: #343a40;
        }
    </style>
  
    {{-- App Script --}}
    <script src="{{ theme('js/app.js', 'foundation') }}"></script>

    {{-- Editor Styles --}}
    @yield('style')
</head>

<body>
    {{-- Editor Content --}}
    @yield('content')

    {{-- Common Footer Scripts --}}
    @include('includes.footer-script')
</body>

</html>

```
