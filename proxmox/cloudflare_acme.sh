#!/bin/bash

# Bash script to setup Proxmox ACME Cloudflare legacy DNS plugin and order cert

# Prompt for variables
read -p "Enter your Cloudflare email: " CLOUDFLARE_EMAIL
read -p "Enter your Cloudflare Global API Key: " CLOUDFLARE_API_KEY
read -p "Enter your domain (e.g., example.com): " DOMAIN
read -p "Enter plugin name [cloudflare-legacy]: " PLUGIN_NAME
PLUGIN_NAME=${PLUGIN_NAME:-cloudflare-legacy}

# Check for empty values
if [[ -z "$CLOUDFLARE_EMAIL" || -z "$CLOUDFLARE_API_KEY" || -z "$DOMAIN" || -z "$PLUGIN_NAME" ]]; then
  echo "Error: All values are required. Exiting."
  exit 1
fi

# Create credentials file
CREDENTIAL_FILE="/root/${PLUGIN_NAME}.txt"
echo "CF_Key=\"$CLOUDFLARE_API_KEY\"" > "$CREDENTIAL_FILE"
echo "CF_Email=\"$CLOUDFLARE_EMAIL\"" >> "$CREDENTIAL_FILE"
chmod 600 "$CREDENTIAL_FILE"

# Remove existing plugin if exists
pvenode acme plugin remove "$PLUGIN_NAME" 2>/dev/null

# Add Cloudflare legacy plugin
pvenode acme plugin add dns "$PLUGIN_NAME" --api cf --data "$CREDENTIAL_FILE"

# Set domain and associate plugin
pvenode config set -acmedomain0 "$DOMAIN,plugin=$PLUGIN_NAME"

# Register ACME account if not already done
pvenode acme account register default "$CLOUDFLARE_EMAIL" --accept-tos || true

# Order certificate
pvenode acme cert order --force

# Output status
pvenode acme status