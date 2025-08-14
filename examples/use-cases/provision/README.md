# Provision Workflow Use Case

This Terraform configuration demonstrates comprehensive device provision workflows using the terraform-provider-catalystcenter. It implements all the workflow operations described in the [Ansible provision workflow documentation](https://github.com/DNACENSolutions/dnac_ansible_workflows/blob/main/workflows/provision/README.md).

## Overview

This use case covers the following provision workflows:

1. **Site Assignment** - Assign a device to a site without provisioning
2. **Device Provision** - Assign a device to site and provision it
3. **Device Re-Provision** - Re-provision an already provisioned device  
4. **Device Un-Provision** - Remove a provisioned device from inventory (via terraform destroy)
5. **Wireless Device Provision** - Provision wireless controllers with managed AP locations
6. **Application Telemetry** - Configure application telemetry settings (configuration only)

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Catalyst Center                              │
├─────────────────────────────────────────────────────────────────┤
│  Site Hierarchy: Global/USA/SAN JOSE/SJ_BLD23                  │
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │   Wired Device  │  │ Wireless Device │  │ Site Assignment │ │
│  │  204.1.2.5      │  │ 204.192.4.200   │  │   204.1.2.6     │ │
│  │  (Provision)    │  │  (Provision)    │  │ (Assign Only)   │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐                      │
│  │ Re-Provision    │  │   Telemetry     │                      │
│  │  204.1.2.7      │  │ 204.1.2.1/2/3   │                      │
│  │ (Re-Provision)  │  │  (Monitor)      │                      │
│  └─────────────────┘  └─────────────────┘                      │
└─────────────────────────────────────────────────────────────────┘
```

## Features

### Workflow Operations

- **Conditional Workflows**: Enable/disable individual workflows via variables
- **Site Assignment**: Assign devices to sites without provisioning
- **Device Provisioning**: Full device provisioning with site assignment
- **Re-provisioning**: Force re-provisioning of existing devices
- **Un-provisioning**: Remove devices via `terraform destroy`
- **Wireless Support**: Provision wireless controllers with AP locations
- **Validation**: Built-in validation rules and error checking

### Configuration Management

- **Dynamic Configuration**: Use variables to control which workflows execute
- **Timeout Management**: Configurable timeouts for operations
- **Debug Support**: Enable debug output for troubleshooting
- **Data Sources**: Automatic device and site lookup
- **Lifecycle Management**: Proper resource lifecycle handling

## Prerequisites

Before using this configuration, ensure you have:

### Catalyst Center Setup

1. **Catalyst Center Access**: Running Catalyst Center instance (version 2.3.7.6+)
2. **Authentication**: Valid credentials configured in provider
3. **Network Connectivity**: Terraform host can reach Catalyst Center
4. **API Access**: REST API enabled on Catalyst Center

### Device Requirements

1. **Device Discovery**: All devices must be discovered in Catalyst Center inventory
2. **Device Connectivity**: Devices must be reachable and manageable
3. **Site Hierarchy**: Target sites must exist in Catalyst Center
4. **Device Status**: Devices should be in a healthy state

### Network Infrastructure

1. **IP Connectivity**: All specified IPs must be accessible
2. **Credentials**: Device credentials configured in Catalyst Center
3. **Protocols**: Required protocols (SNMP, SSH, etc.) enabled on devices

## Quick Start

### 1. Clone and Setup

```bash
# Navigate to the provision use case directory
cd examples/use-cases/provision

# Copy the example variables file
cp terraform.tfvars.example terraform.tfvars
```

### 2. Configure Variables

Edit `terraform.tfvars` with your environment details:

```hcl
# Site hierarchy - update with your actual site
site_name_hierarchy = "Global/USA/SAN JOSE/SJ_BLD23"

# Wired device provision
wired_device_provision = {
  enabled         = true
  management_ip   = "204.1.2.5"      # Your device IP
  provisioning    = true
  force_provisioning = false
}

# Site assignment only (no provisioning)
site_assignment_only = {
  enabled       = true
  management_ip = "204.1.2.6"        # Your device IP
}
```

### 3. Initialize and Plan

```bash
# Initialize Terraform
terraform init

# Review the execution plan
terraform plan
```

### 4. Execute Workflows

```bash
# Apply the configuration
terraform apply

# Verify outputs
terraform output provision_workflow_summary
```

### 5. Clean Up (Un-provision)

```bash
# Remove provisioned devices
terraform destroy
```

## Configuration Examples

### Basic Wired Provisioning

```hcl
wired_device_provision = {
  enabled         = true
  management_ip   = "204.1.2.5"
  provisioning    = true
  force_provisioning = false
}
```

### Wireless Controller Provisioning

```hcl
wireless_device_provision = {
  enabled       = true
  management_ip = "204.192.4.200"
  managed_ap_locations = [
    "Global/USA/SAN JOSE/SJ_BLD23/FLOOR1",
    "Global/USA/SAN JOSE/SJ_BLD23/FLOOR2"
  ]
  force_provisioning = false
}
```

### Site Assignment Only

```hcl
site_assignment_only = {
  enabled       = true
  management_ip = "204.1.2.6"
}
```

### Re-provisioning

```hcl
device_reprovision = {
  enabled       = true
  management_ip = "204.1.2.7"
}
```

## Testing and Validation

### Run Tests

```bash
# Execute the test script
./test.sh
```

The test script validates:
- Terraform configuration syntax
- Required resource definitions
- Variable configurations
- Output definitions
- File structure completeness

### Manual Validation

1. **Catalyst Center UI**: Check Provision > Device Provision
2. **Device Status**: Verify devices show as provisioned
3. **Site Assignment**: Confirm devices are assigned to correct sites
4. **Configuration**: Validate device configurations are applied

## Workflow Details

### 1. Site Assignment Workflow

**Purpose**: Assign devices to sites without provisioning

**Resources Used**:
- `catalystcenter_sda_provision_devices.site_assignment`

**Process**:
1. Get device by IP address
2. Get site by hierarchy name
3. Assign device to site
4. Skip provisioning steps

### 2. Device Provision Workflow

**Purpose**: Full device provisioning with site assignment

**Resources Used**:
- `catalystcenter_sda_provision_devices.wired_provision`

**Process**:
1. Get device by IP address
2. Get site by hierarchy name  
3. Assign device to site
4. Execute provisioning
5. Apply configurations

### 3. Device Re-Provision Workflow

**Purpose**: Re-provision already provisioned devices

**Resources Used**:
- `catalystcenter_sda_provision_devices.device_reprovision`

**Process**:
1. Get existing provisioned device
2. Force recreation using lifecycle rules
3. Re-apply all configurations
4. Verify successful re-provisioning

### 4. Wireless Device Provision Workflow

**Purpose**: Provision wireless controllers with AP management

**Resources Used**:
- `catalystcenter_wireless_provision_device_create.wireless_provision`

**Process**:
1. Get wireless controller by IP
2. Define managed AP locations
3. Configure wireless settings
4. Provision controller
5. Manage AP assignments

### 5. Un-Provision Workflow

**Purpose**: Remove devices from provisioned state

**Implementation**: 
- Execute `terraform destroy`
- Terraform automatically handles resource cleanup
- Devices return to unprovisioned state

## Troubleshooting

### Common Issues

1. **Device Not Found**: Ensure device is discovered in Catalyst Center
2. **Site Not Found**: Verify site hierarchy exists
3. **Provisioning Timeout**: Increase timeout values in variables
4. **Authentication**: Check Catalyst Center credentials

### Debug Mode

Enable debug output:

```hcl
enable_debug = true
```

### Log Analysis

1. **Terraform Logs**: Use `TF_LOG=DEBUG terraform apply`
2. **Catalyst Center Logs**: Check API logs in Catalyst Center
3. **Test Script**: Run `./test.sh` for configuration validation

## Outputs

The configuration provides comprehensive outputs:

- **site_assignment_results**: Site assignment operation results
- **wired_provision_results**: Wired device provisioning results
- **wireless_provision_results**: Wireless device provisioning results
- **reprovision_results**: Re-provisioning operation results
- **provision_workflow_summary**: Overall workflow summary
- **provision_test_results**: Validation and test results

## Best Practices

### Development

1. **Start Small**: Begin with site assignment only
2. **Test Incrementally**: Enable one workflow at a time
3. **Use Debug Mode**: Keep debugging enabled during development
4. **Validate Early**: Run test script before applying

### Production

1. **Backup Configurations**: Save device configs before provisioning
2. **Staged Rollout**: Provision devices in phases
3. **Monitor Progress**: Watch Catalyst Center UI during operations
4. **Have Rollback Plan**: Know how to un-provision if needed

### Security

1. **Credential Management**: Use secure credential storage
2. **Network Isolation**: Ensure secure network connectivity
3. **Access Control**: Limit who can execute provisioning
4. **Audit Trail**: Monitor and log all provisioning activities

## Integration

### With CI/CD

```yaml
# Example GitHub Actions workflow
- name: Terraform Apply
  run: |
    terraform init
    terraform plan
    terraform apply -auto-approve
```

### With Monitoring

- Monitor device status post-provisioning
- Set up alerts for provisioning failures
- Track compliance status
- Generate provisioning reports

## Support

For issues and questions:

1. **Test Script**: Run `./test.sh` for configuration validation
2. **Documentation**: Review Catalyst Center API documentation  
3. **Community**: Check terraform-provider-catalystcenter issues
4. **Logs**: Enable debug mode and review logs

## References

- [Catalyst Center Provision Workflow Documentation](https://github.com/DNACENSolutions/dnac_ansible_workflows/blob/main/workflows/provision/README.md)
- [Terraform Provider Catalyst Center](https://registry.terraform.io/providers/cisco-en-programmability/catalystcenter)
- [Catalyst Center API Documentation](https://developer.cisco.com/docs/dna-center/)

## License

This example is part of the terraform-provider-catalystcenter project and follows the same license terms.