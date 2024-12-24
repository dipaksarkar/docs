## Install via GUI

- Upload all files into the root folder of your hosting (normally, it is `public_html`). Exclude the following folders:
  ```
    /dist
    /node_modules
    /src
    /src-capacitor
    /statics
  ```
- Go to [your-domain-name.com/install] to start the installation process.
- Follow the step-by-step instructions to set up your database connection, site information, and administrator account.
- Login and configure your website using the Welcome Board.

## Enable Tenant Theme Builder

To enable the tenant theme builder, you need to run `npm install` in the `public_html` directory:

1. Open the SSH terminal on your machine and run the following command:

```bash
ssh username@your-domain.com
```

2. **Run the following command** to install the necessary packages:

```bash
cd public_html
npm install
```

This will ensure that all dependencies are installed correctly for theme building.