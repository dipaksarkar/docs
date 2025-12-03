#!/bin/bash
# filepath: install-ioncube.sh

set -e

echo "🔧 IonCube Loader Installation Script for macOS"
echo "================================================"

# Detect PHP version
PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
echo "✅ Detected PHP version: $PHP_VERSION"

# Get extension directory
EXTENSION_DIR=$(php -i | grep extension_dir | awk '{print $3}' | head -1)
echo "✅ Extension directory: $EXTENSION_DIR"

# Get PHP ini directory
PHP_INI_DIR=$(php --ini | grep "Scan for additional .ini files" | awk '{print $NF}')
if [ "$PHP_INI_DIR" = "(none)" ]; then
    PHP_INI_DIR="/opt/homebrew/etc/php/$PHP_VERSION/conf.d"
fi
echo "✅ PHP INI directory: $PHP_INI_DIR"

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

echo "📥 Downloading IonCube Loader..."
curl -L "https://downloads.ioncube.com/loader_downloads/ioncube_loaders_dar_${DOWNLOAD_ARCH}.tar.gz" -o ioncube.tar.gz

echo "📦 Extracting IonCube Loader..."
tar -xzf ioncube.tar.gz

# Copy loader to extension directory
echo "📋 Installing IonCube Loader..."
if [ -f "ioncube/$LOADER_FILE" ]; then
    sudo cp "ioncube/$LOADER_FILE" "$EXTENSION_DIR/"
    echo "✅ Copied $LOADER_FILE to $EXTENSION_DIR"
else
    echo "❌ ERROR: Loader file not found for PHP $PHP_VERSION"
    echo "Available loaders:"
    ls -la ioncube/ioncube_loader_dar_*.so
    exit 1
fi

# Create INI file
INI_FILE="$PHP_INI_DIR/00-ioncube.ini"
echo "📝 Creating configuration file: $INI_FILE"

sudo mkdir -p "$PHP_INI_DIR"
echo "zend_extension = $EXTENSION_DIR/$LOADER_FILE" | sudo tee "$INI_FILE" > /dev/null

# Cleanup
cd -
rm -rf "$TEMP_DIR"

echo ""
echo "🎉 IonCube Loader installed successfully!"
echo ""
echo "🔍 Verifying installation..."
php -v | grep -i ioncube

if [ $? -eq 0 ]; then
    echo "✅ IonCube Loader is active!"
else
    echo "⚠️  IonCube Loader not detected in PHP output"
    echo "   You may need to restart PHP-FPM:"
    echo "   brew services restart php@$PHP_VERSION"
fi

echo ""
echo "📋 Configuration file: $INI_FILE"
echo "📋 Loader file: $EXTENSION_DIR/$LOADER_FILE"
echo ""
echo "🔄 If not working, restart PHP-FPM:"
echo "   brew services restart php@$PHP_VERSION"
