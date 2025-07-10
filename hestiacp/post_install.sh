#!/bin/bash

set -e

# Check if running on Debian/Ubuntu
if [ ! -f /etc/debian_version ]; then
    echo "❌ This script is designed for Debian/Ubuntu systems only."
    exit 1
fi

# Function to check if a package is already installed
is_installed() {
    dpkg-query -W -f='${Status}' $1 2>/dev/null | grep -c "ok installed" > /dev/null
    return $?
}

# Function to install a package if not already installed
install_package() {
    if is_installed $1; then
        echo "✓ $1 is already installed"
    else
        echo "🔄 Installing $1..."
        sudo apt-get install -y $1
        echo "✅ Successfully installed $1"
    fi
}

echo "📋 Starting installation of Redis and SQLite with PHP extensions..."

# Update package lists
echo "🔄 Updating package lists..."
sudo apt-get update
echo "✅ Package lists updated"

# Install redis-server, sqlite3, and rsync
install_package redis-server
install_package sqlite3
install_package rsync

# Find all installed PHP versions (e.g., php8.2, php8.3)
echo "🔍 Detecting installed PHP versions..."
# More reliable method to detect PHP versions on both Debian and Ubuntu
php_versions=$(ls /usr/bin/php* 2>/dev/null | grep -oE 'php[0-9]+\.[0-9]+$' | sed 's/^php//' | sort -u)

# Fallback if the above doesn't work
if [ -z "$php_versions" ]; then
    php_versions=$(apt list --installed 2>/dev/null | grep -oE 'php[0-9]+\.[0-9]+-common' | grep -oE '[0-9]+\.[0-9]+' | sort -u)
fi

if [ -z "$php_versions" ]; then
    echo "⚠️ No PHP versions detected"
else
    echo "✅ Found PHP versions: $php_versions"
    
    # Install redis and sqlite3 extensions for each PHP version
    echo "🔄 Installing PHP extensions..."
    for version in $php_versions; do
        install_package php${version}-redis
        install_package php${version}-sqlite3
    done
    echo "✅ All PHP extensions installed"
    
    # Update php.ini for each PHP version to allow Laravel queue and Horizon functions
    echo "🔄 Updating PHP configurations for Laravel compatibility..."
    for version in $php_versions; do
        # Find php.ini paths - check both CLI and FPM
        PHP_INI_PATHS=$(find /etc/php/${version} -name php.ini 2>/dev/null)
        
        if [ -z "$PHP_INI_PATHS" ]; then
            echo "⚠️ No php.ini found for PHP ${version}"
        else
            for php_ini in $PHP_INI_PATHS; do
                echo "🔧 Updating ${php_ini}"
                
                # Create backup
                sudo cp "${php_ini}" "${php_ini}.bak.$(date +%Y%m%d%H%M%S)"
                
                # Modify disable_functions directive to keep only system,passthru
                if grep -q "^disable_functions" "${php_ini}"; then
                    # Replace the entire disable_functions line
                    sudo sed -i 's/^disable_functions = .*/disable_functions = system,passthru/' "${php_ini}"
                    echo "✅ Updated disable_functions in ${php_ini} to allow Laravel queue and Horizon"
                fi
            done
        fi
    done
    echo "✅ PHP configurations updated for Laravel compatibility"
fi

echo "🎉 Installation completed successfully!"
