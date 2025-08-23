# Development Environment

This directory contains the configuration for the **development** environment of the Terraform Provider Catalyst Center Test Suite.

## Overview

The development environment is designed for:
- Initial testing and validation
- Development and debugging of new use cases
- Experimentation with provider features
- Learning and training purposes

## Configuration

### Files

- **`terraform.tfvars.example`** - Example configuration file
- **`terraform.tfvars`** - Actual configuration (create from example)
- **`inventory.tf`** - Terraform provider and environment configuration
- **`variables.tf`** - Variable definitions
- **`README.md`** - This documentation

### Setup

1. **Create Configuration File**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit Configuration**
   Update `terraform.tfvars` with your development Catalyst Center details:
   ```hcl
   catalyst_username = "admin"
   catalyst_password = "your-dev-password"
   catalyst_base_url = "https://dev-catalyst-center.example.com"
   ```

3. **Initialize Environment**
   ```bash
   ../../scripts/setup-inventory.sh dev
   ```

## Environment Characteristics

### Debug Settings
- **Debug Mode**: Enabled by default (`catalyst_debug = true`)
- **SSL Verification**: Disabled for lab environments (`catalyst_ssl_verify = false`)
- **Validation**: Enabled for thorough testing (`enable_validation = true`)

### Resource Limits
To prevent resource exhaustion in development:
- **Areas**: Maximum 10
- **Buildings**: Maximum 20
- **Floors**: Maximum 50
- **Devices**: Maximum 100

### Testing Features
- **Auto Cleanup**: Enabled to prevent resource accumulation
- **Retry Attempts**: 3 attempts for failed operations
- **Test Timeout**: 30 minutes per test
- **Parallel Tests**: Maximum 2 concurrent tests

### Resource Naming
All resources use the `dev` prefix:
- Areas: `dev-area-*`
- Buildings: `dev-bldg-*`
- Floors: `dev-floor-*`
- Devices: `dev-device-*`

## Security

### Development Security Settings
- SSL verification is disabled by default for lab environments
- Debug logging is enabled (may expose sensitive information)
- Credentials should still be managed securely

### Best Practices
- Use separate development credentials
- Regularly rotate development passwords
- Monitor debug logs for sensitive information exposure
- Keep development environment isolated from production

## Usage

### Run All Tests
```bash
../../scripts/run-test.sh dev
```

### Run Specific Use Case
```bash
../../scripts/run-test.sh dev site-hierarchy
```

### Validate Configuration
```bash
../../scripts/validate-config.sh dev
```

### Cleanup Resources
```bash
../../scripts/cleanup.sh dev
```

## Troubleshooting

### Common Issues

1. **Connection Errors**
   - Verify network connectivity to development Catalyst Center
   - Check username/password in `terraform.tfvars`
   - Ensure development Catalyst Center is running

2. **Resource Limit Errors**
   - Check current resource counts against limits
   - Clean up unused resources
   - Adjust limits in `terraform.tfvars` if needed

3. **Permission Errors**
   - Verify user has appropriate permissions in development Catalyst Center
   - Check if user account is locked or expired

### Debug Mode
Development environment has debug mode enabled by default. Check logs for detailed information:
- Terraform debug logs
- Provider debug output
- API request/response details

### Validation
The development environment includes validation checks:
- Connectivity testing
- Configuration validation
- Resource verification

## Development Workflow

1. **Setup**: Initialize development environment
2. **Test**: Run individual use cases
3. **Debug**: Use debug logs to troubleshoot issues
4. **Iterate**: Modify and re-test configurations
5. **Cleanup**: Remove test resources when done

## Resource Monitoring

Monitor development environment resources:
- Check Catalyst Center UI for created resources
- Review Terraform state files
- Monitor resource counts against limits
- Clean up regularly to prevent accumulation

## Next Steps

After successful development testing:
1. Move to staging environment for integration testing
2. Validate complete workflows
3. Performance and scale testing
4. Production readiness verification