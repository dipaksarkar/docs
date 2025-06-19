#!/bin/bash

# IonCube Encoder API Installation Script
# This script sets up the IonCube Encoder API service

echo "🔐 IonCube Encoder API Installation"
echo "=================================="

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Installing Node.js..."
    echo "   Updating package list..."
    sudo apt update
    echo "   Installing Node.js and npm..."
    sudo apt install -y nodejs npm
    
    if ! command -v node &> /dev/null; then
        echo "❌ Failed to install Node.js. Please install manually:"
        echo "   curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -"
        echo "   sudo apt-get install -y nodejs"
        exit 1
    fi
fi

echo "✅ Node.js version: $(node --version)"

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed. Installing npm..."
    sudo apt install -y npm
    
    if ! command -v npm &> /dev/null; then
        echo "❌ Failed to install npm"
        exit 1
    fi
fi

echo "✅ npm version: $(npm --version)"

# Install dependencies
echo ""
echo "📦 Installing dependencies..."
npm install

if [ $? -eq 0 ]; then
    echo "✅ Dependencies installed successfully"
else
    echo "❌ Failed to install dependencies"
    exit 1
fi

# Create necessary directories
echo ""
echo "📁 Creating directories..."
mkdir -p uploads temp output

echo "✅ Directories created"

# Check if IonCube encoder is available
echo ""
echo "🔍 Checking for IonCube encoder..."

IONCUBE_PATHS=(
    "/usr/local/ioncube/ioncube_encoder"
    "/opt/ioncube/ioncube_encoder"
    "/usr/bin/ioncube_encoder"
    "/usr/local/bin/ioncube_encoder"
    "$(which ioncube_encoder 2>/dev/null)"
)

IONCUBE_FOUND=false
for path in "${IONCUBE_PATHS[@]}"; do
    if [ -f "$path" ] && [ -x "$path" ]; then
        echo "✅ IonCube encoder found at: $path"
        IONCUBE_FOUND=true
        break
    fi
done

if [ "$IONCUBE_FOUND" = false ]; then
    echo "⚠️  IonCube encoder not found in common locations"
    echo "   Please install IonCube encoder manually:"
    echo "   1. Download from: https://www.ioncube.com/loaders.php"
    echo "   2. Extract and install according to documentation"
    echo "   3. Update the path in config/config.js"
    echo ""
    echo "   Or use the provided installation scripts:"
    echo "   - For HestiaCP: ../hestiacp/install_ioncube.sh"
    echo "   - For CloudPanel: ../cloudpanel/enable_ioncube.sh"
else
    echo "✅ IonCube encoder is ready"
fi

# Create environment file template
echo ""
echo "⚙️  Creating environment template..."
cat > .env.example << EOF
# IonCube Encoder API Configuration

# IonCube encoder binary path
IONCUBE_PATH="/usr/local/ioncube/ioncube_encoder"

# Server configuration
PORT=3000

# Directory paths
TEMP_DIR="./temp"
UPLOADS_DIR="./uploads"
OUTPUT_DIR="./output"

# Logging
LOG_LEVEL="info"
ENABLE_FILE_LOGGING="false"
EOF

echo "✅ Environment template created (.env.example)"

# Set permissions
echo ""
echo "🔒 Setting permissions..."
chmod +x install.sh
chmod 755 uploads temp output

echo "✅ Permissions set"

echo ""
echo "🎉 Installation completed!"
echo ""
echo "Next steps:"
echo "1. Configure IonCube path in config/config.js if needed"
echo "2. Start the server: npm start"
echo "3. Open browser: http://localhost:3000"
echo ""
echo "For development mode: npm run dev"
echo ""
echo "API Endpoint: POST http://localhost:3000/encode"
echo "Web Interface: http://localhost:3000"
echo ""
echo "Read README.md for detailed usage instructions."
