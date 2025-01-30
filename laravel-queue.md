# Setting Up Laravel Queue Workers with Supervisor on Ubuntu

## 1️⃣ Install Supervisor

First, ensure that **Supervisor** is installed on your system.
```bash
sudo apt update && sudo apt install supervisor -y
```
After installation, check if Supervisor is running:
```bash
sudo systemctl status supervisor
```
If it’s not running, start it:
```bash
sudo systemctl start supervisor
sudo systemctl enable supervisor
```

---

## 2️⃣ Configure Supervisor for Laravel Queues

Create a Supervisor configuration file for Laravel workers:
```bash
sudo nano /etc/supervisor/conf.d/laravel-worker.conf
```

Add the following content, adjusting paths as needed:
```ini
[program:laravel-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /path-to-your-project/artisan queue:work --sleep=3 --tries=3 --timeout=5
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www-data
numprocs=5
redirect_stderr=true
stdout_logfile=/path-to-your-project/storage/logs/worker.log
stopwaitsecs=3600
```
### **Explanation of Configuration:**
- **`numprocs=5`** → Runs 5 queue workers.
- **`--tries=3`** → Retries failed jobs 3 times before marking them failed.
- **`--timeout=5`** → Ensures jobs don't exceed 5 seconds.
- **`user=www-data`** → Runs as the web server user (change if needed).

Save and exit (`CTRL + X`, then `Y`, then `Enter`).

---

## 3️⃣ Reload and Restart Supervisor

After configuring Supervisor, reload it:
```bash
sudo supervisorctl reread
sudo supervisorctl update
```

Now, start the workers:
```bash
sudo supervisorctl start laravel-worker:*
```

To restart all workers:
```bash
sudo supervisorctl restart laravel-worker:*
```

To check worker status:
```bash
sudo supervisorctl status
```

---

## 4️⃣ Handling Common Issues

### **Supervisor Not Running?**
If you get `unix:///var/run/supervisor.sock no such file`, start Supervisor:
```bash
sudo systemctl start supervisor
```
Or restart it:
```bash
sudo service supervisor restart
```

### **Killing All Queue Workers**
To kill all queue workers:
```bash
pkill -f "queue:work"
```
Or using Supervisor:
```bash
sudo supervisorctl stop laravel-worker:*
```

### **View Logs for Debugging**
```bash
tail -f /path-to-your-project/storage/logs/worker.log
```

---

## 5️⃣ Ensure Supervisor Starts on Boot
Enable Supervisor to start on boot:
```bash
sudo systemctl enable supervisor
```

---

## 🎯 Conclusion
This setup ensures that Laravel's queue workers are **automatically managed, restarted if they fail**, and optimized for performance. If you need to tweak job execution time or worker numbers, modify the `numprocs` and `timeout` values in the configuration file.

✅ **Your Laravel queue workers are now set up and running efficiently!** 🚀