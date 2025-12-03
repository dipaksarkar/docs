#!/bin/bash
// filepath: install-ioncube.sh

set -e

echo "🔧 IonCube Loader Installation Script for macOS"
echo "================================================"
echo ""

# Detect PHP version
PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
PHP_FULL_VERSION=$(php -r "echo PHP_VERSION;")
echo "✅ Detected PHP version: $PHP_VERSION ($PHP_FULL_VERSION)"

# Get extension directory
EXTENSION_DIR=$(php -i | grep extension_dir | awk '{print $3}' | head -1)
echo "✅ Extension directory: $EXTENSION_DIR"

# Get PHP ini directory
PHP_INI_DIR=$(php --ini | grep "Scan for additional .ini files" | awk '{print $NF}')
if [ "$PHP_INI_DIR" = "(none)" ]; then
    PHP_INI_DIR="/opt/homebrew/etc/php/$PHP_VERSION/conf.d"
fi
echo "✅ PHP INI directory: $PHP_INI_DIR"

# Get PHP-FPM config directory
PHP_FPM_INI_DIR="/opt/homebrew/etc/php/$PHP_VERSION/conf.d"
echo "✅ PHP-FPM INI directory: $PHP_FPM_INI_DIR"

# Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    LOADER_FILE="ioncube_loader_dar_${PHP_VERSION}.so"
    DOWNLOAD_ARCH="arm64"
else
    LOADER_FILE="ioncube_loader_dar_${PHP_VERSION}.so"
    DOWNLOAD_ARCH="x86-64"
fi
echo "✅ Architecture: $ARCH ($DOWNLOAD_ARCH)"

# Download IonCube
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

echo ""
echo "📥 Downloading IonCube Loader..."
curl -L "https://downloads.ioncube.com/loader_downloads/ioncube_loaders_dar_${DOWNLOAD_ARCH}.tar.gz" -o ioncube.tar.gz

echo "📦 Extracting IonCube Loader..."
tar -xzf ioncube.tar.gz

# Verify loader file exists
if [ ! -f "ioncube/$LOADER_FILE" ]; then
    echo "❌ ERROR: Loader file not found for PHP $PHP_VERSION"
    echo "Available loaders:"
    ls -la ioncube/ioncube_loader_dar_*.so
    exit 1
fi

# Copy loader to extension directory
echo ""
echo "📋 Installing IonCube Loader..."
sudo cp "ioncube/$LOADER_FILE" "$EXTENSION_DIR/"
echo "✅ Copied $LOADER_FILE to $EXTENSION_DIR"

# Set proper permissions
sudo chmod 755 "$EXTENSION_DIR/$LOADER_FILE"

# Create INI file for CLI
CLI_INI_FILE="$PHP_INI_DIR/00-ioncube.ini"
echo ""
echo "📝 Creating CLI configuration: $CLI_INI_FILE"
sudo mkdir -p "$PHP_INI_DIR"
echo "zend_extension = $EXTENSION_DIR/$LOADER_FILE" | sudo tee "$CLI_INI_FILE" > /dev/null

# Create INI file for PHP-FPM (web services)
FPM_INI_FILE="$PHP_FPM_INI_DIR/00-ioncube.ini"
echo "📝 Creating PHP-FPM configuration: $FPM_INI_FILE"
sudo mkdir -p "$PHP_FPM_INI_DIR"
echo "zend_extension = $EXTENSION_DIR/$LOADER_FILE" | sudo tee "$FPM_INI_FILE" > /dev/null

# Cleanup
cd -
rm -rf "$TEMP_DIR"

echo ""
echo "🎉 IonCube Loader installed successfully!"
echo ""

# Restart PHP-FPM
echo "🔄 Restarting PHP-FPM..."
if brew services list | grep -q "php@$PHP_VERSION.*started"; then
    brew services restart php@$PHP_VERSION
    echo "✅ PHP-FPM restarted"
else
    echo "⚠️  PHP-FPM not running, starting it..."
    brew services start php@$PHP_VERSION
    echo "✅ PHP-FPM started"
fi

# Restart Valet if installed
if command -v valet &> /dev/null; then
    echo "🔄 Restarting Laravel Valet..."
    valet restart
    echo "✅ Valet restarted"
fi

echo ""
echo "🔍 Verifying installation..."
echo ""

# Verify CLI installation
echo "📋 CLI Verification:"
if php -v | grep -i ioncube > /dev/null; then
    echo "✅ IonCube Loader is active in CLI"
    php -v | grep -i ioncube
else
    echo "⚠️  IonCube Loader not detected in CLI"
fi

echo ""
echo "📋 Web Service Verification:"
echo "Create a test file to verify web installation:"
echo ""
echo "Create: /path/to/your/project/public/ioncube-test.php"
echo "<?php phpinfo(); ?>"
echo ""
echo "Then visit: http://gympify.test/ioncube-test.php"
echo "Search for 'ionCube' in the output"
echo ""

echo "📋 Installation Summary:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "PHP Version:        $PHP_VERSION ($PHP_FULL_VERSION)"
echo "Architecture:       $ARCH ($DOWNLOAD_ARCH)"
echo "Extension Dir:      $EXTENSION_DIR"
echo "Loader File:        $LOADER_FILE"
echo "CLI Config:         $CLI_INI_FILE"
echo "PHP-FPM Config:     $FPM_INI_FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🔧 Troubleshooting:"
echo "1. Check loaded extensions: php -m | grep -i ioncube"
echo "2. Check PHP-FPM config: cat $FPM_INI_FILE"
echo "3. Restart services: brew services restart php@$PHP_VERSION && valet restart"
echo "4. Check phpinfo() in browser for 'ionCube Loader'"
