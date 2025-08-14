#!/bin/bash

# Validation script to check if all sites from the provision workflow are covered

echo "=== Provision Workflow Validation ==="
echo

echo "Expected from provision_workflow_inputs.yml:"
echo "Site: Global/USA/SAN JOSE/SJ_BLD23"
echo "Wired devices: 204.1.2.5, 204.1.2.6, 204.1.2.7"  
echo "Wireless device: 204.192.4.200"
echo "Telemetry devices: 204.1.2.1, 204.1.2.3"
echo

echo "Checking Terraform files..."

# Count resources in main.tf
SDA_PROVISIONS=$(grep -c "resource \"catalystcenter_sda_provision_devices\"" main.tf)
WIRELESS_PROVISIONS=$(grep -c "resource \"catalystcenter_wireless_provision_device_create\"" main.tf)
PROVISIONING_SETTINGS=$(grep -c "resource \"catalystcenter_provisioning_settings\"" main.tf)

echo "Resources found in main.tf:"
echo "- SDA Provision Resources: $SDA_PROVISIONS"
echo "- Wireless Provision Resources: $WIRELESS_PROVISIONS"
echo "- Provisioning Settings: $PROVISIONING_SETTINGS"
echo

# Check specific device IPs
echo "Device IP validation:"
for ip in "204.1.2.5" "204.1.2.6" "204.1.2.7" "204.192.4.200" "204.1.2.1" "204.1.2.3"; do
    if grep -q "$ip" variables.tf terraform.tfvars.example; then
        echo "✓ Device IP: $ip"
    else
        echo "✗ Missing device IP: $ip"
    fi
done

echo
echo "Site validation:"
if grep -q "Global/USA/SAN JOSE/SJ_BLD23" variables.tf terraform.tfvars.example; then
    echo "✓ Site: Global/USA/SAN JOSE/SJ_BLD23"
else
    echo "✗ Missing site: Global/USA/SAN JOSE/SJ_BLD23"
fi

echo
echo "Workflow validation:"
workflows=("site_assignment" "wired_provision" "device_reprovision" "wireless_provision")
for workflow in "${workflows[@]}"; do
    if grep -q "$workflow" main.tf; then
        echo "✓ Workflow: $workflow"
    else
        echo "✗ Missing workflow: $workflow"
    fi
done

echo
echo "Files created:"
ls -la *.tf *.md *.example *.sh 2>/dev/null

echo
echo "Validation complete!"