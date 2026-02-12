#!/bin/bash

# ==============================================================================
# Script Name: migrate_cpanel_to_hestia.sh
# Description: Moves cPanel web files and emails to HestiaCP server using rsync.
#              assumes this script is run from the cPanel user's home directory
#              (or a directory containing the mail and web folders).
#
# Usage:       ./migrate_cpanel_to_hestia.sh
# ==============================================================================

# ----------------- Configuration -----------------

# HestiaCP Settings
HESTIA_USER="coderstm"
HESTIA_HOST="vmi4645.goazh.com"

# Source Base Path
# Defaults to current directory. Change to /home/YOUR_CPANEL_USER if needed.
SOURCE_BASE="." 

# Domain Mappings
# Format: "Source_Directory_Name:Destination_Domain_Name"
# "Source_Directory_Name": Relative path to the web content on the local machine (cPanel)
# "Destination_Domain_Name": Domain name created in HestiaCP
domains=(
    "public_html:coderstm.com"
    "cdn.coderstm.com:cdn.coderstm.com"
    "dipaksarkar.in:dipaksarkar.in"
    "docs.coderstm.com:docs.coderstm.com"
    "measurement.coderstm.com:measurement.coderstm.com"
    "npm.coderstm.com:npm.coderstm.com"
    "qaravel-pwa.coderstm.com:qaravel-pwa.coderstm.com"
    "qaravel.coderstm.com:qaravel.coderstm.com"
)

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ----------------- Main Script -----------------

# SSH Connection Sharing
SSH_SOCKET_DIR="$HOME/.ssh/sockets"
mkdir -p "$SSH_SOCKET_DIR"
SSH_SOCKET="$SSH_SOCKET_DIR/hestia_web_${HESTIA_USER}@${HESTIA_HOST}"

echo -e "${GREEN}Establishing persistent SSH connection to $HESTIA_HOST for user $HESTIA_USER...${NC}"
# Start master connection (-M), go to background (-f), do not execute command (-N), use socket
ssh -M -f -N -o ControlPath="$SSH_SOCKET" -o ControlPersist=10m "$HESTIA_USER@$HESTIA_HOST"

# Check if the socket was created successfully
if [ ! -S "$SSH_SOCKET" ]; then
    echo -e "${RED}Error: Failed to establish persistent SSH connection.${NC}"
    echo -e "${YELLOW}Retrying without backgrounding to see errors...${NC}"
    # Retry once without -f but with -N
    ssh -M -N -o ControlPath="$SSH_SOCKET" -o ControlPersist=10m "$HESTIA_USER@$HESTIA_HOST" &
    SSH_PID=$!
    sleep 5
    if [ ! -S "$SSH_SOCKET" ]; then
         echo -e "${RED}Still failed to create socket. Ensure you have correct permissions and no errors on remote shell.${NC}"
         kill $SSH_PID 2>/dev/null
         exit 1
    fi
fi

# Ensure connection is closed on script exit
trap "echo -e '\nClosing SSH connection...'; ssh -O exit -o ControlPath='$SSH_SOCKET' '$HESTIA_USER@$HESTIA_HOST' 2>/dev/null" EXIT

echo -e "${GREEN}Starting migration...${NC}"

for entry in "${domains[@]}"; do
    IFS=":" read -r src_folder dest_domain <<< "$entry"

    echo -e "\n${YELLOW}==============================================${NC}"
    echo -e "${YELLOW}Processing Domain: $dest_domain${NC}"
    echo -e "${YELLOW}==============================================${NC}"

    # ---------------- 1. Web Files Migration ----------------
    # Source: $SOURCE_BASE/$src_folder/
    # Dest:   /home/$HESTIA_USER/web/$dest_domain/public_html/
    
    WEB_SRC="$SOURCE_BASE/$src_folder/"
    WEB_DEST="$HESTIA_USER@$HESTIA_HOST:/home/$HESTIA_USER/web/$dest_domain/public_html/"

    if [ -d "$WEB_SRC" ] || [ -L "$WEB_SRC" ]; then
        echo -e "${GREEN}[WEB] Syncing files...${NC}"
        echo "Source: $WEB_SRC"
        echo "Dest:   $WEB_DEST"
        
        # Use the established control socket
        # Note: If you see 'protocol version mismatch', your remote .bashrc might be printing text.
        rsync -avz --progress -e "ssh -o ControlPath='$SSH_SOCKET'" "$WEB_SRC" "$WEB_DEST"
    else
        echo -e "${RED}[WEB] Source directory not found: $WEB_SRC${NC}"
        echo "Skipping web sync for $dest_domain"
    fi

    # Email migration has been moved to migrate_emails_to_hestia.sh


done

echo -e "\n${GREEN}Migration script finished!${NC}"
