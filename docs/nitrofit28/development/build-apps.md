---
titleTemplate: NitroFIT28
---

# Build Apps

This section will guide you through setting up a basic NitroFIT28 documentation site from scratch.

## Prerequisites

To get started with a Quasar application, you need to ensure you have the following prerequisites:

1. **Node 12+ for Quasar CLI with Webpack**, or **Node 14+ for Quasar CLI with Vite**.
   - To check your Node.js version, run `node -v` in a terminal/console window.
2. **Yarn v1 (strongly recommended)**, PNPM, or NPM.
   - To check your Yarn version, run `yarn -v` in a terminal/console window.

## Installing Quasar CLI

The Quasar CLI is used for project creation, generating application and library code, and various development tasks.

Install the Quasar CLI globally:

```bash
yarn global add @quasar/cli
yarn global add @quasar/icongenie
yarn global add https://github.com/dipaksarkar/quasalang
```

::: tip
On this project, we're using the latest Quasar version (currently 2.x). Please go to [Quasar Capacitor documentation](https://quasar.dev/quasar-cli-vite/developing-capacitor-apps/introduction) page for more information.
:::

## Build Apps

#### Modify `.env.frontend.app-prod`

```
# This is your .env.frontend.app-prod file
# The data added here will be propagated to the client
# example:
# PORT=9000
APP_ENV="Production"
APP_NAME="NitroFIT28"
APP_MODE=app
API_URL=https://api.your-domain-name.com
```

::: warning
To send push notifications to your users you need to [Configure Firebase](./firebase) to make it work.
:::

#### Build the andorid application by executing the following commands

::: code-group

```bash [Android]
yarn install
npm run build:android --env=prod
```

```bash [IOS]
yarn install
npm run build:ios --env=prod
```

:::


::: warning
Before we dive in to the actual development, we need to do some preparation work. Please go to [Preparation for Capacitor App](https://quasar.dev/quasar-cli-vite/developing-capacitor-apps/preparation) page for more information.
:::