---
titleTemplate: Validora
---

# How to Increase Email Verification Scan Speed

## Understanding Validora Scan Speeds

From our testing, Validora's email verification process with a 50 batch size setting typically validates 1-3 emails per second in a single request. This translates to approximately 150,000 email validations per day per instance.

However, it's important to understand that verification speed depends heavily on server-to-server socket connections. While your server will respond quickly when you initiate verification, if the target email server delays its connection to your server, this will slow down the entire scan process. This is something neither you nor Validora has control over – the system must wait for the target server's final response to complete verification.

## Common Factors Affecting Scan Speed

### Mixed Email Quality

When users upload mixed email lists containing some addresses with complete connection failures or bad response data, it isn't Validora's fault but rather an issue with the target server. For these problematic email addresses, Validora attempts to wait until the default connection timeout of 10 seconds has passed.

To improve efficiency, consider adding known problematic domains to your disposable email list in the settings panel so Validora can skip them immediately. While Validora comes with a pre-configured disposable email list, it doesn't contain all disposable addresses worldwide.

### Server Connection Issues

Sometimes the speed limitation comes from network latency between your server and the target email servers. This is especially true when verifying email addresses from domains with slower mail servers or strict anti-spam measures.

## Solutions to Improve Scan Speed

While we can't guarantee these solutions will boost scan speed if your server is experiencing connection issues with target email servers, the following suggestions may help:

### 1. Try a Different Server

Consider using a different VPS provider or server location that might have better connectivity to the email servers you're targeting. See our [VPS Recommendations](/validora/faqs/vps-recommendations) for suggestions.

### 2. Disable Security Features That May Interfere

Temporarily disable or configure:

- Firewall rules that might be throttling SMTP connections
- Antivirus software that scans outgoing connections
- ModSecurity rules that could be blocking or delaying SMTP requests

### 3. Increase Timeout Limits

Adjust the following settings in your server configuration:

- Increase PHP execution time limit
- Extend Apache/Nginx timeout settings
- Modify MySQL connection timeout settings if applicable

Example for PHP settings in `php.ini`:

```ini
max_execution_time = 300
default_socket_timeout = 60
```

### 4. Check IP Reputation

Your server's IP address should not be blacklisted in any internet blacklist database. If it is:

- Request a new IP from your VPS provider
- Delist your IP from DNSBL services if it's blacklisted (see [Why IPs Get Blacklisted](/validora/faqs/why-ip-get-blacklisted))

### 5. Configure DNS Properly

Ensure your server has:

- Proper Reverse DNS (rDNS) setup
- Valid PTR records for your IP address
- Correctly configured SPF, DKIM, and DMARC records

### 6. Direct Connection

Avoid using a proxy or CDN for verification traffic:

- Verification requests should come directly from your server
- Proxies can add latency and trigger spam detection

### 7. Optimize Batch Settings

Experiment with different batch size settings:

- Smaller batch sizes (20-30) may improve overall throughput for problematic email lists
- Larger batch sizes (50-100) might be more efficient for high-quality lists

### 8. Schedule Verifications Strategically

Run verifications during off-peak hours:

- Many email servers respond faster during their low-traffic periods
- Consider the time zones of the domains you're verifying

## Advanced Optimization

For users requiring higher throughput:

### Multiple Server Approach

Consider distributing your verification workload across multiple servers:

- Split your email lists among several Validora instances
- Use different IP addresses to avoid rate limiting
- Implement [IP warming](/validora/faqs/what-is-ip-warming) for each new server

### Preprocessing Email Lists

Before verification, preprocess your lists to:

- Remove obviously invalid formats
- Filter out known disposable domains
- Deduplicate email addresses
- Sort by domain to improve caching efficiency

## Conclusion

While Validora is optimized for efficient email verification, external factors can affect scanning speed. By implementing the suggestions above, you can potentially improve your verification throughput. Remember that email verification is inherently dependent on external servers' response times, which are beyond Validora's control.

If you continue to experience speed issues after trying these solutions, please contact our support team for personalized assistance.
