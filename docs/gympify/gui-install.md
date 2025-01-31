## Install via GUI

1. Upload all files to the root folder of your hosting (usually `public_html`). Exclude the following folders:
    ```
    /src
    /src-capacitor
    /statics
    ```
2. Visit [your-domain-name.com/install] to begin the installation process.
3. Follow the step-by-step instructions to set up your database connection, site information, and administrator account.
4. Log in and configure your website using the Welcome Board.
5. Now you can access tenant dashboard and central admin dashboard using following URLs:
    ```
    Tenant Dashboard: [admin.your-domain-name.com]
    Central Admin Dashboard: [app.your-domain-name.com]
    ```
    
    Credentials for the central admin dashboard are:
    ```
    Email: your email that you have used during installation
    Password: Pa$$w0rd!
    ```

## Enable Tenant Theme Builder

To enable the tenant theme builder, run `npm install` in the `public_html` directory:

1. Open the SSH terminal on your machine and run:

    ```bash
    ssh username@your-domain.com
    ```

2. Navigate to the `public_html` directory and install the necessary packages:

    ```bash
    cd public_html
    npm install
    ```

3. Update the NPM bin path in the `.env` file:

    ```bash
    NPM_BIN_PATH=your-path-to-npm-bin 
    ```

    Replace `your-path-to-npm-bin` with the actual path to the npm bin directory (e.g., `/home/username/.nvm/versions/node/v18.20.3/bin`).
