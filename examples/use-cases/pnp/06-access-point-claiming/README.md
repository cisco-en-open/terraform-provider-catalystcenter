# Access Point Claiming Test

This test demonstrates how to claim and provision Access Points (APs) through PnP. Access Points require special handling and must be claimed after the Wireless LAN Controller (WLC) is fully operational.

## Overview

This test corresponds to the `claim_access_points` task from the Ansible workflow. It claims an Access Point and assigns it to a specific site with RF profile configuration.

## Test Device

The default test device is:
- **Serial Number**: FGL2402LCYH
- **Hostname**: NY-AP1-C9120AXE
- **Product ID**: C9120AXE-E (Catalyst 9120 Access Point)
- **Site**: Global/USA/New York/NY_BLD2/FLOOR1
- **RF Profile**: HIGH
- **PnP Type**: AccessPoint

## Prerequisites

⚠️ **IMPORTANT**: Ensure that the Wireless LAN Controller (WLC) is fully onboarded and operational before claiming Access Points. Otherwise, the claiming process may fail.

## Usage

1. Ensure WLC is operational (run wireless controller claiming test first)
2. Update the common variables in `../terraform-common.tfvars`
3. Run the test:
   ```bash
   cd 06-access-point-claiming
   terraform init
   terraform plan -var-file=../terraform-common.tfvars
   terraform apply -var-file=../terraform-common.tfvars
   ```

## Expected Result

- Access Point is claimed and assigned to the specified site
- RF profile is applied to the Access Point
- AP becomes operational and joins the wireless network
- AP appears in the site hierarchy under the specified floor

## Validation

Check Catalyst Center UI:
1. Navigate to **Device > Plug and Play**
2. Verify the AP status changes from "Unclaimed" to "Claimed" or "Provisioned"
3. Navigate to **Provision > Inventory**
4. Confirm the AP appears in the inventory
5. Navigate to **Assurance > Wireless > Access Points**
6. Verify the AP is operational with the correct RF profile

## Site Assignment Mapping

This test demonstrates the UI workflow:
- **Step 1**: Assign site to the device
- **Step 2**: Configure RF profile settings
- **Step 3**: Provision and validate

## Cleanup

```bash
terraform destroy -var-file=../terraform-common.tfvars
```

## Troubleshooting

If AP claiming fails:
1. Verify WLC is operational and reachable
2. Check network connectivity between AP and WLC
3. Ensure the site hierarchy exists
4. Verify RF profile is valid and available
5. Check AP power and ethernet connectivity

## Notes

- APs typically don't require separate image provisioning
- RF profiles control wireless coverage and performance
- Site assignment determines where the AP appears in the network hierarchy