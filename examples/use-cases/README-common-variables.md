# Common Variables for Terraform Use Cases

This directory contains common variable definitions that can be shared across multiple Cisco Catalyst Center Terraform use cases.

## Files

- **`common-variables.tf`** - Contains common variable definitions used across multiple use cases
- **`common-terraform.tfvars.example`** - Contains example values for the common variables

## Common Variables Included

The following variables are available for use across all use cases:

- `catalyst_username` - Cisco Catalyst Center username (sensitive)
- `catalyst_password` - Cisco Catalyst Center password (sensitive) 
- `catalyst_base_url` - Cisco Catalyst Center base URL, FQDN or IP
- `catalyst_debug` - Boolean to enable debugging
- `catalyst_ssl_verify` - Boolean to enable or disable SSL certificate verification

## Usage Patterns

### Pattern 1: Copy Common Variables (Recommended)

1. Copy `common-variables.tf` to your use case directory:
   ```bash
   cp common-variables.tf your-use-case/
   ```

2. Copy and customize the example tfvars file:
   ```bash
   cp common-terraform.tfvars.example your-use-case/terraform.tfvars
   # Edit terraform.tfvars with your actual values
   ```

3. Add any use-case specific variables to your local `variables.tf` file

### Pattern 2: Symlink Common Variables

1. Create a symlink to the common variables file:
   ```bash
   ln -s ../common-variables.tf your-use-case/common-variables.tf
   ```

2. Reference the common tfvars in your terraform.tfvars:
   ```bash
   # Copy common values and add use-case specific ones
   cp ../common-terraform.tfvars.example terraform.tfvars
   ```

### Pattern 3: Include Common Variables via Terraform

You can also reference the common variables by creating a soft link or using file paths in your terraform configuration.

## Provider Configuration

With common variables, your provider configuration should look like this:

```hcl
provider "catalystcenter" {
  username   = var.catalyst_username
  password   = var.catalyst_password
  base_url   = var.catalyst_base_url
  debug      = var.catalyst_debug
  ssl_verify = var.catalyst_ssl_verify
}
```

## Best Practices

1. **Use Pattern 1 (Copy)** for production use cases to avoid dependency issues
2. **Use Pattern 2 (Symlink)** for development when you want to track changes to common variables
3. Always create your own `terraform.tfvars` file with actual values (never commit sensitive data)
4. Each use case can extend the common variables with its own specific variables
5. Keep sensitive variables marked as `sensitive = true`

## Updating Common Variables

When updating common variables:

1. Update `common-variables.tf` with new variables or changes
2. Update `common-terraform.tfvars.example` with corresponding examples
3. Update this README with any new variables or patterns
4. Test changes across all use cases that depend on common variables

## Migration from Individual Variables

If you have existing use cases with individual catalyst_* variables:

1. Remove duplicate variable definitions from your `variables.tf`
2. Copy or link the common variables file
3. Update your `terraform.tfvars` to use the common variable names
4. Ensure your provider configuration references the variables correctly