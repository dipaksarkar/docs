---
titleTemplate: NitroFIT28
---

# Scripts 

This document outlines the various scripts available in the `package.json` file of the NitroFIT28 project. These scripts simplify development tasks, build processes, and deployment actions.


## `dev`
```bash
npm run dev
```
Cleans the build artifacts and compiles the assets using Laravel Mix for development.

## `build`
```bash
npm run build
```
Cleans the build artifacts and compiles the assets using Laravel Mix for production.

## `build:clean`
```bash
npm run build:clean
```
Cleans old build artifacts, including files in the `public/assets`, `public/pdfjs`, and the `public/mix-manifest.json`.

## `build:prod`
```bash
npm run build:prod
```
Builds the application for production using Quasar, generates app icons, and executes any necessary builds.

## `build:alpha`
```bash
npm run build:alpha
```
Builds the application for the alpha environment, generates app icons, and runs in development mode.

## `build:dev`
```bash
npm run build:dev
```
Builds the application in development mode, generates app icons, and runs Quasar in development.

## `build:android`
```bash
npm run build:android
```
Builds the application for Android using Capacitor, creating the necessary app icons and setting the build mode.

## `build:ios`
```bash
npm run build:ios
```
Builds the application for iOS using Capacitor, creating the necessary app icons and setting the build mode.

## `make:app-icons`
```bash
npm run make:app-icons
```
Generates app icons using the specified splash screen and theme color.

## `make:icons`
```bash
npm run make:icons
```
Generates icons from the configuration defined in `./icongenie-icon.json`.

## `make:ssl`
```bash
npm run make:ssl
```
Generates and installs SSL certificates using mkcert for the specified host defined in the project configuration.

## `fresh`
```bash
npm run fresh
```
Runs Laravel's artisan command to refresh the database, dropping all tables and re-seeding it.

## `gen:lang`
```bash
npm run gen:lang
```
Generates language files using the `quasalang` package, ensuring that localization is properly set up for the application.

## `gen:env`
```bash
npm run gen:env
```
Sets up environment configuration files by copying the frontend environment files into the appropriate locations.

## `start:web`
```bash
npm run start:web
```
Starts the web application in development mode with hot-reloading using Quasar.

## `start:android`
```bash
npm run start:android --env={alpha}
```
Starts the Android application in development mode using Quasar and Capacitor.

## `start:ios`
```bash
npm run start:ios --env={alpha}
```
Starts the iOS application in development mode using Quasar and Capacitor.

## `start:queue`
```bash
npm run start:queue
```
Starts the Laravel queue worker to process jobs in the background.

## `theme:dev`
```bash
npm run theme:dev --name={theme-name}
```
Builds the theme in development mode, allowing for hot reloading using the specified mix configuration.

## `theme:build`
```bash
npm run theme:build --name={theme-name}
```
Builds the theme for production using the specified mix configuration.
