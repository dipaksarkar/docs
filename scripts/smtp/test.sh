#!/usr/bin/env bash
# smtp_test.sh
# A small SMTP test script in bash.
# - Supports implicit SSL (TLS) and STARTTLS
# - Optional AUTH LOGIN (base64)
# - Sends a simple message (no attachments)
# - Prints JSON result and exits 0 on success, 2 on failure

set -u

progname=$(basename "$0")

usage(){
  cat <<EOF
Usage: $progname --host HOST --from FROM --to TO [--port PORT] [--ssl|--starttls] [--user USER --password PASS] [--subject SUBJECT] [--body BODY] [--debug]

Example:
  $progname --host smtp.example.com --starttls --from you@example.com --to recipient@example.org --user you --password secret --subject "Test" --body "Hello"

Notes:
- Requires openssl for SSL/STARTTLS. For plaintext it will use nc if available.
- This script is a simple tester — it does not support attachments or advanced MIME.
EOF
}

# default values
HOST=""
PORT=""
USE_SSL=0
USE_STARTTLS=0
USER=""
PASS=""
FROM_ADDR=""
TO_ADDRS=()
SUBJECT="SMTP Test"
BODY="This is a test message"
DEBUG=0

# parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --host) HOST="$2"; shift 2;;
    --port) PORT="$2"; shift 2;;
    --ssl) USE_SSL=1; shift;;
    --starttls) USE_STARTTLS=1; shift;;
    --user) USER="$2"; shift 2;;
    --password) PASS="$2"; shift 2;;
    --from) FROM_ADDR="$2"; shift 2;;
    --to) TO_ADDRS+=("$2"); shift 2;;
    --subject) SUBJECT="$2"; shift 2;;
    --body) BODY="$2"; shift 2;;
    --debug) DEBUG=1; shift;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1"; usage; exit 2;;
  esac
done

if [[ -z "$HOST" || -z "$FROM_ADDR" || ${#TO_ADDRS[@]} -eq 0 ]]; then
  echo "Missing required arguments" >&2
  usage
  exit 2
fi

# port defaults
if [[ -n "$PORT" ]]; then
  port="$PORT"
else
  if [[ $USE_SSL -eq 1 ]]; then
    port=465
  elif [[ $USE_STARTTLS -eq 1 ]]; then
    port=587
  else
    port=25
  fi
fi

start_time=$(date +%s.%N)

# create temp files
tmp_cmd=$(mktemp /tmp/smtp_cmds.XXXXXX)
out_file=$(mktemp /tmp/smtp_out.XXXXXX)
trap 'rm -f "$tmp_cmd" "$out_file"' EXIT

# build SMTP command sequence
# EHLO/HELO
cat > "$tmp_cmd" <<EOF
EHLO localhost

EOF

# If we rely on openssl -starttls it will perform STARTTLS for us, so we still send commands after
# For AUTH
if [[ -n "$USER" ]]; then
  # insert placeholder; we'll append AUTH LOGIN sequence later
  :
fi

# Build the rest of the sequence: MAIL FROM, RCPT TO, DATA, message, QUIT
{
  echo -en "EHLO localhost\r\n"
  if [[ $USE_STARTTLS -eq 1 && $USE_SSL -eq 0 ]]; then
    # When using openssl -starttls smtp we will call openssl with -starttls; the connection will be TLS
    # We still send EHLO (above) and then continue after TLS handshake
    # Nothing special to add here now
    :
  fi

  if [[ -n "$USER" ]]; then
    # AUTH LOGIN will be issued after connection (for openssl -starttls the TLS layer is negotiated by openssl)
    echo -en "AUTH LOGIN\r\n"
    # base64 encode username and password
    enc_user=$(printf "%s" "$USER" | base64)
    enc_pass=$(printf "%s" "$PASS" | base64)
    echo -en "$enc_user\r\n"
    echo -en "$enc_pass\r\n"
  fi

  echo -en "MAIL FROM:<$FROM_ADDR>\r\n"
  for rcpt in "${TO_ADDRS[@]}"; do
    echo -en "RCPT TO:<$rcpt>\r\n"
  done
  echo -en "DATA\r\n"
  # Headers
  echo -en "From: $FROM_ADDR\r\n"
  echo -en "To: ${TO_ADDRS[*]}\r\n"
  echo -en "Subject: $SUBJECT\r\n"
  echo -en "\r\n"
  # Body
  echo -en "$BODY\r\n"
  echo -en ".\r\n"
  echo -en "QUIT\r\n"
} > "$tmp_cmd"

# helper to run transport
run_transport() {
  local transport="$1" # ssl | starttls | plain
  if [[ $DEBUG -eq 1 ]]; then
    echo "Using transport: $transport, host=$HOST, port=$port" >&2
    echo "Commands sent (debug):" >&2
    sed -n '1,200p' "$tmp_cmd" >&2
  fi

  if [[ "$transport" == "ssl" ]]; then
    # implicit SSL
    if ! command -v openssl >/dev/null 2>&1; then
      echo "openssl required for SSL mode" >&2
      return 2
    fi
    # Use -crlf to ensure CRLF line endings and -quiet to suppress session info
    openssl s_client -crlf -quiet -connect "$HOST:$port" < "$tmp_cmd" > "$out_file" 2>&1
    return $?
  elif [[ "$transport" == "starttls" ]]; then
    if ! command -v openssl >/dev/null 2>&1; then
      echo "openssl required for STARTTLS mode" >&2
      return 2
    fi
    # openssl will perform STARTTLS handshake when -starttls smtp is used
    openssl s_client -crlf -quiet -starttls smtp -connect "$HOST:$port" < "$tmp_cmd" > "$out_file" 2>&1
    return $?
  else
    # plain
    if command -v nc >/dev/null 2>&1; then
      nc "$HOST" "$port" < "$tmp_cmd" > "$out_file" 2>&1
      return $?
    else
      # Fallback: try using openssl without starttls (acts as plain TCP connector)
      if command -v openssl >/dev/null 2>&1; then
        openssl s_client -crlf -quiet -connect "$HOST:$port" < "$tmp_cmd" > "$out_file" 2>&1
        return $?
      else
        echo "Neither nc nor openssl available to make a TCP connection" >&2
        return 2
      fi
    fi
  fi
}

# choose transport
transport="plain"
if [[ $USE_SSL -eq 1 ]]; then
  transport="ssl"
elif [[ $USE_STARTTLS -eq 1 ]]; then
  transport="starttls"
fi

run_transport "$transport"
ret=$?

end_time=$(date +%s.%N)
# compute duration
# bc may not be present on macOS default; use awk to compute difference
duration=$(awk -v s="$start_time" -v e="$end_time" 'BEGIN{printf "%.3f", e - s}')

# read output (trim to reasonable size)
full_out=$(sed -n '1,800p' "$out_file" | tr -d '\r')

# crude success/failure detection
ok=0
error=""
# If we can find a 250 response after DATA or an overall 250 that indicates acceptance, treat as success
if echo "$full_out" | grep -E "(250|2\.0\.0)" >/dev/null 2>&1; then
  # but ensure no 5xx errors
  if echo "$full_out" | grep -E "(^5| 5[0-9]{2})" >/dev/null 2>&1; then
    ok=0
    error="server returned 5xx error"
  else
    ok=1
  fi
else
  ok=0
  error="no 250 response detected"
fi

# Output JSON
if [[ $ok -eq 1 ]]; then
  printf '{"ok": true, "duration": %s, "transport": "%s"}' "$duration" "$transport"
  echo
  exit 0
else
  # include some of the server output for debugging
  # escape newlines for JSON (simple approach)
  out_escaped=$(printf '%s' "$full_out" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')
  # python3 may not exist; try fallback
  if [[ $? -ne 0 ]]; then
    out_escaped="$(printf '%s' "$full_out" | sed ':a;N;$!ba;s/"/\"/g;s/\n/\\n/g')"
    printf '{"ok": false, "duration": %s, "error": "%s", "output": "%s"}' "$duration" "$error" "$out_escaped"
    echo
    exit 2
  else
    # python produced a quoted JSON string; include as-is
    printf '{"ok": false, "duration": %s, "error": "%s", "output": %s}' "$duration" "$error" "$out_escaped"
    echo
    exit 2
  fi
fi
