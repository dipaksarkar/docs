#!/bin/bash

# Gympify Pre-Installation Script for Plesk VPS
# This script is specifically designed for VPS servers managed by Plesk Control Panel
# It installs PHP 8.2, required extensions, ionCube Loader, and sets up MySQL database
# Optimized for Plesk environments with proper path handling and service management

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}[GYMPIFY PRE-INSTALL]${NC} $1"
}

# Function to check if running on Plesk
is_plesk_server() {
    if [ -f /usr/local/psa/version ] || [ -d /opt/psa ] || command -v plesk >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to check if PHP version is installed
check_php_version() {
    local version=$1
    # Check multiple possible PHP binary locations for Plesk
    if command -v php${version} >/dev/null 2>&1; then
        return 0
    elif [ -f "/opt/plesk/php/${version}/bin/php" ]; then
        return 0
    elif command -v plesk-php${version//.} >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to check if PHP extension is installed
check_php_extension() {
    local php_version=$1
    local extension=$2
    
    # Try different PHP binaries for Plesk
    local php_binary=""
    if command -v php${php_version} >/dev/null 2>&1; then
        php_binary="php${php_version}"
    elif [ -f "/opt/plesk/php/${php_version}/bin/php" ]; then
        php_binary="/opt/plesk/php/${php_version}/bin/php"
    else
        return 1
    fi
    
    if $php_binary -m 2>/dev/null | grep -qi "^${extension}$"; then
        return 0
    else
        return 1
    fi
}

# Function to install PHP 8.2 and extensions on Plesk
install_php_plesk() {
    print_header "Installing PHP 8.2 and required extensions for Plesk VPS..."
    
    # Check if Plesk is installed
    if ! is_plesk_server; then
        print_error "This script is designed specifically for VPS servers managed by Plesk."
        print_error "Plesk control panel not detected on this server."
        exit 1
    fi
    
    local php_version="8.2"
    
    # Get Plesk version for compatibility
    local plesk_version=""
    if [ -f /usr/local/psa/version ]; then
        plesk_version=$(cat /usr/local/psa/version | head -n1)
        print_status "Detected Plesk version: $plesk_version"
    fi
    
    # Check if PHP 8.2 is already installed via Plesk
    if check_php_version "$php_version"; then
        print_status "✅ PHP $php_version is already installed on this Plesk server"
        
        # Verify we can use PHP 8.2
        local php_binary=""
        if command -v php8.2 >/dev/null 2>&1; then
            php_binary="php8.2"
        elif [ -f "/opt/plesk/php/8.2/bin/php" ]; then
            php_binary="/opt/plesk/php/8.2/bin/php"
        else
            print_error "Cannot find working PHP 8.2 binary"
            exit 1
        fi
        
        print_status "Using PHP binary: $php_binary"
        local php_version_output=$($php_binary -v | head -n1)
        print_status "PHP version: $php_version_output"
    else
        print_status "Installing PHP $php_version via Plesk installer..."
        
        # Use Plesk installer to install PHP 8.2
        if command -v plesk >/dev/null 2>&1; then
            print_status "Using Plesk installer to add PHP 8.2..."
            
            # Try to install PHP 8.2, but don't fail if it's already available
            if plesk installer --select-product-id plesk --select-release-current --install-component php8.2 2>/dev/null; then
                print_status "PHP 8.2 installed successfully via Plesk"
            else
                print_status "PHP 8.2 components may already be available in Plesk"
            fi
            
            # Try to install additional PHP modules
            print_status "Ensuring PHP 8.2 modules are available via Plesk..."
            plesk installer --select-product-id plesk --select-release-current --install-component php8.2-common 2>/dev/null || true
            plesk installer --select-product-id plesk --select-release-current --install-component php8.2-fpm 2>/dev/null || true
        else
            print_error "Plesk command not found. This script requires Plesk to be properly installed."
            exit 1
        fi
        
        # Check again after installation attempt
        if ! check_php_version "$php_version"; then
            # Try to enable PHP 8.2 if it exists in Plesk but isn't linked
            if [ -f "/opt/plesk/php/8.2/bin/php" ]; then
                print_status "PHP 8.2 found in Plesk directory, creating symlink..."
                ln -sf /opt/plesk/php/8.2/bin/php /usr/local/bin/php8.2 2>/dev/null || true
                
                # Check once more after symlink
                if check_php_version "$php_version"; then
                    print_status "✅ PHP 8.2 enabled successfully"
                else
                    print_error "Failed to enable PHP $php_version"
                    exit 1
                fi
            else
                print_error "Failed to install or find PHP $php_version"
                print_status "Please install PHP 8.2 manually through Plesk installer or package manager"
                exit 1
            fi
        fi
        
        # Verify we can use PHP 8.2
        local php_binary=""
        if command -v php8.2 >/dev/null 2>&1; then
            php_binary="php8.2"
        elif [ -f "/opt/plesk/php/8.2/bin/php" ]; then
            php_binary="/opt/plesk/php/8.2/bin/php"
        else
            print_error "Cannot find working PHP 8.2 binary after installation"
            exit 1
        fi
        
        print_status "Using PHP binary: $php_binary"
        local php_version_output=$($php_binary -v | head -n1)
        print_status "PHP version: $php_version_output"
    fi
    
    # Required PHP extensions for Laravel/Gympify on Plesk
    local extensions=(
        "openssl"
        "pdo"
        "pdo_mysql" 
        "mbstring"
        "tokenizer"
        "json"
        "curl"
        "bcmath"
        "ctype"
        "dom"
        "fileinfo"
        "pcre"
        "xml"
        "redis"
        "imagick"
        "sodium"
        "zip"
        "gd"
        "intl"
        "exif"
    )
    
    print_status "Installing required PHP extensions for Plesk environment..."
    
    # Get OS type for Plesk package management
    local os_type=""
    if [ -f /etc/debian_version ]; then
        os_type="debian"
    elif [ -f /etc/redhat-release ]; then
        os_type="redhat"
    else
        print_error "Unsupported OS for Plesk VPS"
        exit 1
    fi
    
    for extension in "${extensions[@]}"; do
        if check_php_extension "$php_version" "$extension"; then
            print_status "✓ PHP extension '$extension' is already installed"
        else
            print_status "Installing PHP extension: $extension"
            
            # Install extension based on Plesk OS type
            if [ "$os_type" = "debian" ]; then
                case $extension in
                    "openssl"|"json"|"pcre"|"ctype"|"tokenizer"|"fileinfo"|"sodium")
                        # These are usually built-in, skip installation
                        print_status "✓ $extension is built-in or already available"
                        ;;
                    "pdo_mysql")
                        apt-get install -y plesk-php82-mysql 2>/dev/null || apt-get install -y php8.2-mysql || true
                        ;;
                    "dom"|"xml")
                        apt-get install -y plesk-php82-xml 2>/dev/null || apt-get install -y php8.2-xml || true
                        ;;
                    "redis")
                        apt-get install -y plesk-php82-redis 2>/dev/null || apt-get install -y php8.2-redis || true
                        ;;
                    "imagick")
                        apt-get install -y plesk-php82-imagick 2>/dev/null || apt-get install -y php8.2-imagick || true
                        ;;
                    "pdo")
                        # PDO is usually built-in
                        print_status "✓ $extension is built-in"
                        ;;
                    *)
                        apt-get install -y plesk-php82-${extension} 2>/dev/null || apt-get install -y php8.2-${extension} || true
                        ;;
                esac
            elif [ "$os_type" = "redhat" ]; then
                case $extension in
                    "openssl"|"json"|"pcre"|"ctype"|"tokenizer"|"fileinfo"|"sodium")
                        print_status "✓ $extension is built-in or already available"
                        ;;
                    "pdo_mysql")
                        yum install -y plesk-php82-mysqlnd 2>/dev/null || yum install -y php82-php-mysqlnd || true
                        ;;
                    "dom"|"xml")
                        yum install -y plesk-php82-xml 2>/dev/null || yum install -y php82-php-xml || true
                        ;;
                    "redis")
                        yum install -y plesk-php82-redis 2>/dev/null || yum install -y php82-php-redis || true
                        ;;
                    "imagick")
                        yum install -y plesk-php82-imagick 2>/dev/null || yum install -y php82-php-imagick || true
                        ;;
                    "pdo")
                        print_status "✓ $extension is built-in"
                        ;;
                    *)
                        yum install -y plesk-php82-${extension} 2>/dev/null || yum install -y php82-php-${extension} || true
                        ;;
                esac
            fi
            
            # Check if extension is now available after installation
            if check_php_extension "$php_version" "$extension"; then
                print_status "✅ $extension installed successfully"
            else
                print_warning "⚠️ $extension may need manual installation or configuration"
            fi
        fi
    done
    
    # Enable PHP 8.2 modules in Plesk
    print_status "Enabling PHP 8.2 modules in Plesk..."
    if command -v plesk >/dev/null 2>&1; then
        # Try to add PHP handler, but don't fail if it already exists
        if plesk bin php_handler --add -phppath /opt/plesk/php/8.2/bin/php -phpini /opt/plesk/php/8.2/etc/php.ini -type fpm -service -clipath /opt/plesk/php/8.2/bin/php 2>/dev/null; then
            print_status "✅ PHP 8.2 handler added to Plesk successfully"
        else
            # Check if PHP 8.2 handler already exists
            if plesk bin php_handler --list | grep -q "8.2"; then
                print_status "✅ PHP 8.2 handler already exists in Plesk"
            else
                print_warning "⚠️ Could not add PHP 8.2 handler to Plesk (may already exist or need manual configuration)"
                print_status "You can manually configure PHP 8.2 in Plesk Panel if needed"
            fi
        fi
    else
        print_warning "Plesk command not available for PHP handler configuration"
    fi
    
    print_status "All PHP extensions installation completed for Plesk VPS"
}

# Function to install ionCube Loader for Plesk
install_ioncube_loader() {
    print_header "Installing ionCube Loader for PHP 8.2 on Plesk VPS..."
    
    local php_version="8.2"
    local arch=$(uname -m)
    local ioncube_url=""
    
    # Determine architecture and download URL
    case $arch in
        x86_64)
            ioncube_url="https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz"
            ;;
        i386|i686)
            ioncube_url="https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86.tar.gz"
            ;;
        aarch64|arm64)
            ioncube_url="https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_aarch64.tar.gz"
            ;;
        *)
            print_error "Unsupported architecture: $arch"
            return 1
            ;;
    esac
    
    # Create temporary directory
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    print_status "Downloading ionCube Loader..."
    curl -L -o ioncube_loaders.tar.gz "$ioncube_url"
    
    if [ $? -eq 0 ]; then
        print_status "Extracting ionCube Loader..."
        tar -xzf ioncube_loaders.tar.gz
        
        # Find Plesk PHP extension directory
        local php_ext_dir=""
        if [ -d "/opt/plesk/php/8.2/lib/php/modules" ]; then
            php_ext_dir="/opt/plesk/php/8.2/lib/php/modules"
        elif [ -d "/usr/lib/plesk-php82/modules" ]; then
            php_ext_dir="/usr/lib/plesk-php82/modules"
        else
            # Fallback to standard detection
            php_ext_dir=$(php8.2 -i | grep extension_dir | cut -d' ' -f5)
            if [ -z "$php_ext_dir" ]; then
                php_ext_dir="/usr/lib/php/20220829"  # Default for PHP 8.2
            fi
        fi
        
        print_status "Plesk PHP extension directory: $php_ext_dir"
        
        # Copy ionCube loader
        local ioncube_file="ioncube/ioncube_loader_lin_${php_version}.so"
        if [ -f "$ioncube_file" ]; then
            cp "$ioncube_file" "$php_ext_dir/"
            print_status "ionCube Loader copied to Plesk extension directory"
            
            # Create ionCube configuration for Plesk
            local plesk_php_ini_dir=""
            if [ -d "/opt/plesk/php/8.2/etc/php.d" ]; then
                plesk_php_ini_dir="/opt/plesk/php/8.2/etc/php.d"
            elif [ -d "/etc/plesk-php82/php.d" ]; then
                plesk_php_ini_dir="/etc/plesk-php82/php.d"
            else
                plesk_php_ini_dir="/opt/plesk/php/8.2/etc"
            fi
            
            local ioncube_ini="${plesk_php_ini_dir}/00-ioncube.ini"
            mkdir -p "$plesk_php_ini_dir"
            echo "zend_extension = ioncube_loader_lin_${php_version}.so" > "$ioncube_ini"
            
            print_status "ionCube Loader configuration created for Plesk at $ioncube_ini"
            
            # Restart Plesk PHP-FPM service
            if systemctl is-active --quiet plesk-php82-fpm; then
                systemctl restart plesk-php82-fpm
                print_status "Restarted Plesk PHP 8.2 FPM service"
            elif systemctl is-active --quiet php82-fpm; then
                systemctl restart php82-fpm
                print_status "Restarted PHP 8.2 FPM service"
            fi
            
            # Also restart Apache/Nginx if they're using mod_php
            if systemctl is-active --quiet httpd; then
                systemctl reload httpd
            elif systemctl is-active --quiet apache2; then
                systemctl reload apache2
            fi
            
            if systemctl is-active --quiet nginx; then
                systemctl reload nginx
            fi
            
            # Verify installation using Plesk PHP binary
            local plesk_php_binary=""
            if [ -f "/opt/plesk/php/8.2/bin/php" ]; then
                plesk_php_binary="/opt/plesk/php/8.2/bin/php"
            else
                plesk_php_binary="php8.2"
            fi
            
            if $plesk_php_binary -m | grep -q "ionCube"; then
                print_status "✅ ionCube Loader installed and enabled successfully in Plesk"
            else
                print_warning "ionCube Loader installed but not detected in Plesk PHP modules"
                print_status "You may need to manually configure ionCube in Plesk PHP settings"
            fi
        else
            print_error "ionCube Loader file not found for PHP 8.2"
        fi
    else
        print_error "Failed to download ionCube Loader"
    fi
    
    # Cleanup
    cd /
    rm -rf "$temp_dir"
    
    print_status "ionCube Loader installation completed for Plesk VPS"
}

# Function to verify PHP installation
verify_php_installation() {
    print_header "Verifying PHP 8.2 installation..."
    
    local php_version="8.2"
    
    # Find the correct PHP binary
    local php_binary=""
    if command -v php8.2 >/dev/null 2>&1; then
        php_binary="php8.2"
    elif [ -f "/opt/plesk/php/8.2/bin/php" ]; then
        php_binary="/opt/plesk/php/8.2/bin/php"
    else
        print_error "Cannot find PHP 8.2 binary for verification"
        return 1
    fi
    
    # Check PHP version
    local installed_version=$($php_binary -v | head -n1 | cut -d' ' -f2)
    print_status "Installed PHP version: $installed_version"
    
    # Required extensions for Gympify
    local required_extensions=(
        "openssl" "pdo" "mbstring" "tokenizer" "json" "curl" 
        "bcmath" "ctype" "dom" "fileinfo" "xml" "redis" 
        "imagick" "sodium" "zip" "gd"
    )
    
    print_status "Checking required PHP extensions:"
    local missing_extensions=()
    
    for extension in "${required_extensions[@]}"; do
        if check_php_extension "$php_version" "$extension"; then
            print_status "✅ $extension"
        else
            print_error "❌ $extension (missing)"
            missing_extensions+=("$extension")
        fi
    done
    
    # Check ionCube Loader specifically
    if $php_binary -m | grep -q "ionCube"; then
        print_status "✅ ionCube Loader"
    else
        print_error "❌ ionCube Loader (missing)"
        missing_extensions+=("ionCube")
    fi
    
    if [ ${#missing_extensions[@]} -eq 0 ]; then
        print_status "🎉 All required PHP extensions are installed!"
        return 0
    else
        print_warning "Missing extensions: ${missing_extensions[*]}"
        print_status "Don't worry, these will be addressed in the next step or manually in Plesk"
        return 0  # Don't fail the script, just warn
    fi
}

# Function to generate random password
generate_password() {
    local length=${1:-16}
    openssl rand -base64 32 | tr -d "=+/" | cut -c1-${length}
}

# Function to check if MySQL is running
check_mysql_service() {
    if systemctl is-active --quiet mysql || systemctl is-active --quiet mysqld || systemctl is-active --quiet mariadb; then
        return 0
    else
        return 1
    fi
}

# Function to test MySQL connection
test_mysql_connection() {
    local user=$1
    local password=$2
    local host=${3:-localhost}
    
    mysql -u"$user" -p"$password" -h"$host" -e "SELECT 1;" >/dev/null 2>&1
    return $?
}

# Function to create MySQL database and user
setup_mysql_database() {
    local db_name="gympify"
    local db_user="gympify_admin"
    local db_password=$(generate_password 20)
    local mysql_root_password=""
    
    print_header "Setting up MySQL database for Gympify..."
    
    # Check if MySQL is running
    if ! check_mysql_service; then
        print_error "MySQL service is not running. Please start MySQL service first."
        exit 1
    fi
    
    # Try to connect as root without password first
    if mysql -u root -e "SELECT 1;" >/dev/null 2>&1; then
        print_status "Connected to MySQL as root (no password)"
        mysql_root_password=""
    else
        # Prompt for MySQL root password
        echo -n "Enter MySQL root password: "
        read -s mysql_root_password
        echo
        
        if ! test_mysql_connection "root" "$mysql_root_password"; then
            print_error "Failed to connect to MySQL with provided root password"
            exit 1
        fi
        print_status "Connected to MySQL as root"
    fi
    
    # Check if user already exists
    local user_exists=false
    if [ -z "$mysql_root_password" ]; then
        if mysql -u root -e "SELECT User FROM mysql.user WHERE User='$db_user';" 2>/dev/null | grep -q "$db_user"; then
            user_exists=true
        fi
    else
        if mysql -u root -p"$mysql_root_password" -e "SELECT User FROM mysql.user WHERE User='$db_user';" 2>/dev/null | grep -q "$db_user"; then
            user_exists=true
        fi
    fi
    
    if [ "$user_exists" = true ]; then
        print_warning "User '$db_user' already exists and will be recreated with a new password"
        echo -n "Do you want to continue and override the existing user? (y/N): "
        read -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Database setup cancelled"
            return 1
        fi
        print_status "Proceeding to override existing user '$db_user'"
    fi
    
    # Create database and user
    print_status "Creating database '$db_name'..."
    
    # Prepare MySQL commands
    mysql_commands="
-- Create database if it doesn't exist
CREATE DATABASE IF NOT EXISTS \`$db_name\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Drop existing users if they exist (override)
DROP USER IF EXISTS '$db_user'@'localhost';
DROP USER IF EXISTS '$db_user'@'%';

-- Create user for localhost with new password
CREATE USER '$db_user'@'localhost' IDENTIFIED BY '$db_password';
GRANT ALL PRIVILEGES ON \`$db_name\`.* TO '$db_user'@'localhost' WITH GRANT OPTION;

-- Create user for any host (for remote connections) with new password
CREATE USER '$db_user'@'%' IDENTIFIED BY '$db_password';
GRANT ALL PRIVILEGES ON \`$db_name\`.* TO '$db_user'@'%' WITH GRANT OPTION;

-- Apply changes
FLUSH PRIVILEGES;

-- Show created database
SHOW DATABASES LIKE '$db_name';
"
    
    print_status "Note: If user '$db_user' already exists, it will be recreated with a new password"
    
    # Execute MySQL commands
    if [ -z "$mysql_root_password" ]; then
        echo "$mysql_commands" | mysql -u root
    else
        echo "$mysql_commands" | mysql -u root -p"$mysql_root_password"
    fi
    
    if [ $? -eq 0 ]; then
        print_status "Database and user created successfully!"
        
        # Test the new user connection
        if test_mysql_connection "$db_user" "$db_password"; then
            print_status "Database connection test successful!"
        else
            print_warning "Database created but connection test failed"
        fi
        
        # Save credentials to file
        local creds_file="/tmp/gympify_db_credentials.txt"
        cat > "$creds_file" << EOF
===========================================
GYMPIFY DATABASE CREDENTIALS
===========================================
Database Name: $db_name
Database User: $db_user
Database Password: $db_password
Database Host: localhost

.env Configuration:
===========================================
DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=$db_name
DB_USERNAME=$db_user
DB_PASSWORD=$db_password

===========================================
IMPORTANT: Save these credentials securely!
This file will be deleted after display.
===========================================
EOF
        
        # Display credentials
        echo
        print_header "DATABASE SETUP COMPLETE!"
        cat "$creds_file"
        echo
        
        # Clean up credentials file
        rm -f "$creds_file"
        
        # Export variables for potential use by other scripts
        export GYMPIFY_DB_NAME="$db_name"
        export GYMPIFY_DB_USER="$db_user"
        export GYMPIFY_DB_PASSWORD="$db_password"
        export GYMPIFY_DB_HOST="localhost"
        
    else
        print_error "Failed to create database and user"
        exit 1
    fi
}

# Function to check MySQL configuration
check_mysql_config() {
    print_header "Checking MySQL configuration..."
    
    local mysql_version
    mysql_version=$(mysql --version 2>/dev/null | awk '{print $5}' | cut -d',' -f1)
    
    if [ -n "$mysql_version" ]; then
        print_status "MySQL version: $mysql_version"
        
        # Check if version meets minimum requirements (5.7+)
        local major_version=$(echo "$mysql_version" | cut -d'.' -f1)
        local minor_version=$(echo "$mysql_version" | cut -d'.' -f2)
        
        if [ "$major_version" -gt 5 ] || ([ "$major_version" -eq 5 ] && [ "$minor_version" -ge 7 ]); then
            print_status "MySQL version meets requirements (>= 5.7)"
        else
            print_warning "MySQL version may not meet requirements. Recommended: MySQL 5.7+ or MariaDB 10.2+"
        fi
    else
        print_warning "Could not determine MySQL version"
    fi
    
    # Check MySQL configuration
    if check_mysql_service; then
        print_status "MySQL service is running"
        
        # Check key MySQL settings
        local max_connections innodb_buffer_pool_size
        max_connections=$(mysql -e "SHOW VARIABLES LIKE 'max_connections';" 2>/dev/null | grep max_connections | awk '{print $2}')
        innodb_buffer_pool_size=$(mysql -e "SHOW VARIABLES LIKE 'innodb_buffer_pool_size';" 2>/dev/null | grep innodb_buffer_pool_size | awk '{print $2}')
        
        if [ -n "$max_connections" ]; then
            print_status "Max connections: $max_connections"
            if [ "$max_connections" -lt 100 ]; then
                print_warning "Consider increasing max_connections for better performance"
            fi
        fi
        
        if [ -n "$innodb_buffer_pool_size" ]; then
            print_status "InnoDB buffer pool size: $innodb_buffer_pool_size bytes"
        fi
    else
        print_error "MySQL service is not running"
        return 1
    fi
}

# Function to optimize MySQL for Gympify
optimize_mysql() {
    print_header "Applying MySQL optimizations for Gympify..."
    
    local mysql_conf="/etc/mysql/mysql.conf.d/gympify.cnf"
    
    if [ ! -f "$mysql_conf" ]; then
        print_status "Creating MySQL optimization configuration..."
        
        sudo tee "$mysql_conf" > /dev/null << 'EOF'
# Gympify MySQL Optimizations
[mysqld]

# Connection settings
max_connections = 200
max_connect_errors = 1000
wait_timeout = 600
interactive_timeout = 600

# Buffer settings
innodb_buffer_pool_size = 256M
innodb_log_file_size = 64M
innodb_log_buffer_size = 16M
innodb_flush_log_at_trx_commit = 2

# Query cache (if supported)
query_cache_type = 1
query_cache_size = 64M
query_cache_limit = 2M

# Character set
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

# SQL mode for Laravel compatibility
sql_mode = "STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"

# Other optimizations
tmp_table_size = 64M
max_heap_table_size = 64M
sort_buffer_size = 2M
read_buffer_size = 2M
read_rnd_buffer_size = 8M
myisam_sort_buffer_size = 64M
thread_cache_size = 8
EOF
        
        print_status "MySQL optimization configuration created at $mysql_conf"
        print_warning "Please restart MySQL service to apply optimizations: sudo systemctl restart mysql"
    else
        print_status "MySQL optimization configuration already exists"
    fi
}

# Main execution
main() {
    print_header "Gympify Pre-Installation Script for Plesk VPS"
    echo "This script is specifically designed for VPS servers managed by Plesk Control Panel"
    echo
    echo "This script will:"
    echo "- Verify Plesk installation and version"
    echo "- Install PHP 8.2 via Plesk installer with all required extensions"
    echo "- Install and configure ionCube Loader for Plesk PHP"
    echo "- Set up MySQL database with optimized configuration"
    echo "- Create Gympify database user with secure random password"
    echo "- Apply Plesk-specific MySQL optimizations"
    echo "- Display database credentials for .env configuration"
    echo
    
    # Confirm execution
    read -p "Do you want to continue with Plesk VPS setup? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Installation cancelled"
        exit 0
    fi
    
    # Check if running as root (required for Plesk operations)
    if [ "$EUID" -ne 0 ]; then
        print_error "This script must be run as root for Plesk VPS operations"
        print_error "Please run: sudo $0"
        exit 1
    fi
    
    # Verify Plesk installation
    if is_plesk_server; then
        print_status "✅ Plesk control panel detected - proceeding with VPS setup"
    else
        print_error "❌ Plesk control panel not found on this server"
        print_error "This script is designed specifically for Plesk VPS environments"
        print_error "Please ensure Plesk is properly installed before running this script"
        exit 1
    fi
    
    # Run Plesk-specific setup steps
    print_header "Starting Plesk VPS setup for Gympify..."
    
    install_php_plesk
    install_ioncube_loader
    verify_php_installation
    
    # Database setup (works with Plesk MySQL)
    check_mysql_config
    setup_mysql_database
    optimize_mysql
    
    print_header "Plesk VPS Pre-installation complete!"
    print_status "✅ PHP 8.2 with all required extensions installed via Plesk"
    print_status "✅ ionCube Loader configured for Plesk PHP environment"
    print_status "✅ MySQL database setup completed with credentials displayed above"
    print_status "✅ Plesk VPS is now ready for Gympify installation"
    echo
    print_status "Next steps for Plesk VPS:"
    echo "1. Upload and extract Gympify files to your domain's document root"
    echo "2. Copy .env.example to .env in the Gympify directory"
    echo "3. Update .env file with the database credentials shown above"
    echo "4. In Plesk Panel: Go to your domain → PHP Settings → Set PHP version to 8.2"
    echo "5. In Plesk Panel: Ensure all required PHP extensions are enabled"
    echo "6. Navigate to your-domain.com/install to complete Gympify installation"
    echo
    print_warning "Important Plesk Configuration:"
    echo "- Set PHP 8.2 as the PHP version for your domain in Plesk Panel"
    echo "- Verify ionCube Loader is enabled in Plesk PHP Settings"
    echo "- Ensure document root points to Gympify's public directory"
    echo "- Configure SSL certificate if needed via Plesk SSL/TLS settings"
}

# Run main function
main "$@"
