# Consolidated PnP (Plug and Play) Test Suite

This directory contains a comprehensive, consolidated Terraform implementation for testing all PnP (Plug and Play) functionality provided by the terraform-provider-catalystcenter. All 8 test scenarios are combined into a single, configurable implementation.

## Overview

This consolidated test suite covers all PnP workflows in a single Terraform configuration:

1. **Single Device Onboarding** - Add individual devices to PnP
2. **Bulk Device Onboarding** - Import multiple devices simultaneously
3. **Router Claiming** - Claim and provision router devices
4. **Switch Claiming** - Claim and provision switches (including stacks)
5. **Wireless Controller Claiming** - Claim and provision Catalyst 9800 WLCs
6. **Access Point Claiming** - Claim and provision access points
7. **Device Reset** - Reset devices in error states
8. **Global Settings** - Configure PnP global settings

## Key Features

### Unified Configuration
- Single `main.tf` file containing all 8 test scenarios
- Enable/disable individual tests via configuration flags
- Shared resources and data sources
- Consistent naming and structure

### Flexible Testing
- Run all tests or select specific scenarios
- Mix and match test combinations
- Progressive testing approach
- Independent test execution

### Comprehensive Coverage
- All device types supported (routers, switches, APs, WLCs)
- Stack switch configurations
- Smart Account integration
- Virtual Account synchronization
- Custom workflow creation
- Error recovery and reset operations

## Directory Structure

```
pnp/
├── README.md                    # This file
├── main.tf                      # Consolidated implementation of all 8 tests
├── variables.tf                 # Variable definitions for all scenarios
├── variables-common.tf          # Common Catalyst Center variables
├── outputs.tf                   # Comprehensive outputs for all tests
├── terraform.tfvars.example     # Example configuration for all tests
├── terraform-common.tfvars      # Common terraform variables
└── test.sh                      # Test execution script
```

## Configuration

### Step 1: Set Up Common Variables

Copy and configure the common variables:

```bash
# Edit terraform-common.tfvars with your Catalyst Center details
catalyst_username   = "admin"
catalyst_password   = "YourPassword"
catalyst_base_url   = "https://10.0.0.50"
catalyst_debug      = false
catalyst_ssl_verify = false
```

### Step 2: Configure Test Scenarios

Copy the example file and enable desired tests:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` to enable specific test scenarios:

```hcl
# Enable Test 1: Single Device Onboarding
device_onboarding = {
  enabled = true  # Set to true to run this test
  device = {
    serial_number = "FJC2721271T"
    hostname      = "test-switch-01"
    pid           = "C9300-48T"
    mac_address   = "00:1B:44:11:3A:B7"
  }
  day_zero_config = ""
}

# Enable Test 3: Router Claiming
router_claiming = {
  enabled = true  # Set to true to run this test
  site_name_hierarchy = "Global/USA/San Francisco/Building1"
  device = {
    serial_number = "FGL222290LB"
    hostname      = "test-router-01"
    pid           = "ASR1001-X"
    mac_address   = "00:C8:8B:80:BB:00"
    sudi_required = true
  }
  # ... additional configuration
}
```

## Usage

### Initialize Terraform

```bash
terraform init
```

### Run Specific Test Scenarios

Enable only the tests you want in `terraform.tfvars`, then:

```bash
# Preview changes
terraform plan

# Apply configuration
terraform apply
```

### Run All Tests

Enable all test scenarios in `terraform.tfvars`:

```bash
# Run with all tests enabled
terraform apply -auto-approve
```

### Run Tests Progressively

```bash
# Test 1: Basic onboarding
terraform apply -target=catalystcenter_pnp_device.single_device_onboarding

# Test 2: Bulk import
terraform apply -target=catalystcenter_pnp_device_import.bulk_device_import

# Test 3-6: Device claiming
terraform apply -target=catalystcenter_pnp_device_site_claim.router_claim
terraform apply -target=catalystcenter_pnp_device_site_claim.switch_claim
terraform apply -target=catalystcenter_pnp_device_site_claim.wlc_claim
terraform apply -target=catalystcenter_pnp_device_site_claim.ap_claim

# Test 7: Reset operations
terraform apply -target=catalystcenter_pnp_device_reset.device_reset

# Test 8: Global settings
terraform apply -target=catalystcenter_pnp_global_settings.global_settings
```

## Test Scenarios Detail

### Test 1: Single Device Onboarding
- **Purpose**: Basic PnP functionality test
- **Operations**: Add single device to PnP database
- **Device Types**: Any network device
- **Key Variables**: `device_onboarding`

### Test 2: Bulk Device Onboarding
- **Purpose**: Test bulk import capabilities
- **Operations**: Import multiple devices, including stacks
- **Device Types**: Mixed (switches, routers, stacks)
- **Key Variables**: `bulk_onboarding`

### Test 3: Router Claiming
- **Purpose**: Test router provisioning workflow
- **Operations**: Onboard → Claim → Configure
- **Device Types**: ASR routers
- **Key Variables**: `router_claiming`

### Test 4: Switch Claiming
- **Purpose**: Test switch provisioning including stacks
- **Operations**: Onboard → Claim → Configure → Static IP
- **Device Types**: Catalyst switches, stack switches
- **Key Variables**: `switch_claiming`

### Test 5: Wireless Controller Claiming
- **Purpose**: Test WLC provisioning
- **Operations**: Onboard → Claim → HA Configuration
- **Device Types**: Catalyst 9800 WLCs
- **Key Variables**: `wlc_claiming`

### Test 6: Access Point Claiming
- **Purpose**: Test AP provisioning
- **Operations**: Onboard → Claim → RF Profile Assignment
- **Device Types**: Catalyst APs
- **Key Variables**: `ap_claiming`

### Test 7: Device Reset
- **Purpose**: Test error recovery operations
- **Operations**: Reset → Unclaim → Reconfigure
- **Device Types**: Any device in error state
- **Key Variables**: `device_reset`

### Test 8: Global Settings
- **Purpose**: Test organizational PnP settings
- **Operations**: AAA → Smart Account → Sync
- **Configuration**: Global PnP parameters
- **Key Variables**: `global_settings`

## Outputs

The configuration provides comprehensive outputs for monitoring test results:

```bash
# View test summary
terraform output test_suite_summary

# View specific test results
terraform output single_device
terraform output bulk_devices
terraform output router_claiming
# ... etc

# View validation status
terraform output test_validation_status

# View all PnP devices
terraform output all_pnp_devices
```

## Example Configurations

### Example 1: Development Environment Testing

Enable lightweight tests for development:

```hcl
# terraform.tfvars
device_onboarding = {
  enabled = true
  # ... minimal config
}

global_settings = {
  enabled = true
  # ... basic settings
}

# All other tests disabled
```

### Example 2: Full Integration Testing

Enable all tests for comprehensive validation:

```hcl
# terraform.tfvars
device_onboarding = { enabled = true ... }
bulk_onboarding = { enabled = true ... }
router_claiming = { enabled = true ... }
switch_claiming = { enabled = true ... }
wlc_claiming = { enabled = true ... }
ap_claiming = { enabled = true ... }
device_reset = { enabled = true ... }
global_settings = { enabled = true ... }
```

### Example 3: Device Type Specific Testing

Test only specific device types:

```hcl
# Test only wireless devices
wlc_claiming = { enabled = true ... }
ap_claiming = { enabled = true ... }

# Test only switches
switch_claiming = { enabled = true ... }
```

## Troubleshooting

### Common Issues

1. **Device Not Found**
   ```bash
   # Check if device is in PnP database
   terraform output all_pnp_devices
   ```

2. **Site Claim Fails**
   ```bash
   # Verify site exists
   terraform state show data.catalystcenter_sites.router_site
   ```

3. **Global Settings Conflict**
   ```bash
   # Check current settings
   terraform output current_global_settings
   ```

### Debug Mode

Enable debug output:

```hcl
# terraform-common.tfvars
catalyst_debug = true
```

### Validation Commands

```bash
# Validate configuration
terraform validate

# Check planned changes
terraform plan -detailed-exitcode

# Show specific resource state
terraform state show catalystcenter_pnp_device.single_device_onboarding[0]
```

## Best Practices

1. **Progressive Testing**
   - Start with Test 8 (Global Settings)
   - Then Test 1 (Single Device)
   - Progress to bulk operations
   - Finally test claiming workflows

2. **Isolation Testing**
   - Test one scenario at a time initially
   - Combine scenarios after individual validation
   - Use targeted applies for debugging

3. **Resource Dependencies**
   - Global settings should be configured first
   - Devices must be onboarded before claiming
   - Sites must exist before claiming devices

4. **Cleanup**
   - Use Test 7 (Device Reset) for cleanup
   - Destroy resources in reverse order
   - Verify cleanup with data sources

## CI/CD Integration

### GitHub Actions Example

```yaml
name: PnP Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: hashicorp/setup-terraform@v2
      
      - name: Terraform Init
        run: terraform init
        
      - name: Run Test Suite
        run: |
          terraform plan
          terraform apply -auto-approve
        env:
          TF_VAR_catalyst_username: ${{ secrets.CATALYST_USERNAME }}
          TF_VAR_catalyst_password: ${{ secrets.CATALYST_PASSWORD }}
```

### Test Script

Use the included test script for automated testing:

```bash
./test.sh --all           # Run all tests
./test.sh --scenario 1    # Run specific test
./test.sh --validate      # Validation only
```

## Cleanup

To remove all PnP resources:

```bash
# Destroy all resources
terraform destroy

# Or destroy specific tests
terraform destroy -target=catalystcenter_pnp_device.single_device_onboarding
```

## Migration from Separate Tests

If migrating from the previous structure with 8 separate directories:

1. **Backup existing state**
   ```bash
   terraform state pull > backup.tfstate
   ```

2. **Update configuration**
   - Copy device information to consolidated `terraform.tfvars`
   - Enable appropriate test scenarios
   - Map old resources to new naming

3. **Import existing resources** (if needed)
   ```bash
   terraform import catalystcenter_pnp_device.single_device_onboarding[0] <device-id>
   ```

## Additional Resources

- [Cisco Catalyst Center PnP Documentation](https://www.cisco.com/c/en/us/support/cloud-systems-management/dna-center/products-user-guide-list.html)
- [Terraform Provider Documentation](https://registry.terraform.io/providers/cisco-en-programmability/catalystcenter/latest/docs)
- [PnP Best Practices Guide](https://www.cisco.com/c/en/us/td/docs/solutions/CVD/Campus/dnac-pnp-wired-cvd.html)

## Support

For issues or questions:
1. Check the [Troubleshooting](#troubleshooting) section
2. Review Catalyst Center logs
3. Open an issue in the terraform-provider-catalystcenter repository

## License

This example is provided as-is under the same license as the terraform-provider-catalystcenter project.