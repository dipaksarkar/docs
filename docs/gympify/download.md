## Download and Setup Application

To set up the application on your development machine, follow these steps:

1. **Download the latest version of Gympify:**
   
    Visit the [GitHub Release](https://github.com/coders-tm/gympify/releases/latest) page.
    
    Ensure you are logged in with the correct account and have access to the repository. If you do not have access, please contact the repository owner.
    
    Navigate to **Assets** and download **Gympify_v2.4.zip**.
    
    ![Download Gympify](/gympify/release.png)

2. **Extract the downloaded zip file:**
   
    Extract the zip file to a temporary location on your machine. You will find the following file structure:
    ```
    gympify_v2.4
    ├── app
    ├── bootstrap
    ├── config
    ├── database
    ├── lib
    ├── modules
    ├── public
    ├── resources
    ├── routes
    ├── src
    ├── src-capacitor
    ├── statics
    ├── storage
    ├── tenant
    ├── themes
    ├── vendor
    ├── .env.example
    ├── .htaccess.example
    ├── artisan
    ├── composer.json
    ├── composer.lock
    ├── index.html
    ├── package.json
    ├── quasar.config.js
    ├── quasar.extensions.json
    ├── README.md
    ├── webpack.mix.js
    ├── webpack.quasar.mix.js
    ├── webpack.theme.mix.js
    └── yarn.lock
    readme.html
    ```

3. **Copy configuration files:**
   
    Copy `.env.example` to `.env`:
    
    ```bash
    cp .env.example .env
    ```
    
    Copy `.htaccess.example` to `.htaccess`:
    
    ```bash
    cp .htaccess.example .htaccess
    ```

