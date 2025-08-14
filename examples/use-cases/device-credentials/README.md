# Device Credentials Use Case

This Terraform configuration demonstrates comprehensive device credential management in Cisco Catalyst Center using the terraform-provider-catalystcenter. It creates all types of credentials at the global level and assigns them to specific sites.

## Overview

This use case implements the device credentials workflow as described in the [DNA Center Ansible Workflows](https://github.com/DNACENSolutions/dnac_ansible_workflows/blob/main/workflows/device_credentials/README.md) but using Terraform instead of Ansible.

## Credentials Created

### 1. CLI Credentials
- **CLI Sample 1**: Primary CLI credential for device access
- **CLI2**: Secondary CLI credential for device access

### 2. SNMP Credentials
- **SNMPv2c Read**: Read-only SNMP community string
- **SNMPv2c Write**: Read-write SNMP community string
- **SNMPv3**: Secure SNMP with authentication and privacy

### 3. HTTPS Credentials
- **HTTPS Read**: HTTP/HTTPS read access for device monitoring
- **HTTPS Write**: HTTP/HTTPS write access for device configuration

### 4. Netconf Credentials
- **Netconf**: Network configuration protocol credentials

## Site Assignment

The configuration demonstrates assigning credentials to different sites in the hierarchy:
- **Global/India**: Receives all credential types
- **Global/India/Bangalore**: Receives all credential types

## Files Structure

```
device-credentials/
├── main.tf       # Main Terraform configuration
├── variables.tf  # Variable definitions
├── outputs.tf    # Output definitions
└── README.md     # This documentation
```

## Prerequisites

1. **Catalyst Center Access**: You need access to a Catalyst Center instance
2. **Provider Configuration**: The terraform-provider-catalystcenter must be configured
3. **Site Hierarchy**: The sites referenced must exist in your Catalyst Center

## Configuration

### Step 1: Update Site IDs

Before applying this configuration, you need to update the `site_ids` variable in `variables.tf` with actual site IDs from your Catalyst Center:

```hcl
variable "site_ids" {
  default = {
    india     = "your-actual-india-site-id"
    bangalore = "your-actual-bangalore-site-id"
  }
}
```

### Step 2: Customize Credentials (Optional)

All credential values are defined in `variables.tf`. You can customize them as needed:

- CLI usernames, passwords, and enable passwords
- SNMP community strings and v3 parameters
- HTTPS usernames, passwords, and ports
- Netconf connection parameters

### Step 3: Provider Configuration

Ensure your Catalyst Center provider is properly configured with:
- Base URL
- Username and password
- SSL verification settings

## Usage

### Initialize Terraform
```bash
terraform init
```

### Plan the Deployment
```bash
terraform plan
```

### Apply the Configuration
```bash
terraform apply
```

### View Outputs
```bash
terraform output
```

## Security Considerations

- All credential variables are marked as `sensitive = true`
- Passwords and community strings are not displayed in logs
- Store credential values securely (use Terraform Cloud, Vault, etc.)
- Rotate credentials regularly

## Validation

After applying this configuration, you can validate the credentials:

1. **Check Global Credentials**: Verify all credentials appear in Catalyst Center's global credential store
2. **Verify Site Assignment**: Confirm credentials are properly assigned to the specified sites
3. **Test Device Access**: Validate that devices in the sites can be accessed using the assigned credentials

## Troubleshooting

### Common Issues

1. **Invalid Site ID**: Ensure the site IDs in `variables.tf` match actual sites in your Catalyst Center
2. **Authentication Errors**: Verify the provider configuration is correct
3. **Credential Conflicts**: Check if credentials with the same names already exist

### Debug Mode

The provider is configured with `debug = "true"` to provide detailed logging for troubleshooting.

## References

- [DNA Center Ansible Workflows - Device Credentials](https://github.com/DNACENSolutions/dnac_ansible_workflows/blob/main/workflows/device_credentials/README.md)
- [Device Credentials Variables](https://github.com/DNACENSolutions/dnac_ansible_workflows/blob/main/workflows/device_credentials/vars/device_credentials_vars.yml)
- [Terraform Provider Catalyst Center Documentation](https://registry.terraform.io/providers/cisco-en-programmability/catalystcenter/latest/docs)

## Support

This is a demonstration use case. For production environments:
- Customize credential values appropriately
- Implement proper secret management
- Test thoroughly in a non-production environment first
- Follow your organization's security policies