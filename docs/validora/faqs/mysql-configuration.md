---
titleTemplate: Validora
---

# MySQL Configuration for Validora

## Understanding the "MySQL server has gone away" Error

If you encounter the "MySQL server has gone away" error during Validora installation or operation, it indicates that MySQL has insufficient resources allocated to process large data transfers or long-running queries. This commonly happens during:

- Initial installation when importing large datasets
- Running bulk email verification processes
- Generating extensive reports

This error occurs because MySQL has default timeout and packet size settings that are too restrictive for data-intensive operations like those performed by Validora.

## How to Fix MySQL Configuration

The most effective solution is to modify your MySQL configuration file to increase resource limits and timeout values.

### Step 1: Locate Your MySQL Configuration File

The MySQL configuration file is typically named `my.cnf` or `mysql.ini` and can be found in one of these common locations:

```
/etc/my.cnf
/etc/mysql/my.cnf
$MYSQL_HOME/my.cnf
[datadir]/my.cnf
~/.my.cnf
```

If you can't find the file, use one of these commands in your terminal:

```bash
locate my.cnf
whereis my.cnf
find / -name my.cnf
```

### Step 2: Modify Configuration Parameters

Once you've located the configuration file, open it with a text editor (you'll need root/sudo access):

```bash
sudo nano /etc/mysql/my.cnf
```

Add or modify the following parameters in the `[mysqld]` section:

```ini
[mysqld]
max_allowed_packet = 64M
wait_timeout = 600
interactive_timeout = 600
net_read_timeout = 600
net_write_timeout = 600
```

Key parameters explained:

- **max_allowed_packet**: Controls the maximum size of a single packet. Increase to 16M, 64M, or even 128M depending on your server memory.
- **wait_timeout**: The number of seconds the server waits for activity on a non-interactive connection before closing it.
- **interactive_timeout**: Similar to wait_timeout but for interactive connections.
- **net_read_timeout**: Seconds to wait for more data from a connection before aborting the read.
- **net_write_timeout**: Seconds to wait for a block to be written to a connection before aborting the write.

### Step 3: Restart MySQL Server

After saving your changes, restart the MySQL server to apply the new configuration:

```bash
sudo systemctl restart mysql
# OR
sudo service mysql restart
# OR
sudo /etc/init.d/mysql restart
```

## Additional MySQL Optimizations for Validora

For optimal performance, consider these additional MySQL settings:

### InnoDB Settings

If you're using InnoDB (the default MySQL storage engine), add these settings:

```ini
[mysqld]
innodb_buffer_pool_size = 1G
innodb_log_file_size = 256M
innodb_flush_log_at_trx_commit = 2
innodb_flush_method = O_DIRECT
```

Adjust the `innodb_buffer_pool_size` based on your server's available memory. A good rule of thumb is to allocate 50-70% of your server's RAM if MySQL is the primary service.

### Query Cache Settings

For servers with high read operations:

```ini
[mysqld]
query_cache_type = 1
query_cache_size = 64M
query_cache_limit = 2M
```

## Troubleshooting After Configuration Changes

If you continue to experience issues after modifying your MySQL configuration:

1. **Check MySQL Error Logs**:

   ```bash
   sudo tail -f /var/log/mysql/error.log
   ```

2. **Verify Configuration Was Applied**:

   ```bash
   mysql -u root -p -e "SHOW VARIABLES LIKE 'max_allowed_packet';"
   ```

3. **Ensure Sufficient System Resources**:
   - Check that your server has enough free memory
   - Verify that disk space is not critically low

4. **Consider Using Database Connection Pooling**:
   If you're running a high-traffic Validora installation, implementing connection pooling can help manage database connections more efficiently.

## Conclusion

Properly configuring MySQL is crucial for Validora's performance, especially when handling large email verification tasks. By increasing timeouts and packet size limits, you can prevent "MySQL server has gone away" errors and ensure smooth operation.

Remember to monitor your MySQL server's performance after making these changes and adjust settings as needed based on your specific usage patterns and server capabilities.
