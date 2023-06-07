# Installation

This section will help you build a basic NitroFIT28 documentation site from ground up.

## Prerequisites

For getting started an Quasar application you needs two things as Prerequisites. 

- Node 12+ for Quasar CLI with Webpack, Node 14+ for Quasar CLI with Vite.
  - To check your node version, run `node -v` in a terminal/console window.
- Yarn v1 (strongly recommended), PNPM, or NPM.
  - To check your yarn version, run `yarn -v` in a terminal/console window.

## Server Requirements

The NitroFIT28 has a few system requirements. You should ensure that your web server has the following minimum PHP version and extensions:

- Apache, nginx, or another compatible web server.
- PHP >= 8.0
- BCMath PHP Extension
- Ctype PHP Extension
- cURL PHP Extension
- DOM PHP Extension
- Fileinfo PHP Extension
- JSON PHP Extension
- Mbstring PHP Extension
- OpenSSL PHP Extension
- PCRE PHP Extension
- PDO PHP Extension
- Tokenizer PHP Extension
- XML PHP Extension

::: warning
On this project, we're using the latest Laravel version (currently 9.x). Please go to [Laravel documentation](https://laravel.com/docs) page for more information.

It’s based on Laravel framework, the root folder for it is /public. You shouldn’t install it on a sub-folder, use sub-domain is better than sub-folder. (we won’t support to install our product on sub-folder).
:::

## Installing Quasar CLI

You use the Quasar CLI to create projects, generate application and library code, and perform a variety of ongoing development tasks as it is a progressive framework for building user interfaces.

Install the Quasar CLI globally.

To install the CLI using npm, open a terminal/console window and enter the following command:

```
yarn global add @quasar/cli
```

::: warning
On this project, we're using the latest Quasar version (currently 2.x). Please go to [Quasar documentation](https://quasar.dev/start/quasar-cli) page for more information.
:::

## Create Subdomains

You will need to create there subdomain with document root `public_html/public` for api, admin and members as follows:

```
api.your_app_domain.com
admin.your_app_domain.com
members.your_app_domain.com
```

::: warning
This different for different hosting service provider. Please go to [How to create a subdomain](https://www.namecheap.com/support/knowledgebase/article.aspx/9190/29/how-to-create-a-subdomain-in-cpanel/) for cPanel based hosting provider.
:::

## Build Application

- Open a terminal/console window and enter the following command:

```
cp .env.example .env
cp .env.frontend .env.frontend.prod
```

- Change `.env.frontend.prod`

```
APP_ENV=Production
APP_NAME=NitroFIT28
APP_DEBUG=false
APP_CURRENCY=$
API_URL=https://api.your_app_domain.com
PRIVACY_URL=https://your_app_domain.com/privacy
TERMS_URL=https://your_app_domain.com/terms
STRIPE_KEY=pk_test_XXXXXXXXXXXXXXXXXXXXXXX
```

- Build > Open a terminal/console window and enter the following command:

```
yarn install
yarn build:prod
```

## Install Procedure (Video)

<iframe width="100%" height="360" src="https://www.youtube-nocookie.com/embed/QIC4nNRFogY" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Install via GUI

- Create database and Upload all files into the root folder of your hosting (normally, it is public_html). Without followings:
  - `/dist`
  - `/node_modules`
- Go to [your_app_domain.com/install] to start installation.
- Step by step to setup your database conntection, site information and administrator.
- Login and setup your website on Welcome Board.

## Remove Dummy Data

Open the SSH terminal on your machine and run the following command: 

```
ssh your_username@host_ip_address
```

Type in your password and hit Enter.

```
cd nitrofit28_root_path
php artisan migrate:fresh --force
```