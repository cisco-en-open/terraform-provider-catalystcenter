# PnP (Plug and Play) Test Suite

This directory contains comprehensive Terraform tests for PnP (Plug and Play) functionality provided by the terraform-provider-catalystcenter. These tests are based on the workflows outlined in the [DNACENSolutions/dnac_ansible_workflows](https://github.com/DNACENSolutions/dnac_ansible_workflows/tree/main/workflows/plug_and_play) repository.

## Overview

The PnP test suite covers the following scenarios:

1. **Device Onboarding** - Adding devices to PnP without claiming them
2. **Bulk Device Onboarding** - Adding multiple devices simultaneously 
3. **Router Device Claiming** - Claiming and provisioning router devices
4. **Switch Device Claiming** - Claiming and provisioning switch devices  
5. **Wireless Controller Claiming** - Claiming and provisioning EWLC devices
6. **Access Point Claiming** - Claiming and provisioning access points
7. **Device Reset** - Resetting devices in error states
8. **Global Settings** - Managing PnP global configurations

## Test Structure

```
pnp/
├── README.md                          # This file
├── test.sh                           # Main test runner script
├── terraform-common.tfvars          # Common Terraform variables
├── variables-common.tf               # Common variable definitions
├── 01-device-onboarding/            # Basic device onboarding tests
├── 02-bulk-device-onboarding/       # Bulk device onboarding tests
├── 03-router-claiming/              # Router claiming and provisioning
├── 04-switch-claiming/              # Switch claiming and provisioning
├── 05-wireless-controller-claiming/ # EWLC claiming and provisioning
├── 06-access-point-claiming/        # AP claiming and provisioning
├── 07-device-reset/                 # Device reset and error handling
└── 08-global-settings/             # PnP global settings management
```

## Prerequisites

Before running these tests, ensure you have:

1. **Terraform** installed (version 1.0 or higher)
2. **Access to Cisco Catalyst Center** with PnP enabled
3. **Proper network connectivity** to Catalyst Center
4. **Test devices** that support PnP functionality
5. **Valid credentials** for Catalyst Center

## Configuration

1. Copy `terraform-common.tfvars.example` to `terraform-common.tfvars`
2. Update the variables with your Catalyst Center details:
   ```hcl
   catalyst_center_host     = "your-catalyst-center-ip"
   catalyst_center_username = "your-username"
   catalyst_center_password = "your-password"
   catalyst_center_debug    = "false"
   catalyst_center_ssl_verify = "false"
   ```

3. Update device-specific variables in each test directory

## Running Tests

### Run All Tests
```bash
./test.sh
```

### Run Specific Test Category
```bash
./test.sh --category device-onboarding
./test.sh --category bulk-device-onboarding  
./test.sh --category router-claiming
./test.sh --category switch-claiming
./test.sh --category wireless-controller-claiming
./test.sh --category access-point-claiming
./test.sh --category device-reset
./test.sh --category global-settings
```

### Run Individual Test
```bash
cd 01-device-onboarding
terraform init
terraform plan -var-file=../terraform-common.tfvars
terraform apply -var-file=../terraform-common.tfvars
```

## Device Types Supported

- **Routers**: ASR series (e.g., ASR1001-X)
- **Switches**: Catalyst 9300 series (e.g., C9300-48T, C9300-48UXM)
- **Wireless Controllers**: Catalyst 9800 series (e.g., C9800-40-K9)
- **Access Points**: Catalyst 9120 series (e.g., C9120AXE-E)

## Test Scenarios

Each test scenario includes:
- Terraform configuration files
- Variable definitions
- Sample data based on Ansible workflows
- Validation scripts
- Expected outcomes documentation

## Validation

The test suite includes comprehensive validation:
- Terraform syntax and formatting checks
- Configuration validation
- Resource creation verification
- State management validation
- Cleanup verification

## Troubleshooting

Common issues and solutions:
- **Authentication failures**: Verify credentials and network connectivity
- **Device not found**: Ensure devices are PnP-capable and connected
- **Template/image not found**: Verify template and image names in Catalyst Center
- **Site hierarchy issues**: Ensure site hierarchy exists before claiming devices

## References

- [Terraform Provider CatalystCenter Documentation](https://registry.terraform.io/providers/cisco-en-programmability/catalystcenter/latest/docs)
- [Cisco Catalyst Center API Documentation](https://developer.cisco.com/docs/dna-center/)
- [DNACENSolutions Ansible Workflows](https://github.com/DNACENSolutions/dnac_ansible_workflows)