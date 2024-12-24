## Setup Database & User

Follow these steps to create a MySQL user and database on cPanel, which can be used to manage your Laravel application's database.

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
CPANEL_URL=https://your-cpanel-server.com:2083
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
