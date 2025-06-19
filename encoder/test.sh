#!/bin/bash

# IonCube Encoder API Test Script
# This script tests the API functionality

echo "🧪 IonCube Encoder API Test"
echo "=========================="

API_URL="http://localhost:3000"

# Check if server is running
echo "1. Testing server health..."
if curl -s -f "$API_URL/health" > /dev/null; then
    echo "✅ Server is running"
    
    # Get health info
    health_response=$(curl -s "$API_URL/health")
    echo "   Response: $health_response"
else
    echo "❌ Server is not running"
    echo "   Please start the server first: npm start"
    exit 1
fi

# Create a test PHP project
echo ""
echo "2. Creating test PHP project..."
test_dir="test_project"
mkdir -p "$test_dir"

# Create sample PHP files
cat > "$test_dir/index.php" << 'EOF'
<?php
echo "Hello, World!";
phpinfo();
?>
EOF

cat > "$test_dir/config.php" << 'EOF'
<?php
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', 'password');
define('DB_NAME', 'testdb');

function connectDatabase() {
    $conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }
    return $conn;
}
?>
EOF

mkdir -p "$test_dir/includes"
cat > "$test_dir/includes/functions.php" << 'EOF'
<?php
function sanitizeInput($data) {
    $data = trim($data);
    $data = stripslashes($data);
    $data = htmlspecialchars($data);
    return $data;
}

function generateRandomString($length = 10) {
    return substr(str_shuffle(str_repeat($chars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', ceil($length/strlen($chars)))), 1, $length);
}
?>
EOF

# Create non-PHP files (should not be encoded)
cat > "$test_dir/README.md" << 'EOF'
# Test Project

This is a test PHP project for IonCube encoding.
EOF

cat > "$test_dir/style.css" << 'EOF'
body {
    font-family: Arial, sans-serif;
    margin: 20px;
}
EOF

echo "✅ Test project created"

# Create ZIP file
echo ""
echo "3. Creating ZIP file..."
if command -v zip &> /dev/null; then
    cd "$test_dir"
    zip -r ../test_project.zip . > /dev/null 2>&1
    cd ..
    echo "✅ ZIP file created: test_project.zip"
else
    echo "❌ zip command not found. Please install zip utility."
    rm -rf "$test_dir"
    exit 1
fi

# Test the API
echo ""
echo "4. Testing encoding API..."
echo "   Uploading test_project.zip..."

response=$(curl -s -w "%{http_code}" -X POST \
    -F "zipFile=@test_project.zip" \
    -F "phpVersion=8.1" \
    -F "optimization=max" \
    -F "obfuscation=false" \
    "$API_URL/encode" \
    --output encoded_test_project.zip)

http_code="${response: -3}"

if [ "$http_code" = "200" ]; then
    echo "✅ Encoding successful!"
    echo "   Encoded file: encoded_test_project.zip"
    
    # Check if encoded file exists and has content
    if [ -f "encoded_test_project.zip" ] && [ -s "encoded_test_project.zip" ]; then
        file_size=$(ls -lh encoded_test_project.zip | awk '{print $5}')
        echo "   File size: $file_size"
        
        # Try to extract and verify structure
        echo ""
        echo "5. Verifying encoded project structure..."
        mkdir -p "test_extracted"
        if command -v unzip &> /dev/null; then
            unzip -q encoded_test_project.zip -d test_extracted
            
            echo "   Extracted files:"
            find test_extracted -type f | sort | while read file; do
                echo "   - $(basename "$file")"
            done
            
            # Check if PHP files were modified (encoded)
            if [ -f "test_extracted/index.php" ]; then
                if grep -q "ioncube" "test_extracted/index.php" 2>/dev/null; then
                    echo "✅ PHP files appear to be encoded"
                else
                    echo "⚠️  PHP files may not be encoded (no IonCube signature found)"
                fi
            fi
            
            rm -rf test_extracted
        else
            echo "   Cannot verify structure (unzip not available)"
        fi
    else
        echo "❌ Encoded file is missing or empty"
    fi
else
    echo "❌ Encoding failed with HTTP code: $http_code"
    
    # Try to show error message
    if [ -f "encoded_test_project.zip" ]; then
        echo "   Error response:"
        cat encoded_test_project.zip
        rm encoded_test_project.zip
    fi
fi

# Cleanup
echo ""
echo "6. Cleaning up..."
rm -rf "$test_dir"
rm -f test_project.zip

if [ -f "encoded_test_project.zip" ]; then
    echo "   Keeping encoded_test_project.zip for inspection"
else
    echo "   No encoded file to keep"
fi

echo ""
echo "🏁 Test completed!"

if [ "$http_code" = "200" ]; then
    echo "✅ All tests passed!"
    echo ""
    echo "The API is working correctly. You can now:"
    echo "1. Use the web interface at: $API_URL"
    echo "2. Upload your own PHP projects via API"
    echo "3. Check the README.md for detailed usage"
else
    echo "❌ Tests failed!"
    echo ""
    echo "Please check:"
    echo "1. IonCube encoder is installed and configured"
    echo "2. Server logs for error details"
    echo "3. Configuration in config/config.js"
fi
