#!/bin/bash

# IonCube Encoder Upload/Encode/Download Script
# Usage: ./encoder.sh <path> [--include pattern1,pattern2,...]
# Example: ./encoder.sh /path/to/project --include "*.php,*.inc"

set -e  # Exit on any error

# Configuration - Update these variables for your setup
SSH_HOST="${SSH_HOST:-192.168.64.3}"
SSH_USER="${SSH_USER:-ubuntu}"
SSH_PORT="${SSH_PORT:-22}"
REMOTE_WORK_DIR="${REMOTE_WORK_DIR:-/tmp/encoder_work}"
IONCUBE_ENCODER_PATH="${IONCUBE_ENCODER_PATH:-/usr/local/bin/ioncube_encoder}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 <path> [--include relative/path] [--include relative/path] ..."
    echo ""
    echo "Arguments:"
    echo "  path                 Path to the directory/file to encode"
    echo "  --include path       Relative path to include (can be used multiple times)"
    echo "                      If not specified, all files will be included"
    echo ""
    echo "Examples:"
    echo "  $0 /path/to/project"
    echo "  $0 /path/to/project --include relative/path --include relative/foo/path"
    echo "  $0 /path/to/project --include src/Controllers --include app/Models"
    echo ""
    echo "Environment Variables:"
    echo "  SSH_HOST             Remote server hostname (default: your-server.com)"
    echo "  SSH_USER             SSH username (default: username)"
    echo "  SSH_PORT             SSH port (default: 22)"
    echo "  REMOTE_WORK_DIR      Remote working directory (default: /tmp/encoder_work)"
    echo "  IONCUBE_ENCODER_PATH Path to IonCube encoder on remote server"
    exit 1
}

# Function to check if required tools are available
check_dependencies() {
    local missing_tools=()
    
    for tool in zip unzip ssh scp; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        print_error "Please install the missing tools and try again."
        exit 1
    fi
}

# Function to test SSH connection
test_ssh_connection() {
    print_status "Testing SSH connection to ${SSH_USER}@${SSH_HOST}:${SSH_PORT}..."
    if ! ssh -p "$SSH_PORT" -o ConnectTimeout=10 -o BatchMode=yes "${SSH_USER}@${SSH_HOST}" "echo 'SSH connection successful'" &> /dev/null; then
        print_error "Failed to connect to SSH server. Please check your credentials and connection."
        print_error "Make sure you have SSH key authentication set up or use ssh-agent."
        exit 1
    fi
    print_success "SSH connection successful"
}

# Function to create zip file with optional include paths
create_zip_file() {
    local source_path="$1"
    shift
    local include_paths=("$@")
    local zip_file="${include_paths[-1]}"  # Last argument is the zip file
    unset 'include_paths[-1]'  # Remove zip file from include paths
    
    print_status "Creating zip file from: $source_path"
    
    if [ ! -e "$source_path" ]; then
        print_error "Source path does not exist: $source_path"
        exit 1
    fi
    
    # Remove existing zip file if it exists
    [ -f "$zip_file" ] && rm -f "$zip_file"
    
    if [ ${#include_paths[@]} -eq 0 ]; then
        # Include all files
        print_status "Including all files from the source path"
        if [ -d "$source_path" ]; then
            cd "$(dirname "$source_path")"
            zip -r "$zip_file" "$(basename "$source_path")" -x "*.DS_Store" "*__MACOSX*" "*.git*"
        else
            cd "$(dirname "$source_path")"
            zip "$zip_file" "$(basename "$source_path")"
        fi
    else
        # Include only specified relative paths
        print_status "Including specific relative paths: ${include_paths[*]}"
        cd "$source_path"
        
        # Create temporary file list
        local temp_list=$(mktemp)
        
        for rel_path in "${include_paths[@]}"; do
            print_status "Including relative path: $rel_path"
            
            if [ -e "$rel_path" ]; then
                if [ -d "$rel_path" ]; then
                    # Add directory and all its contents
                    find "$rel_path" -type f >> "$temp_list" 2>/dev/null || true
                else
                    # Add single file
                    echo "$rel_path" >> "$temp_list"
                fi
            else
                print_warning "Relative path not found: $rel_path"
            fi
        done
        
        if [ ! -s "$temp_list" ]; then
            print_error "No files found for the specified relative paths"
            rm -f "$temp_list"
            exit 1
        fi
        
        # Create zip from file list
        zip "$zip_file" -@ < "$temp_list"
        rm -f "$temp_list"
    fi
    
    if [ ! -f "$zip_file" ]; then
        print_error "Failed to create zip file"
        exit 1
    fi
    
    local zip_size=$(ls -lh "$zip_file" | awk '{print $5}')
    print_success "Created zip file: $zip_file ($zip_size)"
}

# Function to upload zip file via SSH
upload_zip_file() {
    local zip_file="$1"
    local remote_zip_path="$2"
    
    print_status "Uploading zip file to remote server..."
    
    # Create remote directory if it doesn't exist
    ssh -p "$SSH_PORT" "${SSH_USER}@${SSH_HOST}" "mkdir -p '$REMOTE_WORK_DIR'"
    
    # Upload the zip file
    if ! scp -P "$SSH_PORT" "$zip_file" "${SSH_USER}@${SSH_HOST}:$remote_zip_path"; then
        print_error "Failed to upload zip file"
        exit 1
    fi
    
    print_success "Uploaded zip file to: $remote_zip_path"
}

# Function to extract and encode files on remote server
encode_files_remotely() {
    local remote_zip_path="$1"
    local remote_encoded_zip="$2"
    
    print_status "Extracting and encoding files on remote server..."
    
    # Create the remote encoding script
    local remote_script="$REMOTE_WORK_DIR/encode_script.sh"
    
    ssh -p "$SSH_PORT" "${SSH_USER}@${SSH_HOST}" "cat > '$remote_script'" << 'EOF'
#!/bin/bash
set -e

WORK_DIR="$1"
ZIP_FILE="$2"
ENCODED_ZIP="$3"
ENCODER_PATH="$4"

cd "$WORK_DIR"

# Extract the uploaded zip
echo "Extracting zip file..."
unzip -q "$ZIP_FILE"

# Find the extracted directory/files
EXTRACTED_ITEMS=$(ls -1 | grep -v "$(basename "$ZIP_FILE")" | grep -v "$(basename "$ENCODED_ZIP")" | grep -v "encode_script.sh" | head -1)

if [ -z "$EXTRACTED_ITEMS" ]; then
    echo "Error: No extracted files found"
    exit 1
fi

echo "Found extracted content: $EXTRACTED_ITEMS"

# Create encoded directory
ENCODED_DIR="encoded_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$ENCODED_DIR"

# Check if IonCube encoder exists
if [ ! -f "$ENCODER_PATH" ]; then
    echo "Error: IonCube encoder not found at: $ENCODER_PATH"
    echo "Please install IonCube encoder or update IONCUBE_ENCODER_PATH"
    exit 1
fi

echo "Encoding files with IonCube encoder..."

# Encode files while preserving directory structure
if [ -d "$EXTRACTED_ITEMS" ]; then
    # If it's a directory, encode recursively
    "$ENCODER_PATH" --copy-unparseable --ignore-missing-files --ignore-parse-errors \
        --into "$ENCODED_DIR" "$EXTRACTED_ITEMS"
else
    # If it's a single file, encode it
    mkdir -p "$ENCODED_DIR"
    "$ENCODER_PATH" --copy-unparseable --ignore-missing-files --ignore-parse-errors \
        --into "$ENCODED_DIR" "$EXTRACTED_ITEMS"
fi

echo "Encoding completed successfully"

# Create zip file with encoded content
echo "Creating zip file with encoded content..."
cd "$ENCODED_DIR"
zip -r "../$ENCODED_ZIP" . -x "*.DS_Store" "*__MACOSX*"

echo "Encoded zip file created: $ENCODED_ZIP"
EOF

    # Make the script executable and run it
    ssh -p "$SSH_PORT" "${SSH_USER}@${SSH_HOST}" "chmod +x '$remote_script'"
    ssh -p "$SSH_PORT" "${SSH_USER}@${SSH_HOST}" "'$remote_script' '$REMOTE_WORK_DIR' '$(basename "$remote_zip_path")' '$(basename "$remote_encoded_zip")' '$IONCUBE_ENCODER_PATH'"
    
    print_success "Files encoded successfully on remote server"
}

# Function to download encoded zip file
download_encoded_zip() {
    local remote_encoded_zip="$1"
    local local_encoded_zip="$2"
    
    print_status "Downloading encoded zip file..."
    
    if ! scp -P "$SSH_PORT" "${SSH_USER}@${SSH_HOST}:$remote_encoded_zip" "$local_encoded_zip"; then
        print_error "Failed to download encoded zip file"
        exit 1
    fi
    
    local zip_size=$(ls -lh "$local_encoded_zip" | awk '{print $5}')
    print_success "Downloaded encoded zip file: $local_encoded_zip ($zip_size)"
}

# Function to extract encoded files to destination
extract_encoded_files() {
    local encoded_zip="$1"
    local destination_path="$2"
    
    print_status "Extracting encoded files to: $destination_path"
    
    # Create backup of original if it exists
    if [ -e "$destination_path" ]; then
        local backup_path="${destination_path}.backup.$(date +%Y%m%d_%H%M%S)"
        print_warning "Creating backup of original: $backup_path"
        if [ -d "$destination_path" ]; then
            cp -r "$destination_path" "$backup_path"
        else
            cp "$destination_path" "$backup_path"
        fi
    fi
    
    # Extract to temporary directory first
    local temp_extract_dir=$(mktemp -d)
    cd "$temp_extract_dir"
    unzip -q "$encoded_zip"
    
    # Move extracted content to destination
    local extracted_items=(*)
    if [ ${#extracted_items[@]} -eq 1 ] && [ -d "${extracted_items[0]}" ]; then
        # If there's only one directory, move its contents
        if [ -d "$destination_path" ]; then
            rm -rf "$destination_path"
        fi
        mv "${extracted_items[0]}" "$destination_path"
    else
        # Multiple items or files, create destination directory if needed
        mkdir -p "$destination_path"
        mv * "$destination_path/"
    fi
    
    cd - > /dev/null
    rm -rf "$temp_extract_dir"
    
    print_success "Extracted encoded files to: $destination_path"
}

# Function to cleanup temporary files
cleanup() {
    print_status "Cleaning up temporary files..."
    
    # Cleanup local temporary files
    [ -f "$LOCAL_ZIP" ] && rm -f "$LOCAL_ZIP"
    [ -f "$LOCAL_ENCODED_ZIP" ] && rm -f "$LOCAL_ENCODED_ZIP"
    
    # Cleanup remote temporary files
    ssh -p "$SSH_PORT" "${SSH_USER}@${SSH_HOST}" "rm -rf '$REMOTE_WORK_DIR'" 2>/dev/null || true
    
    print_success "Cleanup completed"
}

# Main function
main() {
    # Parse arguments
    if [ $# -lt 1 ]; then
        show_usage
    fi
    
    local SOURCE_PATH="$1"
    local INCLUDE_PATHS=()
    
    # Parse --include arguments
    shift
    while [ $# -gt 0 ]; do
        case "$1" in
            --include)
                shift
                if [ $# -eq 0 ]; then
                    print_error "--include requires a path argument"
                    show_usage
                fi
                INCLUDE_PATHS+=("$1")
                ;;
            *)
                print_error "Unknown argument: $1"
                show_usage
                ;;
        esac
        shift
    done
    
    # Convert to absolute path
    SOURCE_PATH=$(realpath "$SOURCE_PATH")
    
    # Generate unique filenames
    local TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    local LOCAL_ZIP="/tmp/source_${TIMESTAMP}.zip"
    local LOCAL_ENCODED_ZIP="/tmp/encoded_${TIMESTAMP}.zip"
    local REMOTE_ZIP="$REMOTE_WORK_DIR/source_${TIMESTAMP}.zip"
    local REMOTE_ENCODED_ZIP="$REMOTE_WORK_DIR/encoded_${TIMESTAMP}.zip"
    
    # Set up cleanup trap
    trap cleanup EXIT
    
    print_status "Starting IonCube encoding process..."
    print_status "Source path: $SOURCE_PATH"
    if [ ${#INCLUDE_PATHS[@]} -gt 0 ]; then
        print_status "Include paths: ${INCLUDE_PATHS[*]}"
    else
        print_status "Including all files"
    fi
    print_status "Remote server: ${SSH_USER}@${SSH_HOST}:${SSH_PORT}"
    
    # Check dependencies
    check_dependencies
    
    # Test SSH connection
    test_ssh_connection
    
    # Create zip file
    if [ ${#INCLUDE_PATHS[@]} -gt 0 ]; then
        create_zip_file "$SOURCE_PATH" "${INCLUDE_PATHS[@]}" "$LOCAL_ZIP"
    else
        create_zip_file "$SOURCE_PATH" "$LOCAL_ZIP"
    fi
    
    # Upload zip file
    upload_zip_file "$LOCAL_ZIP" "$REMOTE_ZIP"
    
    # Encode files remotely
    encode_files_remotely "$REMOTE_ZIP" "$REMOTE_ENCODED_ZIP"
    
    # Download encoded zip file
    download_encoded_zip "$REMOTE_ENCODED_ZIP" "$LOCAL_ENCODED_ZIP"
    
    # Extract encoded files back to source location
    extract_encoded_files "$LOCAL_ENCODED_ZIP" "$SOURCE_PATH"
    
    print_success "IonCube encoding process completed successfully!"
    print_success "Original files have been backed up (if they existed)"
    print_success "Encoded files are now in: $SOURCE_PATH"
}

# Run main function with all arguments
main "$@"
