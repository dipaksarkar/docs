# IonCube Encoder API

A Node.js API service that allows you to upload PHP project ZIP files and encode them using IonCube encoder while maintaining the original file structure.

## Features

- 🔐 **IonCube Encoding**: Encode PHP files using IonCube encoder
- 📁 **Structure Preservation**: Maintains original project file/folder structure
- 🎯 **Selective Encoding**: Only encodes PHP files, leaves other files untouched
- ⚙️ **Configurable Options**: PHP version, optimization level, obfuscation, expiration, server restrictions
- 🌐 **Web Interface**: Easy-to-use web UI for uploading and configuring encoding
- 🚀 **RESTful API**: Programmatic access via HTTP API
- 🧹 **Auto Cleanup**: Automatic cleanup of temporary files

## Prerequisites

### 1. Node.js
Install Node.js (version 14 or higher):
```bash
# macOS with Homebrew
brew install node

# Or download from https://nodejs.org/
```

### 2. IonCube Encoder
You need to install IonCube Encoder on your system:

#### Option A: Download from IonCube
1. Visit [IonCube Downloads](https://www.ioncube.com/loaders.php)
2. Download the encoder for your platform
3. Extract and install according to IonCube documentation

#### Option B: Using the provided scripts
If you have the installation scripts in your workspace:

```bash
# For HestiaCP
chmod +x ../hestiacp/install_ioncube.sh
sudo ../hestiacp/install_ioncube.sh

# For CloudPanel
chmod +x ../cloudpanel/enable_ioncube.sh
sudo ../cloudpanel/enable_ioncube.sh
```

## Installation

### For Ubuntu

1. **Clone or navigate to the encoder directory:**
   ```bash
   cd encoder
   ```

2. **Run the automatic installation script:**
   ```bash
   chmod +x install.sh
   ./install.sh
   ```
   
   This will:
   - Install Node.js and npm automatically
   - Install project dependencies
   - Create necessary directories
   - Check for IonCube encoder

3. **Install IonCube encoder (if not found):**
   ```bash
   chmod +x install-ioncube-ubuntu.sh
   ./install-ioncube-ubuntu.sh
   ```

4. **Start the server:**
   ```bash
   npm start
   ```

### Manual Installation

1. **Install Node.js and npm:**
   ```bash
   sudo apt update
   sudo apt install -y nodejs npm
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Create directories:**
   ```bash
   mkdir -p uploads temp output
   ```

4. **Configure IonCube path (if needed):**
   
   Edit `config/config.js` and update the `ioncubePath` if IonCube is installed in a different location:
   ```javascript
   ioncubePath: '/path/to/your/ioncube_encoder'
   ```

   Or set environment variable:
   ```bash
   export IONCUBE_PATH="/path/to/your/ioncube_encoder"
   ```

## Usage

### Starting the Server

```bash
# Production
npm start

# Development (with auto-restart)
npm run dev
```

The server will start on `http://localhost:3000`

### Web Interface

1. Open your browser and go to `http://localhost:3000`
2. Upload your PHP project ZIP file
3. Configure encoding options:
   - **PHP Version**: Target PHP version (5.6 to 8.2)
   - **Optimization**: Code optimization level
   - **Obfuscation**: Enable code obfuscation
   - **Expiration**: Set expiration date (optional)
   - **Allowed Servers**: Restrict to specific domains (optional)
4. Click "Start Encoding"
5. Download the encoded ZIP file

### API Usage

#### Health Check
```bash
curl http://localhost:3000/health
```

#### Encode PHP Project
```bash
curl -X POST \
  -F "zipFile=@/path/to/your/project.zip" \
  -F "phpVersion=8.1" \
  -F "optimization=max" \
  -F "obfuscation=true" \
  http://localhost:3000/encode \
  --output encoded-project.zip
```

#### API Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `zipFile` | File | Required | ZIP file containing PHP project |
| `phpVersion` | String | `8.1` | Target PHP version (5.6-8.2) |
| `optimization` | String | `max` | Optimization level (none, low, medium, high, max) |
| `obfuscation` | Boolean | `false` | Enable code obfuscation |
| `expiration` | String | `null` | Expiration date (YYYY-MM-DD) |
| `allowedServers` | String | `null` | Comma-separated allowed domains |

## Configuration

### Environment Variables

```bash
# IonCube encoder path
IONCUBE_PATH="/usr/local/ioncube/ioncube_encoder"

# Directory paths
TEMP_DIR="./temp"
UPLOADS_DIR="./uploads"
OUTPUT_DIR="./output"

# Server settings
PORT=3000
LOG_LEVEL="info"
ENABLE_FILE_LOGGING="false"
```

### File Exclusions

The encoder automatically excludes certain files and directories:

**Excluded Files:**
- `composer.json`, `composer.lock`
- `package.json`, `package-lock.json`
- `.env`, `.env.example`
- `README.md`, `.gitignore`

**Excluded Directories:**
- `node_modules`, `.git`, `.svn`
- `vendor/bin`
- `storage/logs`, `storage/cache`, `storage/sessions`
- `bootstrap/cache`

## File Structure

```
encoder/
├── server.js                 # Main server file
├── package.json              # Dependencies
├── config/
│   └── config.js             # Configuration settings
├── services/
│   └── ioncube-encoder.js    # IonCube encoding service
├── public/
│   └── index.html            # Web interface
├── uploads/                  # Temporary upload directory
├── temp/                     # Temporary processing directory
└── output/                   # Encoded files output
```

## API Response Examples

### Success Response
The API returns the encoded ZIP file directly with appropriate headers:
```
Content-Type: application/zip
Content-Disposition: attachment; filename="encoded-project.zip"
```

### Error Response
```json
{
  "success": false,
  "message": "Error description"
}
```

## Production Deployment (Ubuntu)

### Using the Deployment Script

1. **Prepare for deployment:**
   ```bash
   chmod +x deploy.sh
   sudo ./deploy.sh
   ```

   This will:
   - Install Node.js if not present
   - Create application directory at `/opt/ioncube-encoder-api`
   - Set up systemd service
   - Configure proper permissions

2. **Start the service:**
   ```bash
   sudo systemctl start ioncube-encoder-api
   sudo systemctl enable ioncube-encoder-api
   ```

3. **Check service status:**
   ```bash
   sudo systemctl status ioncube-encoder-api
   ```

### Manual Deployment

1. **Create application directory:**
   ```bash
   sudo mkdir -p /opt/ioncube-encoder-api
   sudo cp -r . /opt/ioncube-encoder-api/
   ```

2. **Install dependencies:**
   ```bash
   cd /opt/ioncube-encoder-api
   sudo npm install --production
   ```

3. **Create systemd service:**
   ```bash
   sudo cp ioncube-encoder-api.service /etc/systemd/system/
   sudo systemctl daemon-reload
   sudo systemctl enable ioncube-encoder-api
   sudo systemctl start ioncube-encoder-api
   ```

### Using with Nginx (Optional)

Create `/etc/nginx/sites-available/ioncube-api`:
```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        client_max_body_size 100M;
    }
}
```

Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/ioncube-api /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## Troubleshooting

### Common Issues

1. **"IonCube encoder not found"**
   - Ensure IonCube encoder is installed and path is correct
   - Check `IONCUBE_PATH` environment variable or `config.js`

2. **"Only ZIP files are allowed"**
   - Ensure you're uploading a valid ZIP file
   - Check file extension and MIME type

3. **"File too large"**
   - Maximum file size is 100MB by default
   - Modify `maxFileSize` in config if needed

4. **Permission errors**
   - Ensure the application has write permissions to temp directories
   - Check IonCube encoder executable permissions

### Logs

Check console output for detailed logging:
```bash
npm start
```

## Security Considerations

- The service automatically cleans up temporary files
- Uploaded files are deleted after processing
- Output files are automatically removed after 1 hour
- Only ZIP files are accepted for upload
- File size limits prevent abuse

## License

MIT License - see LICENSE file for details

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review server logs for error details
3. Ensure IonCube encoder is properly installed and configured
