
## Setup Database & User

Follow these steps to create a MySQL user with appropriate privileges for managing the database using Laravel.

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

After creating the user, update the `.env` file in your Laravel project to include the database credentials:

```bash
DB_DATABASE=gympify_admin
DB_USERNAME=gympify_admin
DB_PASSWORD=your-password
```

Ensure that the credentials match the values you used in the previous step.
