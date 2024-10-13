---
titleTemplate: Gympify

---

# Build Apps

This section provides a step-by-step guide to setting up a basic Gympify app using Quasar from scratch.

## Prerequisites

Before you begin, make sure you have the following tools installed:

1. **Node.js**:
   - **Node.js 12+** (for Quasar CLI with Webpack) or **Node.js 14+** (for Quasar CLI with Vite).
   - To verify your Node.js version, run the command: `node -v`.

2. **Package Manager**:
   - **Yarn v1** (strongly recommended), PNPM, or NPM.
   - To check your Yarn version, run: `yarn -v`.

## Installing Quasar CLI

The Quasar CLI is a powerful tool for creating projects, generating application and library code, and managing development tasks.

To install Quasar CLI globally, run the following commands:

```bash
yarn global add @quasar/cli
yarn global add @quasar/icongenie
yarn global add https://github.com/dipaksarkar/quasalang
```

::: tip Info
We are using the latest version of Quasar (currently 2.x). For more detailed guidance, visit the official [Quasar Capacitor documentation](https://quasar.dev/quasar-cli-vite/developing-capacitor-apps/introduction).
:::

## Configuring the Application

### Modify the `.env.frontend.app-prod` File

You will need to update the `.env.frontend.app-prod` file to configure environment-specific settings for your app:

```plaintext
# .env.frontend.app-prod
# These values will be accessible in the client application.

APP_ENV="Production"
APP_NAME="Gympify"
APP_MODE=app
API_URL=https://fitpro.gympify.com/api # API endpoint of the tenant you're building the app for.
```

Here’s the updated section with the note added for clarity:

```plaintext
# .env.frontend.app-prod
# These values will be accessible in the client application.

APP_ENV="Production"
APP_NAME="Gympify"
APP_MODE=app
API_URL=https://fitpro.gympify.com/api # API endpoint of the tenant you're building the app for.
```

::: tip Info
In the `API_URL`, `{fitpro}` represents the primary domain of the tenant, and `{gympify.com}` is the domain where the Gympify app is installed. Make sure to replace these with the actual tenant and app domains you're working with.
:::

::: warning
To enable push notifications for your app, you'll need to [Configure Firebase](./firebase). Ensure you have it set up correctly to make notifications work.
:::

## Building the Mobile Application

### Android & iOS Build Instructions

To build the app for Android or iOS, follow these steps:

::: code-group

```bash [Android]
yarn install
npm run build:android --env=prod
```

```bash [iOS]
yarn install
npm run build:ios --env=prod
```

:::

::: warning
Before proceeding with the actual development, ensure you’ve completed the necessary preparation. Visit [Preparation for Capacitor App](https://quasar.dev/quasar-cli-vite/developing-capacitor-apps/preparation) for more details.
:::

This improved version simplifies the instructions, enhances readability, and ensures the user follows a structured approach from setup to building the application.