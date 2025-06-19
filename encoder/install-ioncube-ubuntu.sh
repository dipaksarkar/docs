#!/bin/bash

# IonCube Encoder Installation Script for Ubuntu
# This script downloads and installs IonCube encoder on Ubuntu

echo "🔐 IonCube Encoder Installation for Ubuntu"
echo "=========================================="

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "⚠️  This script should not be run as root for security reasons"
    echo "   Please run as a regular user with sudo privileges"
    exit 1
fi

# Check if user has sudo privileges
if ! sudo -n true 2>/dev/null; then
    echo "❌ This script requires sudo privileges"
    echo "   Please ensure your user is in the sudo group"
    exit 1
fi

# Check architecture
ARCH=$(uname -m)
case $ARCH in
    x86_64)
        ARCH_NAME="x86-64"
        ;;
    aarch64|arm64)
        ARCH_NAME="aarch64"
        ;;
    *)
        echo "❌ Unsupported architecture: $ARCH"
        echo "   Supported: x86_64, aarch64"
        exit 1
        ;;
esac

echo "✅ Detected architecture: $ARCH ($ARCH_NAME)"

# Create installation directory
INSTALL_DIR="/opt/ioncube"
echo ""
echo "📁 Creating installation directory: $INSTALL_DIR"
sudo mkdir -p "$INSTALL_DIR"

# Download IonCube encoder
echo ""
echo "📥 Downloading IonCube encoder..."
cd /tmp

# Get the latest version URL (you may need to update this)
DOWNLOAD_URL="https://downloads.ioncube.com/eval_tools/ioncube_encoder_eval_linux_${ARCH_NAME}.tar.gz"

echo "   Downloading from: $DOWNLOAD_URL"
wget -O ioncube_encoder.tar.gz "$DOWNLOAD_URL"

if [ $? -ne 0 ]; then
    echo "❌ Failed to download IonCube encoder"
    echo "   Please check your internet connection or download manually from:"
    echo "   https://www.ioncube.com/encoder_eval_download.php"
    exit 1
fi

echo "✅ Download completed"

# Extract the archive
echo ""
echo "📦 Extracting IonCube encoder..."
tar -xzf ioncube_encoder.tar.gz

if [ $? -ne 0 ]; then
    echo "❌ Failed to extract archive"
    exit 1
fi

# Find the extracted directory
EXTRACTED_DIR=$(find . -maxdepth 1 -name "ioncube*" -type d | head -n 1)

if [ -z "$EXTRACTED_DIR" ]; then
    echo "❌ Could not find extracted IonCube directory"
    exit 1
fi

echo "✅ Extracted to: $EXTRACTED_DIR"

# Copy files to installation directory
echo ""
echo "📋 Installing IonCube encoder..."
sudo cp -r "$EXTRACTED_DIR"/* "$INSTALL_DIR/"

if [ $? -ne 0 ]; then
    echo "❌ Failed to copy files to installation directory"
    exit 1
fi

# Set permissions
sudo chmod +x "$INSTALL_DIR/ioncube_encoder"
sudo chown -R root:root "$INSTALL_DIR"

# Create symlink for easier access
echo ""
echo "🔗 Creating symbolic link..."
sudo ln -sf "$INSTALL_DIR/ioncube_encoder" /usr/local/bin/ioncube_encoder

# Verify installation
echo ""
echo "🔍 Verifying installation..."
if [ -x "$INSTALL_DIR/ioncube_encoder" ]; then
    echo "✅ IonCube encoder installed successfully at: $INSTALL_DIR/ioncube_encoder"
    echo "✅ Symbolic link created at: /usr/local/bin/ioncube_encoder"
    
    # Test the encoder
    VERSION_OUTPUT=$("$INSTALL_DIR/ioncube_encoder" --help 2>&1 | head -n 5)
    echo ""
    echo "📋 IonCube encoder information:"
    echo "$VERSION_OUTPUT"
else
    echo "❌ Installation verification failed"
    exit 1
fi

# Clean up
echo ""
echo "🧹 Cleaning up temporary files..."
cd - > /dev/null
rm -f /tmp/ioncube_encoder.tar.gz
rm -rf /tmp/$EXTRACTED_DIR

echo ""
echo "🎉 IonCube encoder installation completed!"
echo ""
echo "Installation details:"
echo "- Binary location: $INSTALL_DIR/ioncube_encoder"
echo "- Symlink location: /usr/local/bin/ioncube_encoder"
echo ""
echo "You can now use the encoder with:"
echo "  ioncube_encoder [options]"
echo ""
echo "To configure the API, update the IONCUBE_PATH in:"
echo "  config/config.js"
echo ""
echo "Next steps:"
echo "1. Run: npm install (if not already done)"
echo "2. Run: npm start"
echo "3. Open: http://localhost:3000"
