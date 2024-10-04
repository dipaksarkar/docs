---
titleTemplate: NitroFIT28
---

# Scripts Guide

This document provides an overview of the key scripts available in the `package.json` file of the **NitroFIT28** project. These scripts streamline various development, build, and deployment tasks to ensure efficient project management.

## Build Scripts

### `build:prod`
```bash
npm run build:prod
```
Generates a production build of the application using Quasar, including app icon generation and other necessary assets. The production environment variables from `.env.frontend.prod` are used.

### `build:alpha`
```bash
npm run build:alpha
```
Creates a build for the **alpha** environment, running the application in development mode with app icon generation. It uses environment variables from `.env.frontend.alpha`.

### `build:dev`
```bash
npm run build:dev
```
Builds the application in **development** mode, generating app icons and running Quasar for real-time development. It uses environment variables from `.env.frontend.dev`.

### `build:android`
```bash
npm run build:android --env={alpha}
```
Builds the application for **Android** using Capacitor. It generates app icons and sets the appropriate environment (`alpha`, `prod`, etc.) by loading environment variables from `.env.frontend.{env}`.

### `build:ios`
```bash
npm run build:ios --env={alpha}
```
Builds the application for **iOS** using Capacitor. Similar to Android, it creates app icons and uses the specified environment from `.env.frontend.{env}`.

## Utility Scripts

### `make:app-icons`
```bash
npm run make:app-icons
```
Generates app icons based on the project's configured splash screen and theme colors, ensuring consistency across platforms.

### `make:icons`
```bash
npm run make:icons
```
Creates icons using the configuration defined in the `./icongenie-icon.json` file, optimizing for different sizes and platforms.

### `make:ssl`
```bash
npm run make:ssl
```
Generates and installs SSL certificates using **mkcert** for the host defined in the project configuration. You must have **mkcert** installed on your system for this command to work.

## Database & Environment Setup

### `fresh`
```bash
npm run fresh
```
Runs Laravel's Artisan command to **refresh** the database by dropping all existing tables and re-seeding them. Ideal for setting up a clean environment for development or testing.

### `gen:lang`
```bash
npm run gen:lang
```
Generates language translation files using the **quasalang** package to ensure the application’s localization is up-to-date.

Parse your source files from (`/src/**/*.{js,vue}`) and Add them to (`/translations.csv`) as Default language. Then Translate your CSV file using Google translate

#### Example

Given the following label in your source files:

```html
<base-label>{{ $t("// Phone Number") }}</base-label>
or
<base-label>{{ $t("// label::Phone Number") }}</base-label>
```

The command will convert them to:

```html
<base-label>{{ $t("phoneNumber") }}</base-label>
or
<base-label>{{ $t("label.phoneNumber") }}</base-label>
```

The corresponding translation key will be added to `translations.csv`:

```
phoneNumber,"Phone Number"
or
label.phoneNumber,"Phone Number"
```

For more details on the **quasalang** package and its functionalities, please refer to the [quasalang docs](https://github.com/dipaksarkar/quasalang/blob/master/README.md).

### `gen:env`
```bash
npm run gen:env
```
Copies the appropriate frontend environment files (`.env.frontend`) into their correct locations, setting up the environment configurations for different build processes.

## Start Scripts

### `start:web`
```bash
npm run start:web
```
Starts the web application in **development** mode using Quasar with hot-reloading enabled for a smooth development experience.

### `start:android`
```bash
npm run start:android --env={alpha}
```
Launches the Android application in **development** mode using Quasar and Capacitor. It runs the app with the specified environment variables from `.env.frontend.{env}`.

### `start:ios`
```bash
npm run start:ios --env={alpha}
```
Starts the iOS application in **development** mode with Quasar and Capacitor, loading environment variables from `.env.frontend.{env}`.

### `start:queue`
```bash
npm run start:queue
```
Starts the Laravel **queue worker** to process background jobs, ensuring asynchronous tasks like email sending and notifications are handled efficiently.

## Theme Management Scripts

### `theme:dev`
```bash
npm run theme:dev --name={theme-name}
```
Builds the theme in **development** mode for real-time updates and hot reloading. This uses the specific theme configuration defined in the project.

### `theme:build`
```bash
npm run theme:build --name={theme-name}
```
Compiles and builds the theme for **production**, using the defined mix configuration. This ensures optimized and minified assets for faster load times.