#!/bin/bash

# IonCube Encoder Upload/Encode/Download Script
# Usage: encoder.sh {path} --encode src/App --encode src/Lib

set -e  # Exit on any error

# Configuration - Update these variables for your setup
SSH_HOST="${SSH_HOST:-192.168.79.3}"
SSH_USER="${SSH_USER:-ubuntu}"
SSH_PORT="${SSH_PORT:-22}"
REMOTE_WORK_DIR="${REMOTE_WORK_DIR:-/tmp/encoder_work}"
IONCUBE_ENCODER_PATH="${IONCUBE_ENCODER_PATH:-/home/ubuntu/ioncube_encoder5_basic_13.0/ioncube_encoder.sh}"

# IonCube encoding options for Laravel/type-hinted projects
IONCUBE_OPTIONS="${IONCUBE_OPTIONS:---optimize max --allow-reflection-all}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables
PROJECT_PATH=""
ENCODE_PATHS=()
EXCLUDE_FILES=()
CUSTOM_IONCUBE_OPTIONS=()
ENCODE_ENTIRE_PROJECT=false
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
ZIP_NAME="project_${TIMESTAMP}.zip"
ENCODED_ZIP_NAME="encoded_${TIMESTAMP}.zip"
BACKUP_DIR=""
DOWNLOAD_DIR=""
CREATE_BACKUP=false

# Function to print colored output
print_info() {
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
usage() {
    echo "Usage: $0 {path} [--encode {directory1}] [--encode {directory2}] ... [--backup] [--exclude {file1}] [--exclude {file2}] ... [ioncube_options]"
    echo ""
    echo "Modes:"
    echo "  Entire Project: Encode the entire project (exclude vendor by default)"
    echo "  Specific Paths: Use --encode to specify directories to encode"
    echo ""
    echo "Options:"
    echo "  --encode    Specify directories to encode (can be used multiple times)"
    echo "              If not used, entire project will be encoded"
    echo "  --backup    Create backup of original files before replacing (optional)"
    echo "  --exclude   Exclude specific files/directories (can be used multiple times)"
    echo ""
    echo "IonCube Options (pass directly to encoder):"
    echo "  --optimize {level}, --no-doc-comments, --obfuscate-variables,"
    echo "  --binary-encoding, --allow-reflection-all, --allow-reflection {pattern}, etc."
    echo ""
    echo "Examples:"
    echo "  # Encode entire project with custom options"
    echo "  $0 /path/to/laravel-project --optimize max --allow-reflection-all --exclude vendor"
    echo ""
    echo "  # Encode specific paths"
    echo "  $0 /path/to/laravel-project --encode app --encode database --optimize max --allow-reflection-all --exclude vendor --exclude tests"
    echo ""
    echo "  # With backup and specific reflection patterns"
    echo "  $0 /path/to/laravel-project --encode app --backup --optimize max --allow-reflection 'App\\Models::*' --allow-reflection 'App\\Services::*'"
    echo ""
    echo "Environment variables:"
    echo "  SSH_HOST     - Remote server hostname/IP (default: 192.168.64.3)"
    echo "  SSH_USER     - SSH username (default: ubuntu)"
    echo "  SSH_PORT     - SSH port (default: 22)"
    echo "  REMOTE_WORK_DIR - Remote working directory (default: /tmp/encoder_work)"
    echo "  IONCUBE_ENCODER_PATH - Path to IonCube encoder on remote server"
    echo "  IONCUBE_OPTIONS - Default IonCube encoding options (can be overridden by command line)"
    exit 1
}

# Function to cleanup on exit
cleanup() {
    if [ -n "$ZIP_NAME" ] && [ -f "$ZIP_NAME" ]; then
        print_info "Cleaning up local zip file: $ZIP_NAME"
        rm -f "$ZIP_NAME"
    fi
    
    if [ -n "$ENCODED_ZIP_NAME" ] && [ -f "$ENCODED_ZIP_NAME" ]; then
        print_info "Cleaning up downloaded zip file: $ENCODED_ZIP_NAME"
        rm -f "$ENCODED_ZIP_NAME"
    fi
    
    # Cleanup temporary download directory
    if [ -n "$DOWNLOAD_DIR" ] && [ -d "$DOWNLOAD_DIR" ]; then
        print_info "Cleaning up temporary download directory: $DOWNLOAD_DIR"
        rm -rf "$DOWNLOAD_DIR"
    fi
    
    # Cleanup remote files
    print_info "Cleaning up remote files..."
    ssh -p "$SSH_PORT" "$SSH_USER@$SSH_HOST" "rm -rf '$REMOTE_WORK_DIR'" 2>/dev/null || true
}

trap cleanup EXIT

# Parse command line arguments
if [ $# -lt 1 ]; then
    print_error "Insufficient arguments provided"
    usage
fi

PROJECT_PATH="$1"
shift

# Parse --encode, --backup, --exclude, and ioncube options
while [ $# -gt 0 ]; do
    case $1 in
        --encode)
            if [ -z "$2" ]; then
                print_error "--encode requires a directory path"
                usage
            fi
            ENCODE_PATHS+=("$2")
            shift 2
            ;;
        --backup)
            CREATE_BACKUP=true
            shift
            ;;
        --exclude)
            if [ -z "$2" ]; then
                print_error "--exclude requires a file path"
                usage
            fi
            EXCLUDE_FILES+=("$2")
            shift 2
            ;;
        --*)
            # Treat all other -- options as IonCube encoder options
            CUSTOM_IONCUBE_OPTIONS+=("$1")
            # Check if this option takes a value
            if [ $# -gt 1 ] && [[ ! "$2" =~ ^-- ]] && [[ ! "$2" =~ ^/ ]]; then
                CUSTOM_IONCUBE_OPTIONS+=("$2")
                shift 2
            else
                shift
            fi
            ;;
        *)
            print_error "Unknown argument: $1"
            usage
            ;;
    esac
done

# Validate arguments
if [ -z "$PROJECT_PATH" ]; then
    print_error "Project path is required"
    usage
fi

# Determine encoding mode
if [ ${#ENCODE_PATHS[@]} -eq 0 ]; then
    ENCODE_ENTIRE_PROJECT=true
    print_info "Mode: Encoding entire project"
    # Add vendor to exclude list by default for entire project encoding
    if [[ ! " ${EXCLUDE_FILES[@]} " =~ " vendor " ]]; then
        EXCLUDE_FILES+=("vendor")
    fi
else
    ENCODE_ENTIRE_PROJECT=false
    print_info "Mode: Encoding specific paths"
fi

# Build final IonCube options
FINAL_IONCUBE_OPTIONS=""
if [ ${#CUSTOM_IONCUBE_OPTIONS[@]} -gt 0 ]; then
    FINAL_IONCUBE_OPTIONS="${CUSTOM_IONCUBE_OPTIONS[*]}"
    print_info "Using custom IonCube options: $FINAL_IONCUBE_OPTIONS"
else
    FINAL_IONCUBE_OPTIONS="$IONCUBE_OPTIONS"
    print_info "Using default IonCube options: $FINAL_IONCUBE_OPTIONS"
fi

print_info "Starting encoding process..."
print_info "Project path: $PROJECT_PATH"
if [ "$ENCODE_ENTIRE_PROJECT" = true ]; then
    print_info "Encoding: Entire project"
else
    print_info "Encode paths: ${ENCODE_PATHS[*]}"
fi
if [ ${#EXCLUDE_FILES[@]} -gt 0 ]; then
    print_info "Exclude files: ${EXCLUDE_FILES[*]}"
fi
print_info "Create backup: $CREATE_BACKUP"
print_info "Remote server: $SSH_USER@$SSH_HOST:$SSH_PORT"

# Step 1: Check if the provided path exists
print_info "Step 1: Checking if project path exists..."
if [ ! -d "$PROJECT_PATH" ]; then
    print_error "Project path does not exist: $PROJECT_PATH"
    exit 1
fi
print_success "Project path exists: $PROJECT_PATH"

# Step 2: Create a zip file from all files in the path
print_info "Step 2: Creating zip file from project..."
cd "$PROJECT_PATH"
zip -r "../$ZIP_NAME" . -x "*.git*" "node_modules/*" "vendor/*" ".DS_Store" "*.log"
cd - > /dev/null
ZIP_PATH="$(dirname "$PROJECT_PATH")/$ZIP_NAME"

if [ ! -f "$ZIP_PATH" ]; then
    print_error "Failed to create zip file"
    exit 1
fi
print_success "Created zip file: $ZIP_PATH"

# Step 3: Upload the zip file using SSH
print_info "Step 3: Uploading zip file to remote server..."
ssh -p "$SSH_PORT" "$SSH_USER@$SSH_HOST" "mkdir -p '$REMOTE_WORK_DIR'"
scp -P "$SSH_PORT" "$ZIP_PATH" "$SSH_USER@$SSH_HOST:$REMOTE_WORK_DIR/"
print_success "Uploaded zip file to remote server"

# Step 4: Extract the zip file on the remote server
print_info "Step 4: Extracting zip file on remote server..."
ssh -p "$SSH_PORT" "$SSH_USER@$SSH_HOST" "
    cd '$REMOTE_WORK_DIR' && 
    unzip -q '$ZIP_NAME' -d extracted/ &&
    echo 'Extraction completed successfully'
"
print_success "Extracted zip file on remote server"

# Step 5: Encode the files using ioncube_encoder
print_info "Step 5: Encoding files with IonCube..."

if [ "$ENCODE_ENTIRE_PROJECT" = true ]; then
    print_info "Encoding entire project"
    ssh -p "$SSH_PORT" "$SSH_USER@$SSH_HOST" "
        cd '$REMOTE_WORK_DIR/extracted' &&
        mkdir -p '../encoded' &&
        '$IONCUBE_ENCODER_PATH' . -o '../encoded' --replace-target $FINAL_IONCUBE_OPTIONS &&
        echo 'Encoded entire project successfully'
    "
else
    for encode_path in "${ENCODE_PATHS[@]}"; do
        print_info "Encoding: $encode_path"
        ssh -p "$SSH_PORT" "$SSH_USER@$SSH_HOST" "
            cd '$REMOTE_WORK_DIR/extracted' &&
            if [ ! -d '$encode_path' ]; then
                echo 'ERROR: Directory $encode_path does not exist in the project'
                exit 1
            fi &&
            mkdir -p '../encoded/$encode_path' &&
            '$IONCUBE_ENCODER_PATH' '$encode_path' -o '../encoded/$encode_path' --replace-target $FINAL_IONCUBE_OPTIONS &&
            echo 'Encoded $encode_path successfully'
        "
    done
fi
print_success "All specified paths have been encoded"

# Step 6: Create a new zip file from the encoded files only
print_info "Step 6: Creating zip file from encoded files..."

# Build exclude arguments for zip command
EXCLUDE_ARGS=""
for exclude_file in "${EXCLUDE_FILES[@]}"; do
    EXCLUDE_ARGS="$EXCLUDE_ARGS -x '$exclude_file'"
done

ssh -p "$SSH_PORT" "$SSH_USER@$SSH_HOST" "
    cd '$REMOTE_WORK_DIR/encoded' &&
    if [ -n '$EXCLUDE_ARGS' ]; then
        eval \"zip -r '../$ENCODED_ZIP_NAME' . $EXCLUDE_ARGS\"
    else
        zip -r '../$ENCODED_ZIP_NAME' .
    fi &&
    echo 'Created encoded zip file successfully'
"
print_success "Created encoded zip file on remote server"

# Step 7: Download the new zip file using SSH
print_info "Step 7: Downloading encoded zip file..."

# Determine the best download location (use a temporary directory to avoid conflicts)
DOWNLOAD_DIR=$(mktemp -d)
if scp -P "$SSH_PORT" "$SSH_USER@$SSH_HOST:$REMOTE_WORK_DIR/$ENCODED_ZIP_NAME" "$DOWNLOAD_DIR/"; then
    ENCODED_ZIP_PATH="$DOWNLOAD_DIR/$ENCODED_ZIP_NAME"
    print_success "Downloaded encoded zip file: $ENCODED_ZIP_PATH"
else
    print_error "Failed to download encoded zip file"
    rmdir "$DOWNLOAD_DIR"
    exit 1
fi

# Step 8: Take a backup of the original files before unzipping (if requested)
if [ "$CREATE_BACKUP" = true ]; then
    print_info "Step 8: Creating backup of original files..."
    BACKUP_DIR="$(dirname "$PROJECT_PATH")/backup_${TIMESTAMP}"
    mkdir -p "$BACKUP_DIR"

    if [ "$ENCODE_ENTIRE_PROJECT" = true ]; then
        print_info "Backing up entire project"
        cp -r "$PROJECT_PATH" "$BACKUP_DIR/"
    else
        for encode_path in "${ENCODE_PATHS[@]}"; do
            if [ -d "$PROJECT_PATH/$encode_path" ]; then
                print_info "Backing up: $encode_path"
                mkdir -p "$BACKUP_DIR/$(dirname "$encode_path")"
                cp -r "$PROJECT_PATH/$encode_path" "$BACKUP_DIR/$encode_path"
            fi
        done
    fi
    print_success "Backup created at: $BACKUP_DIR"
else
    print_info "Step 8: Skipping backup creation (--backup not specified)"
fi

# Step 9: Unzip the new zip file on the local machine at the specified path
print_info "Step 9: Extracting encoded files to project directory..."

# Check if the zip file exists at the expected location
if [ ! -f "$ENCODED_ZIP_PATH" ]; then
    print_error "Encoded zip file not found at: $ENCODED_ZIP_PATH"
    print_info "Looking for zip file in project directory..."
    
    # Try to find the zip file in the project directory
    FOUND_ZIP=$(find "$PROJECT_PATH" -name "*encoded_*.zip" -type f | head -1)
    if [ -n "$FOUND_ZIP" ]; then
        print_info "Found zip file: $FOUND_ZIP"
        ENCODED_ZIP_PATH="$FOUND_ZIP"
    else
        print_error "No encoded zip file found"
        exit 1
    fi
fi

cd "$PROJECT_PATH"
if ! unzip -o "$ENCODED_ZIP_PATH"; then
    print_error "Failed to extract encoded files"
    cd - > /dev/null
    exit 1
fi
cd - > /dev/null

# Verify that encoded files were extracted
print_info "Verifying extracted files..."
if [ "$ENCODE_ENTIRE_PROJECT" = true ]; then
    print_info "✓ Verified: Entire project encoded"
else
    for path in "${ENCODE_PATHS[@]}"; do
        if [ -d "$PROJECT_PATH/$path" ]; then
            print_info "✓ Verified: $path"
        else
            print_warning "⚠ Warning: $path not found after extraction"
        fi
    done
fi

print_success "Encoded files extracted to project directory"

# Cleanup downloaded zip file and temporary directory
if [ -f "$ENCODED_ZIP_PATH" ]; then
    print_info "Cleaning up downloaded zip file: $ENCODED_ZIP_PATH"
    rm -f "$ENCODED_ZIP_PATH"
fi

if [ -n "$DOWNLOAD_DIR" ] && [ -d "$DOWNLOAD_DIR" ]; then
    print_info "Cleaning up temporary download directory: $DOWNLOAD_DIR"
    rmdir "$DOWNLOAD_DIR" 2>/dev/null || true
fi

# Cleanup project zip file
if [ -f "$ZIP_PATH" ]; then
    print_info "Cleaning up project zip file: $ZIP_PATH"
    rm -f "$ZIP_PATH"
fi

print_success "Encoding process completed successfully!"
if [ "$CREATE_BACKUP" = true ] && [ -n "$BACKUP_DIR" ]; then
    print_info "Backup location: $BACKUP_DIR"
fi
if [ "$ENCODE_ENTIRE_PROJECT" = true ]; then
    print_info "Encoded: Entire project"
else
    print_info "Encoded paths: ${ENCODE_PATHS[*]}"
fi

# Final cleanup will be handled by the trap
