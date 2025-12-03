[DOCS](https://idroot.us/install-ioncube-loader-ubuntu-22-04/)

/usr/bin/php8.1 -i | grep extension_dir

sudo cp ioncube_loader_lin_8.3.so ioncube_loader_lin_8.3_ts.so /usr/lib/php/20230831
echo -e "; configuration for php ioncube module\n; priority=00\nzend_extension=/usr/lib/php/20230831/ioncube_loader_lin_8.3.so" | sudo tee /etc/php/8.3/fpm/conf.d/00-ioncube.ini
cat /etc/php/8.3/fpm/conf.d/00-ioncube.ini

echo -e "; configuration for php ioncube module\n; priority=00\nzend_extension=/usr/lib/php/20230831/ioncube_loader_lin_8.3.so" | sudo tee /etc/php/8.3/cli/conf.d/00-ioncube.ini
cat /etc/php/8.3/cli/conf.d/00-ioncube.ini

/etc/php/8.1/fpm/php.ini


cat /etc/php/8.1/fpm/conf.d/00-ioncube.ini
; configuration for php ioncube module
; priority=00
zend_extension=/usr/lib/php/20200930/ioncube_loader_lin_8.1.so
sudo nano /etc/php/8.1/fpm/php.ini

grep -inr ioncube /etc/php/7.0

rm /etc/php/8.3/cli/conf.d/00-ioncube.ini
rm /etc/php/8.3/fpm/conf.d/00-ioncube.ini


# Install ionCube Loader on Ubuntu 22.04

```bash
wget https://raw.githubusercontent.com/dipaksarkar/docs/refs/heads/master/hestiacp/install_ioncube.sh
chmod +x install_ioncube.sh
./install_ioncube.sh
```

Here's an automated script to install IonCube on macOS with Homebrew PHP:

```bash
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
```

**Installation Instructions:**

1. **Save the script:**
   ```bash
   curl -o install-ioncube.sh https://gist.githubusercontent.com/YOUR_GIST/install-ioncube.sh
   chmod +x install-ioncube.sh
   ```

2. **Run the script:**
   ```bash
   ./install-ioncube.sh
   ```

3. **Restart PHP-FPM:**
   ```bash
   brew services restart php@8.2
   # Or for your specific PHP version:
   brew services restart php@$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
   ```

4. **Verify installation:**
   ```bash
   php -v | grep -i ioncube
   ```

**Alternative: Manual Installation**

If you prefer manual steps:

```bash
# Download IonCube for Apple Silicon (ARM64)
curl -L "https://downloads.ioncube.com/loader_downloads/ioncube_loaders_dar_arm64.tar.gz" -o ioncube.tar.gz

# Extract
tar -xzf ioncube.tar.gz

# Copy loader (adjust PHP version if needed)
sudo cp ioncube/ioncube_loader_dar_8.2.so /opt/homebrew/lib/php/pecl/20230831/

# Create config
echo "zend_extension = /opt/homebrew/lib/php/pecl/20230831/ioncube_loader_dar_8.2.so" | sudo tee /opt/homebrew/etc/php/8.2/conf.d/00-ioncube.ini

# Restart PHP-FPM
brew services restart php@8.2
```

**Troubleshooting:**

- If `php -v` doesn't show IonCube, check: `php --ini` to verify the INI file is loaded
- Ensure the loader file matches your PHP version exactly (8.2, 8.3, etc.)
- For Laravel Valet users, restart Valet: `valet restart`
