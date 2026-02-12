#!/bin/bash

# ==============================================================================
# Script Name: download_emails_from_goazh.sh
# Description: Downloads emails from ssh.goazh.com using rsync and SSH multiplexing.
#
# Usage:       ./download_emails_from_goazh.sh [DOMAIN_OR_PATH] [LOCAL_DEST]
#              If no arguments provided, it syncs the configured domains.
# ==============================================================================

# ----------------- Configuration -----------------

HOST="ssh.goazh.com"
USER="coderstm"
REMOTE_BASE_MAIL="~/mail" # cPanel mail path
LOCAL_BASE="/home/coderstm/mail"

# List of domains to sync
# Format: "Source_Directory_Name:Destination_Domain_Name"
# "Source_Directory_Name": Directory name in cPanel (relative to mail folder)
# "Destination_Domain_Name": Domain name in HestiaCP (folder name)
# Note: For main domain, cPanel often uses 'mail/domain.com' structure too,
# but sometimes puts main domain mail directly in mail/ folders (like cur, new, etc).
# Assuming standard cPanel structure here: ~/mail/domain.com/
domains=(
    "coderstm.com:coderstm.com"
    "dipaksarkar.in:dipaksarkar.in"
)

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# ----------------- SSH Connection Sharing -----------------
SSH_SOCKET_DIR="$HOME/.ssh/sockets"
mkdir -p "$SSH_SOCKET_DIR"
SSH_SOCKET="$SSH_SOCKET_DIR/download_mail_${USER}@${HOST}"

echo -e "${GREEN}Establishing persistent SSH connection to $HOST...${NC}"
ssh -M -f -N -o ControlPath="$SSH_SOCKET" -o ControlPersist=10m "$USER@$HOST"

# Check socket
if [ ! -S "$SSH_SOCKET" ]; then
    echo -e "${RED}Error: Failed to establish SSH connection.${NC}"
    echo -e "${YELLOW}Retrying interactively to check for errors...${NC}"
    ssh -M -N -o ControlPath="$SSH_SOCKET" -o ControlPersist=10m "$USER@$HOST" &
    SSH_PID=$!
    sleep 5
    if [ ! -S "$SSH_SOCKET" ]; then
         echo -e "${RED}Still failed. Check your password or remote .bashrc output.${NC}"
         kill $SSH_PID 2>/dev/null
         exit 1
    fi
fi

trap "echo -e '\nClosing SSH connection...'; ssh -O exit -o ControlPath='$SSH_SOCKET' '$USER@$HOST' 2>/dev/null" EXIT

# ----------------- Functions -----------------

sync_mail() {
    local src_param=$1
    local dest_param=$2

    # Determine Remote Path
    local remote_path
    if [[ "$src_param" == ~* ]] || [[ "$src_param" == /* ]]; then
        remote_path="$src_param"
    else
        # Default to ~/mail/{domain}
        remote_path="$REMOTE_BASE_MAIL/$src_param"
    fi

    # Determine Local Path
    local local_dest
    if [ -n "$dest_param" ]; then
        if [[ "$dest_param" == /* ]] || [[ "$dest_param" == ~* ]] || [[ "$dest_param" == .* ]]; then
             # Looks like a path
             local_dest="$dest_param"
        else
             # Looks like a domain name -> ~/mail/{domain}
             local_dest="$LOCAL_BASE/$dest_param"
        fi
    else
        # Fallback
        local_dest="$LOCAL_BASE/$src_param"
    fi

    echo -e "\n${YELLOW}==============================================${NC}"
    echo -e "${YELLOW}Downloading Email: $src_param -> $dest_param${NC}"
    echo -e "${YELLOW}From: $USER@$HOST:$remote_path${NC}"
    echo -e "${YELLOW}To:   $local_dest${NC}"
    echo -e "${YELLOW}==============================================${NC}"

    mkdir -p "$local_dest"
    
    # Sync FROM remote TO local
    rsync -avz --progress -e "ssh -o ControlPath='$SSH_SOCKET'" \
        "$USER@$HOST:$remote_path/" "$local_dest/"
}

# ----------------- Main Execution -----------------

if [ -n "$1" ]; then
    # User provided arguments: ./script source_domain [dest_domain]
    SRC="$1"
    DEST="$2"
    sync_mail "$SRC" "$DEST"
else
    # Sync all configured domains
    echo -e "${GREEN}No specific target provided. Syncing all configured domains...${NC}"
    for entry in "${domains[@]}"; do
        IFS=":" read -r src_dir dest_domain <<< "$entry"
        sync_mail "$src_dir" "$dest_domain"
    done
fi

echo -e "\n${GREEN}Email download finished!${NC}"
