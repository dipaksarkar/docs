## Add Cron Jobs

Cron jobs are essential for automating tasks like running scripts or triggering specific actions at set times. Add the following cron jobs to your server:

```bash
# Run Laravel scheduler
* * * * * /usr/bin/php8.2 {project-root}/artisan schedule:run >> /dev/null 2>&1
```

Make sure to replace {project-root} with the actual path to your Laravel project.