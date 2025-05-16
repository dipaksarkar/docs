
## Setup Database & User

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
