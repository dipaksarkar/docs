#!/bin/bash
# Installs ionCube on all existing and supported PHP versions using HestiaCP

# set -e

source /etc/hestiacp/hestia.conf

# Detect architecture
arch=$(arch)
[ "$arch" = "x86_64" ] && arch="x86-64"

# Prepare download URL
url="https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_$arch.tar.gz"
tmpdir=$(mktemp -d)

echo "📦 Downloading ionCube loaders for $arch..."
wget -q "$url" -O "$tmpdir/ioncube.tar.gz"

echo "📂 Extracting archive..."
tar -xzf "$tmpdir/ioncube.tar.gz" -C "$tmpdir"

if [ ! -d "$tmpdir/ioncube" ]; then
    echo "❌ Extraction failed — ioncube folder not found."
    exit 1
fi

# Loop through all PHP versions installed via Hestia
for php_version in $($HESTIA/bin/v-list-sys-php plain); do
    loader_file="$tmpdir/ioncube/ioncube_loader_lin_${php_version}.so"

    if [ ! -f "$loader_file" ]; then
        echo "⚠️ ionCube loader for PHP $php_version not found. Skipping..."
        continue
    fi

    # Determine the extension_dir
    extension_dir=$(/usr/bin/php$php_version -i | grep '^extension_dir =>' | awk '{print $3}')
    if [ -z "$extension_dir" ] || [ ! -d "$extension_dir" ]; then
        echo "❌ Could not determine extension_dir for PHP $php_version. Skipping..."
        continue
    fi

    # Copy loader to extension directory
    cp "$loader_file" "$extension_dir"

    # Create ioncube config files for FPM and CLI
    for sapi in cli fpm; do
        conf_file="/etc/php/$php_version/$sapi/conf.d/00-ioncube-loader.ini"
        echo "zend_extension=$(basename "$loader_file")" > "$conf_file"
        echo "✅ Created $conf_file"
    done

    echo "✅ ionCube enabled for PHP $php_version"
done

# Restart all PHP-FPM versions
echo "🔁 Restarting PHP-FPM services..."
$HESTIA/bin/v-restart-service 'php-fpm' yes

# Cleanup
rm -rf "$tmpdir"
echo "🧹 Cleaned up temporary files"

echo "✅ ionCube installation completed"
