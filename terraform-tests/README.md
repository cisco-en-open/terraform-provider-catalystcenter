# Terraform Provider Catalyst Center Test Suite

This project provides a comprehensive test framework for the Cisco Catalyst Center Terraform provider with support for dynamic inventory management across multiple environments.

## Overview

The test suite is designed to validate Terraform provider functionality using real use cases sourced from `terraform-provider-catalystcenter/examples/use-cases`. It supports multiple environments (inventories) such as development, staging, and production, each with their own Catalyst Center instances and configurations.

## Project Structure

```
terraform-tests/
├── README.md                    # This file
├── inventories/                 # Environment-specific configurations
│   ├── dev/                     # Development environment
│   │   ├── terraform.tfvars     # Dev-specific variables
│   │   ├── inventory.tf         # Dev inventory configuration
│   │   └── README.md            # Dev environment documentation
│   ├── staging/                 # Staging environment
│   │   ├── terraform.tfvars     # Staging-specific variables
│   │   ├── inventory.tf         # Staging inventory configuration
│   │   └── README.md            # Staging environment documentation
│   └── production/              # Production environment
│       ├── terraform.tfvars     # Production-specific variables
│       ├── inventory.tf         # Production inventory configuration
│       └── README.md            # Production environment documentation
├── use-cases/                   # Test use cases
│   ├── site-hierarchy/          # Site hierarchy tests
│   ├── pnp/                     # Plug and Play tests
│   ├── inventory/               # Inventory management tests
│   ├── device-credentials/      # Device credentials tests
│   └── ...                      # Additional use cases
├── scripts/                     # Automation scripts
│   ├── run-test.sh              # Test execution script
│   ├── setup-inventory.sh       # Inventory setup script
│   ├── validate-config.sh       # Configuration validation
│   └── cleanup.sh               # Cleanup script
└── examples/                    # Usage examples
    ├── basic-workflow.md        # Basic usage example
    └── advanced-scenarios.md    # Advanced scenarios
```

## Key Features

### Dynamic Inventory Management
- Support for multiple environments (dev, staging, production)
- Environment-specific Catalyst Center configurations
- Isolated terraform state management per environment
- Easy switching between environments

### Comprehensive Use Case Coverage
- All use cases from the main provider examples
- Modular test structure allowing selective execution
- Validation and verification scripts
- Automated cleanup capabilities

### Environment Isolation
- Separate terraform.tfvars for each environment
- Independent state files
- Environment-specific resource naming
- Configurable resource limits per environment

## Quick Start

### 1. Setup Environment
Choose your target environment and configure it:

```bash
# Copy example configuration
cp inventories/dev/terraform.tfvars.example inventories/dev/terraform.tfvars

# Edit with your Catalyst Center details
vi inventories/dev/terraform.tfvars
```

### 2. Initialize Environment
```bash
# Initialize the development environment
./scripts/setup-inventory.sh dev
```

### 3. Run Tests
```bash
# Run all use cases against development environment
./scripts/run-test.sh dev

# Run specific use case
./scripts/run-test.sh dev site-hierarchy

# Run with validation
./scripts/run-test.sh dev pnp --validate
```

### 4. Cleanup
```bash
# Clean up resources in development environment
./scripts/cleanup.sh dev
```

## Environment Configuration

Each inventory (environment) contains:

### terraform.tfvars
Environment-specific variables including:
- Catalyst Center connection details (URL, credentials)
- Environment-specific naming prefixes
- Resource limits and configurations
- Debug and SSL settings

### inventory.tf
Environment-specific resource definitions:
- Provider configuration
- Backend configuration (if using remote state)
- Environment-specific locals and data sources

## Use Cases

The following use cases are available for testing:

1. **site-hierarchy** - Network site hierarchy management
2. **pnp** - Plug and Play device onboarding
3. **inventory** - Device inventory workflows
4. **device-credentials** - Device credential management
5. **network-settings** - Network configuration settings
6. **device-discovery** - Device discovery processes
7. **provision** - Device provisioning workflows
8. **swim** - Software image management
9. **network-compliance** - Network compliance validation

Each use case can be executed independently or as part of a complete test suite.

## Scripts

### run-test.sh
Main test execution script with options:
- Environment selection
- Use case selection
- Validation mode
- Parallel execution
- Results reporting

### setup-inventory.sh
Environment initialization script:
- Terraform initialization
- State backend configuration
- Dependency validation
- Environment verification

### validate-config.sh
Configuration validation script:
- Terraform syntax validation
- Variable validation
- Connectivity testing
- Resource verification

### cleanup.sh
Resource cleanup script:
- Selective resource deletion
- Complete environment cleanup
- State file management
- Backup creation

## Best Practices

### Development
1. Always test in development environment first
2. Use debug mode for troubleshooting
3. Validate configurations before execution
4. Monitor resource usage and limits

### Staging
1. Mirror production configurations
2. Test complete workflows end-to-end
3. Validate integration scenarios
4. Performance and scale testing

### Production
1. Use approved configurations only
2. Implement change management processes
3. Monitor and audit all changes
4. Maintain backup and rollback capabilities

## Security Considerations

- Store credentials securely (use environment variables or secret management)
- Use SSL verification in production environments
- Implement access controls for different environments
- Audit and log all test activities
- Regular credential rotation

## Troubleshooting

### Common Issues
1. **Connection Errors**: Verify network connectivity and credentials
2. **Resource Conflicts**: Check for existing resources with same names
3. **State Corruption**: Use state backup and recovery procedures
4. **Permission Errors**: Verify Catalyst Center user permissions

### Debug Mode
Enable debug mode by setting `catalyst_debug = true` in terraform.tfvars for detailed logging.

## Contributing

When adding new use cases or environments:

1. Follow existing directory structure and naming conventions
2. Include comprehensive documentation
3. Add validation and cleanup scripts
4. Test against multiple environments
5. Update this README with new capabilities

## Support

This test suite is designed for validating the terraform-provider-catalystcenter functionality. For provider-specific issues, refer to the main project documentation and issues.

## License

This project follows the same license as the terraform-provider-catalystcenter project.