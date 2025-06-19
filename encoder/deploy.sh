#!/bin/bash

# IonCube Encoder API Deployment Script
# This script helps deploy the service to production

echo "🚀 IonCube Encoder API Deployment"
echo "================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Please run this script as root (use sudo)"
    exit 1
fi

# Get current directory
CURRENT_DIR=$(pwd)
SERVICE_NAME="ioncube-encoder-api"

echo "📍 Current directory: $CURRENT_DIR"

# Install Node.js if not present
if ! command -v node &> /dev/null; then
    echo "📦 Installing Node.js..."
    
    # Detect OS
    if [[ -f /etc/debian_version ]]; then
        # Debian/Ubuntu
        curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
        apt-get install -y nodejs
    elif [[ -f /etc/redhat-release ]]; then
        # CentOS/RHEL
        curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
        yum install -y nodejs
    else
        echo "❌ Unsupported OS. Please install Node.js manually."
        exit 1
    fi
    
    echo "✅ Node.js installed: $(node --version)"
fi

# Install dependencies
echo "📦 Installing application dependencies..."
npm install --production

if [ $? -ne 0 ]; then
    echo "❌ Failed to install dependencies"
    exit 1
fi

# Create service user
echo "👤 Creating service user..."
if ! id "ioncube-api" &>/dev/null; then
    useradd -r -s /bin/false -d /var/lib/ioncube-api ioncube-api
    echo "✅ User 'ioncube-api' created"
else
    echo "✅ User 'ioncube-api' already exists"
fi

# Create directories with proper permissions
echo "📁 Setting up directories..."
mkdir -p /var/lib/ioncube-api/{uploads,temp,output,logs}
chown -R ioncube-api:ioncube-api /var/lib/ioncube-api
chmod 755 /var/lib/ioncube-api
chmod 755 /var/lib/ioncube-api/{uploads,temp,output,logs}

# Copy service files
echo "📋 Installing systemd service..."
cp "$CURRENT_DIR/$SERVICE_NAME.service" /etc/systemd/system/

# Update service file with correct paths
sed -i "s|/path/to/encoder|$CURRENT_DIR|g" /etc/systemd/system/$SERVICE_NAME.service
sed -i "s|User=www-data|User=ioncube-api|g" /etc/systemd/system/$SERVICE_NAME.service
sed -i "s|ReadWritePaths=.*|ReadWritePaths=$CURRENT_DIR/uploads $CURRENT_DIR/temp $CURRENT_DIR/output /var/lib/ioncube-api|g" /etc/systemd/system/$SERVICE_NAME.service

# Set permissions for application files
echo "🔒 Setting file permissions..."
chown -R ioncube-api:ioncube-api "$CURRENT_DIR"
chmod 755 "$CURRENT_DIR"
chmod 644 "$CURRENT_DIR"/*.js
chmod 644 "$CURRENT_DIR"/config/*.js
chmod 644 "$CURRENT_DIR"/services/*.js
chmod 755 "$CURRENT_DIR"/{uploads,temp,output}

# Reload systemd and enable service
echo "⚙️  Configuring systemd service..."
systemctl daemon-reload
systemctl enable $SERVICE_NAME

# Check IonCube installation
echo "🔍 Checking IonCube encoder..."
IONCUBE_PATHS=(
    "/usr/local/ioncube/ioncube_encoder"
    "/opt/ioncube/ioncube_encoder"
    "/usr/bin/ioncube_encoder"
)

IONCUBE_FOUND=false
for path in "${IONCUBE_PATHS[@]}"; do
    if [ -f "$path" ] && [ -x "$path" ]; then
        echo "✅ IonCube encoder found at: $path"
        # Update service file with correct path
        sed -i "s|Environment=IONCUBE_PATH=.*|Environment=IONCUBE_PATH=$path|g" /etc/systemd/system/$SERVICE_NAME.service
        IONCUBE_FOUND=true
        break
    fi
done

if [ "$IONCUBE_FOUND" = false ]; then
    echo "⚠️  IonCube encoder not found!"
    echo "   Please install IonCube encoder and update the path in:"
    echo "   /etc/systemd/system/$SERVICE_NAME.service"
fi

# Reload systemd after path update
systemctl daemon-reload

# Setup nginx reverse proxy (optional)
read -p "🌐 Do you want to set up Nginx reverse proxy? (y/n): " setup_nginx
if [[ $setup_nginx =~ ^[Yy]$ ]]; then
    if command -v nginx &> /dev/null; then
        echo "📝 Creating Nginx configuration..."
        
        cat > /etc/nginx/sites-available/$SERVICE_NAME << EOF
server {
    listen 80;
    server_name your-domain.com;  # Change this to your domain
    
    client_max_body_size 100M;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        
        # Timeout settings for large file uploads
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 300s;
    }
}
EOF
        
        # Enable site
        ln -sf /etc/nginx/sites-available/$SERVICE_NAME /etc/nginx/sites-enabled/
        
        # Test nginx configuration
        if nginx -t; then
            echo "✅ Nginx configuration is valid"
            systemctl reload nginx
            echo "✅ Nginx reloaded"
        else
            echo "❌ Nginx configuration error"
        fi
    else
        echo "❌ Nginx not found. Please install nginx first."
    fi
fi

# Setup firewall (optional)
read -p "🔥 Do you want to configure firewall? (y/n): " setup_firewall
if [[ $setup_firewall =~ ^[Yy]$ ]]; then
    if command -v ufw &> /dev/null; then
        echo "🔥 Configuring UFW firewall..."
        ufw allow 3000/tcp comment "IonCube Encoder API"
        ufw allow 80/tcp comment "HTTP"
        ufw allow 443/tcp comment "HTTPS"
        echo "✅ Firewall rules added"
    elif command -v firewall-cmd &> /dev/null; then
        echo "🔥 Configuring firewalld..."
        firewall-cmd --permanent --add-port=3000/tcp
        firewall-cmd --permanent --add-service=http
        firewall-cmd --permanent --add-service=https
        firewall-cmd --reload
        echo "✅ Firewall rules added"
    else
        echo "❌ No supported firewall found"
    fi
fi

# Start the service
echo "🚀 Starting service..."
systemctl start $SERVICE_NAME

# Check service status
sleep 2
if systemctl is-active --quiet $SERVICE_NAME; then
    echo "✅ Service started successfully!"
    
    # Show service status
    echo ""
    echo "📊 Service Status:"
    systemctl status $SERVICE_NAME --no-pager -l
    
    echo ""
    echo "🎉 Deployment completed successfully!"
    echo ""
    echo "Service Information:"
    echo "  • Service name: $SERVICE_NAME"
    echo "  • Status: $(systemctl is-active $SERVICE_NAME)"
    echo "  • Auto-start: $(systemctl is-enabled $SERVICE_NAME)"
    echo "  • Port: 3000"
    echo "  • User: ioncube-api"
    echo ""
    echo "Management Commands:"
    echo "  • Start:   systemctl start $SERVICE_NAME"
    echo "  • Stop:    systemctl stop $SERVICE_NAME"
    echo "  • Restart: systemctl restart $SERVICE_NAME"
    echo "  • Status:  systemctl status $SERVICE_NAME"
    echo "  • Logs:    journalctl -u $SERVICE_NAME -f"
    echo ""
    echo "Access the service:"
    echo "  • Local: http://localhost:3000"
    if [[ $setup_nginx =~ ^[Yy]$ ]]; then
        echo "  • Web: http://your-domain.com (update domain in nginx config)"
    fi
    echo ""
    echo "Next steps:"
    echo "1. Update domain in nginx configuration if using reverse proxy"
    echo "2. Set up SSL certificate (Let's Encrypt recommended)"
    echo "3. Test the API with: curl http://localhost:3000/health"
    
else
    echo "❌ Service failed to start!"
    echo ""
    echo "Check logs with: journalctl -u $SERVICE_NAME -f"
    echo "Check status with: systemctl status $SERVICE_NAME"
    exit 1
fi
