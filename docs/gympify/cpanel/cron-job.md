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
```

Replace `/home/username/public_html` with the actual path to your Gympify installation. If you're unsure about your PHP path, you can use this command instead:

```bash
/usr/bin/env php /home/username/public_html/artisan schedule:run >> /dev/null 2>&1
```

### Additional Configuration for Shared Hosting

If you're using cPanel shared hosting, you need to enable the queue manager. This process is handled in two steps:

1. **Enable the queue manager in the application code**
   
   In your Gympify installation, open `app/Console/Kernel.php` and uncomment the following line:
   
   ```php
   // If deploying on cPanel shared hosting, uncomment the line below to run the queue manager every minute.
   $schedule->command('queue:manager')->everyMinute();
   ```

2. **Verify cron job execution**

   After setting up your cron job, wait a few minutes and check if it's running properly. You can verify this by looking at the application logs or checking if scheduled tasks are being performed.

### Troubleshooting Common Issues

- **Incorrect PHP Path**: If you're getting errors, try to find the correct PHP path using SSH with the command `which php`
- **Permission Issues**: Make sure the user running the cron job has appropriate permissions
- **Path Problems**: Ensure you're using absolute paths to your Gympify installation

For advanced setups or dedicated servers, you might want to consider using Supervisor to manage your queue workers more efficiently.


