---
titleTemplate: Mailzor
---

# Queue Monitoring

Mailzor's high-performance sending engine relies on Laravel's queue system. We use **Laravel Horizon** to provide a beautiful, real-time dashboard for monitoring background jobs.

## Accessing Horizon

The Horizon dashboard is available at:
`https://your-domain.com/admin/horizon`

::: important
Horizon is only accessible to users with the **Super Admin** role.
:::

## Real-time Metrics

Horizon provides visibility into:
- **Throughput**: How many jobs are being processed per minute.
- **Wait Time**: How long jobs are sitting in the queue before being picked up.
- **Failures**: Real-time logging of any job that encounters an error.

## Queue Architecture

Mailzor uses multiple dedicated queues to prioritize traffic:

| Queue | Purpose | Priority |
| :--- | :--- | :--- |
| **emails** | High-priority individual email sends (2FA, reset). | Highest |
| **campaigns** | Bulk email campaign sends and batching. | Medium |
| **validations** | Background email validation jobs. | Medium |
| **default** | General tasks like CSV imports and report generation. | Low |

## Managing Failed Jobs

If a job fails (e.g., SES API timeout or SMTP connection error):
1. It is logged in the **Failed Jobs** tab of Horizon.
2. You can view the full exception stack trace.
3. You can manually **Retry** the job once the underlying issue is resolved.

## Scaling Workers

To increase sending speed, you can scale the number of processes in your `horizon.php` config:

```php
'environments' => [
    'production' => [
        'supervisor-1' => [
            'connection' => 'redis',
            'queue' => ['emails', 'campaigns', 'validations'],
            'balance' => 'auto',
            'minProcesses' => 1,
            'maxProcesses' => 10,
            'tries' => 3,
        ],
    ],
],
```

## System Requirements
- **Redis**: Required as the queue driver.
- **Supervisor**: Required to keep the `php artisan horizon` process alive on your server.

## Developer Notes
- **Library**: `laravel/horizon`
- **Command**: `php artisan horizon`
- **Monitoring**: `php artisan horizon:terminate` (to restart workers after a code update).
