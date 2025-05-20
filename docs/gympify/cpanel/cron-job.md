## Add Cron Jobs

Cron jobs are scheduled tasks that run at predefined times or intervals on your server. They are essential for Gympify to automate critical processes such as subscription management, scheduled notifications, and maintenance tasks.

### Setting Up Cron Jobs in cPanel

1. **Log in to your cPanel account**

2. **Find the Cron Jobs section**
   - Navigate to the "Advanced" section and click on "Cron Jobs"
   
   ![cPanel Cron Jobs Section](/gympify/cpanel-cron-job.png)

3. **Add a new cron job**
   - Select "Once Per Minute" from the Common Settings dropdown
   - In the Command field, enter:

```bash
# Run Gympify scheduler
/usr/bin/php /home/username/public_html/artisan schedule:run >> /dev/null 2>&1
/usr/bin/php /home/username/public_html/artisan queue:manager >> /dev/null 2>&1
```

Replace `/home/username/public_html` with the actual path to your Gympify installation. If you're unsure about your PHP path, you can use this command instead:

```bash
/usr/bin/env php /home/username/public_html/artisan schedule:run >> /dev/null 2>&1
/usr/bin/env php /home/username/public_html/artisan queue:manager >> /dev/null 2>&1
```

### Troubleshooting Common Issues

- **Incorrect PHP Path**: If you're getting errors, try to find the correct PHP path using SSH with the command `which php`
- **Permission Issues**: Make sure the user running the cron job has appropriate permissions
- **Path Problems**: Ensure you're using absolute paths to your Gympify installation

For advanced setups or dedicated servers, you might want to consider using Supervisor to manage your queue workers more efficiently.


