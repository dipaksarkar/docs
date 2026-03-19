#!/usr/bin/env bash
# =============================================================================
# cPanel → HestiaCP Migration Script
# =============================================================================
# Migrates a cPanel account to HestiaCP including:
#   - Web files (public_html)
#   - MySQL databases + users (same username/password)
#   - Mail accounts + stored emails (Maildir)
#
# Run as root. HestiaCP CLI commands (v-*) are called directly.
#
# Usage:
#   bash cpanel-to-hestia-migrate.sh \
#     --cpanel-host cp.example.com \
#     --cpanel-user myuser \
#     --cpanel-key  CPANEL_API_TOKEN \
#     [--domain     example.com]          # override auto-detected main domain
#     [--hestia-user TARGET_USER]         # defaults to --cpanel-user
#     [--skip-files]
#     [--skip-db]
#     [--skip-mail]
#     [--dry-run]
# =============================================================================

set -euo pipefail

# ─── Colour helpers ──────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${CYAN}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; }
die()     { error "$*"; exit 1; }
hr()      { echo -e "${BOLD}$(printf '─%.0s' {1..70})${RESET}"; }

# ─── Defaults ────────────────────────────────────────────────────────────────
CPANEL_HOST=""
CPANEL_USER=""
CPANEL_KEY=""
HESTIA_USER=""   # defaults to CPANEL_USER
DOMAIN_OVERRIDE=""
SKIP_FILES=false
SKIP_DB=false
SKIP_MAIL=false
DRY_RUN=false
DEBUG=false
WORK_DIR="/tmp/cpanel_migration_$$"

# ─── Argument parsing ────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --cpanel-host)  CPANEL_HOST="$2";  shift 2 ;;
    --cpanel-user)  CPANEL_USER="$2";  shift 2 ;;
    --cpanel-key)   CPANEL_KEY="$2";   shift 2 ;;
    --domain)       DOMAIN_OVERRIDE="$2"; shift 2 ;;
    --hestia-user)  HESTIA_USER="$2";  shift 2 ;;
    --skip-files)   SKIP_FILES=true;   shift ;;
    --skip-db)      SKIP_DB=true;      shift ;;
    --skip-mail)    SKIP_MAIL=true;    shift ;;
    --dry-run)      DRY_RUN=true;      shift ;;
    --debug)        DEBUG=true;        shift ;;
    -h|--help)
      sed -n '/^# Usage:/,/^# ===/p' "$0" | sed 's/^# \?//'
      exit 0 ;;
    *) die "Unknown option: $1" ;;
  esac
done

if $DEBUG; then
  info "Debug mode enabled (trace ON)"
  set -x
fi

# ─── Validation ──────────────────────────────────────────────────────────────
[[ -z "$CPANEL_HOST" ]] && die "--cpanel-host is required"
[[ -z "$CPANEL_USER" ]] && die "--cpanel-user is required"
[[ -z "$CPANEL_KEY"  ]] && die "--cpanel-key is required"
HESTIA_USER="${HESTIA_USER:-$CPANEL_USER}"

[[ $EUID -ne 0 ]] && die "This script must be run as root"

for cmd in curl jq ssh mysqldump; do
  command -v "$cmd" &>/dev/null || die "Required tool not found: $cmd"
done

# Usage: hestia_run cmd [args...]
hestia_run() {
  if $DRY_RUN; then
    info "[DRY-RUN] hestia: $*"
    return 0
  fi
  "$@"
}

# Usage: hestia_cli add-user arg1 arg2 ...  → calls v-add-user arg1 arg2 ...
hestia_cli() {
  local subcmd="$1"; local cmd="v-$1"; shift
  if $DRY_RUN; then
    info "[DRY-RUN] ${cmd} $*"
    return 0
  fi

  # Helper to run the command and check if it's an "already exists" error
  run_and_check() {
    local out; local code=0
    out=$("$@" 2>&1) || code=$?
    if [[ $code -ne 0 ]]; then
      if echo "$out" | grep -Ei "exists|already" &>/dev/null; then
        info "Notice: $subcmd $* (already exists, skipping)"
        return 0
      else
        echo "$out" >&2
        warn "${cmd} exited with code ${code}"
        return $code
      fi
    fi
    return 0
  }

  run_and_check "$cmd" "$@"
}

# ─── Helper: cPanel UAPI call ────────────────────────────────────────────────
# The /execute/ endpoint wraps all responses as:
#   { "result": { "status": 1, "data": { ... } } }
# This helper returns the full JSON; callers use .result.data.<field>
cpanel_api() {
  local module="$1"; local func="$2"; shift 2
  local params=""
  for kv in "$@"; do params+="&${kv}"; done
  local resp http_code
  resp=$(curl -s -w '\n__HTTP_CODE__:%{http_code}' \
    -H "Authorization: cpanel ${CPANEL_USER}:${CPANEL_KEY}" \
    "https://${CPANEL_HOST}:2083/execute/${module}/${func}?${params}" 2>&1) || true

  # Split body from http code
  http_code=$(echo "$resp" | grep '__HTTP_CODE__:' | cut -d: -f2)
  resp=$(echo "$resp" | grep -v '__HTTP_CODE__:')

  if [[ "$http_code" == "401" ]]; then
    die "cPanel API auth failed (HTTP 401) — check --cpanel-user and --cpanel-key"
  fi
  if [[ -z "$resp" ]]; then
    die "cPanel API returned empty response for ${module}/${func} (HTTP ${http_code:-no response}) — check --cpanel-host and port 2083"
  fi

  echo "$resp"
}

# ─── Helper: run command on cPanel server as the cPanel user ─────────────────
cpanel_ssh() {
  ssh -o StrictHostKeyChecking=no -o BatchMode=yes \
    "${CPANEL_USER}@${CPANEL_HOST}" "$@"
}

# ─── Helper: check SSH connectivity ──────────────────────────────────────────
check_ssh_access() {
  local target="$1"
  local description="$2"
  info "Checking SSH access to ${target} (${description}) …"
  if ssh -o StrictHostKeyChecking=no -o BatchMode=yes -o ConnectTimeout=5 "${target}" "exit" &>/dev/null; then
    success "SSH access to ${target} OK"
    return 0
  else
    return 1
  fi
}

# ─── Cleanup on exit ─────────────────────────────────────────────────────────
cleanup() { [[ -d "$WORK_DIR" ]] && rm -rf "$WORK_DIR"; }
trap cleanup EXIT
mkdir -p "$WORK_DIR"

# =============================================================================
# STEP 0 – Banner
# =============================================================================
hr
echo -e "${BOLD}  cPanel → HestiaCP Migration${RESET}"
echo -e "  Source  : ${CYAN}${CPANEL_USER}@${CPANEL_HOST}${RESET}"
echo -e "  Target  : ${CYAN}${HESTIA_USER}@localhost${RESET}"
$DRY_RUN && echo -e "  ${YELLOW}DRY-RUN MODE — no changes will be made${RESET}"
hr

# =============================================================================
# STEP 1 – Detect domain & home directory
# =============================================================================
info "Detecting domain and home directory …"

# Home dir is always /home/<user> on standard cPanel
HOME_DIR="/home/${CPANEL_USER}"

if [[ -n "$DOMAIN_OVERRIDE" ]]; then
  DOMAIN="$DOMAIN_OVERRIDE"
  info "Domain  : ${DOMAIN} (from --domain flag)"
else
  # Try DomainInfo/domains_data (available on all modern cPanel versions)
  info "Fetching main domain via DomainInfo/domains_data …"
  DOMAIN_JSON=$(cpanel_api DomainInfo domains_data "format=json" 2>/dev/null || echo "")

  if echo "$DOMAIN_JSON" | jq empty 2>/dev/null; then
    # Grab the first entry where domain_type == "main"
    DOMAIN=$(echo "$DOMAIN_JSON" | \
      jq -r '(.result.data // .data) | to_entries[]?.value |
              select(.domain_type=="main") | .domain' 2>/dev/null | head -1)

    # Fallback: first domain regardless of type
    if [[ -z "$DOMAIN" || "$DOMAIN" == "null" ]]; then
      DOMAIN=$(echo "$DOMAIN_JSON" | \
        jq -r '(.result.data // .data) | to_entries[]?.value | .domain' \
        2>/dev/null | head -1)
    fi
  fi

  # Last resort: fetch via Domains/list_domains
  if [[ -z "$DOMAIN" || "$DOMAIN" == "null" ]]; then
    info "Trying Domains/list_domains …"
    DOMAINS_JSON=$(cpanel_api Domains list_domains 2>/dev/null || echo "")
    if echo "$DOMAINS_JSON" | jq empty 2>/dev/null; then
      DOMAIN=$(echo "$DOMAINS_JSON" | \
        jq -r '(.result.data // .data).main_domain // empty' 2>/dev/null | head -1)
    fi
  fi

  if [[ -z "$DOMAIN" || "$DOMAIN" == "null" ]]; then
    die "Could not auto-detect domain. Pass --domain yourdomain.com to set it manually."
  fi

  info "Domain  : ${DOMAIN}"
fi

info "Home    : ${HOME_DIR}"

# =============================================================================
# STEP 1.5 – Pre-flight SSH check
# =============================================================================
if ! $DRY_RUN; then
  hr
  info "Performing pre-flight SSH connectivity checks …"
  SSH_FAIL=false
  
  if ! check_ssh_access "${CPANEL_USER}@${CPANEL_HOST}" "cPanel User"; then
    error "SSH access failed for ${CPANEL_USER}@${CPANEL_HOST}"
    SSH_FAIL=true
  fi
  
  if $SSH_FAIL; then
    hr
    echo -e "${YELLOW}${BOLD}ACTION REQUIRED: SSH Key Setup${RESET}"
    echo -e "This script requires passwordless SSH access to the cPanel server."
    echo -e "Please run the following commands from this server ($(hostname)):"
    echo -e ""
    echo -e "  # 1. Generate SSH key if needed"
    echo -e "  ${CYAN}ssh-keygen -t rsa -b 4096${RESET}"
    echo -e ""
    echo -e "  # 2. Copy key to cPanel user"
    echo -e "  ${CYAN}ssh-copy-id ${CPANEL_USER}@${CPANEL_HOST}${RESET}"
    hr
    die "SSH connectivity check failed. Please resolve the above and re-run."
  fi
fi

# =============================================================================
# STEP 2 – Create HestiaCP user & web domain
# =============================================================================
hr
info "Creating HestiaCP user '${HESTIA_USER}' …"
HESTIA_PASS=$(openssl rand -base64 32 | tr -dc 'A-Za-z0-9!@#$%' | cut -c1-20)

hestia_cli "add-user" \
  "$HESTIA_USER" "$HESTIA_PASS" "admin@${DOMAIN}" "default" "Migrated User" \
  || true   # ignore if user already exists

hestia_cli "add-web-domain" "$HESTIA_USER" "$DOMAIN" || true

# =============================================================================
# STEP 3 – Migrate web files
# =============================================================================
if ! $SKIP_FILES; then
  hr; info "Migrating web files (public_html) …"

  HESTIA_WEB_DIR="/home/${HESTIA_USER}/web/${DOMAIN}/public_html"

    if ! $DRY_RUN; then
      # Pull web files via tar over SSH directly from local Hestia server
      mkdir -p "$HESTIA_WEB_DIR"
      cpanel_ssh "tar czf - -C '${HOME_DIR}' public_html" \
        | tar xzf - -C "/home/${HESTIA_USER}/web/${DOMAIN}" --strip-components=1
      success "Web files transferred"
    else
      info "[DRY-RUN] Would transfer ${HOME_DIR}/public_html → ${HESTIA_WEB_DIR}"
    fi
else
  warn "Skipping web files (--skip-files)"
fi

# =============================================================================
# STEP 4 – Migrate MySQL databases
# =============================================================================
if ! $SKIP_DB; then
  hr; info "Fetching database list from cPanel …"

  DB_JSON=$(cpanel_api Mysql list_databases)
  DBS=$(echo "$DB_JSON" | jq -r '(.result.data // .data)[]?.database // empty')

  if [[ -z "$DBS" ]]; then
    info "No MySQL databases found."
  else
    for DB in $DBS; do
      info "Processing database: ${DB}"

      SHORT_DB="${DB#${CPANEL_USER}_}"
      HESTIA_DB="${HESTIA_USER}_${SHORT_DB}"
      DUMP_FILE="${WORK_DIR}/${DB}.sql.gz"

      # ── Get users assigned to this DB ─────────────────────────────────────
      PRIV_JSON=$(cpanel_api Mysql list_users_for_database "database=${DB}" 2>/dev/null \
                  || echo '{"result":{"data":[]}}')
      DB_USERS=$(echo "$PRIV_JSON" | jq -r '(.result.data // .data)[]?.user // empty')

      if [[ -z "$DB_USERS" ]]; then
        info "  No users found for '${DB}'; creating temporary migration user …"
        DB_USER="${CPANEL_USER}_migrate"
        NEW_PASS=$(openssl rand -base64 32 | tr -dc 'A-Za-z0-9' | cut -c1-20)
        
        # Create user and grant privileges via cPanel API
        cpanel_api Mysql create_user "user=${DB_USER}" "password=${NEW_PASS}" >/dev/null
        cpanel_api Mysql set_privileges_on_database "user=${DB_USER}" "database=${DB}" "privileges=ALL PRIVILEGES" >/dev/null
      else
        # Pick the first user and reset their password via API
        DB_USER=$(echo "$DB_USERS" | head -1)
        NEW_PASS=$(openssl rand -base64 32 | tr -dc 'A-Za-z0-9' | cut -c1-20)
        info "  Setting new random password for source DB user '${DB_USER}' …"
        cpanel_api Mysql set_password "user=${DB_USER}" "password=${NEW_PASS}" >/dev/null
      fi

      SHORT_USER="${DB_USER#${CPANEL_USER}_}"
      HESTIA_DB_USER="${HESTIA_USER}_${SHORT_USER}"
      
      # ── Create DB + user on HestiaCP ───────────────────────────────────
      info "  Creating target DB '${HESTIA_DB}' / user '${HESTIA_DB_USER}' …"
      if ! hestia_cli "add-database" \
        "$HESTIA_USER" "$SHORT_DB" "$SHORT_USER" "${NEW_PASS}" \
        "mysql" "localhost"; then
        error "  Failed to create database '${HESTIA_DB}' on HestiaCP. Skipping import."
        continue
      fi

      # ── Dump using the new credentials ─────────────────────────────────────
      if ! $DRY_RUN; then
        info "  Dumping ${DB} from source …"
        if ! cpanel_ssh "mysqldump -u'${DB_USER}' -p'${NEW_PASS}' --single-transaction --routines --triggers --events '${DB}' | gzip" > "$DUMP_FILE"; then
          error "  Dump failed for ${DB}!"
          rm -f "$DUMP_FILE"
          continue
        fi
        
        # Cleanup temporary user if we created one
        if [[ "$DB_USER" == "${CPANEL_USER}_migrate" ]]; then
           cpanel_api Mysql delete_user "user=${DB_USER}" >/dev/null
        fi
        
        success "  Dump: $(du -sh "$DUMP_FILE" | cut -f1)"
      fi

      # ── Import dump ────────────────────────────────────────────────────────
      if ! $DRY_RUN; then
        info "  Importing dump into '${HESTIA_DB}' …"
        
        # Hestia's v-import-database expects an uncompressed .sql file
        SQL_FILE="${DUMP_FILE%.gz}"
        zcat "$DUMP_FILE" > "$SQL_FILE"
        
        # Running locally on HestiaCP
        if v-import-database "$HESTIA_USER" "$SHORT_DB" "$SQL_FILE" &>/dev/null; then
          success "  Database '${HESTIA_DB}' imported"
        else
          # Fallback to direct mysql if v-import-database fails or is missing
          mysql "${HESTIA_DB}" < "$SQL_FILE" && success "  Database '${HESTIA_DB}' imported (fallback)" || error "  Import failed"
        fi
        rm -f "$SQL_FILE"
      else
        info "[DRY-RUN] Would import ${DUMP_FILE} → ${HESTIA_DB}"
      fi
    done
  fi

  # ── PostgreSQL (if any) ─────────────────────────────────────────────────────
  info "Checking for PostgreSQL databases …"
  PG_JSON=$(cpanel_api Postgresql list_databases 2>/dev/null || echo '{"result":{"data":[]}}')
  PG_DBS=$(echo "$PG_JSON" | jq -r '(.result.data // .data)[]?.database // empty')

  for PGDB in $PG_DBS; do
    info "Processing PostgreSQL database: ${PGDB}"
    PGDUMP_FILE="${WORK_DIR}/${PGDB}.pg.gz"
    SHORT_DB="${PGDB#${CPANEL_USER}_}"

    if ! $DRY_RUN; then
      cpanel_ssh "pg_dump '${PGDB}' | gzip" > "$PGDUMP_FILE"

      hestia_cli "add-database" \
        "$HESTIA_USER" "$SHORT_DB" "$SHORT_DB" "changeme" \
        "pgsql" "localhost" "$SHORT_DB" || true

      info "  Importing PostgreSQL dump …"
      zcat "$PGDUMP_FILE" | psql "${HESTIA_USER}_${SHORT_DB}"
      success "  PostgreSQL '${HESTIA_USER}_${SHORT_DB}' imported"
    else
      info "[DRY-RUN] Would migrate PG DB: $PGDB"
    fi
  done

else
  warn "Skipping databases (--skip-db)"
fi

# =============================================================================
# STEP 5 – Migrate mail accounts & emails
# =============================================================================
if ! $SKIP_MAIL; then
  hr; info "Fetching email accounts from cPanel …"

  MAIL_JSON=$(cpanel_api Email list_pops)
  ACCOUNTS=$(echo "$MAIL_JSON" | jq -c '(.result.data // .data)[]?')

  if [[ -z "$ACCOUNTS" ]]; then
    info "No email accounts found."
  else
    hestia_cli "add-mail-domain" "$HESTIA_USER" "$DOMAIN" || true

    while IFS= read -r acc; do
      EMAIL=$(echo "$acc" | jq -r '.email')
      LOCAL=$(echo "$acc" | jq -r '.user')
      QUOTA=$(echo "$acc" | jq -r '.diskquota // "0"')

      info "Migrating mail account: ${EMAIL}"

      # ── Retrieve password hash from cPanel shadow file ────────────────────
      MAIL_PASS_HASH=$(cpanel_ssh \
        "grep '^${LOCAL}:' \"${HOME_DIR}/etc/${DOMAIN}/shadow\" 2>/dev/null | cut -d: -f2 || echo ''" \
        2>/dev/null || echo "")

      if [[ -n "$MAIL_PASS_HASH" ]]; then
        MAIL_PASS="placeholder_overwritten_below"
      else
        warn "  Cannot read shadow for ${EMAIL}; a random password will be set"
        MAIL_PASS=$(openssl rand -base64 24 | tr -dc 'A-Za-z0-9!@#' | cut -c1-16)
      fi

      QUOTA_MB="0"
      [[ "$QUOTA" =~ ^[0-9]+$ ]] && QUOTA_MB="$QUOTA"

      # ── Create mail account on HestiaCP ───────────────────────────────────
      hestia_cli "add-mail-account" \
        "$HESTIA_USER" "$DOMAIN" "$LOCAL" "$MAIL_PASS" "$QUOTA_MB" || true

      # ── Restore original password hash ─────────────────────────────────────
      if [[ -n "$MAIL_PASS_HASH" ]] && ! $DRY_RUN; then
        info "  Restoring original password hash for ${EMAIL} …"
        HESTIA_SHADOW="/home/${HESTIA_USER}/mail/${DOMAIN}/.shadow"
        hestia_run bash -c "
          if grep -q '^${LOCAL}:' '${HESTIA_SHADOW}' 2>/dev/null; then
            sed -i 's|^${LOCAL}:.*|${LOCAL}:${MAIL_PASS_HASH}|' '${HESTIA_SHADOW}'
          else
            echo '${LOCAL}:${MAIL_PASS_HASH}' >> '${HESTIA_SHADOW}'
          fi"
        success "  Password restored for ${EMAIL}"
      fi

      # ── Sync Maildir ───────────────────────────────────────────────────────
      info "  Syncing Maildir for ${EMAIL} …"
      if ! $DRY_RUN; then
        HESTIA_MAIL_DOMAIN_DIR="/home/${HESTIA_USER}/mail/${DOMAIN}"
        mkdir -p "$HESTIA_MAIL_DOMAIN_DIR"
        cpanel_ssh "tar czf - -C '${HOME_DIR}/mail/${DOMAIN}' '${LOCAL}' 2>/dev/null || true" \
          | tar xzf - -C "$HESTIA_MAIL_DOMAIN_DIR" 2>/dev/null || true
        chown -R "${HESTIA_USER}:mail" "${HESTIA_MAIL_DOMAIN_DIR}/${LOCAL}" 2>/dev/null || true
        success "  Maildir synced for ${EMAIL}"
      else
        info "[DRY-RUN] Would sync Maildir for ${EMAIL}"
      fi

    done <<< "$ACCOUNTS"

    # ── Email forwarders ──────────────────────────────────────────────────────
    info "Migrating email forwarders …"
    FWD_JSON=$(cpanel_api Email list_forwarders "domain=${DOMAIN}")
    while IFS= read -r fwd; do
      FROM_LOCAL=$(echo "$fwd" | jq -r '.dest'    | cut -d@ -f1)
      TO_EMAIL=$(echo "$fwd"   | jq -r '.forward')
      
      if [[ -z "$FROM_LOCAL" ]]; then
        info "  Skipping catchall forwarder (@${DOMAIN}) as Hestia requires a local account."
        continue
      fi

      info "  Forwarder: ${FROM_LOCAL}@${DOMAIN} → ${TO_EMAIL}"
      hestia_cli "add-mail-account-alias" \
        "$HESTIA_USER" "$DOMAIN" "$FROM_LOCAL" "$TO_EMAIL" || true
    done <<< "$(echo "$FWD_JSON" | jq -c '(.result.data // .data)[]?')"

    # ── Create DNS domain on HestiaCP first ─────────────────────────────────────
    hestia_cli "add-dns-domain" "$HESTIA_USER" "$DOMAIN" || true

    # ── MX records ────────────────────────────────────────────────────────────
    info "Migrating MX records …"
    MX_JSON=$(cpanel_api Email list_mx_records "domain=${DOMAIN}")
    while IFS= read -r mx; do
      MX_PRIO=$(echo "$mx" | jq -r '.priority')
      MX_DEST=$(echo "$mx" | jq -r '.exchange')
      
      [[ -z "$MX_DEST" ]] && continue

      info "  MX ${MX_PRIO} ${MX_DEST}"
      hestia_cli "add-dns-record" \
        "$HESTIA_USER" "$DOMAIN" "" "MX" "$MX_DEST" "$MX_PRIO" "3600" || true
    done <<< "$(echo "$MX_JSON" | jq -c '(.result.data // .data)[]?')"
  fi

else
  warn "Skipping mail (--skip-mail)"
fi

# =============================================================================
# STEP 6 – Fix ownership & rebuild user
# =============================================================================
hr; info "Fixing ownership and rebuilding HestiaCP user …"
if ! $DRY_RUN; then
  hestia_run bash -c "
    chown -R '${HESTIA_USER}:${HESTIA_USER}' '/home/${HESTIA_USER}/web/'  2>/dev/null || true
    chown -R '${HESTIA_USER}:mail'            '/home/${HESTIA_USER}/mail/' 2>/dev/null || true
    v-rebuild-user '${HESTIA_USER}' no 2>/dev/null || true"
  success "Done"
else
  info "[DRY-RUN] Would fix ownership and rebuild user '${HESTIA_USER}'"
fi

# =============================================================================
# Done
# =============================================================================
hr
success "Migration complete!"
info "Final variable state: CPANEL_HOST='${CPANEL_HOST}', HESTIA_USER='${HESTIA_USER}'"
echo ""
echo -e "  ${BOLD}Summary${RESET}"
echo -e "  HestiaCP user : ${CYAN}${HESTIA_USER}${RESET}"
echo -e "  HestiaCP pass : ${YELLOW}${HESTIA_PASS}${RESET}  ← save this!"
echo -e "  Domain        : ${CYAN}${DOMAIN}${RESET}"
echo ""
echo -e "  ${YELLOW}Next steps:${RESET}"
echo -e "  1. Update DNS to point to this server"
echo -e "  2. Test website, databases, and email"
echo -e "  3. Update app config files — DB names are prefixed with '${HESTIA_USER}_'"
echo -e "  4. Change the HestiaCP panel password via the web UI"
hr
