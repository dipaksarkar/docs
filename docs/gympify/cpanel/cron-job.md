## Add Cron Jobs

Cron jobs are essential for automating tasks like running scripts or triggering specific actions at set times. Add the following cron jobs to your server:

```bash
# Run Gympify scheduler
* * * * * /usr/bin/php8.2 {project-root}/artisan schedule:run >> /dev/null 2>&1
* * * * * /usr/bin/php8.2 {project-root}/artisan queue:manager
```

Make sure to replace {project-root} with the actual path to your Gympify project.