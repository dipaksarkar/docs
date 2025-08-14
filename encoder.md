# IonCube Encoder Script

A powerful Bash script for encoding PHP projects using IonCube Encoder 13. This script supports both entire project encoding and specific path encoding with full customization of IonCube encoder options.

## Features

- 🚀 **Two Encoding Modes**: Encode entire project or specific directories
- ⚙️ **Custom IonCube Options**: Pass any IonCube encoder option directly
- 🔒 **Smart Exclusions**: Automatic vendor exclusion for Laravel projects
- 💾 **Backup Support**: Optional backup before encoding
- 🌐 **Remote Encoding**: Uses SSH to encode on a remote server
- 📝 **Detailed Logging**: Comprehensive progress reporting and error handling
- 🎯 **Laravel Optimized**: Default options optimized for Laravel/type-hinted projects

## Prerequisites

- Bash shell (macOS/Linux)
- SSH access to a server with IonCube Encoder installed
- `zip`/`unzip` utilities
- `scp` for file transfers

## Installation

1. Clone or download the script:
```bash
wget https://your-repo/encoder.sh
chmod +x encoder.sh
```

2. Configure your environment variables (optional):
```bash
export SSH_HOST="your-server-ip"
export SSH_USER="your-username"
export SSH_PORT="22"
export IONCUBE_ENCODER_PATH="/path/to/ioncube_encoder.sh"
```

## Usage

### Basic Syntax

```bash
./encoder.sh {project_path} [options] [ioncube_options]
```

### Encoding Modes

#### 1. Entire Project Encoding

Encode the entire project (automatically excludes `vendor` directory):

```bash
# Basic entire project encoding
./encoder.sh /path/to/laravel-project --optimize max --allow-reflection-all

# With custom excludes
./encoder.sh /path/to/laravel-project --optimize max --allow-reflection-all --exclude vendor --exclude tests --exclude storage

# With backup
./encoder.sh /path/to/laravel-project --optimize max --allow-reflection-all --backup
```

#### 2. Specific Path Encoding

Encode only specified directories:

```bash
# Encode specific directories
./encoder.sh /path/to/laravel-project --encode app --encode database --optimize max --allow-reflection-all

# Multiple paths with excludes and specific reflection patterns
./encoder.sh /path/to/laravel-project --encode app --encode config --exclude app/Console/Commands/TestCommand.php --optimize max --allow-reflection 'App\Models::*'
```

## Options

### Script Options

| Option | Description | Example |
|--------|-------------|---------|
| `--encode <path>` | Specify directory to encode (can be used multiple times) | `--encode app --encode database` |
| `--backup` | Create backup before encoding | `--backup` |
| `--exclude <path>` | Exclude files/directories (can be used multiple times) | `--exclude vendor --exclude tests` |

### IonCube Encoder Options

Pass any IonCube encoder option directly to the script:

| Option | Description |
|--------|-------------|
| `--optimize <level>` | Optimization level (none, more, max) |
| `--allow-reflection-all` | Enable Reflection API for all functions/methods (Laravel compatible) |
| `--allow-reflection <pattern>` | Enable Reflection API for specific patterns |
| `--no-doc-comments` | Remove documentation comments |
| `--obfuscate-variables` | Obfuscate variable names |
| `--obfuscate-functions` | Obfuscate function names |
| `--binary-encoding` | Use binary encoding |
| `--encrypt <pattern>` | Encrypt files matching pattern |
| `--copy <pattern>` | Copy files without encoding |
| `--ignore <pattern>` | Ignore files/directories |

For a complete list of IonCube options, refer to the [IonCube Encoder Documentation](https://www.ioncube.com/encoder_guide.pdf).

## Type Hints & Reflection API Support

Laravel heavily relies on PHP's Reflection API for features like:
- **Dependency Injection**: Container resolution using type hints
- **Model Relationships**: Automatic relationship detection
- **Route Model Binding**: Automatic model injection
- **Service Provider Registration**: Automatic service discovery

### Reflection Options

| Option | Use Case | Example |
|--------|----------|---------|
| `--allow-reflection-all` | Enable reflection for all functions/methods (recommended for Laravel) | `--allow-reflection-all` |
| `--allow-reflection <pattern>` | Enable reflection for specific patterns only | `--allow-reflection 'App\Models::*'` |

### Common Laravel Reflection Patterns

```bash
# Allow reflection for all Laravel models
--allow-reflection 'App\Models::*'

# Allow reflection for all services
--allow-reflection 'App\Services::*'

# Allow reflection for specific controller
--allow-reflection 'App\Http\Controllers\UserController::*'

# Allow reflection for entire namespace
--allow-reflection 'App\Http::*'

# Allow reflection for specific method
--allow-reflection 'App\Models\User::relationships'
```

### Why Reflection is Important for Laravel

Without proper reflection support, these Laravel features may fail:
- `Route::model()` bindings
- `app()->make()` container resolution
- Eloquent model relationships
- Service container auto-wiring
- FormRequest validation

**Recommendation**: Always use `--allow-reflection-all` for Laravel projects unless you have specific security requirements that need granular reflection control.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SSH_HOST` | `192.168.64.3` | Remote server hostname/IP |
| `SSH_USER` | `ubuntu` | SSH username |
| `SSH_PORT` | `22` | SSH port |
| `REMOTE_WORK_DIR` | `/tmp/encoder_work` | Remote working directory |
| `IONCUBE_ENCODER_PATH` | `/home/ubuntu/ioncube_encoder5_basic_13.0/ioncube_encoder.sh` | Path to IonCube encoder |
| `IONCUBE_OPTIONS` | `--optimize max --allow-reflection-all` | Default IonCube options |

## Examples

### Laravel Project Examples

#### Development Build
```bash
# Encode app and config with debugging info preserved
./encoder.sh /var/www/laravel-app --encode app --encode config --optimize more --allow-reflection-all --exclude vendor --backup
```

#### Production Build
```bash
# Encode entire project with maximum optimization
./encoder.sh /var/www/laravel-app --optimize max --allow-reflection-all --no-doc-comments --obfuscate-variables --exclude vendor --exclude tests --exclude storage/logs
```

#### API-Only Application
```bash
# Encode specific API directories with reflection support
./encoder.sh /var/www/api-app --encode app/Http/Controllers --encode app/Services --encode app/Models --optimize max --allow-reflection 'App\Models::*' --allow-reflection 'App\Services::*'
```

### Custom Server Configuration
```bash
# Using custom server settings with reflection support
SSH_HOST="production-server.com" \
SSH_USER="deploy" \
SSH_PORT="2222" \
IONCUBE_ENCODER_PATH="/opt/ioncube/ioncube_encoder.sh" \
./encoder.sh /var/www/app --encode app --optimize max --allow-reflection-all
```

## Workflow

The script follows these steps:

1. **Validation**: Checks project path and arguments
2. **Packaging**: Creates zip file from project (excludes .git, node_modules, vendor)
3. **Upload**: Transfers zip to remote server via SSH
4. **Extraction**: Extracts project on remote server
5. **Encoding**: Runs IonCube encoder with specified options
6. **Packaging**: Creates zip from encoded files
7. **Download**: Downloads encoded zip back to local machine
8. **Backup**: Creates backup of original files (if --backup specified)
9. **Deployment**: Extracts encoded files to project directory
10. **Cleanup**: Removes temporary files

## Directory Structure

```
project/
├── app/                    # Your application code
├── config/                 # Configuration files
├── database/              # Database files
├── vendor/                # Composer dependencies (excluded by default)
└── backup_20250814_123456/ # Backup directory (if --backup used)
```

## Troubleshooting

### Common Issues

#### SSH Connection Failed
```bash
# Test SSH connection
ssh -p $SSH_PORT $SSH_USER@$SSH_HOST "echo 'Connection successful'"
```

#### IonCube Encoder Not Found
```bash
# Verify encoder path on remote server
ssh -p $SSH_PORT $SSH_USER@$SSH_HOST "ls -la /path/to/ioncube_encoder.sh"
```

#### Permission Denied
```bash
# Check file permissions
chmod +x encoder.sh
```

#### Large Project Timeouts
For large projects, consider:
- Excluding more directories with `--exclude`
- Using specific path encoding instead of entire project
- Increasing SSH timeout settings

### Error Messages

| Error | Solution |
|-------|----------|
| `Project path does not exist` | Verify the project path is correct and accessible |
| `Directory X does not exist in the project` | Check that --encode paths exist in your project |
| `Failed to create zip file` | Ensure you have write permissions in the parent directory |
| `Failed to download encoded zip file` | Check SSH connection and remote server disk space |

## Security Considerations

- **SSH Keys**: Use SSH key authentication instead of passwords
- **Server Security**: Ensure your encoding server is secure and isolated
- **Backup Safety**: Store backups in a secure location
- **Clean Temporary Files**: The script automatically cleans up temporary files

## Performance Tips

- **Exclude Unnecessary Files**: Use `--exclude` for tests, logs, cache files
- **Remote Server**: Use a powerful remote server for faster encoding
- **Parallel Encoding**: For multiple projects, run scripts in parallel
- **Local Network**: Use a server on your local network to reduce transfer time

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This script is provided as-is. Please ensure you have proper licensing for IonCube Encoder.

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review IonCube documentation
3. Create an issue in the repository

---

**Note**: This script requires a valid IonCube Encoder license. Please ensure compliance with IonCube's licensing terms.
