# Inventory Workflow Use Case

This use case demonstrates comprehensive inventory management workflows for Cisco Catalyst Center using Terraform. It covers the complete lifecycle of network devices from onboarding to deletion, including provisioning, operations, and maintenance scheduling.

## Overview

This use case covers the following inventory workflows:

1. **Device Onboarding** - Add new devices into inventory with automated workflows
2. **Site Assignment & Provisioning** - Assign devices to specific sites and provision them
3. **Device Operations** - Support update, resync, and reboot operations for managed devices
4. **Device Deletion** - Remove devices cleanly from the fabric inventory (with or without cleanup)
5. **Maintenance Scheduling** - Schedule periodic or one-time maintenance or device restarts

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Catalyst Center                            │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐     │
│  │ Device Onboard  │  │ Site Assignment │  │   Provisioning  │     │
│  │ 204.1.2.10/11   │  │ Global/.../SJ   │  │ SDA Fabric      │     │
│  │   (PnP DB)      │  │   Assignment    │  │  Configuration  │     │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘     │
│                                                                     │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐     │
│  │ Device Ops      │  │ Device Deletion │  │   Maintenance   │     │
│  │ Resync/Reboot   │  │ Clean Removal   │  │   Scheduling    │     │
│  │ 204.1.2.x       │  │ With/Without    │  │  Windows        │     │
│  └─────────────────┘  │ Config Cleanup  │  └─────────────────┘     │
│                       └─────────────────┘                          │
└─────────────────────────────────────────────────────────────────────┘
```

## Prerequisites

### Environment Requirements

1. **Cisco Catalyst Center**: Version 2.3.7.6 or later
2. **Terraform**: Version 0.14 or later
3. **Network Connectivity**: Terraform host must reach Catalyst Center
4. **Authentication**: Valid Catalyst Center credentials configured

### Device Requirements

- **For Onboarding**: New devices not yet discovered in Catalyst Center
- **For Provisioning**: Devices already discovered and reachable
- **For Operations**: Devices provisioned and managed by Catalyst Center
- **For Deletion**: Test devices or devices safe to remove

### Access Requirements

- Administrative access to Catalyst Center
- Permissions for device management and provisioning
- Site hierarchy already configured in Catalyst Center

## Quick Start

### 1. Clone and Setup

```bash
# Navigate to inventory use case
cd examples/use-cases/inventory

# Copy example configuration
cp terraform.tfvars.example terraform.tfvars
```

### 2. Configure Variables

Edit `terraform.tfvars` with your environment:

```hcl
# Update site hierarchy
site_name_hierarchy = "Global/USA/YourSite/YourBuilding"

# Configure device onboarding
device_onboarding = {
  enabled = true
  devices = [
    {
      description   = "Your Device Description"
      hostname      = "YOUR-DEVICE-01"
      mac_address   = "00:1A:2B:3C:4D:5E"  # Your device MAC
      pid           = "C9300-24T"           # Your device model
      serial_number = "FDO12345678"         # Your device serial
    }
  ]
}

# Configure other workflows as needed...
```

### 3. Initialize and Plan

```bash
# Initialize Terraform
terraform init

# Plan the configuration
terraform plan

# Review the planned changes
terraform show plan.out
```

### 4. Execute Workflows

```bash
# Apply the configuration
terraform apply

# Monitor progress in Catalyst Center UI:
# - Device Onboarding: Tools > Plug and Play
# - Provisioning: Provision > Device Provision  
# - Operations: Monitor > Activities
# - Maintenance: Operations > Schedules
```

### 5. Clean Up (Un-provision)

```bash
# Enable device deletion in terraform.tfvars if needed
# device_deletion.enabled = true

# Remove devices (CAUTION: This will delete devices!)
terraform destroy
```

## Workflow Details

### 1. Device Onboarding Workflow

**Purpose**: Add new devices to Catalyst Center inventory

**Resources Used**:
- `catalystcenter_pnp_device.device_onboarding`

**Process**:
1. Add device details to PnP database
2. Configure device metadata (hostname, serial, PID)
3. Assign to target site
4. Prepare for discovery

**Configuration**:
```hcl
device_onboarding = {
  enabled = true
  devices = [
    {
      description   = "Access Switch 01"
      hostname      = "SW-ACCESS-01"
      mac_address   = "00:1A:2B:3C:4D:5E"
      pid           = "C9300-24T"
      serial_number = "FDO12345678"
    }
  ]
}
```

### 2. Site Assignment & Provisioning Workflow

**Purpose**: Assign devices to sites and provision configurations

**Resources Used**:
- `catalystcenter_sda_provision_devices.site_assignment_provision`

**Process**:
1. Get device by management IP
2. Get site by hierarchy name
3. Assign device to site
4. Execute provisioning
5. Apply site-specific configurations

**Configuration**:
```hcl
site_assignment_provision = {
  enabled = true
  device_ips = ["204.1.2.10", "204.1.2.11"]
}
```

### 3. Device Operations Workflow

**Purpose**: Perform operational tasks on managed devices

**Resources Used**:
- `catalystcenter_network_device_sync.device_resync`
- `catalystcenter_device_reboot_apreboot.ap_reboot`

**Process**:
- **Resync**: Synchronize device state with Catalyst Center
- **Reboot**: Restart Access Point devices

**Configuration**:
```hcl
device_operations = {
  resync_enabled = true
  reboot_enabled = false  # Set true for AP reboots
  force_sync     = false  # High-priority sync if true
  device_ids     = ["device-uuid-1", "device-uuid-2"]
  ap_mac_addresses = ["00:2A:3B:4C:5D:6E"]
}
```

### 4. Device Deletion Workflow

**Purpose**: Remove devices from inventory

**Resources Used**:
- `catalystcenter_network_devices_delete_with_cleanup` (clean removal)
- `catalystcenter_network_devices_delete_without_cleanup` (quick removal)

**Process**:
- **With Cleanup**: Removes device configuration then deletes from inventory
- **Without Cleanup**: Removes from inventory without config cleanup

**Configuration**:
```hcl
device_deletion = {
  enabled      = false  # Enable with caution
  clean_config = true   # true = with cleanup, false = without
  device_ids   = ["device-uuid-to-delete"]
}
```

### 5. Maintenance Scheduling Workflow

**Purpose**: Schedule maintenance windows for devices

**Resources Used**:
- `catalystcenter_network_device_maintenance_schedules.maintenance_schedule`

**Features**:
- One-time or recurring schedules
- Multiple devices per schedule
- Automatic device state management

**Configuration**:
```hcl
maintenance_scheduling = {
  enabled = true
  schedules = [
    {
      description          = "Monthly maintenance"
      device_ids          = ["device-uuid-1"]
      start_time          = 1735689000000  # Unix epoch milliseconds
      end_time            = 1735692600000
      recurrence_interval = 30             # Optional: days between
      recurrence_end_time = 1767225000000  # Optional: end recurring
    }
  ]
}
```

## Testing and Validation

### Running Tests

```bash
# Run validation script
./test.sh

# Manual validation
terraform init
terraform plan
terraform validate
```

### Monitoring Operations

1. **Catalyst Center UI**:
   - Device Onboarding: Tools > Plug and Play
   - Provisioning: Provision > Device Provision
   - Operations: Monitor > Activities
   - Maintenance: Operations > Device Administration > Schedules

2. **Terraform Outputs**:
   ```bash
   terraform output
   terraform output inventory_workflow_summary
   ```

3. **Logs and Debugging**:
   ```bash
   # Enable debug mode
   export TF_LOG=DEBUG
   terraform apply
   ```

## Time Conversion for Maintenance

Maintenance scheduling uses Unix epoch time in milliseconds:

```bash
# Convert human time to Unix epoch milliseconds
date -d "2025-01-01 00:30:00 UTC" +%s000

# Examples:
# 2025-01-01 00:30:00 UTC = 1735689000000
# 2025-01-01 01:30:00 UTC = 1735692600000
# 2026-01-01 00:30:00 UTC = 1767225000000
```

## Best Practices

### Development

1. **Start Small**: Begin with device onboarding or simple operations
2. **Test Incrementally**: Enable one workflow at a time
3. **Use Debug Mode**: Keep debugging enabled during development
4. **Validate Early**: Run test script before applying

### Production

1. **Backup Configurations**: Save device configs before major operations
2. **Staged Rollout**: Process devices in phases
3. **Monitor Progress**: Watch Catalyst Center UI during operations
4. **Have Rollback Plan**: Know how to reverse operations if needed

### Security

1. **Credential Management**: Use secure credential storage
2. **Network Isolation**: Ensure secure network connectivity
3. **Access Control**: Limit who can execute inventory operations
4. **Audit Trail**: Monitor and log all inventory activities

## Troubleshooting

### Common Issues

1. **Device Not Found**:
   - Verify device is discovered in Catalyst Center
   - Check device IP/UUID is correct
   - Ensure device is reachable

2. **Site Assignment Fails**:
   - Verify site hierarchy exists
   - Check site name hierarchy path
   - Ensure user has site permissions

3. **Provisioning Timeout**:
   - Increase timeout settings
   - Check device connectivity
   - Verify site templates are configured

4. **Maintenance Scheduling Issues**:
   - Verify time format (Unix epoch milliseconds)
   - Check device IDs are valid
   - Ensure no conflicting schedules

### Debug Steps

1. **Enable Debug Logging**:
   ```bash
   export TF_LOG=DEBUG
   export TF_LOG_PATH=terraform.log
   ```

2. **Check Catalyst Center Tasks**:
   - Monitor > Activities
   - Look for failed tasks
   - Check task details

3. **Validate Configuration**:
   ```bash
   terraform validate
   terraform plan -detailed-exitcode
   ```

4. **Check Resource State**:
   ```bash
   terraform state list
   terraform state show <resource>
   ```

## Advanced Configuration

### Custom Timeouts

```hcl
timeout_settings = {
  onboarding_timeout = 300   # Adjust for device complexity
  provision_timeout  = 600   # Increase for large sites
  operation_timeout  = 180   # Adjust for network latency
  deletion_timeout   = 240   # Increase for cleanup operations
}
```

### Multiple Site Support

```hcl
# For multiple sites, create separate configurations
# or use Terraform workspaces
terraform workspace new site-a
terraform workspace new site-b
```

### Error Handling

The configuration includes built-in error handling:
- Conditional resource creation
- Validation of required parameters
- Graceful degradation for optional features

## Support and Maintenance

### Regular Tasks

1. **Monitor Device Health**: Check device status regularly
2. **Update Configurations**: Keep site templates current  
3. **Review Schedules**: Maintain appropriate maintenance windows
4. **Audit Operations**: Review inventory changes

### Version Compatibility

- Tested with Catalyst Center 2.3.7.6+
- Compatible with Terraform 0.14+
- Works with cisco-en-programmability/catalystcenter provider

## Related Documentation

- [Catalyst Center API Documentation](https://developer.cisco.com/docs/dna-center/)
- [Terraform Provider Documentation](https://registry.terraform.io/providers/cisco-en-programmability/catalystcenter)
- [SDA Provisioning Guide](../provision/README.md)
- [Site Hierarchy Management](../site-hierarchy/README.md)

## Contributing

When contributing to this use case:

1. Follow existing code style and patterns
2. Update documentation for new features
3. Add appropriate validation and error handling
4. Test with different device types and scenarios
5. Update the test script for new workflows