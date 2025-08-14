# Device Discovery Use Case

This Terraform configuration demonstrates comprehensive device discovery functionality in Cisco Catalyst Center using the terraform-provider-catalystcenter. It implements all discovery methods specified in the [DNA Center Ansible Workflows](https://github.com/DNACENSolutions/dnac_ansible_workflows/blob/main/workflows/device_discovery/README.md) but using Terraform instead of Ansible.

## Overview

This use case implements device discovery workflows that scan your network to identify devices and add them to the inventory. The configuration creates multiple discovery jobs covering all supported discovery methods:

### Discovery Methods Implemented

1. **CDP Discovery**: Uses Cisco Discovery Protocol with seed IP addresses
2. **Single IP Discovery**: Discovers individual devices with comprehensive credential sets
3. **Range Discovery**: Scans specified IP address ranges
4. **Multi Range Discovery**: Handles multiple IP ranges simultaneously

### Discovery Types Created

- **CDP Based Discovery**: Simple discovery using CDP with seed IP
- **Single IP Discovery 1**: Individual device discovery with HTTP credentials
- **Single IP Discovery 2**: Individual device discovery with SNMPv3 credentials
- **Range IP Discovery**: IP range scanning with full credential set
- **Multi Range IP Discovery**: Multiple IP range discovery with timeout configuration

## Files Structure

- `main.tf` - Main Terraform configuration with all discovery resources
- `variables.tf` - Variable definitions for flexible configuration
- `outputs.tf` - Output definitions to display created discoveries and test results
- `terraform.tfvars.example` - Example values file for easy setup
- `test.sh` - Validation script to check configuration correctness
- `README.md` - This documentation file

## Prerequisites

1. **Catalyst Center Access**: You need access to a Catalyst Center instance
2. **Provider Configuration**: The terraform-provider-catalystcenter must be configured
3. **Global Credentials**: Global credentials must exist in your Catalyst Center for:
   - CLI access credentials
   - SNMP credentials (v2c and/or v3)
   - HTTPS credentials
4. **Network Access**: Ensure Catalyst Center has appropriate network access to reach target devices
5. **Device Support**: Verify target devices support the chosen discovery protocols (CDP, LLDP, SNMP)

## Configuration

1. Update the variables in `variables.tf` or create a `terraform.tfvars` file with your Catalyst Center configuration:

```hcl
# Global credential IDs from your Catalyst Center
global_credential_id_list = [
  "your-cli-credential-id",
  "your-snmp-credential-id", 
  "your-https-credential-id"
]

# Customize discovery configurations
cdp_discovery = {
  discovery_name   = "Production CDP Discovery"
  ip_address_list  = ["10.1.1.1"]  # Your seed IP
  # ... other settings
}
```

2. Configure the provider in your `main.tf` or create a separate `provider.tf`:

```hcl
provider "catalystcenter" {
  base_url = "https://your-catalyst-center.domain.com"
  username = "your-username"
  password = "your-password"
  debug    = "true"  # Optional: enable for debugging
}
```

## Usage

### Option 1: Standard Deployment

1. Initialize Terraform:
```bash
terraform init
```

2. Create your configuration file:
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your actual values
```

3. Review the planned changes:
```bash
terraform plan
```

4. Apply the configuration:
```bash
terraform apply
```

5. View the discovery results:
```bash
terraform output
```

### Option 2: Quick Test with Default Values

For testing purposes, you can use the default values (ensure they match your environment):

```bash
terraform init
terraform plan
terraform apply
```

### Cleanup

To remove all created discoveries:
```bash
terraform destroy
```

## Discovery Configuration Details

### CDP Discovery
- **Type**: CDP (Cisco Discovery Protocol)
- **Use Case**: Automatic neighbor discovery using CDP
- **Requirements**: CDP-enabled devices
- **IP Format**: Single seed IP (e.g., "10.1.1.1")

### Single IP Discovery
- **Type**: Single
- **Use Case**: Targeted individual device discovery
- **Requirements**: Direct IP access to specific devices
- **IP Format**: Single IP address (e.g., "10.1.1.10")
- **Credentials**: HTTP Read/Write, optional SNMP

### Range Discovery
- **Type**: Range
- **Use Case**: Discover devices within IP range
- **Requirements**: Network access to IP range
- **IP Format**: IP range notation (e.g., "10.1.1.10-10.1.1.20")
- **Credentials**: Full credential set including SNMPv3

### Multi Range Discovery
- **Type**: Multi Range
- **Use Case**: Discover devices across multiple IP ranges
- **Requirements**: Network access to multiple subnets
- **IP Format**: Multiple range notation (e.g., "10.1.1.10-10.1.1.20,10.2.1.10-10.2.1.20")
- **Credentials**: Full credential set with timeout configuration

## Validation

After successful deployment, you can verify the discoveries by:

1. **Terraform Outputs**: Check the output values showing discovery IDs and status
2. **Catalyst Center Web Interface**: 
   - Navigate to Provision > Network Discovery
   - View active discovery jobs and their status
3. **Discovery Results**: Monitor discovery progress and discovered devices

The configuration includes test outputs that validate:
- All discovery types are created successfully
- Discovery IDs are generated
- Credential configurations are applied
- IP address ranges are properly formatted

## Security Considerations

### Credential Management
- Store sensitive credentials securely using Terraform's sensitive variables
- Use Catalyst Center's global credential management
- Avoid hardcoding passwords in configuration files
- Consider using environment variables for sensitive data

### Network Security
- Ensure discovery scopes are appropriate for your network
- Limit IP ranges to authorized network segments  
- Configure discovery credentials with minimal required privileges
- Monitor discovery activities in Catalyst Center

## Troubleshooting

### Common Issues

1. **Invalid Global Credential IDs**
   - Verify credential IDs exist in Catalyst Center
   - Check credential types match discovery requirements

2. **Network Connectivity**
   - Ensure Catalyst Center can reach target IP addresses
   - Verify firewall rules allow discovery protocols

3. **Authentication Failures**
   - Validate device credentials are correct
   - Check SNMP community strings and versions

4. **Discovery Timeouts**
   - Adjust timeout values for slower networks
   - Reduce IP range sizes for large discoveries

### Validation Commands

```bash
# Check Terraform configuration
terraform validate

# View current state
terraform show

# Check for configuration drift
terraform plan

# View discovery outputs
terraform output discovery_summary
terraform output discovery_test_results
```

## Advanced Usage

### Custom Credential Configuration

You can override credential settings for specific discoveries:

```hcl
# Custom SNMPv3 configuration
single_ip_discovery_2 = {
  snmp_v3_credential = {
    username = "custom-snmp-user"
    snmp_mode = "AUTHNOPRIV"  # Alternative to AUTHPRIV
    auth_type = "MD5"         # Alternative to SHA
    # ... other settings
  }
  # ... other discovery settings
}
```

### Multiple Network Segments

Configure discoveries for different network segments:

```hcl
# Production network discovery
range_ip_discovery = {
  ip_address_list = ["10.10.0.1-10.10.0.254"]
  # ... other settings
}

# DMZ network discovery
multi_range_ip_discovery = {
  ip_address_list = [
    "192.168.1.1-192.168.1.50",
    "192.168.2.1-192.168.2.50"
  ]
  # ... other settings
}
```

## References

- [DNA Center Ansible Workflows - Device Discovery](https://github.com/DNACENSolutions/dnac_ansible_workflows/blob/main/workflows/device_discovery/README.md)
- [Device Discovery Variables](https://github.com/DNACENSolutions/dnac_ansible_workflows/blob/main/workflows/device_discovery/vars/device_discovery_vars.yml)
- [Terraform Provider Catalyst Center Documentation](https://registry.terraform.io/providers/cisco-en-programmability/catalystcenter/latest/docs)
- [Catalyst Center Discovery Documentation](https://www.cisco.com/c/en/us/td/docs/cloud-systems-management/network-automation-and-management/dna-center/2-3-7/user_guide/b_cisco_dna_center_ug_2_3_7/b_cisco_dna_center_ug_2_3_7_chapter_0111.html)

## Support

This is a demonstration use case. For production environments:
- Customize IP ranges and credentials appropriately
- Implement proper secret management
- Test thoroughly in a non-production environment first
- Follow your organization's network security policies
- Monitor discovery activities and resource usage

## Notes

- Discovery jobs will run asynchronously in Catalyst Center
- Large IP ranges may take significant time to complete
- Some devices may require specific credential configurations
- Discovery results can be viewed in the Catalyst Center inventory
- Failed discoveries should be investigated using Catalyst Center logs