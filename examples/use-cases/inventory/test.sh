#!/bin/bash

# Inventory Workflow Test Script
# This script validates the Terraform configurations for inventory management workflows

set -e  # Exit on any error

echo "=== Inventory Workflow Terraform Configuration Test ==="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    if [ "$1" = "SUCCESS" ]; then
        echo -e "${GREEN}✓ $2${NC}"
    elif [ "$1" = "WARNING" ]; then
        echo -e "${YELLOW}⚠ $2${NC}"
    elif [ "$1" = "ERROR" ]; then
        echo -e "${RED}✗ $2${NC}"
    elif [ "$1" = "INFO" ]; then
        echo -e "${BLUE}ℹ $2${NC}"
    else
        echo "  $2"
    fi
}

# Test 1: Check File Structure
print_status "INFO" "Checking inventory workflow file structure..."

required_files=("main.tf" "variables.tf" "outputs.tf" "terraform.tfvars.example" "README.md")
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        print_status "SUCCESS" "Found required file: $file"
    else
        print_status "ERROR" "Missing required file: $file"
    fi
done

# Test 2: Configuration Validation
print_status "INFO" "Validating Terraform configuration syntax..."

# Function to validate terraform configuration
validate_terraform() {
    if command -v terraform >/dev/null 2>&1; then
        local temp_dir=$(mktemp -d)
        cp *.tf "$temp_dir/"
        cd "$temp_dir"
        
        if terraform fmt -check=true -diff=true >/dev/null 2>&1; then
            print_status "SUCCESS" "Terraform formatting is correct"
        else
            print_status "WARNING" "Terraform formatting could be improved"
        fi
        
        if terraform validate >/dev/null 2>&1; then
            print_status "SUCCESS" "Terraform configuration is valid"
        else
            print_status "ERROR" "Terraform configuration validation failed"
        fi
        
        cd - >/dev/null
        rm -rf "$temp_dir"
    else
        print_status "WARNING" "Terraform not found, skipping validation"
    fi
}

validate_terraform

# Test 3: Check README Content
print_status "INFO" "Validating README documentation..."

if [ -f "README.md" ]; then
    if grep -q "Inventory Workflow" "README.md"; then
        print_status "SUCCESS" "README contains inventory workflow documentation"
    else
        print_status "WARNING" "README title may need updating"
    fi
    
    if grep -q "Prerequisites" "README.md"; then
        print_status "SUCCESS" "README contains prerequisites section"
    else
        print_status "WARNING" "README missing prerequisites section"
    fi
    
    if grep -q "Device Onboarding" "README.md"; then
        print_status "SUCCESS" "README documents device onboarding workflow"
    else
        print_status "WARNING" "README missing device onboarding documentation"
    fi
    
    if grep -q "Site Assignment" "README.md"; then
        print_status "SUCCESS" "README documents site assignment workflow"
    else
        print_status "WARNING" "README missing site assignment documentation"
    fi
    
    if grep -q "Device Operations" "README.md"; then
        print_status "SUCCESS" "README documents device operations workflow"
    else
        print_status "WARNING" "README missing device operations documentation"
    fi
    
    if grep -q "Maintenance Scheduling" "README.md"; then
        print_status "SUCCESS" "README documents maintenance scheduling workflow"
    else
        print_status "WARNING" "README missing maintenance scheduling documentation"
    fi
else
    print_status "WARNING" "README.md not found - will be created"
fi

# Test 4: Workflow Validation Against Requirements
echo ""
print_status "INFO" "Validating workflows against Ansible workflow requirements..."

workflows=("Device Onboarding" "Site Assignment" "Device Operations" "Device Deletion" "Maintenance Scheduling")
resources=("pnp_device" "sda_provision_devices" "network_device_sync" "delete_with_cleanup" "maintenance_schedules")

for i in "${!workflows[@]}"; do
    workflow="${workflows[$i]}"
    resource="${resources[$i]}"
    
    if grep -q "$resource" "main.tf" 2>/dev/null; then
        print_status "SUCCESS" "Found required workflow: $workflow"
    else
        print_status "ERROR" "Required workflow missing: $workflow"
    fi
done

# Test 5: Variable Configuration Check
print_status "INFO" "Checking variable configurations..."

if grep -q "device_onboarding" "variables.tf"; then
    print_status "SUCCESS" "Device onboarding variables configured"
else
    print_status "ERROR" "Device onboarding variables missing"
fi

if grep -q "site_assignment_provision" "variables.tf"; then
    print_status "SUCCESS" "Site assignment/provisioning variables configured"
else
    print_status "ERROR" "Site assignment/provisioning variables missing"
fi

if grep -q "device_operations" "variables.tf"; then
    print_status "SUCCESS" "Device operations variables configured"
else
    print_status "ERROR" "Device operations variables missing"
fi

if grep -q "device_deletion" "variables.tf"; then
    print_status "SUCCESS" "Device deletion variables configured"
else
    print_status "ERROR" "Device deletion variables missing"
fi

if grep -q "maintenance_scheduling" "variables.tf"; then
    print_status "SUCCESS" "Maintenance scheduling variables configured"
else
    print_status "ERROR" "Maintenance scheduling variables missing"
fi

# Test 6: Example Configuration Check
print_status "INFO" "Checking example configuration file..."

if [ -f "terraform.tfvars.example" ]; then
    if grep -q "site_name_hierarchy" "terraform.tfvars.example"; then
        print_status "SUCCESS" "Example contains site hierarchy configuration"
    else
        print_status "WARNING" "Example missing site hierarchy"
    fi
    
    if grep -q "device_onboarding" "terraform.tfvars.example"; then
        print_status "SUCCESS" "Example contains device onboarding configuration"
    else
        print_status "WARNING" "Example missing device onboarding configuration"
    fi
    
    if grep -q "INSTRUCTIONS FOR CUSTOMIZATION" "terraform.tfvars.example"; then
        print_status "SUCCESS" "Example contains customization instructions"
    else
        print_status "WARNING" "Example missing customization instructions"
    fi
else
    print_status "ERROR" "terraform.tfvars.example file missing"
fi

# Test 7: Output Configuration Check
print_status "INFO" "Checking output configurations..."

if [ -f "outputs.tf" ]; then
    expected_outputs=("device_onboarding_results" "site_assignment_provision_results" "device_operations_results" "device_deletion_results" "maintenance_scheduling_results" "inventory_workflow_summary")
    
    for output in "${expected_outputs[@]}"; do
        if grep -q "$output" "outputs.tf"; then
            print_status "SUCCESS" "Found output: $output"
        else
            print_status "WARNING" "Missing output: $output"
        fi
    done
else
    print_status "ERROR" "outputs.tf file missing"
fi

# Test 8: Resource Count Validation
print_status "INFO" "Checking resource implementations..."

if [ -f "main.tf" ]; then
    # Count different types of resources
    pnp_count=$(grep -c "resource \"catalystcenter_pnp_device\"" main.tf 2>/dev/null || echo "0")
    provision_count=$(grep -c "resource \"catalystcenter_sda_provision_devices\"" main.tf 2>/dev/null || echo "0")
    sync_count=$(grep -c "resource \"catalystcenter_network_device_sync\"" main.tf 2>/dev/null || echo "0")
    reboot_count=$(grep -c "resource \"catalystcenter_device_reboot_apreboot\"" main.tf 2>/dev/null || echo "0")
    delete_cleanup_count=$(grep -c "resource \"catalystcenter_network_devices_delete_with_cleanup\"" main.tf 2>/dev/null || echo "0")
    delete_no_cleanup_count=$(grep -c "resource \"catalystcenter_network_devices_delete_without_cleanup\"" main.tf 2>/dev/null || echo "0")
    maintenance_count=$(grep -c "resource \"catalystcenter_network_device_maintenance_schedules\"" main.tf 2>/dev/null || echo "0")
    
    total_resources=$((pnp_count + provision_count + sync_count + reboot_count + delete_cleanup_count + delete_no_cleanup_count + maintenance_count))
    
    if [ "$total_resources" -ge 7 ]; then
        print_status "SUCCESS" "All inventory workflows implemented ($total_resources resources)"
    else
        print_status "WARNING" "Expected at least 7 inventory resources, found: $total_resources"
    fi
    
    # Detailed resource check
    [ "$pnp_count" -gt 0 ] && print_status "SUCCESS" "Device onboarding resource implemented"
    [ "$provision_count" -gt 0 ] && print_status "SUCCESS" "Site assignment/provision resource implemented"
    [ "$sync_count" -gt 0 ] && print_status "SUCCESS" "Device sync resource implemented"
    [ "$reboot_count" -gt 0 ] && print_status "SUCCESS" "Device reboot resource implemented"
    [ "$delete_cleanup_count" -gt 0 ] && print_status "SUCCESS" "Device deletion (cleanup) resource implemented"
    [ "$delete_no_cleanup_count" -gt 0 ] && print_status "SUCCESS" "Device deletion (no cleanup) resource implemented"
    [ "$maintenance_count" -gt 0 ] && print_status "SUCCESS" "Maintenance scheduling resource implemented"
fi

# Test 9: Data Source Check
print_status "INFO" "Checking data source configurations..."

if grep -q "data \"catalystcenter_sites\"" "main.tf"; then
    print_status "SUCCESS" "Sites data source configured"
else
    print_status "WARNING" "Sites data source missing"
fi

if grep -q "data \"catalystcenter_network_device_by_ip\"" "main.tf"; then
    print_status "SUCCESS" "Network device by IP data source configured"
else
    print_status "WARNING" "Network device by IP data source missing"
fi

# Check files created
echo ""
print_status "INFO" "Files created:"
ls -la *.tf *.md *.example 2>/dev/null || print_status "WARNING" "Some expected files may be missing"
echo

echo ""
print_status "SUCCESS" "Inventory workflow configuration test completed!"
echo ""
echo "Next steps:"
echo "1. Copy terraform.tfvars.example to terraform.tfvars"
echo "2. Update device details, IPs, and site hierarchy for your environment"
echo "3. Ensure devices are properly discovered/configured in Catalyst Center"
echo "4. Run 'terraform init && terraform plan' to validate"
echo "5. Run 'terraform apply' to execute inventory workflows"
echo "6. Verify results in Catalyst Center UI:"
echo "   - Device Onboarding: Tools > Plug and Play"
echo "   - Provisioning: Provision > Device Provision"
echo "   - Operations: Monitor > Activities"
echo "   - Maintenance: Operations > Device Administration > Schedules"
echo ""
print_status "WARNING" "CAUTION: Device deletion operations will permanently remove devices from inventory!"
echo ""