## Setup Queue Worker

Systemd provides more robust control over the service, including automatic restarts and easier management.

Follow these steps to set up a systemd service:

#### Step 1: Create the Service File

Start by creating a new service file for your Gympify queue worker:

```bash
sudo nano /etc/systemd/system/gympify-queues.service
```

#### Step 2. Add the Service Configuration

Add the following configuration to the service file:

```
# This systemd service is responsible for managing the queue workers for gympify.

[Unit]
Description=Gympify Queues
After=network.target

[Service]
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php8.2 {project-root}/artisan queue:work --sleep=3 --tries=3 --max-time=3600
RestartSec=5
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=gympify-queues

[Install]
WantedBy=multi-user.target
```

Make sure to replace `{project-root}` with the path to your Gympify project.

- **User and Group:** Ensure that the `User` and `Group` are set to the user that your web server runs under (commonly `www-data`).


#### Step 3: Enable and Start the Service

After creating the service file, run the following commands to reload systemd, enable the service to start at boot, and start the queue worker:

```bash
sudo systemctl daemon-reload
sudo systemctl enable gympify-queues
sudo systemctl start gympify-queues
```

#### Step 4: Check the Status

To ensure the queue worker is running properly, check its status:

```bash
sudo systemctl status gympify-queues
```
