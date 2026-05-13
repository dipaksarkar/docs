---
titleTemplate: Mailzor
---

# Proxies

Maintaining a good IP reputation is critical for reliable email verification. Mailzor integrates seamlessly with SOCKS5 proxies to protect your server's IP.

## What is a SOCKS5 Proxy?

A **SOCKS5 proxy** is a flexible proxy protocol that supports various types of traffic, including SMTP. When using it for email verifications, the reputation of the **proxy’s IP** is what matters, not your own server's IP. This is crucial for maintaining deliverability and avoiding issues like blacklisting.

Choosing a reputable 3rd-party proxy will greatly improve the quality of your email verification results.

::: warning NOTE
SMTP email verifications are not possible via a traditional HTTP proxy. You MUST use a SOCKS5 proxy that supports SMTP traffic.
:::

## Setting up a Proxy

To configure a proxy in Mailzor:

1.  Navigate to **Settings > Email Validation Configuration**.
2.  Enable the **Use Proxy** toggle.
3.  Enter your SOCKS5 proxy details:
    - **Proxy Host**: The IP or hostname of your proxy.
    - **Proxy Port**: The port number (typically 1080).
    - **Proxy Username**: (Optional) For authenticated proxies.
    - **Proxy Password**: (Optional) For authenticated proxies.
4.  Click **Save** to apply the settings.

## Recommended Proxies

Mailzor recommends using high-quality proxies tailored for SMTP traffic. We have tested and verified compatibility with several providers.

### Proxy5

Mailzor has been working closely with [Proxy5](https://proxy.coderstm.com) since early 2023. This service is run by industry experts who understand the complications and challenges that arise from large-scale SMTP connections. Their proxies integrate seamlessly with Mailzor and are specifically tailored for B2B email verification.

For an introduction or more information, you can reach out to `hello@coderstm.com`.
