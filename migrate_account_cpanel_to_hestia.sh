#!/bin/bash

# ==============================================================================
# Script Name: migrate_account_cpanel_to_hestia.sh
# Description: Migrates a cPanel account to HestiaCP.
#              - Creates User
#              - Creates Web Domains (and Aliases)
#              - Rsyncs Web Content
#              - Creates DBs and Data
#              - Creates Email Accounts and Data
#
# Usage:       ./migrate_account_cpanel_to_hestia.sh [REMOTE_HOST] [REMOTE_USER]
# ==============================================================================

# ----------------- Configuration -----------------

# Set default password for new accounts (Change this or use a random generator)
DEFAULT_PASS="ChangeMe123!"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run as root.${NC}"
  exit 1
fi

# ----------------- Input -----------------

if [ -z "$1" ] || [ -z "$2" ]; then
    echo -e "${YELLOW}Usage: $0 [REMOTE_HOST] [REMOTE_USER]${NC}"
    echo -e "Example: $0 ssh.goazh.com coderstm"
    exit 1
fi

REMOTE_HOST="$1"
REMOTE_USER="$2"
HESTIA_USER="$REMOTE_USER" # Use same username

# ----------------- SSH Connection Sharing -----------------
SSH_SOCKET_DIR="$HOME/.ssh/sockets"
mkdir -p "$SSH_SOCKET_DIR"
SSH_SOCKET="$SSH_SOCKET_DIR/migrate_${REMOTE_USER}@${REMOTE_HOST}"

echo -e "${GREEN}Establishing persistent SSH connection to $REMOTE_HOST...${NC}"
ssh -M -f -N -o ControlPath="$SSH_SOCKET" -o ControlPersist=10m "$REMOTE_USER@$REMOTE_HOST"

if [ ! -S "$SSH_SOCKET" ]; then
    echo -e "${RED}Error: Failed to establish SSH connection.${NC}"
    # Interactive retry
    ssh -M -N -o ControlPath="$SSH_SOCKET" -o ControlPersist=10m "$REMOTE_USER@$REMOTE_HOST" &
    SSH_PID=$!
    sleep 5
    if [ ! -S "$SSH_SOCKET" ]; then
         echo -e "${RED}Still failed. Check your password.${NC}"
         kill $SSH_PID 2>/dev/null
         exit 1
    fi
fi

trap "echo -e '\nClosing SSH connection...'; ssh -O exit -o ControlPath='$SSH_SOCKET' '$REMOTE_USER@$REMOTE_HOST' 2>/dev/null" EXIT

# ----------------- Helper Functions -----------------
remote_cmd() {
    ssh -o ControlPath="$SSH_SOCKET" "$REMOTE_USER@$REMOTE_HOST" "$@"
}

log() {
    echo -e "${GREEN}[$(date +'%T')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%T')] $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%T')] $1${NC}"
}

# ----------------- 1. Create User -----------------
log "Creating Hestia User: $HESTIA_USER"
if v-list-user "$HESTIA_USER" >/dev/null 2>&1; then
    warn "User $HESTIA_USER already exists. Skipping creation."
else
    # Generate random email or use a placeholder
    EMAIL="admin@$HESTIA_USER.com"
    v-add-user "$HESTIA_USER" "$DEFAULT_PASS" "$EMAIL"
    log "User created."
fi

# ----------------- 2. Retrieve & Create Domains -----------------
log "Retrieving Domains from cPanel..."
# Use uapi to list domains. Output is YAML-like or JSON depending on flags.
# We'll use --output=json usually, or parse text.
# Let's try to get a simple list via uapi DomainInfo list_domains
# Parsing JSON with python/jq is best. Assuming remote has python or we parse line by line.

DOMAINS_JSON=$(remote_cmd "uapi --output=json DomainInfo list_domains")
# We need to parse this locally.
# Structure: result -> data -> main_domain, sub_domains[], addon_domains[]
# We'll rely on python for parsing JSON in bash
DOMAINS_LIST=$(echo "$DOMAINS_JSON" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['result']['data']['main_domain']); print('\n'.join(d for d in data['result']['data']['sub_domains'])); print('\n'.join(d for d in data['result']['data']['addon_domains']))" 2>/dev/null)

if [ -z "$DOMAINS_LIST" ]; then
    error "Failed to retrieve domains or no domains found."
    # Fallback to listing public_html directories? No, proceed with caution.
else
    echo "$DOMAINS_LIST" | while read -r DOMAIN; do
        [ -z "$DOMAIN" ] && continue
        log "Processing Domain: $DOMAIN"
        
        if v-list-web-domain "$HESTIA_USER" "$DOMAIN" >/dev/null 2>&1; then
            warn "Domain $DOMAIN already exists."
        else
            v-add-web-domain "$HESTIA_USER" "$DOMAIN"
            log "Domain added."
        fi
        
        # 3. Sync Web Content
        # cPanel path: ~/public_html for main, ~/{domain} or ~/public_html/{domain} for addons.
        # We need to find the document root.
        # uapi DomainInfo list_domains includes documentroot. Let's re-parse or query per domain.
        DOCROOT=$(remote_cmd "uapi --output=json DomainInfo list_domains" | python3 -c "import sys, json; data=json.load(sys.stdin); 
def find_root(d):
    if data['result']['data']['main_domain'] == d: return data['result']['data']['doc_root']
    for sub in data['result']['data']['sub_domains']: 
        if sub == d: return 'UNKNOWN' # Subdomains logic tricky
    for addon in data['result']['data']['addon_domains']:
        if addon == d: return 'UNKNOWN_ADDON' # detailed logic needed
    return ''
print(find_root('$DOMAIN'))" 2>/dev/null)
        
        # Simplified Path Guessing (Robust enough for standard cPanel)
        # Main domain: ~/public_html
        # Addon: ~/{domain} usually
        
        # Let's try rsyncing standard paths
        if [ "$DOMAIN" == "$(echo "$DOMAINS_LIST" | head -n 1)" ]; then
             REMOTE_PATH="~/public_html/"
        else
             REMOTE_PATH="~/$DOMAIN/"
             # Check if it exists
             if ! remote_cmd "[ -d $REMOTE_PATH ]"; then
                 REMOTE_PATH="~/public_html/$DOMAIN/"
             fi
        fi
        
        LOCAL_PATH="/home/$HESTIA_USER/web/$DOMAIN/public_html/"
        log "Syncing Web Content: $REMOTE_PATH -> $LOCAL_PATH"
        rsync -avz -e "ssh -o ControlPath='$SSH_SOCKET'" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH" "$LOCAL_PATH"
        chown -R "$HESTIA_USER:$HESTIA_USER" "$LOCAL_PATH"
    done
fi

# ----------------- 4. Databases -----------------
log "Retrieving Databases..."
# uapi Mysql list_databases
DBS_JSON=$(remote_cmd "uapi --output=json Mysql list_databases")
DBS_LIST=$(echo "$DBS_JSON" | python3 -c "import sys, json; print('\n'.join(d['database'] for d in json.load(sys.stdin)['result']['data']))" 2>/dev/null)

echo "$DBS_LIST" | while read -r DB; do
    [ -z "$DB" ] && continue
    log "Processing Database: $DB"
    
    # Create DB in Hestia check existence
    # Hestia appends user prefix: remote 'coderstm_db' -> local 'coderstm_db'
    # Hestia v-add-database adds prefix automatically.
    # If remote is 'coderstm_db', suffix is 'db'.
    
    DB_SUFFIX="${DB#${REMOTE_USER}_}"
    if [ "$DB_SUFFIX" == "$DB" ]; then
         # No prefix match, use whole name (might fail if too long or mismatched user)
         DB_SUFFIX="$DB"
    fi
    
    if v-list-database "$HESTIA_USER" "$DB_SUFFIX" >/dev/null 2>&1; then
        warn "Database $DB_SUFFIX already exists."
    else
        v-add-database "$HESTIA_USER" "$DB_SUFFIX" "$DB_SUFFIX" "$DEFAULT_PASS"
        log "Database created."
    fi
    
    # Dump and Import
    DUMP_FILE="$DB.sql"
    log "Dumping remote database..."
    remote_cmd "mysqldump $DB > $DUMP_FILE"
    
    log "Downloading dump..."
    rsync -avz -e "ssh -o ControlPath='$SSH_SOCKET'" "$REMOTE_USER@$REMOTE_HOST:~/$DUMP_FILE" "/home/$HESTIA_USER/$DUMP_FILE"
    
    log "Importing database..."
    # Hestia CLI wrapper for import? Or direct mysql
    # v-add-database-dump USER DATABASE FILE
    # Note: v-add-database-dump was recently added or use mysql CLI
    if [ -f "/usr/local/hestia/bin/v-import-database" ]; then
         v-import-database "$HESTIA_USER" "$DB_SUFFIX" "/home/$HESTIA_USER/$DUMP_FILE"
    else
         # Determine DB credentials from Hestia config or just use root
         mysql "${HESTIA_USER}_${DB_SUFFIX}" < "/home/$HESTIA_USER/$DUMP_FILE"
    fi
    log "Database imported."
    
    # Clean up
    rm "/home/$HESTIA_USER/$DUMP_FILE"
    remote_cmd "rm $DUMP_FILE"
done

# ----------------- 5. Emails -----------------
log "Retrieving Email Accounts..."
# uapi Email list_pops
EMAILS_JSON=$(remote_cmd "uapi --output=json Email list_pops regex='.*'")
# Parse email, Login, Domain
# We need to loop through and create accounts

# Python parser to output "email|domain|user"
EMAIL_Accts=$(echo "$EMAILS_JSON" | python3 -c "import sys, json; 
data=json.load(sys.stdin); 
for d in data['result']['data']:
    print(f\"{d['email']}|{d['domain']}|{d['login']}\")" 2>/dev/null)

echo "$EMAIL_Accts" | while read -r line; do
    [ -z "$line" ] && continue
    IFS="|" read -r FULL_EMAIL DOMAIN LOGIN <<< "$line"
    
    EMAIL_USER="${FULL_EMAIL%@*}"
    log "Processing Email: $FULL_EMAIL"
    
    # Check/Add Mail Domain first (usually handled by web domain, but ensure mail support is on)
    # v-add-mail-domain USER DOMAIN
    if ! v-list-mail-domain "$HESTIA_USER" "$DOMAIN" >/dev/null 2>&1; then
        v-add-mail-domain "$HESTIA_USER" "$DOMAIN"
    fi
    
    # Add Account
    if v-list-mail-account "$HESTIA_USER" "$DOMAIN" "$EMAIL_USER" >/dev/null 2>&1; then
        warn "Email account $FULL_EMAIL already exists."
    else
        v-add-mail-account "$HESTIA_USER" "$DOMAIN" "$EMAIL_USER" "$DEFAULT_PASS"
    fi
    
    # Sync Content
    # Remote: ~/mail/domain/user/
    # Local: /home/USER/mail/domain/user/
    
    REMOTE_MAIL_PATH="~/mail/$DOMAIN/$EMAIL_USER/"
    LOCAL_MAIL_PATH="/home/$HESTIA_USER/mail/$DOMAIN/$EMAIL_USER/"
    
    log "Syncing Email Data..."
    mkdir -p "$LOCAL_MAIL_PATH"
    rsync -avz -e "ssh -o ControlPath='$SSH_SOCKET'" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_MAIL_PATH" "$LOCAL_MAIL_PATH"
    chown -R "$HESTIA_USER:mail" "$LOCAL_MAIL_PATH"
done

log "Migration Completed!"
