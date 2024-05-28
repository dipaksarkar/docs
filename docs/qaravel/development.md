# Development

This section will guide you through setting up a basic Qaravel documentation site from scratch.

## Prerequisites

To get started with a Quasar application, you need to ensure you have the following prerequisites:

1. **Node 12+ for Quasar CLI with Webpack**, or **Node 14+ for Quasar CLI with Vite**.
   - To check your Node.js version, run `node -v` in a terminal/console window.
2. **Yarn v1 (strongly recommended)**, PNPM, or NPM.
   - To check your Yarn version, run `yarn -v` in a terminal/console window.

### How to deply it in local?

Valet is a Laravel development environment for Mac minimalists. No Vagrant, no /etc/hosts file. You
can even share your sites publicly using local tunnels. Yeah, we like it too. We used valet to
deploy this project. Check the configuration of [Laravel Valet](https://laravel.com/docs/11.x/valet)

### Customize the configuration

See [Configuring quasar.conf.js](https://quasar.dev/quasar-cli/quasar-conf-js).

::: info
For Qaravel installation, please refer to the [Installation Guide](/qaravel/installation) for detailed instructions.
:::

::: info
For upgrading your existing Qaravel installation, please refer to the [Upgrade Guide](/qaravel/upgrade) for detailed instructions.
:::

::: warning
Configuring your Stripe account is essential to make the subscription system functional. However, if you choose not to accept payments via credit card, you must still configure your Stripe account for other payment methods or functionality.
:::

## Install the dependencies

```bash
yarn global add @quasar/cli
yarn global add @quasar/icongenie
yarn global add https://github.com/dipaksarkar/quasalang
yarn
```

## Add Configuration

```bash
cp .env.example .env
cp .env.frontend .env.frontend.dev
cp .env.frontend .env.frontend.prod
cp .env.frontend.app-dev .env.frontend.app-prod
cp qaravel.config.example.js qaravel.config.js

```

## Migrate the Database

Add your database details on .env

```
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=qaravel
DB_USERNAME=root
DB_PASSWORD=password
```

```bash
yarn fresh
```

## Start the app in development mode (hot-code reloading, error reporting, etc.)

```bash
yarn start:web
```

## Generate Modules

::: info
For Qaravel config, please refer to the [Config Guide](/qaravel/config) for detailed instructions.
:::

```bash
yarn qaravel generate // skip already generated
yarn qaravel generate --force // replace already generated
```
