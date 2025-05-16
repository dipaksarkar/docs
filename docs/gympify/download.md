## Download and Setup Application

To set up the application on your development machine, follow these steps:

1. **Download the latest version of Gympify:**
   
    Visit the [GitHub Release](https://github.com/coders-tm/gympify/releases/latest) page.
    
    Ensure you are logged in with the correct account and have access to the repository. If you do not have access, please contact the repository owner.
    
    Navigate to **Assets** and download **Gympify_v2.6.1.zip**.
    
    ![Download Gympify](/gympify/release.png)

2. **Upload the zipped file to your server:**
    - Use an FTP client (like FileZilla) to upload the zipped file to your server.
    - Unzip the file on your server. You can use the following command:
        ```bash
        unzip Gympify_v2.6.1.zip
        ```
    - If you are using cPanel, you can unzip the file directly from the File Manager.

3. **Copy configuration files:**
   
    Copy `.env.example` to `.env`:
    
    ```bash
    cp .env.example .env
    ```
    
    Copy `.htaccess.example` to `.htaccess`:
    
    ```bash
    cp .htaccess.example .htaccess
    ```
4. **Update the .env file:**
   
    Open the `.env` file in a text editor and update the following lines:
    
    ```bash
    APP_DOMAIN=your-domain-name.com
    ```
    
    Replace `your-domain-name.com` with your actual domain name.