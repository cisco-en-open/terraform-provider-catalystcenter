# Device Onboarding Test

This test demonstrates how to add a single device to Plug and Play (PnP) without claiming it. This is the basic onboarding step that prepares a device for later claiming and provisioning.

## Overview

This test corresponds to the `add_network_device` task from the Ansible workflow. It adds a device to the PnP database with "Unclaimed" status, making it available for claiming and provisioning workflows.

## Test Device

The default test device is:
- **Serial Number**: FJC27212582
- **Hostname**: DC-T-9300.cisco.local
- **Product ID**: C9300-48T (Catalyst 9300 48-port switch)
- **State**: Unclaimed

## Usage

1. Update the common variables in `../terraform-common.tfvars`
2. Run the test:
   ```bash
   cd 01-device-onboarding
   terraform init
   terraform plan -var-file=../terraform-common.tfvars
   terraform apply -var-file=../terraform-common.tfvars
   ```

## Expected Result

- Device is added to PnP with "Unclaimed" status
- Device appears in Catalyst Center UI under Device > Plug and Play
- Device is ready for claiming and provisioning

## Validation

Check Catalyst Center UI:
1. Navigate to **Device > Plug and Play**
2. Verify the device appears in the device list
3. Confirm the status is "Unclaimed"
4. Note the device details match the configuration

## Cleanup

```bash
terraform destroy -var-file=../terraform-common.tfvars
```