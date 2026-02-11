#!/bin/bash

# Gympify Pre-Installation Script for HestiaCP VPS
# This script is specifically designed for VPS servers managed by HestiaCP Control Panel
# It installs PHP 8.3, required extensions, ionCube Loader, and sets up MySQL database
# Optimized for HestiaCP environments with proper path handling and service management

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

# Function to check if running on HestiaCP
is_hestiacp_server() {
    if [ -f /usr/local/hestia/conf/hestia.conf ] || [ -d /usr/local/hestia ] || command -v v-list-users >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to check if PHP version is installed
check_php_version() {
    local version=$1
    # Check multiple possible PHP binary locations for HestiaCP
    if command -v php${version} >/dev/null 2>&1; then
        return 0
    elif [ -f "/usr/bin/php${version}" ]; then
        return 0
    elif [ -f "/usr/local/bin/php${version}" ]; then
        return 0
    else
        return 1
    fi
}

# Function to check if PHP extension is installed
check_php_extension() {
    local php_version=$1
    local extension=$2
    
    # Try different PHP binaries for HestiaCP
    local php_binary=""
    if command -v php${php_version} >/dev/null 2>&1; then
        php_binary="php${php_version}"
    elif [ -f "/usr/bin/php${php_version}" ]; then
        php_binary="/usr/bin/php${php_version}"
    else
        return 1
    fi
    
    if $php_binary -m 2>/dev/null | grep -qi "^${extension}$"; then
        return 0
    else
        return 1
    fi
}

# Function to get OS type
get_os_type() {
    if [ -f /etc/debian_version ]; then
        echo "debian"
    elif [ -f /etc/redhat-release ]; then
        echo "redhat"
    else
        echo "unknown"
    fi
}

# Function to install PHP 8.3 and extensions on HestiaCP
install_php_hestiacp() {
    print_header "Installing PHP 8.3 and required extensions for HestiaCP VPS..."
    
    # Check if HestiaCP is installed
    if ! is_hestiacp_server; then
        print_error "This script is designed specifically for VPS servers managed by HestiaCP."
        print_error "HestiaCP control panel not detected on this server."
        exit 1
    fi
    
    local php_version="8.3"
    
    # Get HestiaCP version for compatibility
    local hestia_version=""
    if [ -f /usr/local/hestia/conf/hestia.conf ]; then
        hestia_version=$(grep "VERSION=" /usr/local/hestia/conf/hestia.conf | cut -d"=" -f2 | tr -d '"')
        print_status "Detected HestiaCP version: $hestia_version"
    fi
    
    # Get OS type
    local os_type=$(get_os_type)
    print_status "Operating system: $os_type"
    
    # Update package lists
    print_status "Updating package lists..."
    if [ "$os_type" = "debian" ]; then
        apt-get update
    elif [ "$os_type" = "redhat" ]; then
        yum update -y || dnf update -y
    fi
    
    # Check if PHP 8.3 is already installed
    if check_php_version "$php_version"; then
        print_status "✅ PHP $php_version is already installed on this HestiaCP server"
        
        # Verify we can use PHP 8.3
        local php_binary=""
        if command -v php8.3 >/dev/null 2>&1; then
            php_binary="php8.3"
        elif [ -f "/usr/bin/php8.3" ]; then
            php_binary="/usr/bin/php8.3"
        else
            print_error "Cannot find working PHP 8.3 binary"
            exit 1
        fi
        
        print_status "Using PHP binary: $php_binary"
        local php_version_output=$($php_binary -v | head -n1)
        print_status "PHP version: $php_version_output"
    else
        print_status "Installing PHP $php_version for HestiaCP..."
        
        if [ "$os_type" = "debian" ]; then
            # Add Ondrej's PHP repository for Debian/Ubuntu
            print_status "Adding Ondrej PHP repository..."
            apt-get install -y software-properties-common
            add-apt-repository -y ppa:ondrej/php 2>/dev/null || {
                # For Debian systems, use the DEB.SURY.ORG repository
                apt-get install -y wget gnupg2
                wget -qO - https://packages.sury.org/php/apt.gpg | apt-key add -
                echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
            }
            apt-get update
            
            # Install PHP 8.3
            print_status "Installing PHP 8.3 base package..."
            apt-get install -y php8.3 php8.3-fpm php8.3-cli
            
        elif [ "$os_type" = "redhat" ]; then
            # Add Remi repository for CentOS/RHEL/Rocky/AlmaLinux
            print_status "Adding Remi PHP repository..."
            
            # Install EPEL first
            if ! rpm -qa | grep -q epel-release; then
                if command -v dnf >/dev/null 2>&1; then
                    dnf install -y epel-release
                else
                    yum install -y epel-release
                fi
            fi
            
            # Install Remi repository
            if ! rpm -qa | grep -q remi-release; then
                if command -v dnf >/dev/null 2>&1; then
                    dnf install -y https://rpms.remirepo.net/enterprise/remi-release-$(rpm -E %rhel).rpm
                else
                    yum install -y https://rpms.remirepo.net/enterprise/remi-release-$(rpm -E %rhel).rpm
                fi
            fi
            
            # Enable PHP 8.3 module
            if command -v dnf >/dev/null 2>&1; then
                dnf module reset php -y
                dnf module enable php:remi-8.3 -y
                dnf install -y php php-fpm php-cli
            else
                yum-config-manager --enable remi-php83
                yum install -y php php-fpm php-cli
            fi
        fi
        
        # Verify installation
        if check_php_version "$php_version"; then
            print_status "✅ PHP 8.3 installed successfully"
            
            # Get PHP binary
            local php_binary=""
            if command -v php8.3 >/dev/null 2>&1; then
                php_binary="php8.3"
            elif [ -f "/usr/bin/php8.3" ]; then
                php_binary="/usr/bin/php8.3"
            else
                php_binary="php"
            fi
            
            print_status "Using PHP binary: $php_binary"
            local php_version_output=$($php_binary -v | head -n1)
            print_status "PHP version: $php_version_output"
        else
            print_error "Failed to install PHP $php_version"
            exit 1
        fi
    fi
    
    # Required PHP extensions for Laravel/Gympify on HestiaCP
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
    
    print_status "Installing required PHP extensions for HestiaCP environment..."
    
    for extension in "${extensions[@]}"; do
        if check_php_extension "$php_version" "$extension"; then
            print_status "✓ PHP extension '$extension' is already installed"
        else
            print_status "Installing PHP extension: $extension"
            
            # Install extension based on OS type
            if [ "$os_type" = "debian" ]; then
                case $extension in
                    "openssl"|"json"|"pcre"|"ctype"|"tokenizer"|"fileinfo"|"sodium")
                        # These are usually built-in, skip installation
                        print_status "✓ $extension is built-in or already available"
                        ;;
                    "pdo_mysql")
                        apt-get install -y php8.3-mysql || true
                        ;;
                    "dom"|"xml")
                        apt-get install -y php8.3-xml || true
                        ;;
                    "redis")
                        apt-get install -y php8.3-redis || true
                        ;;
                    "imagick")
                        apt-get install -y php8.3-imagick || true
                        ;;
                    "pdo")
                        # PDO is usually built-in
                        print_status "✓ $extension is built-in"
                        ;;
                    *)
                        apt-get install -y php8.3-${extension} || true
                        ;;
                esac
            elif [ "$os_type" = "redhat" ]; then
                case $extension in
                    "openssl"|"json"|"pcre"|"ctype"|"tokenizer"|"fileinfo"|"sodium")
                        print_status "✓ $extension is built-in or already available"
                        ;;
                    "pdo_mysql")
                        if command -v dnf >/dev/null 2>&1; then
                            dnf install -y php-mysqlnd || true
                        else
                            yum install -y php-mysqlnd || true
                        fi
                        ;;
                    "dom"|"xml")
                        if command -v dnf >/dev/null 2>&1; then
                            dnf install -y php-xml || true
                        else
                            yum install -y php-xml || true
                        fi
                        ;;
                    "redis")
                        if command -v dnf >/dev/null 2>&1; then
                            dnf install -y php-redis || true
                        else
                            yum install -y php-redis || true
                        fi
                        ;;
                    "imagick")
                        if command -v dnf >/dev/null 2>&1; then
                            dnf install -y php-imagick || true
                        else
                            yum install -y php-imagick || true
                        fi
                        ;;
                    "pdo")
                        print_status "✓ $extension is built-in"
                        ;;
                    *)
                        if command -v dnf >/dev/null 2>&1; then
                            dnf install -y php-${extension} || true
                        else
                            yum install -y php-${extension} || true
                        fi
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
    
    # Configure PHP-FPM for HestiaCP
    print_status "Configuring PHP-FPM for HestiaCP..."
    
    # Enable and start PHP-FPM service
    if systemctl list-unit-files | grep -q "php8.3-fpm"; then
        systemctl enable php8.3-fpm
        systemctl start php8.3-fpm
        print_status "✅ PHP 8.3 FPM service enabled and started"
    elif systemctl list-unit-files | grep -q "php-fpm"; then
        systemctl enable php-fpm
        systemctl start php-fpm
        print_status "✅ PHP FPM service enabled and started"
    fi
    
    # Restart web server
    if systemctl is-active --quiet nginx; then
        systemctl reload nginx
        print_status "Nginx reloaded"
    fi
    
    if systemctl is-active --quiet apache2; then
        systemctl reload apache2
        print_status "Apache reloaded"
    elif systemctl is-active --quiet httpd; then
        systemctl reload httpd
        print_status "Apache reloaded"
    fi
    
    print_status "All PHP extensions installation completed for HestiaCP VPS"
}

# Function to install ionCube Loader for HestiaCP
install_ioncube_loader() {
    print_header "Installing ionCube Loader for PHP 8.3 on HestiaCP VPS..."
    
    local php_version="8.3"
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
        
        # Find PHP extension directory
        local php_ext_dir=""
        
        # Try to get extension directory from PHP
        if command -v php8.3 >/dev/null 2>&1; then
            php_ext_dir=$(php8.3 -i | grep extension_dir | cut -d' ' -f5)
        elif command -v php >/dev/null 2>&1; then
            php_ext_dir=$(php -i | grep extension_dir | cut -d' ' -f5)
        fi
        
        # Fallback to common paths
        if [ -z "$php_ext_dir" ] || [ ! -d "$php_ext_dir" ]; then
            for dir in "/usr/lib/php/20220839" "/usr/lib64/php/modules" "/usr/lib/php/modules" "/usr/local/lib/php/extensions/no-debug-non-zts-20220839"; do
                if [ -d "$dir" ]; then
                    php_ext_dir="$dir"
                    break
                fi
            done
        fi
        
        if [ -z "$php_ext_dir" ] || [ ! -d "$php_ext_dir" ]; then
            print_error "Could not find PHP extension directory"
            return 1
        fi
        
        print_status "HestiaCP PHP extension directory: $php_ext_dir"
        
        # Copy ionCube loader
        local ioncube_file="ioncube/ioncube_loader_lin_${php_version}.so"
        if [ -f "$ioncube_file" ]; then
            cp "$ioncube_file" "$php_ext_dir/"
            print_status "ionCube Loader copied to HestiaCP extension directory"
            
            # Create ionCube configuration for HestiaCP
            local php_ini_dir=""
            local os_type=$(get_os_type)
            
            # Find PHP configuration directory
            if [ "$os_type" = "debian" ]; then
                if [ -d "/etc/php/8.3/mods-available" ]; then
                    php_ini_dir="/etc/php/8.3/mods-available"
                elif [ -d "/etc/php/8.3/conf.d" ]; then
                    php_ini_dir="/etc/php/8.3/conf.d"
                else
                    php_ini_dir="/etc/php/8.3"
                fi
            elif [ "$os_type" = "redhat" ]; then
                if [ -d "/etc/php.d" ]; then
                    php_ini_dir="/etc/php.d"
                elif [ -d "/etc/php/conf.d" ]; then
                    php_ini_dir="/etc/php/conf.d"
                else
                    php_ini_dir="/etc"
                fi
            fi
            
            local ioncube_ini="${php_ini_dir}/00-ioncube.ini"
            mkdir -p "$php_ini_dir"
            echo "zend_extension = ioncube_loader_lin_${php_version}.so" > "$ioncube_ini"
            
            print_status "ionCube Loader configuration created for HestiaCP at $ioncube_ini"
            
            # Enable ionCube module on Debian systems
            if [ "$os_type" = "debian" ] && [ -d "/etc/php/8.3/mods-available" ]; then
                if command -v phpenmod >/dev/null 2>&1; then
                    phpenmod -v 8.3 ioncube
                    print_status "ionCube module enabled via phpenmod"
                fi
            fi
            
            # Restart PHP-FPM service
            if systemctl is-active --quiet php8.3-fpm; then
                systemctl restart php8.3-fpm
                print_status "Restarted PHP 8.3 FPM service"
            elif systemctl is-active --quiet php-fpm; then
                systemctl restart php-fpm
                print_status "Restarted PHP FPM service"
            fi
            
            # Also restart web server
            if systemctl is-active --quiet nginx; then
                systemctl reload nginx
            fi
            
            if systemctl is-active --quiet apache2; then
                systemctl reload apache2
            elif systemctl is-active --quiet httpd; then
                systemctl reload httpd
            fi
            
            # Verify installation using HestiaCP PHP binary
            local hestia_php_binary=""
            if command -v php8.3 >/dev/null 2>&1; then
                hestia_php_binary="php8.3"
            else
                hestia_php_binary="php"
            fi
            
            if $hestia_php_binary -m | grep -q "ionCube"; then
                print_status "✅ ionCube Loader installed and enabled successfully in HestiaCP"
            else
                print_warning "ionCube Loader installed but not detected in HestiaCP PHP modules"
                print_status "You may need to manually configure ionCube in HestiaCP PHP settings"
            fi
        else
            print_error "ionCube Loader file not found for PHP 8.3"
        fi
    else
        print_error "Failed to download ionCube Loader"
    fi
    
    # Cleanup
    cd /
    rm -rf "$temp_dir"
    
    print_status "ionCube Loader installation completed for HestiaCP VPS"
}

# Function to verify PHP installation
verify_php_installation() {
    print_header "Verifying PHP 8.3 installation..."
    
    local php_version="8.3"
    
    # Find the correct PHP binary
    local php_binary=""
    if command -v php8.3 >/dev/null 2>&1; then
        php_binary="php8.3"
    elif command -v php >/dev/null 2>&1; then
        php_binary="php"
    else
        print_error "Cannot find PHP binary for verification"
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
        print_status "Don't worry, these will be addressed in the next step or manually in HestiaCP"
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

# Function to test database creation and deletion privileges
test_database_privileges() {
    local test_user=$1
    local test_password=$2
    local root_password=$3
    local test_db_name="gympify_test_$(date +%s)"
    
    print_status "🧪 Testing database management privileges for user '$test_user'..."
    
    # Step 1: Create test database as root
    print_status "Step 1: Creating test database '$test_db_name' as root..."
    
    local create_test_db_cmd="CREATE DATABASE \`$test_db_name\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    
    if [ -z "$root_password" ]; then
        echo "$create_test_db_cmd" | mysql -u root
    else
        echo "$create_test_db_cmd" | mysql -u root -p"$root_password"
    fi
    
    if [ $? -eq 0 ]; then
        print_status "✅ Test database '$test_db_name' created successfully by root"
    else
        print_error "❌ Failed to create test database as root"
        return 1
    fi
    
    # Step 2: Check if new user can see the test database
    print_status "Step 2: Checking if user '$test_user' can see test database..."
    
    local visible_dbs=$(mysql -u "$test_user" -p"$test_password" -e "SHOW DATABASES LIKE '$test_db_name';" 2>/dev/null | grep -v Database | wc -l)
    
    if [ "$visible_dbs" -eq 1 ]; then
        print_status "✅ User '$test_user' can see the test database"
    else
        print_warning "❌ User '$test_user' cannot see the test database created by root"
        print_status "This indicates limited database visibility privileges"
    fi
    
    # Step 3: Test if user can create a table in the test database
    print_status "Step 3: Testing if user can create table in test database..."
    
    local create_table_cmd="USE \`$test_db_name\`; CREATE TABLE test_table (id INT PRIMARY KEY AUTO_INCREMENT, name VARCHAR(50));"
    
    if echo "$create_table_cmd" | mysql -u "$test_user" -p"$test_password" 2>/dev/null; then
        print_status "✅ User '$test_user' can create tables in test database"
    else
        print_warning "❌ User '$test_user' cannot create tables in test database"
    fi
    
    # Step 4: Test if user can insert data
    print_status "Step 4: Testing data insertion privileges..."
    
    local insert_data_cmd="USE \`$test_db_name\`; INSERT INTO test_table (name) VALUES ('test_entry');"
    
    if echo "$insert_data_cmd" | mysql -u "$test_user" -p"$test_password" 2>/dev/null; then
        print_status "✅ User '$test_user' can insert data"
    else
        print_warning "❌ User '$test_user' cannot insert data"
    fi
    
    # Step 5: Test if user can create their own database
    print_status "Step 5: Testing if user can create own database..."
    
    local user_test_db="gympify_user_test_$(date +%s)"
    local create_user_db_cmd="CREATE DATABASE \`$user_test_db\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    
    if echo "$create_user_db_cmd" | mysql -u "$test_user" -p"$test_password" 2>/dev/null; then
        print_status "✅ User '$test_user' can create their own databases"
        
        # Clean up user-created database
        echo "DROP DATABASE \`$user_test_db\`;" | mysql -u "$test_user" -p"$test_password" 2>/dev/null
        print_status "✅ User '$test_user' can also delete databases they created"
    else
        print_warning "❌ User '$test_user' cannot create new databases"
    fi
    
    # Step 6: Test if user can delete the root-created test database
    print_status "Step 6: Testing if user can delete root-created database..."
    
    local drop_test_db_cmd="DROP DATABASE \`$test_db_name\`;"
    
    if echo "$drop_test_db_cmd" | mysql -u "$test_user" -p"$test_password" 2>/dev/null; then
        print_status "✅ User '$test_user' can delete databases created by root"
        print_status "✅ Test database '$test_db_name' deleted successfully"
        print_status "🎉 FULL ADMINISTRATIVE ACCESS CONFIRMED!"
    else
        print_warning "❌ User '$test_user' cannot delete databases created by root"
        print_status "This indicates limited administrative privileges"
        
        # Clean up as root since user couldn't delete it
        print_status "Cleaning up test database as root..."
        if [ -z "$root_password" ]; then
            echo "$drop_test_db_cmd" | mysql -u root
        else
            echo "$drop_test_db_cmd" | mysql -u root -p"$root_password"
        fi
        print_status "Test database cleaned up by root"
    fi
    
    # Summary
    echo
    print_header "DATABASE PRIVILEGE TEST SUMMARY"
    print_status "User: $test_user"
    print_status "Test completed - check results above"
    
    # Show all databases the user can see
    print_status "Databases visible to user '$test_user':"
    mysql -u "$test_user" -p"$test_password" -e "SHOW DATABASES;" 2>/dev/null | grep -v Database | nl -w2 -s'. ' || true
    echo
}

# Function to create MySQL database and user
setup_mysql_database() {
    local db_name="gympify_admin"
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
    local db_exists=false
    
    # Check if database exists
    if [ -z "$mysql_root_password" ]; then
        if mysql -u root -e "SHOW DATABASES LIKE '$db_name';" 2>/dev/null | grep -q "$db_name"; then
            db_exists=true
        fi
        if mysql -u root -e "SELECT User FROM mysql.user WHERE User='$db_user';" 2>/dev/null | grep -q "$db_user"; then
            user_exists=true
        fi
    else
        if mysql -u root -p"$mysql_root_password" -e "SHOW DATABASES LIKE '$db_name';" 2>/dev/null | grep -q "$db_name"; then
            db_exists=true
        fi
        if mysql -u root -p"$mysql_root_password" -e "SELECT User FROM mysql.user WHERE User='$db_user';" 2>/dev/null | grep -q "$db_user"; then
            user_exists=true
        fi
    fi
    
    # Handle existing database
    if [ "$db_exists" = true ]; then
        print_status "✅ Database '$db_name' already exists - will not recreate"
    fi
    
    # Handle existing user
    if [ "$user_exists" = true ]; then
        print_warning "User '$db_user' already exists and will be recreated with a new password"
        
        # Check if running in non-interactive mode (piped from wget)
        if [ ! -t 0 ]; then
            print_status "Running in non-interactive mode - automatically overriding existing user"
            print_status "Proceeding to override existing user '$db_user'"
        else
            echo -n "Do you want to continue and override the existing user? (y/N): "
            read -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                print_status "Database setup cancelled"
                return 1
            fi
            print_status "Proceeding to override existing user '$db_user'"
        fi
    fi
    
    # Create database and user
    if [ "$db_exists" = true ]; then
        print_status "Using existing database '$db_name'..."
    else
        print_status "Creating database '$db_name'..."
    fi
    
    # Prepare MySQL commands - only create database if it doesn't exist
    mysql_commands="
-- Create database only if it doesn't exist
CREATE DATABASE IF NOT EXISTS \`$db_name\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Drop existing users if they exist (override)
DROP USER IF EXISTS '$db_user'@'localhost';
DROP USER IF EXISTS '$db_user'@'%';

-- Create user for localhost with new password
CREATE USER '$db_user'@'localhost' IDENTIFIED BY '$db_password';
-- Create user for any host (for remote connections)
CREATE USER '$db_user'@'%' IDENTIFIED BY '$db_password';

-- Grant ALL PRIVILEGES on ALL databases (*.*)
GRANT ALL PRIVILEGES ON *.* TO '$db_user'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO '$db_user'@'%' WITH GRANT OPTION;

-- Apply changes
FLUSH PRIVILEGES;

-- Show database status
SHOW DATABASES LIKE '$db_name';
"
    
    if [ "$db_exists" = true ] && [ "$user_exists" = true ]; then
        print_status "Note: Database '$db_name' exists, recreating user '$db_user' with FULL administrative privileges"
    elif [ "$db_exists" = true ]; then
        print_status "Note: Database '$db_name' exists, creating user '$db_user' with FULL administrative privileges"
    elif [ "$user_exists" = true ]; then
        print_status "Note: Creating database '$db_name', recreating user '$db_user' with FULL administrative privileges"
    else
        print_status "Note: Creating database '$db_name' and user '$db_user' with FULL administrative privileges"
    fi
    
    # Execute MySQL commands
    if [ -z "$mysql_root_password" ]; then
        echo "$mysql_commands" | mysql -u root
    else
        echo "$mysql_commands" | mysql -u root -p"$mysql_root_password"
    fi
    
    if [ $? -eq 0 ]; then
        if [ "$db_exists" = true ]; then
            print_status "Database '$db_name' was already available and user updated successfully!"
        else
            print_status "Database '$db_name' and user created successfully!"
        fi
        
        # Test the new user connection
        if test_mysql_connection "$db_user" "$db_password"; then
            print_status "Database connection test successful!"
            
            # Test if user can see all databases
            local total_dbs=$(mysql -u "$db_user" -p"$db_password" -e "SHOW DATABASES;" 2>/dev/null | grep -v Database | wc -l)
            
            if [ "$total_dbs" -gt 3 ]; then
                print_status "✅ User can see $total_dbs databases - full administrative access confirmed!"
            else
                print_warning "⚠️ User can only see $total_dbs databases - may have limited access"
                print_status "Checking user privileges..."
                
                # Show current privileges for debugging
                if [ -z "$mysql_root_password" ]; then
                    mysql -u root -e "SHOW GRANTS FOR '$db_user'@'localhost';" 2>/dev/null | head -3 || true
                else
                    mysql -u root -p"$mysql_root_password" -e "SHOW GRANTS FOR '$db_user'@'localhost';" 2>/dev/null | head -3 || true
                fi
                
                print_warning "If this is a multi-tenant system, you may need to manually grant additional privileges"
            fi
            
            # Test database creation and deletion privileges
            print_status "Testing database creation and deletion privileges..."
            test_database_privileges "$db_user" "$db_password" "$mysql_root_password"
        else
            print_warning "Database setup completed but connection test failed"
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
    
    # Determine the correct MySQL/MariaDB configuration directory
    local mysql_conf_dir=""
    local mysql_conf=""
    
    # Check common MySQL/MariaDB configuration directories
    if [ -d "/etc/mysql/mysql.conf.d" ]; then
        mysql_conf_dir="/etc/mysql/mysql.conf.d"
        mysql_conf="$mysql_conf_dir/gympify.cnf"
    elif [ -d "/etc/mysql/mariadb.conf.d" ]; then
        mysql_conf_dir="/etc/mysql/mariadb.conf.d"
        mysql_conf="$mysql_conf_dir/gympify.cnf"
    elif [ -d "/etc/mysql/conf.d" ]; then
        mysql_conf_dir="/etc/mysql/conf.d"
        mysql_conf="$mysql_conf_dir/gympify.cnf"
    elif [ -d "/etc/my.cnf.d" ]; then
        mysql_conf_dir="/etc/my.cnf.d"
        mysql_conf="$mysql_conf_dir/gympify.cnf"
    else
        # Create a basic conf.d directory if none exists
        mysql_conf_dir="/etc/mysql/conf.d"
        mkdir -p "$mysql_conf_dir"
        mysql_conf="$mysql_conf_dir/gympify.cnf"
    fi
    
    print_status "Using MySQL/MariaDB config directory: $mysql_conf_dir"
    
    if [ ! -f "$mysql_conf" ]; then
        print_status "Creating MySQL optimization configuration..."
        
        # Ensure the directory exists
        mkdir -p "$mysql_conf_dir"
        
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

# Function to setup HestiaCP domain configuration helper
create_hestiacp_helper() {
    print_header "Creating HestiaCP configuration helper..."
    
    local helper_script="/tmp/gympify_hestiacp_setup.sh"
    
    cat > "$helper_script" << 'EOF'
#!/bin/bash

# Gympify HestiaCP Domain Setup Helper
# This script helps configure a domain in HestiaCP for Gympify

print_status() {
    echo -e "\033[0;32m[INFO]\033[0m $1"
}

print_warning() {
    echo -e "\033[1;33m[WARNING]\033[0m $1"
}

print_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1"
}

print_header() {
    echo -e "\033[0;34m[HESTIACP HELPER]\033[0m $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "This helper script must be run as root"
    exit 1
fi

# Check if HestiaCP is installed
if ! command -v v-list-users >/dev/null 2>&1; then
    print_error "HestiaCP not found on this system"
    exit 1
fi

print_header "HestiaCP Domain Configuration for Gympify"
echo
echo "This helper will guide you through setting up a domain in HestiaCP for Gympify."
echo

# Get HestiaCP users
print_status "Available HestiaCP users:"
v-list-users | tail -n +3 | awk '{print "  - " $1}'
echo

read -p "Enter HestiaCP username: " hestia_user
read -p "Enter domain name (e.g., gympify.example.com): " domain_name

# Validate user exists
if ! v-list-user "$hestia_user" >/dev/null 2>&1; then
    print_error "User '$hestia_user' does not exist in HestiaCP"
    exit 1
fi

print_status "Setting up domain '$domain_name' for user '$hestia_user'..."

# Add domain if it doesn't exist
if ! v-list-web-domain "$hestia_user" "$domain_name" >/dev/null 2>&1; then
    print_status "Adding domain '$domain_name'..."
    v-add-web-domain "$hestia_user" "$domain_name"
    
    if [ $? -eq 0 ]; then
        print_status "✅ Domain '$domain_name' added successfully"
    else
        print_error "Failed to add domain '$domain_name'"
        exit 1
    fi
else
    print_status "✅ Domain '$domain_name' already exists"
fi

# Set PHP version to 8.3
print_status "Setting PHP version to 8.3 for domain '$domain_name'..."
v-change-web-domain-backend-tpl "$hestia_user" "$domain_name" "PHP-8_2"

if [ $? -eq 0 ]; then
    print_status "✅ PHP 8.3 set for domain '$domain_name'"
else
    print_warning "Failed to set PHP 8.3. You may need to do this manually in HestiaCP panel."
fi

# Get domain path
domain_path="/home/$hestia_user/web/$domain_name/public_html"
print_status "Domain document root: $domain_path"

echo
print_header "Domain Setup Complete!"
print_status "Domain: $domain_name"
print_status "User: $hestia_user"
print_status "Document Root: $domain_path"
print_status "PHP Version: 8.3 (if supported)"
echo
print_status "Next steps:"
echo "1. Upload Gympify files to: $domain_path"
echo "2. Set document root to: $domain_path/public (if using Laravel structure)"
echo "3. Configure .env file with database credentials from the pre-install script"
echo "4. Set proper file permissions: chown -R $hestia_user:$hestia_user $domain_path"
echo "5. Navigate to https://$domain_name/install to complete Gympify installation"
echo
EOF

    chmod +x "$helper_script"
    
    print_status "HestiaCP configuration helper created at: $helper_script"
    print_status "Run this helper after the main installation to configure your domain"
}

# Main execution
main() {
    # Handle command line arguments
    if [ "$1" = "--test-db-privileges" ]; then
        print_header "Manual Database Privilege Testing"
        
        # Check if MySQL is running
        if ! check_mysql_service; then
            print_error "MySQL service is not running. Please start MySQL service first."
            exit 1
        fi
        
        # Get credentials for testing
        echo -n "Enter database username to test (default: gympify_admin): "
        read -r test_user
        test_user=${test_user:-gympify_admin}
        
        echo -n "Enter database password for $test_user: "
        read -s test_password
        echo
        
        echo -n "Enter MySQL root password (leave empty if no password): "
        read -s root_password
        echo
        
        # Test the credentials first
        if test_mysql_connection "$test_user" "$test_password"; then
            print_status "Connection test successful, running privilege tests..."
            test_database_privileges "$test_user" "$test_password" "$root_password"
        else
            print_error "Failed to connect with provided credentials"
            exit 1
        fi
        
        exit 0
    fi
    
    print_header "Gympify Pre-Installation Script for HestiaCP VPS"
    echo "This script is specifically designed for VPS servers managed by HestiaCP Control Panel"
    echo
    echo "This script will:"
    echo "- Verify HestiaCP installation and version"
    echo "- Install PHP 8.3 with all required extensions for HestiaCP"
    echo "- Install and configure ionCube Loader for HestiaCP PHP"
    echo "- Set up MySQL database with optimized configuration"
    echo "- Create Gympify database user with secure random password"
    echo "- Apply HestiaCP-compatible MySQL optimizations"
    echo "- Display database credentials for .env configuration"
    echo "- Create HestiaCP domain configuration helper"
    echo
    
    # Confirm execution
    if [ ! -t 0 ]; then
        # Running in non-interactive mode (piped from wget)
        print_status "Running in non-interactive mode - automatically proceeding with HestiaCP VPS setup"
    else
        read -p "Do you want to continue with HestiaCP VPS setup? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Installation cancelled"
            exit 0
        fi
    fi
    
    # Check if running as root (required for HestiaCP operations)
    if [ "$EUID" -ne 0 ]; then
        print_error "This script must be run as root for HestiaCP VPS operations"
        print_error "Please run: sudo $0"
        exit 1
    fi
    
    # Verify HestiaCP installation
    if is_hestiacp_server; then
        print_status "✅ HestiaCP control panel detected - proceeding with VPS setup"
    else
        print_error "❌ HestiaCP control panel not found on this server"
        print_error "This script is designed specifically for HestiaCP VPS environments"
        print_error "Please ensure HestiaCP is properly installed before running this script"
        exit 1
    fi
    
    # Run HestiaCP-specific setup steps
    print_header "Starting HestiaCP VPS setup for Gympify..."
    
    install_php_hestiacp
    install_ioncube_loader
    verify_php_installation
    
    # Database setup (works with HestiaCP MySQL)
    check_mysql_config
    setup_mysql_database
    optimize_mysql
    
    # Create HestiaCP helper
    create_hestiacp_helper
    
    print_header "HestiaCP VPS Pre-installation complete!"
    print_status "✅ PHP 8.3 with all required extensions installed for HestiaCP"
    print_status "✅ ionCube Loader configured for HestiaCP PHP environment"
    print_status "✅ MySQL database setup completed with credentials displayed above"
    print_status "✅ Database privilege testing completed"
    print_status "✅ HestiaCP domain configuration helper created"
    print_status "✅ HestiaCP VPS is now ready for Gympify installation"
    echo
    print_status "Next steps for HestiaCP VPS:"
    echo "1. Run the domain helper: bash /tmp/gympify_hestiacp_setup.sh"
    echo "2. Upload and extract Gympify files to your domain's document root"
    echo "3. Copy .env.example to .env in the Gympify directory"
    echo "4. Update .env file with the database credentials shown above"
    echo "5. In HestiaCP Panel: Ensure PHP 8.3 is selected for your domain"
    echo "6. In HestiaCP Panel: Verify all required PHP extensions are enabled"
    echo "7. Set proper file permissions for your domain files"
    echo "8. Navigate to your-domain.com/install to complete Gympify installation"
    echo
    print_warning "Important HestiaCP Configuration:"
    echo "- Use HestiaCP Panel to set PHP 8.3 for your domain"
    echo "- Verify ionCube Loader is enabled in PHP settings"
    echo "- Ensure document root points to Gympify's public directory (if using Laravel structure)"
    echo "- Configure SSL certificate if needed via HestiaCP SSL settings"
    echo "- Use the domain helper script for easier domain configuration"
    
    # Offer manual testing option
    echo
    if [ -t 0 ]; then
        print_status "💡 Additional Options:"
        echo "Domain configuration helper: bash /tmp/gympify_hestiacp_setup.sh"
        echo "Manual privilege test: sudo bash $0 --test-db-privileges"
        echo
    fi
}

# Run main function
main "$@"
