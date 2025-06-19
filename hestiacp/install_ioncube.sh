#!/bin/bash

# Exit on error, undefined variable, or pipe failure
set -euo pipefail

source /etc/hestiacp/hestia.conf

# Detect architecture
arch=$(arch)
[ "$arch" = "x86_64" ] && arch="x86-64"

# Prepare download
url="https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_$arch.tar.gz"
tmpdir=$(mktemp -d)

echo "📦 Downloading ionCube loaders for $arch..."
wget -q "$url" -O "$tmpdir/ioncube.tar.gz"

echo "📂 Extracting ionCube archive..."
tar -xzf "$tmpdir/ioncube.tar.gz" -C "$tmpdir"

if [ ! -d "$tmpdir/ioncube" ]; then
    echo "❌ Extraction failed: ioncube directory not found"
    exit 1
fi

echo "🔍 Detected PHP versions:"
php_versions=$($HESTIA/bin/v-list-sys-php plain)
echo "$php_versions"

for php_version in $php_versions; do
    echo "🔧 Processing PHP $php_version..."

    loader_file="$tmpdir/ioncube/ioncube_loader_lin_${php_version}.so"

    if [ ! -f "$loader_file" ]; then
        echo "⚠️ ionCube does NOT support PHP $php_version (loader not found)"
        continue
    fi

    # Get extension_dir
    extension_dir=$(/usr/bin/php$php_version -i | grep '^extension_dir =>' | awk '{print $3}')
    echo "📁 extension_dir = $extension_dir"

    if [ -z "$extension_dir" ] || [ ! -d "$extension_dir" ]; then
        echo "❌ extension_dir not found or invalid for PHP $php_version. Skipping..."
        continue
    fi

    # Copy loader
    cp "$loader_file" "$extension_dir"
    echo "✅ Copied ionCube loader to $extension_dir"

    # Create config files
    for sapi in cli fpm; do
        conf_file="/etc/php/$php_version/$sapi/conf.d/00-ioncube-loader.ini"
        echo "zend_extension=$(basename "$loader_file")" > "$conf_file"
        echo "✅ Created $conf_file"
    done

    echo "✅ ionCube enabled for PHP $php_version"
done

# Restart PHP-FPM
echo "🔁 Restarting PHP-FPM..."
$HESTIA/bin/v-restart-service 'php-fpm' yes

# Clean up
rm -rf "$tmpdir"
echo "🧹 Cleanup done"

echo "🎉 ionCube installation complete!"
