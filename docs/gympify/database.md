
### 1. Create Database User on VPS

Follow these steps to create a MySQL user with appropriate privileges for managing the database using Gympify.

#### Step 1: Login to MySQL

Log in to MySQL as the root user on your VPS:

```bash
mysql -u root
```

#### Step 2: Create a User for Both `localhost` and `%` Hosts

Run the following SQL commands to create a new user and grant full privileges on the database for both `localhost` and any host (`%`). The `localhost` user will only be able to connect from the local machine, while the `%` user can connect from any host.

```sql
-- Create user for localhost
CREATE USER 'gympify_admin'@'localhost' IDENTIFIED BY 'your-password';
GRANT ALL PRIVILEGES ON *.* TO 'gympify_admin'@'localhost' WITH GRANT OPTION;

-- Create user for any host
CREATE USER 'gympify_admin'@'%' IDENTIFIED BY 'your-password';
GRANT ALL PRIVILEGES ON *.* TO 'gympify_admin'@'%' WITH GRANT OPTION;

-- Apply changes
FLUSH PRIVILEGES;
```

Replace `'your-password'` with your desired password.

#### Step 3: Update `.env` File

After creating the user, update the `.env` file in your Gympify project to include the database credentials:

```bash
DB_DATABASE=gympify_admin
DB_USERNAME=gympify_admin
DB_PASSWORD=your-password
```

Ensure that the credentials match the values you used in the previous step.

### 2. Create Database User on cPanel Hosting

Follow these steps to create a MySQL user and database on cPanel, which can be used to manage your Gympify application's database.

#### Step 1: Generate an API Token

To automate database creation on tenant creation, generate an API token in cPanel:

1. **Log in to cPanel** as the desired user.
2. Navigate to the **"Manage API Tokens"** section.
3. Enter a name for the API token (this is for your reference).
4. Leave the expiration field **blank** (no expiration).
5. Click the **Create** button.
6. **Copy the token** and store it securely.

#### Step 2: Create a Database and User

To create the database and user:

1. **Create a Database:**
   - Enter a name for the database in the **New Database** text box and click **Next Step**.

2. **Create a Database User:**
   - Enter a name for the user in the **Username** field (only alphanumeric characters allowed).
   - Set and confirm the user's password.

3. **Grant Privileges:**
   - Select **ALL PRIVILEGES** to allow the user full access to the database.

4. **Complete the Setup:**
   - Click **Next Step** to finalize the creation of the database and user.

#### Step 3: Update `.env` File

Update the `.env` file with the following details for the database, cPanel, and tenancy configuration:

```bash
DB_DATABASE=your-database-name
DB_USERNAME=your-database-username
DB_PASSWORD=your-password

# cPanel Service
CPANEL_URL=https://s12.my-control-panel.com:2083
CPANEL_USER=your-cpanel-username
CPANEL_TOKEN=your-cpanel-token

# Tenancy Settings
TENANCY_DB_MANAGER_MYSQL=cpanel-permission-controlled
TENANCY_DB_PREFIX="${CPANEL_USER}_"
```

Replace the placeholders with the actual values:
- `your-database-name`: The name of the database you created.
- `your-database-username`: The username for the new database user.
- `your-password`: The password for the database user.
- `your-cpanel-username`: Your cPanel username.
- `your-cpanel-token`: The API token generated earlier.

#### Additional Notes:

- For **VPS environments**, ensure MySQL is configured to allow connections from external hosts, if necessary.
- For **cPanel hosting**, verify that your hosting plan supports MySQL database creation and API access.
- After updating the `.env` file, clear the Gympify config cache to apply the changes:

  ```bash
  php artisan config:clear
  ```