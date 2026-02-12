# 📘 Laravel Queue + Redis + Supervisor Setup (Hestia CP)

Server Specs:

* 8 Core CPU
* 16GB RAM
* Hestia CP
* Ubuntu/Debian

---

# 1️⃣ Install Redis

## Install

```bash
apt update
apt install redis-server -y
```

Enable & start:

```bash
systemctl enable redis-server
systemctl start redis-server
```

Test:

```bash
redis-cli ping
```

Output must be:

```
PONG
```

---

## Secure Redis

Edit:

```bash
nano /etc/redis/redis.conf
```

Set:

```
supervised systemd
bind 127.0.0.1 ::1
requirepass YourStrongPasswordHere
```

Restart:

```bash
systemctl restart redis-server
```

Test with password:

```bash
redis-cli
AUTH YourStrongPasswordHere
PING
```

---

# 2️⃣ Install PHP Redis Extension

Check PHP version:

```bash
php -v
```

Example (PHP 8.2):

```bash
apt install php8.2-redis
```

Restart PHP-FPM:

```bash
systemctl restart php8.2-fpm
```

Verify:

```bash
php -m | grep redis
```

---

# 3️⃣ Configure Laravel

In `.env`:

```
QUEUE_CONNECTION=redis

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=YourStrongPasswordHere
REDIS_PORT=6379
```

Clear cache:

```bash
php artisan config:clear
php artisan cache:clear
```

Verify:

```bash
php artisan tinker
```

Then:

```php
config('queue.default');
```

Must return:

```
"redis"
```

---

# 4️⃣ Install Supervisor

```bash
apt install supervisor -y
```

Enable & start:

```bash
systemctl enable supervisor
systemctl start supervisor
```

Check:

```bash
systemctl status supervisor
```

---

# 5️⃣ Create Laravel Worker

Create config:

```bash
nano /etc/supervisor/conf.d/coderstm-worker.conf
```

### ✅ Clean Single Worker Config

```ini
[program:coderstm-worker]
command=/usr/bin/php artisan queue:work --sleep=2 --tries=3 --timeout=120
directory=/home/coderstm/web/coderstm.com/public_html
autostart=true
autorestart=true
user=coderstm
redirect_stderr=true
stdout_logfile=/home/coderstm/web/coderstm.com/public_html/storage/logs/worker.log
stopasgroup=true
killasgroup=true
stopwaitsecs=360
```

---

# 6️⃣ Activate Worker

```bash
supervisorctl reread
supervisorctl update
supervisorctl start coderstm-worker
```

Check status:

```bash
supervisorctl status
```

Expected:

```
coderstm-worker   RUNNING
```

---

# 7️⃣ If Using Multiple Workers

Change config:

```
numprocs=3
process_name=%(program_name)s_%(process_num)02d
```

Start with:

```bash
supervisorctl start coderstm-worker:*
```

---

# 8️⃣ Managing Workers

Start:

```bash
supervisorctl start coderstm-worker
```

Stop:

```bash
supervisorctl stop coderstm-worker
```

Restart:

```bash
supervisorctl restart coderstm-worker
```

Status:

```bash
supervisorctl status
```

---

# 9️⃣ Allow Hestia User To Manage Worker

Edit sudoers:

```bash
visudo
```

Add:

```
coderstm ALL=(ALL) NOPASSWD: /usr/bin/supervisorctl
```

Now user can run:

```bash
sudo supervisorctl status
```

Safest multi-user method.

---

# 🔟 Important: Remove Old Manual Workers

Before using Supervisor:

```bash
pkill -f "artisan queue:work"
```

Prevents duplicate workers.

---

# 1️⃣1️⃣ MySQL Optimization (To Prevent Old Error)

Update MySQL:

```
max_connections = 400
max_user_connections = 250
wait_timeout = 60
thread_cache_size = 64
```

Restart MySQL:

```bash
systemctl restart mysql
```

This prevents:

```
SQLSTATE[HY000] [1203] max_user_connections
```

---

# 1️⃣2️⃣ Production Best Practices

For 8 Core / 16GB:

| Traffic | Workers |
| ------- | ------- |
| Low     | 1       |
| Medium  | 2       |
| High    | 3-4     |

Never exceed 6 total workers across server.

---

# 1️⃣3️⃣ Deployment Best Practice

After deployment:

```bash
php artisan queue:restart
```

This gracefully reloads workers.

---

# 1️⃣4️⃣ Troubleshooting

### Worker not running?

Check logs:

```bash
tail -f /home/coderstm/worker.log
```

### Check Redis connections:

```bash
redis-cli info clients
```

### Check running workers:

```bash
ps aux | grep queue
```
