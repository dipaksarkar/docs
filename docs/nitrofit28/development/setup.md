---
titleTemplate: NitroFIT28
---

# NitroFIT28 Developer Documentation

We use [Laravel Valet](https://laravel.com/docs/11.x/valet) for local deployment. Laravel Valet is a development environment for Mac minimalists that allows you to run sites without the hassle of Vagrant or modifying the `/etc/hosts` file. 

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

::: warning
On this project, we're using the latest Quasar version (currently 2.x). Please go to [Quasar Capacitor documentation](https://quasar.dev/quasar-cli-vite/developing-capacitor-apps/introduction) page for more information.
:::

## Add Configuration
Set up your environment files by copying the example files:
```bash
yarn
yarn gen:env
```

Update your `.env.frontend.dev` file with your details:
```
APP_ENV=Development
APP_NAME="NitroFIT28"
APP_DEBUG=true
HOST_NAME=nitrofit28.test
PORT=9001
```

## Migrate the Database
Update your `.env` file with your database details:
```
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=nitrofit28
DB_USERNAME=root
DB_PASSWORD=password
```
Then, run the following command to migrate the database:
```bash
yarn fresh:dev
```

## Start the App in Development Mode
To start the app in development mode with hot-code reloading and error reporting, use:
```bash
yarn start:web
```
## Generate Language Files with `yarn gen:lang`

The `yarn gen:lang` command is used to generate language files for your application. It runs a series of commands provided by the **quasalang** package to ensure that your localization files are up-to-date and properly structured. This command performs three main tasks:

1. **Generate the language structure**.
2. **Translate existing phrases**.
3. **Compile the generated language files**.

### Command Definition

In your `package.json`, the `gen:lang` script is defined as follows:

```json
"gen:lang": "quasalang p && quasalang t && quasalang g --force"
```

### Breakdown of the Command

- `quasalang p`: This command prepares the necessary files and directories for the language structure.
- `quasalang t`: This command translates existing phrases in your application to the desired languages. Make sure your source phrases are defined before running this command.
- `quasalang g --force`: This command generates the final language files, overriding any existing files if necessary due to the `--force` flag.

### Usage

To run the command and generate your language files, execute the following in your terminal:

```bash
yarn gen:lang
```

### Additional Information

For more details on the **quasalang** package and its functionalities, please refer to the [quasalang README](https://github.com/dipaksarkar/quasalang/blob/master/README.md).