#!/bin/bash

# Get all installed PHP versions
PHP_VERSIONS=$(ls /etc/php/ | sort -V)

echo "Detected PHP versions: $PHP_VERSIONS"

# Loop through each PHP version
for VERSION in $PHP_VERSIONS; do
    echo "Processing PHP $VERSION..."
    
    # Define file paths
    CLI_INI="/etc/php/$VERSION/cli/php.ini"
    FPM_INI="/etc/php/$VERSION/fpm/php.ini"
    IONCUBE_LINE="zend_extension=ioncube_loader_lin_$VERSION.so"
    
    # Enable ionCube in CLI php.ini
    if [[ -f "$CLI_INI" ]]; then
        echo "Updating $CLI_INI..."
        sudo sed -i "s@;${IONCUBE_LINE}@${IONCUBE_LINE}@" "$CLI_INI"
    else
        echo "⚠️ $CLI_INI not found, skipping..."
    fi

    # Enable ionCube in FPM php.ini
    if [[ -f "$FPM_INI" ]]; then
        echo "Updating $FPM_INI..."
        sudo sed -i "s@;${IONCUBE_LINE}@${IONCUBE_LINE}@" "$FPM_INI"
        
        # Restart PHP-FPM service
        echo "Restarting PHP-FPM for PHP $VERSION..."
        sudo systemctl restart php$VERSION-fpm
    else
        echo "⚠️ $FPM_INI not found, skipping..."
    fi
done

echo "✅ ionCube Loader enabled for all detected PHP versions!"
