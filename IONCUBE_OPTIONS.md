# IonCube Encoder 13 Options Reference

This document provides a comprehensive reference for IonCube Encoder 13 options that can be used with the encoder script.

## Common Options for Laravel Projects

### Optimization
- `--optimize none` - No optimization (fastest encoding)
- `--optimize more` - More optimization (balanced)
- `--optimize max` - Maximum optimization (slowest encoding, best performance)

### Reflection API Support (Critical for Laravel)
- `--allow-reflection-all` - Enable Reflection API for all functions/methods (recommended for Laravel)
- `--allow-reflection <pattern>` - Enable Reflection API for specific patterns only

### File Processing
- `--no-doc-comments` - Remove documentation comments to reduce file size
- `--ignore <pattern>` - Ignore files/directories matching pattern
- `--copy <pattern>` - Copy files without encoding (e.g., config files)
- `--encrypt <pattern>` - Encrypt specific files (e.g., Blade templates)

### Obfuscation (Security)
- `--obfuscate-variables` - Obfuscate variable names
- `--obfuscate-functions` - Obfuscate function names
- `--obfuscate-classes` - Obfuscate class names
- `--obfuscate all` - Apply all obfuscation options

### Encoding Options
- `--binary-encoding` - Use binary encoding (smaller files)
- `--replace-target` - Replace target files (used by script)

## Laravel-Specific Recommendations

### Development Environment
```bash
--optimize more --allow-reflection-all
```

### Production Environment
```bash
--optimize max --allow-reflection-all --no-doc-comments --obfuscate-variables
```

### High Security
```bash
--optimize max --no-doc-comments --obfuscate all --binary-encoding --allow-reflection 'App\Models::*' --allow-reflection 'App\Services::*'
```

## Reflection API Patterns for Laravel

Laravel heavily uses PHP's Reflection API. Here are common patterns:

### Universal Reflection (Recommended)
```bash
--allow-reflection-all
```
**Best for**: Development, testing, most production Laravel apps

### Namespace-based Patterns
```bash
--allow-reflection 'App\Models::*'           # All model methods
--allow-reflection 'App\Services::*'         # All service methods  
--allow-reflection 'App\Http\Controllers::*' # All controller methods
--allow-reflection 'App\Http::*'             # Entire HTTP namespace
```

### Class-specific Patterns
```bash
--allow-reflection 'App\Models\User::*'                    # All User model methods
--allow-reflection 'App\Http\Controllers\UserController::*' # All UserController methods
```

### Method-specific Patterns
```bash
--allow-reflection 'App\Models\User::relationships'  # Specific method
--allow-reflection 'boot'                            # All boot() methods
```

### Why Reflection Matters for Laravel

Laravel features that require Reflection API:
- **Dependency Injection**: `app()->make()`, constructor injection
- **Route Model Binding**: Automatic model resolution
- **Eloquent Relationships**: Dynamic relationship detection
- **Service Providers**: Auto-discovery and registration
- **Form Requests**: Validation rule discovery
- **Event Listeners**: Automatic listener registration

## File Pattern Examples

### Exclude Patterns
- `--ignore "vendor/"` - Exclude vendor directory
- `--ignore "tests/"` - Exclude tests directory
- `--ignore "*.log"` - Exclude log files
- `--ignore "storage/logs/"` - Exclude Laravel logs

### Copy Patterns (Don't Encode)
- `--copy "config/*"` - Copy config files without encoding
- `--copy "*.json"` - Copy JSON files without encoding
- `--copy "public/*"` - Copy public assets without encoding

### Encrypt Patterns
- `--encrypt "*.blade.php"` - Encrypt Blade templates
- `--encrypt "resources/views/*"` - Encrypt all view files

## Complete Example Commands

### Basic Laravel Encoding
```bash
./encoder.sh /path/to/laravel --optimize max --allow-reflection-all --ignore "vendor/" --ignore "tests/" --copy "config/*"
```

### Production Laravel with Obfuscation
```bash
./encoder.sh /path/to/laravel --optimize max --allow-reflection-all --no-doc-comments --obfuscate-variables --obfuscate-functions --ignore "vendor/" --ignore "tests/" --ignore "storage/logs/" --encrypt "*.blade.php"
```

### Specific Directories with Granular Reflection
```bash
./encoder.sh /path/to/laravel --encode app --encode database --optimize max --allow-reflection 'App\Models::*' --allow-reflection 'App\Services::*'
```

## Performance vs Security Trade-offs

| Level | Optimization | Obfuscation | Reflection | Encoding Speed | Runtime Performance | Security |
|-------|-------------|-------------|------------|---------------|-------------------|----------|
| Basic | `--optimize more` | None | `--allow-reflection-all` | Fast | Good | Low |
| Balanced | `--optimize max` | `--obfuscate-variables` | `--allow-reflection-all` | Medium | Better | Medium |
| High Security | `--optimize max` | `--obfuscate all` | `--allow-reflection 'App\Models::*'` | Slow | Best | High |

## Troubleshooting Common Issues

### "unrecognized option" Error
- Check option spelling and format
- Use `--help` on the encoder to see available options
- Some options may require specific IonCube edition

### Laravel Not Working After Encoding
- Ensure `--without-runtime-loader-protection` is used
- Don't encode config files (`--copy "config/*"`)
- Don't encode vendor directory (`--ignore "vendor/"`)
- Check that IonCube Loader is installed on target server

### Performance Issues
- Use `--optimize max` for production
- Consider `--binary-encoding` for smaller files
- Use `--no-doc-comments` to reduce file size

## IonCube Loader Requirements

Ensure your target server has the appropriate IonCube Loader:
- PHP 7.4: ioncube_loader_lin_7.4.so
- PHP 8.0: ioncube_loader_lin_8.0.so
- PHP 8.1: ioncube_loader_lin_8.1.so
- PHP 8.2: ioncube_loader_lin_8.2.so

Add to php.ini:
```ini
zend_extension = /path/to/ioncube_loader_lin_X.X.so
```

For more detailed information, refer to the official [IonCube Encoder User Guide](https://www.ioncube.com/encoder_guide.pdf).
