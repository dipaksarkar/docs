#!/usr/bin/env bash
# =============================================================================
# HestiaCP: cPanel Backup Import Script
# =============================================================================
# This script downloads a cPanel backup from a remote server via SSH and then
# imports it using HestiaCP's 'v-import-cpanel' command.
#
# Prerequisites:
#   1. Passwordless SSH access to the cPanel server.
#   2. HestiaCP installed on this server.
#
# Usage:
#   sudo bash cpanel-backup-import.sh \
#     --host remote.cpanel.com \
#     --user cpuser \
#     --backup backup-3.19.2026_03-11-19_gympify.tar.gz \
#     [--port 22] \
#     [--path /home/cpuser]
# =============================================================================

set -euo pipefail

# ─── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${CYAN}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; }
die()     { error "$*"; exit 1; }

# ─── Defaults ────────────────────────────────────────────────────────────────
HOST=""
USER=""
BACKUP=""
PORT="22"
REMOTE_PATH=""

# ─── Argument Parsing ────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --host)   HOST="$2";   shift 2 ;;
    --user)   USER="$2";   shift 2 ;;
    --backup) BACKUP="$2"; shift 2 ;;
    --port)   PORT="$2";   shift 2 ;;
    --path)   REMOTE_PATH="$2"; shift 2 ;;
    -h|--help)
      grep '^#' "$0" | head -n 20 | sed 's/^# \?//'
      exit 0 ;;
    *) die "Unknown option: $1" ;;
  esac
done

# ─── Validation ──────────────────────────────────────────────────────────────
[[ -z "$HOST" ]]   && die "--host is required"
[[ -z "$USER" ]]   && die "--user is required"
[[ -z "$BACKUP" ]] && die "--backup (filename) is required"

[[ $EUID -ne 0 ]] && die "This script must be run as root"

# Ensure v-import-cpanel is available
HESTIA_BIN="/usr/local/hestia/bin"
IMPORT_CMD="./v-import-cpanel.sh"

if [[ ! -x "$IMPORT_CMD" ]]; then
  # Try finding it in path if not in standard Hestia location
  if ! command -v v-import-cpanel &>/dev/null; then
    die "HestiaCP import command 'v-import-cpanel' not found. Is HestiaCP installed?"
  fi
  IMPORT_CMD="./v-import-cpanel.sh"
fi

# Determine remote path
if [[ -z "$REMOTE_PATH" ]]; then
  REMOTE_PATH="/home/${USER}/${BACKUP}"
else
  # Ensure it ends with a slash and append backup name if needed
  if [[ "$REMOTE_PATH" != *"$BACKUP" ]]; then
      REMOTE_PATH="${REMOTE_PATH%/}/${BACKUP}"
  fi
fi

LOCAL_BACKUP_DIR="/backup"
LOCAL_BACKUP_PATH="${LOCAL_BACKUP_DIR}/${BACKUP}"

# ─── Step 1: Download Backup ─────────────────────────────────────────────────
info "Starting download of ${BACKUP} from ${HOST} …"
mkdir -p "$LOCAL_BACKUP_DIR"

if scp -P "$PORT" "${USER}@${HOST}:${REMOTE_PATH}" "$LOCAL_BACKUP_PATH"; then
    success "Backup downloaded successfully to ${LOCAL_BACKUP_PATH}"
else
    die "Failed to download backup from ${HOST}. Check SSH access and file path."
fi

# ─── Step 2: Import Backup ───────────────────────────────────────────────────
info "Importing backup into HestiaCP …"
if $IMPORT_CMD "$LOCAL_BACKUP_PATH" yes; then
    success "Backup import completed!"
else
    error "Import failed. Please check HestiaCP logs."
    die "Import command executed: $IMPORT_CMD $LOCAL_BACKUP_PATH yes"
fi

# ─── Cleanup ─────────────────────────────────────────────────────────────────
info "Cleaning up …"
# Optional: remove the backup file after import to save space
# rm -f "$LOCAL_BACKUP_PATH"

success "Process finished."
echo -e "\nYou can now log in to HestiaCP to verify the imported user."
