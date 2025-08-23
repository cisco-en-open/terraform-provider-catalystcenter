# Bulk Device Onboarding Test

This test demonstrates how to add multiple devices to Plug and Play (PnP) simultaneously. This bulk approach is efficient for large-scale deployments where multiple devices need to be onboarded at once.

## Overview

This test corresponds to the `add_bulk_network_devices` task from the Ansible workflow. It adds multiple devices of different types to the PnP database with "Unclaimed" status.

## Test Devices

The default test includes three devices representing different device types:

1. **Router Device**:
   - Serial Number: FXS2502Q2HC
   - Hostname: SF-BN-2-ASR.cisco.local
   - Product ID: ASR1001-X

2. **Switch Device**:
   - Serial Number: FJC271923AK
   - Hostname: NY-EN-9300
   - Product ID: C9300-48UXM

3. **Wireless Controller Device**:
   - Serial Number: FOX2639PAYD
   - Hostname: SJ-EWLC-1.cisco.local
   - Product ID: C9800-40-K9

## Usage

1. Update the common variables in `../terraform-common.tfvars`
2. Run the test:
   ```bash
   cd 02-bulk-device-onboarding
   terraform init
   terraform plan -var-file=../terraform-common.tfvars
   terraform apply -var-file=../terraform-common.tfvars
   ```

## Expected Result

- All three devices are added to PnP with "Unclaimed" status
- Devices appear in Catalyst Center UI under Device > Plug and Play
- Each device type is correctly identified
- All devices are ready for claiming and provisioning

## Validation

Check Catalyst Center UI:
1. Navigate to **Device > Plug and Play**
2. Verify all three devices appear in the device list
3. Confirm all devices have "Unclaimed" status
4. Note the different device types (Router, Switch, Wireless Controller)

## Cleanup

```bash
terraform destroy -var-file=../terraform-common.tfvars
```

## Notes

- This test demonstrates handling multiple device types in a single operation
- Each device can later be claimed independently with type-specific configurations
- Bulk operations are more efficient than individual device additions for large deployments