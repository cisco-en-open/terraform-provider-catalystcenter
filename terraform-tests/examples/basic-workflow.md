# Basic Workflow Examples

This document provides step-by-step examples for common workflows using the Terraform Provider Catalyst Center Test Suite.

## Prerequisites

Before starting any workflow:

1. **Terraform Installed**: Ensure Terraform is installed and in your PATH
2. **Network Connectivity**: Ensure connectivity to your Catalyst Center instances
3. **Credentials**: Have valid Catalyst Center credentials for each environment
4. **Repository**: Clone and navigate to the terraform-tests directory

## Workflow 1: Setting Up Development Environment

### Step 1: Initialize Development Environment

```bash
# Navigate to the terraform-tests directory
cd terraform-tests

# Initialize the development environment
./scripts/setup-inventory.sh dev
```

### Step 2: Configure Development Credentials

```bash
# Edit the development configuration
vi inventories/dev/terraform.tfvars
```

Update with your development Catalyst Center details:
```hcl
catalyst_username = "admin"
catalyst_password = "your-dev-password"
catalyst_base_url = "https://dev-catalyst-center.example.com"
catalyst_debug = true
catalyst_ssl_verify = false
```

### Step 3: Validate Configuration

```bash
# Validate the configuration
./scripts/validate-config.sh dev

# Test connectivity
./scripts/validate-config.sh dev --connectivity
```

### Step 4: Run Your First Test

```bash
# Run a simple use case (dry run first)
./scripts/run-test.sh dev site-hierarchy --dry-run

# If dry run looks good, run for real
./scripts/run-test.sh dev site-hierarchy
```

### Step 5: Clean Up

```bash
# Clean up when done (dry run first)
./scripts/cleanup.sh dev --dry-run

# Actually clean up
./scripts/cleanup.sh dev
```

## Workflow 2: Progressive Environment Testing

This workflow demonstrates testing across multiple environments.

### Step 1: Development Testing

```bash
# Setup and test in development
./scripts/setup-inventory.sh dev
# Configure inventories/dev/terraform.tfvars
./scripts/validate-config.sh dev --connectivity
./scripts/run-test.sh dev site-hierarchy
```

### Step 2: Staging Validation

```bash
# Setup staging environment
./scripts/setup-inventory.sh staging
# Configure inventories/staging/terraform.tfvars
./scripts/validate-config.sh staging --connectivity

# Run the same use case in staging
./scripts/run-test.sh staging site-hierarchy --validate
```

### Step 3: Production Readiness Check

```bash
# Setup production (with extreme caution)
./scripts/setup-inventory.sh production
# Configure inventories/production/terraform.tfvars

# Validate only (never run actual changes without approval)
./scripts/validate-config.sh production
./scripts/run-test.sh production site-hierarchy --dry-run
```

## Workflow 3: Comprehensive Use Case Testing

Testing all available use cases in development.

### Step 1: Setup Environment

```bash
./scripts/setup-inventory.sh dev --validate
```

### Step 2: Run Individual Use Cases

```bash
# Test each use case individually
./scripts/run-test.sh dev site-hierarchy
./scripts/run-test.sh dev device-credentials
./scripts/run-test.sh dev pnp
./scripts/run-test.sh dev inventory
```

### Step 3: Run All Use Cases

```bash
# Run all use cases at once
./scripts/run-test.sh dev all
```

### Step 4: Results Analysis

```bash
# Check the work directory for results
ls -la inventories/dev/work/

# Review outputs for each use case
for use_case in site-hierarchy pnp inventory device-credentials; do
    echo "=== $use_case outputs ==="
    cd inventories/dev/work/$use_case
    terraform output
    cd ../../../../
done
```

## Workflow 4: Troubleshooting and Debugging

When things don't work as expected.

### Step 1: Enable Verbose Mode

```bash
# Run with verbose output
./scripts/run-test.sh dev site-hierarchy --verbose
```

### Step 2: Check Configuration

```bash
# Validate configuration syntax
./scripts/validate-config.sh dev --syntax-only

# Test connectivity
./scripts/validate-config.sh dev --connectivity
```

### Step 3: Manual Debugging

```bash
# Navigate to the specific use case work directory
cd inventories/dev/work/site-hierarchy

# Run terraform commands manually
terraform plan -detailed-exitcode
terraform validate
terraform fmt -check
```

### Step 4: Review Logs

```bash
# Check initialization logs
cat init.log

# Check terraform output
terraform plan -no-color > plan.log 2>&1
cat plan.log
```

## Workflow 5: Configuration Management

Managing different configurations across environments.

### Step 1: Environment-Specific Variables

Development (`inventories/dev/terraform.tfvars`):
```hcl
catalyst_debug = true
catalyst_ssl_verify = false
resource_prefix = "dev"
max_devices = 100
test_timeout = "30m"
```

Staging (`inventories/staging/terraform.tfvars`):
```hcl
catalyst_debug = false
catalyst_ssl_verify = true
resource_prefix = "stg"
max_devices = 500
test_timeout = "60m"
```

Production (`inventories/production/terraform.tfvars`):
```hcl
catalyst_debug = false
catalyst_ssl_verify = true
resource_prefix = "prod"
max_devices = 5000
test_timeout = "120m"
```

### Step 2: Validate All Environments

```bash
# Validate all environments at once
./scripts/validate-config.sh all
```

### Step 3: Environment-Specific Testing

```bash
# Run the same test in all environments
for env in dev staging; do
    echo "Testing in $env..."
    ./scripts/run-test.sh $env device-credentials --validate
done
```

## Workflow 6: Backup and Recovery

Protecting your configurations and state.

### Step 1: Create Backups Before Major Changes

```bash
# Backup before running tests
./scripts/cleanup.sh dev --backup --dry-run

# Run tests
./scripts/run-test.sh dev all

# Backup after successful tests
./scripts/cleanup.sh dev --backup --dry-run
```

### Step 2: Backup Management

```bash
# List available backups
ls -la inventories/dev/backups/

# Restore from backup if needed
cd inventories/dev
cp -r backups/20231215_143022/* .
```

### Step 3: State Management

```bash
# Check terraform state
cd inventories/dev/work/site-hierarchy
terraform state list
terraform state show <resource_name>
```

## Workflow 7: Continuous Integration

Automating testing in CI/CD pipelines.

### CI Script Example

```bash
#!/bin/bash
set -e

# Setup
./scripts/setup-inventory.sh dev

# Validate
./scripts/validate-config.sh dev --connectivity

# Test all use cases
./scripts/run-test.sh dev all --auto-approve

# Cleanup
./scripts/cleanup.sh dev --auto-approve

echo "CI testing completed successfully"
```

### Parallel Testing (Development Only)

```bash
# Run tests in parallel (dev environment only)
./scripts/run-test.sh dev all --parallel
```

## Common Commands Reference

### Quick Commands

```bash
# Setup environment
./scripts/setup-inventory.sh <env>

# Validate configuration
./scripts/validate-config.sh <env>

# Run specific use case
./scripts/run-test.sh <env> <use-case>

# Clean up
./scripts/cleanup.sh <env>
```

### Safety Commands

```bash
# Always dry run first
./scripts/run-test.sh <env> <use-case> --dry-run
./scripts/cleanup.sh <env> --dry-run

# Validate before running
./scripts/run-test.sh <env> <use-case> --validate

# Plan only (no apply)
./scripts/run-test.sh <env> <use-case> --plan-only
```

### Troubleshooting Commands

```bash
# Verbose output
./scripts/run-test.sh <env> <use-case> --verbose

# Syntax validation only
./scripts/validate-config.sh <env> --syntax-only

# Connectivity testing
./scripts/validate-config.sh <env> --connectivity
```

## Best Practices Summary

1. **Always start with development environment**
2. **Use dry run mode first** (`--dry-run`)
3. **Validate configurations** before running tests
4. **Test connectivity** before executing use cases
5. **Create backups** before major operations
6. **Use environment-appropriate settings** (debug, SSL, etc.)
7. **Follow the progression**: dev → staging → production
8. **Clean up resources** after testing
9. **Document any issues** or custom configurations
10. **Use version control** for your terraform.tfvars files (excluding sensitive data)

## Next Steps

After mastering these basic workflows, explore:
- [Advanced Scenarios](advanced-scenarios.md)
- Custom use case development
- Integration with CI/CD pipelines
- Multi-environment orchestration
- Custom validation scripts