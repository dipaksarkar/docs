# Fixing 500/502/504 Gateway Timeouts

When running Bouncify on a new VPS setup, you might encounter 500, 502, or 504 gateway timeout errors, particularly during scan or import operations. These errors occur when your server takes too long to respond to requests.

## Common Causes

1. **PHP Timeout Settings**: Default PHP timeout values are too low for processing large email lists
2. **Web Server Timeout Configuration**: Nginx/Apache timeout settings need adjustment
3. **Memory Limitations**: Insufficient memory allocation for PHP processes
4. **MySQL Configuration**: Suboptimal database settings for large operations
5. **System Resource Constraints**: CPU/memory limitations on your VPS

## Solutions

### PHP Configuration Adjustments

Edit your `php.ini` file to increase timeout and memory limits:

```ini
max_execution_time = 3600     ; Increase to 3600 seconds or more
memory_limit = 512M          ; Increase to 512MB or more
post_max_size = 100M         ; Increase for larger uploads
upload_max_filesize = 100M   ; Increase for larger uploads
```

For CLI operations (used in background tasks):

```ini
max_execution_time = 0       ; 0 means no time limit for CLI operations
```

### Nginx Configuration

Edit your Nginx site configuration:

```nginx
server {
    # Other configuration...
    
    client_max_body_size 100M;
    proxy_connect_timeout 300s;
    proxy_send_timeout 300s;
    proxy_read_timeout 300s;
    fastcgi_read_timeout 300s;
    
    # Other configuration...
}
```

### Apache Configuration

If using Apache, edit your `.htaccess` file or VirtualHost configuration:

```apache
# .htaccess
php_value max_execution_time 300
php_value memory_limit 512M
php_value post_max_size 100M
php_value upload_max_filesize 100M

# Or in VirtualHost
<VirtualHost *:80>
    # Other settings...
    Timeout 300
    ProxyTimeout 300
    # Other settings...
</VirtualHost>
```

### System-Level Considerations

1. **VPS Resources**: Ensure your VPS has adequate resources (minimum 2GB RAM recommended)
2. **Swap Memory**: Configure swap space to prevent out-of-memory errors
3. **Monitor Resources**: Set up monitoring to identify bottlenecks during processing

## Testing Your Configuration

After making changes, test your configuration:

```bash
php -i | grep max_execution_time
php -i | grep memory_limit
```

## Still Having Issues?

If you're still encountering timeout errors after these adjustments:

1. Check your server logs for specific error messages
2. Consider increasing the number of queue workers
3. Split large email lists into smaller batches
4. Contact your hosting provider to ensure your VPS doesn't have additional limitations

For persistent issues, consider upgrading your VPS resources or optimizing your database with [MySQL Configuration](/bouncify/faqs/mysql-configuration).
