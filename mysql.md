## Create User
CREATE USER 'admin'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

ALTER USER 'root'@'localhost' IDENTIFIED BY 'password';
FLUSH PRIVILEGES;

CREATE USER 'admin'@'127.0.0.1' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'127.0.0.1' WITH GRANT OPTION;
FLUSH PRIVILEGES;

## Import Database
mysql -u root shoparket_production < /home/shoparket/shoparket_production.sql
mysql -u root shoparket_dipak < /home/shoparket/shop_dipak.sql

## Phpmyadmin, root permissions and view all databases
CREATE USER 'gympify_admin'@'localhost' IDENTIFIED BY 'uw!?Z@eo9^6Bd*R';
GRANT ALL PRIVILEGES ON *.* TO 'gympify_admin'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;

I managed to do it by successfully creating a new user and giving it privileges.
The problem with the first attempt with this technique was bad writing, I missed the asterisks between the .

Do not waste time trying to give root access directly, for me it was impossible, I needed to create a new user as indicated above.

The problem that users will have to log in to each database they have remains unresolved and this is undoubtedly the worst.
Not to mention the impossibility of reusing users-db.

I will continue investigating ‘by myself’