## Remove Dummy Data

1. Open the SSH terminal on your machine and run the following command:

```bash
ssh username@your-domain.com
```

::: warning
Please ask your hosting provider for details on how to use SSH access.
:::

2. After logging in, run the following commands to remove dummy data:

```bash
cd public_html
php artisan migrate:fresh --force
```
