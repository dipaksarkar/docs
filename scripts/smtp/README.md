# test.sh

This folder contains `test.sh`, a small bash script to test SMTP servers.

## What it does

- Connects to an SMTP server using implicit SSL (port 465) or plaintext/STARTTLS (25/587).
- Optionally performs AUTH LOGIN (username/password) using base64.
- Sends a simple plain-text message (no attachments).
- Emits a JSON result and uses exit code 0 for success and 2 for failure.

## Prerequisites

- bash (POSIX shell)
- openssl (required for SSL and STARTTLS; also used as a fallback for TCP)
- nc (netcat) is optional — used for plaintext if available
- python3 is optional — used to safely JSON-escape server output; the script falls back to a simple escaping approach when python3 is not present.

## Usage

Make script executable and run it from this folder or call it by path:

```sh
chmod +x test.sh
./test.sh --host smtp.example.com --starttls --from you@example.com --to recipient@example.org --user you --password secret
```

## Notes

- The script is intended for quick testing and diagnostics, not as a production mailer.
- It does not construct full MIME messages or support attachments.
- Keep credentials out of version control; prefer environment variables or CI secrets when automating tests.
