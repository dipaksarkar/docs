#!/bin/bash
# Installs ionCube for all PHP versions supported by HestiaCP

set -eo pipefail

source /etc/hestiacp/hestia.conf

# Ensure HESTIA is set
if [ -z "${HESTIA:-}" ]; then
  echo "❌ HESTIA path is not set. Make sure /etc/hestiacp/hestia.conf exists and contains HESTIA variable."
  exit 1
fi

# Detect architecture
arch=$(arch)
[ "$arch" = "x86_64" ] && arch="x86-64"

# Download and extract to current directory
url="https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_$arch.tar.gz"
archive="ioncube_loaders_lin_$arch.tar.gz"

echo "📦 Downloading ionCube loaders for $arch..."
wget -q "$url" -O "$archive"

echo "📂 Extracting archive to ./ioncube"
tar -xzf "$archive"
rm -f "$archive"

if [ ! -d "./ioncube" ]; then
    echo "❌ Extraction failed: ./ioncube directory not found"
    exit 1
fi

echo "🔍 Detected PHP versions:"
php_versions=$($HESTIA/bin/v-list-sys-php plain)
echo "$php_versions"

for php_version in $php_versions; do
    echo "🔧 Processing PHP $php_version..."

    loader_file="./ioncube/ioncube_loader_lin_${php_version}.so"

    if [ ! -f "$loader_file" ]; then
        echo "⚠️ ionCube does NOT support PHP $php_version (loader not found)"
        continue
    fi

    extension_dir=$(/usr/bin/php$php_version -i | grep '^extension_dir =>' | awk '{print $3}')
    echo "📁 extension_dir = $extension_dir"

    if [ -z "$extension_dir" ] || [ ! -d "$extension_dir" ]; then
        echo "❌ extension_dir not found or invalid for PHP $php_version. Skipping..."
        continue
    fi

    cp "$loader_file" "$extension_dir"
    echo "✅ Copied loader to $extension_dir"

    for sapi in cli fpm; do
        conf_file="/etc/php/$php_version/$sapi/conf.d/00-ioncube-loader.ini"
        echo "zend_extension=$(basename "$loader_file")" > "$conf_file"
        echo "✅ Created $conf_file"
    done

    echo "✅ ionCube enabled for PHP $php_version"
done

echo "🔁 Restarting PHP-FPM..."
$HESTIA/bin/v-restart-service 'php-fpm' yes

echo "🎉 ionCube installation complete! (./ioncube retained)"
