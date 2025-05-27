---
titleTemplate: Bouncify
---

# Server Requirements for Bouncify SaaS

Bouncify is a Software as a Service (SaaS) application that requires specific server environments to run efficiently. This guide outlines the recommended server infrastructure and environment configurations for optimal performance.

## Minimum Server Requirements

As a SaaS application, Bouncify needs robust infrastructure to handle multiple users, concurrent verification processes, and data storage. Here are the minimum server requirements:

### Hardware Requirements

- **CPU**: 4+ cores (8+ cores recommended for high traffic)
- **RAM**: 8GB minimum (16GB+ recommended)
- **Storage**: 100GB SSD (more depending on your user base and data retention policies)
- **Network**: 1Gbps connection with unmetered or high monthly transfer allowance

### Software Environment

- **Operating System**: 
  - Ubuntu 20.04 LTS or newer (recommended)
  - CentOS 8+ or Rocky Linux 8+
  - Debian 11+

- **Web Server**:
  - Nginx (recommended for best performance)
  - Apache with event MPM

- **Database**:
  - MySQL 8.0+ or MariaDB 10.5+
  - Redis for caching and queues

- **PHP Requirements**:
  - PHP 8.3+ (with OPcache enabled)
  - Required extensions as listed in the [Installation guide](/bouncify/installation)

### Cloud Provider Recommendations

Bouncify performs well on major cloud platforms, including:

- **AWS**: t3.large or better for small to medium deployments
- **Google Cloud**: e2-standard-4 or better
- **DigitalOcean**: Premium Droplets with 4GB RAM or higher
- **Linode/Akamai**: Dedicated 4GB+ plans
- **Vultr**: High Performance instances 4GB+

## Recommended VPS Providers

For optimal performance of Bouncify, we recommend using reliable VPS providers that support the requirements listed above. Not all VPS providers offer suitable environments for email verification services, particularly regarding SMTP port 25 accessibility.

For detailed recommendations on specific VPS providers and control panels that work well with Bouncify, please see our [VPS Recommendations Guide](/bouncify/faqs/vps-recommendations).

## Scaling Considerations

As your user base grows, consider these scaling strategies:

### Vertical Scaling
- Increase server resources (CPU, RAM) for immediate performance gains
- Useful for small to medium-sized deployments

### Horizontal Scaling
- Deploy multiple application servers behind a load balancer
- Separate database servers from application servers
- Implement Redis for centralized session management
- Use a CDN for static assets

## Email Sending Infrastructure

Since Bouncify involves email verification, proper email infrastructure is critical:

- **Dedicated IP Addresses**: Use dedicated IPs for email verification processes
- **Multiple IPs**: Consider using multiple IPs and rotation for high-volume verification
- **IP Warming**: Follow proper [IP warming procedures](/bouncify/faqs/what-is-ip-warming)
- **Reverse DNS**: Ensure proper PTR records for all IPs
- **Email Authentication**: Implement SPF, DKIM, and DMARC

## Monitoring and Maintenance

For optimal performance and reliability, implement:

- **Server Monitoring**: Tools like New Relic, Datadog, or Prometheus/Grafana
- **Log Management**: Centralized logging with ELK Stack or similar
- **Backup Systems**: Regular automated backups with off-site storage
- **Security Measures**: Firewall, intrusion detection, and regular security updates

## Docker Deployment

Bouncify supports containerized deployment using Docker:

```yaml
version: '3'
services:
  app:
    image: bouncify/app:latest
    ports:
      - "80:80"
    environment:
      - DB_HOST=db
      - REDIS_HOST=redis
    depends_on:
      - db
      - redis
  db:
    image: mysql:8.0
    volumes:
      - db_data:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=secure_password
      - MYSQL_DATABASE=bouncify
  redis:
    image: redis:latest
volumes:
  db_data:
```

## Common Server Issues

### High CPU Usage
High CPU usage is often caused by:
- Too many concurrent verification processes
- Inefficient database queries
- PHP OPcache not enabled

### Memory Issues
To prevent memory problems:
- Configure PHP memory limit appropriately (at least 512MB)
- Implement proper Redis caching
- Monitor for memory leaks

### Connection Timeouts
When experiencing timeouts:
- Adjust PHP and web server timeout settings
- Configure rate limiting for verification requests
- Implement proper queue handling for long-running processes

## Conclusion

Running Bouncify as a SaaS application requires proper server infrastructure planning. By following these recommendations, you can ensure your Bouncify installation performs optimally, scales effectively, and provides reliable service to your users.

For specific deployment questions or custom configuration assistance, please contact our support team.
