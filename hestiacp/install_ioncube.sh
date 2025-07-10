#!/bin/bash

set -e

IONCUBE_DL_URL="https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz"
IONCUBE_DIR="/usr/local/ioncube"

echo "[*] Installing ionCube for all available PHP versions..."

# Step 1: Download ionCube if not already present
cd /usr/local
if [ ! -f ioncube_loaders_lin_x86-64.tar.gz ]; then
  echo "[*] Downloading ionCube..."
  curl -s -O ${IONCUBE_DL_URL}
fi

if [ ! -d "${IONCUBE_DIR}" ]; then
  tar -xf ioncube_loaders_lin_x86-64.tar.gz
fi

# Step 2: Loop through all installed PHP versions
for PHP_VERSION_PATH in /etc/php/*; do
  PHP_VERSION=$(basename "$PHP_VERSION_PATH")
  IONCUBE_SO="ioncube_loader_lin_${PHP_VERSION}.so"
  EXT_DIR=$(php -d "extension_dir=/tmp" -r "echo ini_get('extension_dir');" 2>/dev/null | sed "s|/tmp|/usr/lib/php/$(php -r 'echo PHP_ZTS ? PHP_API . "zts" : PHP_API;' 2>/dev/null)|")

  if [ -f "${IONCUBE_DIR}/${IONCUBE_SO}" ]; then
    echo "[*] Installing for PHP ${PHP_VERSION}..."

    # Determine extension dir
    EXT_DIR=$(php -d "extension_dir=/tmp" -r "echo ini_get('extension_dir');" 2>/dev/null | sed "s|/tmp|/usr/lib/php/$(php -r 'echo PHP_ZTS ? PHP_API . "zts" : PHP_API;' 2>/dev/null)|")

    # Some systems may have versioned subdirs, use fallback
    EXT_DIR="/usr/lib/php/$(ls -1 /usr/lib/php | head -n 1)"
    IONCUBE_DEST="${EXT_DIR}/${IONCUBE_SO}"

    # Copy ionCube loader to extension dir
    cp "${IONCUBE_DIR}/${IONCUBE_SO}" "${IONCUBE_DEST}"
    echo "  [+] Copied ${IONCUBE_SO} to ${IONCUBE_DEST}"

    for SAPI in cli fpm; do
      CONF_DIR="/etc/php/${PHP_VERSION}/${SAPI}/conf.d"
      CONF_FILE="${CONF_DIR}/00-ioncube-loader.ini"

      if [ -d "$CONF_DIR" ]; then
        echo "zend_extension=${IONCUBE_DEST}" > "${CONF_FILE}"
        echo "  [+] Created ${CONF_FILE}"
      fi
    done

    # Restart PHP-FPM if available
    if systemctl list-units --type=service --all | grep -q "php${PHP_VERSION}-fpm"; then
      echo "  [*] Restarting php${PHP_VERSION}-fpm..."
      systemctl restart "php${PHP_VERSION}-fpm"
    fi
  else
    echo "[!] ionCube loader for PHP ${PHP_VERSION} not found. Skipping..."
  fi
done

# Final check for CLI
php -v | grep -i ioncube && echo "[✓] ionCube loaded in CLI." || echo "[✗] ionCube NOT loaded in CLI."
