#!/bin/bash

# ==============================================================================
# Script Name: migrate_emails_to_hestia.sh
# Description: Moves cPanel emails to HestiaCP server using rsync.
#              assumes this script is run from the cPanel user's home directory
#              (or a directory containing the mail folder).
#
# Usage:       ./migrate_emails_to_hestia.sh
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
# "Source_Directory_Name": Directory name in the mail folder
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
SSH_SOCKET="$SSH_SOCKET_DIR/hestia_mail_root@${HESTIA_HOST}"

echo -e "${GREEN}Establishing persistent SSH connection to $HESTIA_HOST for user root...${NC}"
# Start master connection (-M), go to background (-f), do not execute command (-N), use socket
ssh -M -f -N -o ControlPath="$SSH_SOCKET" -o ControlPersist=10m "root@$HESTIA_HOST"

# Check if the socket was created successfully
if [ ! -S "$SSH_SOCKET" ]; then
    echo -e "${RED}Error: Failed to establish persistent SSH connection.${NC}"
    echo -e "${YELLOW}Retrying without backgrounding to see errors...${NC}"
    # Retry once without -f but with -N
    ssh -M -N -o ControlPath="$SSH_SOCKET" -o ControlPersist=10m "root@$HESTIA_HOST" &
    SSH_PID=$!
    sleep 5
    if [ ! -S "$SSH_SOCKET" ]; then
         echo -e "${RED}Still failed to create socket. Ensure you have correct permissions and no errors on remote shell.${NC}"
         kill $SSH_PID 2>/dev/null
         exit 1
    fi
fi

# Ensure connection is closed on script exit
trap "echo -e '\nClosing SSH connection...'; ssh -O exit -o ControlPath='$SSH_SOCKET' 'root@$HESTIA_HOST' 2>/dev/null" EXIT

echo -e "${GREEN}Starting email migration to $HESTIA_HOST for user $HESTIA_USER...${NC}"

for entry in "${domains[@]}"; do
    IFS=":" read -r src_folder dest_domain <<< "$entry"

    echo -e "\n${YELLOW}==============================================${NC}"
    echo -e "${YELLOW}Processing Domain: $dest_domain${NC}"
    echo -e "${YELLOW}==============================================${NC}"

    # ---------------- Email Migration ----------------
    # Source: $SOURCE_BASE/mail/$src_folder/ (Standard cPanel path)
    # Dest:   /home/$HESTIA_USER/mail/$dest_domain/
    # Note:   Using 'root' connection for emails to ensure permissions/ownership can be set
    
    # Check if we should look for mail under the domain name in the mail folder
    # cPanel typically stores mail in ~/mail/domain.com/
    # Note: The mapping provided for web often uses folder names that match domains,
    # but for mail, we usually look for 'mail/domain.com'.
    # If src_folder is 'public_html', it likely means the main domain 'coderstm.com'.
    # We'll try to deduce the mail source logic.
    
    MAIL_SRC_CANDIDATE_1="$SOURCE_BASE/mail/$dest_domain/"
    MAIL_SRC_CANDIDATE_2="$SOURCE_BASE/mail/$src_folder/"
    
    if [ -d "$MAIL_SRC_CANDIDATE_1" ]; then
        MAIL_SRC="$MAIL_SRC_CANDIDATE_1"
    elif [ -d "$MAIL_SRC_CANDIDATE_2" ]; then
        MAIL_SRC="$MAIL_SRC_CANDIDATE_2"
    else
        MAIL_SRC=""
    fi
     
    MAIL_DEST="root@$HESTIA_HOST:/home/$HESTIA_USER/mail/$dest_domain/"

    if [ -n "$MAIL_SRC" ]; then
        echo -e "${GREEN}[MAIL] Syncing emails...${NC}"
        echo "Source: $MAIL_SRC"
        echo "Dest:   $MAIL_DEST"

        # Rsync the mail content
        rsync -avz --progress -e "ssh -o ControlPath='$SSH_SOCKET'" "$MAIL_SRC" "$MAIL_DEST"

        # Fix Permissions on Destination
        # Using ssh root to chown the files to hestia_user:mail
        echo -e "${GREEN}[MAIL] Fixing permissions...${NC}"
        ssh -o ControlPath="$SSH_SOCKET" "root@$HESTIA_HOST" "chown -R $HESTIA_USER:mail /home/$HESTIA_USER/mail/$dest_domain"
        
    else
        echo -e "${YELLOW}[MAIL] Mail directory not found for $dest_domain${NC}"
        echo "Checked: $MAIL_SRC_CANDIDATE_1"
        echo "Checked: $MAIL_SRC_CANDIDATE_2"
        echo "Skipping email sync for $dest_domain"
    fi

done

echo -e "\n${GREEN}Email migration script finished!${NC}"
