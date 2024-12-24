## Build Application

To build the frontend application on your development machine, follow these steps:

1. Open a terminal and navigate to the project path:

```bash
cd /path/to/your/machine/gympify
```

2. Execute the following commands in a terminal/console window:

```bash
cp .env.example .env
cp .htaccess.example .htaccess
```

3. (Optional) Modify `.env.frontend.prod`:

```bash
...
APP_ENV=Production
APP_NAME=Gympify
....
```

4. (Optional) Build the application by executing the following commands:

```bash
yarn install
yarn build:prod
```