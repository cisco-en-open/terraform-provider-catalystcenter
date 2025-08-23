# Network Compliance Workflow for Cisco Catalyst Center

This Terraform configuration implements the network compliance workflow for Cisco Catalyst Center, providing capabilities to:

- Perform compliance checks on reachable devices using IP addresses or site hierarchy
- Support different compliance categories (INTENT, RUNNING_CONFIG, IMAGE, PSIRT, EOX)
- Remediate configuration compliance issues
- Synchronize device configurations (running config with startup config)

This implementation follows the guidelines and workflow outlined in the [DNACENSolutions network compliance workflow](https://github.com/DNACENSolutions/dnac_ansible_workflows/blob/main/workflows/network_compliance/README.md).

## Features

### Device Selection
- **IP Address List**: Specify individual devices by their IP addresses
- **Site-based Selection**: Select all devices within a specified site hierarchy
- **Combined Selection**: Use both IP addresses and site selection simultaneously

### Compliance Operations
- **Full Compliance Check**: Trigger comprehensive compliance validation across all categories
- **Category-specific Checks**: Run compliance checks for specific categories only
- **Compliance Categories Supported**:
  - `INTENT`: Network settings, profiles, workflows, fabric, application visibility
  - `RUNNING_CONFIG`: Running configuration compliance
  - `IMAGE`: Software image compliance  
  - `PSIRT`: Product Security Incident Response Team advisories
  - `EOX`: End of Life/End of Support status
  - `NETWORK_SETTINGS`: Network configuration settings

### Remediation Capabilities
- **Automatic Remediation**: Fix compliance issues found during checks
- **Configuration Sync**: Synchronize startup configuration with running configuration
- **Selective Remediation**: Choose which operations to perform

## Prerequisites

1. **Cisco Catalyst Center**: Version 2.3.7.6 or later
2. **Network Connectivity**: Ensure connectivity to your Catalyst Center instance
3. **Authentication**: Valid credentials with appropriate permissions
4. **Device Reachability**: Target devices must be reachable from Catalyst Center

## Configuration

### Required Variables

```hcl
# Catalyst Center connection details
catalystcenter_host     = "your-catalyst-center-ip"
catalystcenter_username = "admin"
catalystcenter_password = "your-password"

# Device selection (choose one or both)
ip_address_list = ["192.168.1.1", "192.168.1.2"]
# OR
site_name = "Global/USA/SAN JOSE/BLD23"
```

### Optional Configuration

```hcl
# Compliance settings
run_compliance = true
run_compliance_categories = ["INTENT", "RUNNING_CONFIG", "IMAGE"]
trigger_full_compliance = false

# Remediation settings
remediate_compliance_issues = true
sync_device_config = true

# Timeouts
compliance_timeout = "30m"
remediation_timeout = "45m"
sync_timeout = "15m"
```

## Usage Examples

### Basic Compliance Check

```hcl
# Check compliance for specific devices
ip_address_list = ["204.1.2.1", "204.1.2.2"]
run_compliance = true
run_compliance_categories = ["INTENT", "RUNNING_CONFIG"]
```

### Site-wide Compliance with Remediation

```hcl
# Check and fix compliance for all devices in a site
site_name = "Global/USA/SAN JOSE/BLD23"
run_compliance = true
remediate_compliance_issues = true
sync_device_config = true
run_compliance_categories = ["INTENT", "RUNNING_CONFIG", "IMAGE", "PSIRT"]
```

### Full Compliance Scan

```hcl
# Comprehensive compliance check across all categories
ip_address_list = ["204.1.2.1", "204.1.2.2"]
trigger_full_compliance = true
remediate_compliance_issues = true
```

## Running the Configuration

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Plan the deployment**:
   ```bash
   terraform plan -var-file="terraform.tfvars"
   ```

3. **Apply the configuration**:
   ```bash
   terraform apply -var-file="terraform.tfvars"
   ```

4. **Monitor progress**: Use the output task IDs to monitor progress in Catalyst Center

## Important Notes

### ⚠️ Network Impact Warning
Fixing compliance mismatches could result in possible network disruptions. Always:
- Test in a lab environment first
- Schedule during maintenance windows
- Have rollback procedures ready
- Monitor network connectivity during remediation

### Compliance Categories
- **INTENT**: Maps to network settings, profiles, workflows, fabric, and application visibility
- **RUNNING_CONFIG**: Compares running configuration with intended configuration
- **IMAGE**: Validates software image compliance with golden images
- **PSIRT**: Checks for security advisories
- **EOX**: Validates End of Life/End of Support status

### Limitations
- Some compliance issues cannot be automatically remediated (Routing, HA Remediation, Software Images, Security Advisories, SD-Access configurations)
- Devices must be reachable and managed by Catalyst Center
- Appropriate permissions required for remediation operations

## Outputs

The configuration provides comprehensive outputs including:

- **Device Information**: Details of target devices
- **Compliance Results**: Task IDs and compliance check results  
- **Remediation Status**: Results of remediation operations
- **Configuration Sync**: Status of configuration synchronization
- **Workflow Summary**: Overall execution summary
- **Debug Information**: Troubleshooting details (when debug enabled)

## Troubleshooting

### Common Issues

1. **No devices found**: Check IP addresses and site names for accuracy
2. **Permission denied**: Ensure user has compliance and remediation permissions
3. **Task timeouts**: Increase timeout values for large environments
4. **Unreachable devices**: Verify network connectivity and device management status

### Debug Mode

Enable debug mode for detailed troubleshooting:

```hcl
enable_debug = true
catalystcenter_debug = true
```

## Related Resources

This configuration uses the following Catalyst Center resources:
- `catalystcenter_compliance`: Run compliance checks
- `catalystcenter_network_devices_issues_remediation_provision`: Remediate issues
- `catalystcenter_network_device`: Get device information
- `catalystcenter_network_device_by_ip`: Get devices by IP address
- `catalystcenter_compliance_device_details`: Get compliance details

## Compatibility

- **Terraform**: >= 1.0
- **Provider**: cisco-en-open/catalystcenter >= 1.0.0
- **Catalyst Center**: >= 2.3.7.6

## References

- [Cisco Catalyst Center Terraform Provider Documentation](https://registry.terraform.io/providers/cisco-en-open/catalystcenter/latest/docs)
- [Network Compliance Ansible Workflow](https://github.com/DNACENSolutions/dnac_ansible_workflows/tree/main/workflows/network_compliance)
- [Cisco Catalyst Center API Documentation](https://developer.cisco.com/docs/dna-center/)