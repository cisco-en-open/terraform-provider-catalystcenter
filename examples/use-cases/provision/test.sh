#!/bin/bash

# Provision Workflow Test Script
# This script validates the Terraform configurations for device provision workflows

set -e  # Exit on any error

echo "=== Provision Workflow Terraform Configuration Test ==="
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

# Function to check Terraform files
check_terraform_files() {
    local config_name="$1"
    local main_file="$2"
    local variables_file="$3"
    
    echo ""
    print_status "INFO" "Checking $config_name configuration..."
    
    # Check if files exist
    if [ ! -f "$main_file" ]; then
        print_status "ERROR" "$main_file not found"
        return 1
    fi
    
    if [ ! -f "$variables_file" ]; then
        print_status "ERROR" "$variables_file not found"
        return 1
    fi
    
    print_status "SUCCESS" "Files exist: $main_file, $variables_file"
    
    # Check for basic terraform syntax (if terraform is available)
    if command -v terraform >/dev/null 2>&1; then
        # Create a temporary directory for validation
        temp_dir=$(mktemp -d)
        cp "$main_file" "$temp_dir/main.tf"
        cp "$variables_file" "$temp_dir/variables.tf"
        
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

# Function to check provision workflows
check_provision_workflows() {
    local config_file="$1"
    
    echo ""
    print_status "INFO" "Checking provision workflows in $config_file..."
    
    # Check for all required provision workflows
    if grep -q "catalystcenter_sda_provision_devices.*site_assignment" "$config_file"; then
        print_status "SUCCESS" "Found site assignment workflow configuration"
    else
        print_status "ERROR" "Site assignment workflow configuration not found"
    fi
    
    if grep -q "catalystcenter_sda_provision_devices.*wired_provision" "$config_file"; then
        print_status "SUCCESS" "Found wired device provision workflow"
    else
        print_status "ERROR" "Wired device provision workflow not found"
    fi
    
    if grep -q "catalystcenter_sda_provision_devices.*device_reprovision" "$config_file"; then
        print_status "SUCCESS" "Found device re-provision workflow"
    else
        print_status "ERROR" "Device re-provision workflow not found"
    fi
    
    if grep -q "catalystcenter_wireless_provision_device_create.*wireless_provision" "$config_file"; then
        print_status "SUCCESS" "Found wireless device provision workflow"
    else
        print_status "WARNING" "Wireless device provision workflow not found"
    fi
}

# Function to check resource configurations
check_resource_configurations() {
    local config_file="$1"
    
    echo ""
    print_status "INFO" "Checking resource configurations in $config_file..."
    
    # Check for provisioning settings
    if grep -q "catalystcenter_provisioning_settings" "$config_file"; then
        print_status "SUCCESS" "Found provisioning settings configuration"
    else
        print_status "ERROR" "Provisioning settings configuration not found"
    fi
    
    # Check for data sources
    if grep -q "data.*catalystcenter_sites" "$config_file"; then
        print_status "SUCCESS" "Found sites data source configuration"
    else
        print_status "ERROR" "Sites data source configuration not found"
    fi
    
    if grep -q "data.*catalystcenter_network_device_by_ip" "$config_file"; then
        print_status "SUCCESS" "Found network device data source configuration"
    else
        print_status "ERROR" "Network device data source configuration not found"
    fi
    
    # Check for lifecycle rules
    if grep -q "lifecycle" "$config_file"; then
        print_status "SUCCESS" "Found lifecycle management configuration"
    else
        print_status "WARNING" "Lifecycle management configuration not found"
    fi
    
    # Check for timeouts
    if grep -q "timeouts" "$config_file"; then
        print_status "SUCCESS" "Found timeout configurations"
    else
        print_status "WARNING" "Timeout configurations not found"
    fi
}

# Function to check variable definitions
check_variables() {
    local variables_file="$1"
    
    echo ""
    print_status "INFO" "Checking variable definitions..."
    
    # Check for required variable blocks
    variables=(
        "site_name_hierarchy" 
        "wired_device_provision" 
        "site_assignment_only" 
        "device_reprovision" 
        "wireless_device_provision"
        "application_telemetry"
        "enable_debug"
        "timeout_settings"
    )
    
    for var in "${variables[@]}"; do
        if grep -q "variable \"$var\"" "$variables_file"; then
            print_status "SUCCESS" "Found variable definition: $var"
        else
            print_status "ERROR" "Variable definition not found: $var"
        fi
    done
}

# Function to check device IP formats
check_device_configurations() {
    local variables_file="$1"
    
    echo ""
    print_status "INFO" "Checking device configurations..."
    
    # Check for different device IP formats in default values
    if grep -q "204.1.2.5" "$variables_file"; then
        print_status "SUCCESS" "Found wired device IP format"
    else
        print_status "WARNING" "Wired device IP examples not found"
    fi
    
    if grep -q "204.192.4.200" "$variables_file"; then
        print_status "SUCCESS" "Found wireless device IP format"
    else
        print_status "WARNING" "Wireless device IP examples not found"
    fi
    
    if grep -q "managed_ap_locations" "$variables_file"; then
        print_status "SUCCESS" "Found AP location configuration"
    else
        print_status "WARNING" "AP location configuration not found"
    fi
    
    # Check for site hierarchy
    if grep -q "Global/USA/SAN JOSE/SJ_BLD23" "$variables_file"; then
        print_status "SUCCESS" "Found site hierarchy configuration"
    else
        print_status "WARNING" "Site hierarchy examples not found"
    fi
}

# Function to validate workflow operations
check_workflow_operations() {
    local config_file="$1"
    
    echo ""
    print_status "INFO" "Validating workflow operations..."
    
    # Check for proper conditional logic
    if grep -q "count.*\.enabled.*?.*1.*:.*0" "$config_file"; then
        print_status "SUCCESS" "Found conditional workflow enablement"
    else
        print_status "WARNING" "Conditional workflow logic may need improvement"
    fi
    
    # Check for validation rules
    if grep -q "terraform_data.*validation" "$config_file"; then
        print_status "SUCCESS" "Found validation rules"
    else
        print_status "WARNING" "Validation rules not found"
    fi
    
    # Check for locals
    if grep -q "locals" "$config_file"; then
        print_status "SUCCESS" "Found local value calculations"
    else
        print_status "WARNING" "Local value calculations not found"
    fi
}

# Test 1: Main Configuration
check_terraform_files "Main" "main.tf" "variables.tf"
if [ -f "main.tf" ]; then
    check_provision_workflows "main.tf"
    check_resource_configurations "main.tf"
    check_workflow_operations "main.tf"
fi

if [ -f "variables.tf" ]; then
    check_variables "variables.tf"
    check_device_configurations "variables.tf"
fi

# Test 2: Output Configuration
echo ""
print_status "INFO" "Checking outputs configuration..."

if [ -f "outputs.tf" ]; then
    print_status "SUCCESS" "Found outputs configuration"
    
    # Check for provision outputs
    if grep -q "site_assignment_results" "outputs.tf"; then
        print_status "SUCCESS" "Found site assignment output"
    else
        print_status "WARNING" "Site assignment output not found"
    fi
    
    if grep -q "wired_provision_results" "outputs.tf"; then
        print_status "SUCCESS" "Found wired provision output"
    else
        print_status "WARNING" "Wired provision output not found"
    fi
    
    if grep -q "wireless_provision_results" "outputs.tf"; then
        print_status "SUCCESS" "Found wireless provision output"
    else
        print_status "WARNING" "Wireless provision output not found"
    fi
    
    if grep -q "provision_workflow_summary" "outputs.tf"; then
        print_status "SUCCESS" "Found workflow summary output"
    else
        print_status "WARNING" "Workflow summary output not found"
    fi
    
    if grep -q "provision_test_results" "outputs.tf"; then
        print_status "SUCCESS" "Found test results output"
    else
        print_status "WARNING" "Test results output not found"
    fi
else
    print_status "ERROR" "outputs.tf not found"
fi

# Test 3: Additional Files
echo ""
print_status "INFO" "Checking additional files..."

if [ -f "terraform.tfvars.example" ]; then
    print_status "SUCCESS" "Found terraform.tfvars.example"
    
    # Check if example has customization guidance
    if grep -q "Replace with your" "terraform.tfvars.example"; then
        print_status "SUCCESS" "Example file contains customization guidance"
    else
        print_status "WARNING" "Example file may need more customization guidance"
    fi
    
    # Check for all workflow examples
    if grep -q "wired_device_provision" "terraform.tfvars.example"; then
        print_status "SUCCESS" "Found wired device provision examples"
    else
        print_status "WARNING" "Wired device provision examples missing"
    fi
else
    print_status "WARNING" "terraform.tfvars.example not found"
fi

if [ -f "README.md" ]; then
    print_status "SUCCESS" "Found README.md"
    
    # Check README content
    if grep -q "Provision Workflow Use Case" "README.md"; then
        print_status "SUCCESS" "README contains proper title"
    else
        print_status "WARNING" "README title may need updating"
    fi
    
    if grep -q "Prerequisites" "README.md"; then
        print_status "SUCCESS" "README contains prerequisites section"
    else
        print_status "WARNING" "README missing prerequisites section"
    fi
else
    print_status "WARNING" "README.md not found - will be created"
fi

# Test 4: Workflow Validation Against Requirements
echo ""
print_status "INFO" "Validating workflows against Ansible workflow requirements..."

workflows=("Site Assignment" "Device Provision" "Device Re-Provision" "Wireless Provision")
resources=("site_assignment" "wired_provision" "device_reprovision" "wireless_provision")

for i in "${!workflows[@]}"; do
    workflow="${workflows[$i]}"
    resource="${resources[$i]}"
    
    if grep -q "$resource" "main.tf" 2>/dev/null; then
        print_status "SUCCESS" "Found required workflow: $workflow"
    else
        print_status "ERROR" "Required workflow missing: $workflow"
    fi
done

# Check for application telemetry configuration
if grep -q "application_telemetry" "variables.tf" 2>/dev/null; then
    print_status "SUCCESS" "Found application telemetry configuration"
else
    print_status "WARNING" "Application telemetry configuration not found"
fi

# Final Summary
echo ""
echo "=== Test Summary ==="

files_exist=0
if [ -f "main.tf" ] && [ -f "variables.tf" ] && [ -f "outputs.tf" ]; then
    files_exist=1
fi

if [ $files_exist -eq 1 ]; then
    print_status "SUCCESS" "All required configuration files present"
else
    print_status "ERROR" "Missing required configuration files"
fi

# Count provision resources
if [ -f "main.tf" ]; then
    sda_provision_count=$(grep -c "resource \"catalystcenter_sda_provision_devices\"" main.tf 2>/dev/null || echo "0")
    wireless_provision_count=$(grep -c "resource \"catalystcenter_wireless_provision_device_create\"" main.tf 2>/dev/null || echo "0")
    total_workflows=$((sda_provision_count + wireless_provision_count))
    
    if [ "$total_workflows" -ge 4 ]; then
        print_status "SUCCESS" "All provision workflows implemented ($total_workflows resources)"
    else
        print_status "WARNING" "Expected at least 4 provision resources, found: $total_workflows"
    fi
fi

# Check files created
echo ""
print_status "INFO" "Files created:"
ls -la *.tf *.md *.example 2>/dev/null || print_status "WARNING" "Some expected files may be missing"
echo

echo ""
print_status "SUCCESS" "Provision workflow configuration test completed!"
echo ""
echo "Next steps:"
echo "1. Copy terraform.tfvars.example to terraform.tfvars"
echo "2. Update device IPs and site hierarchy for your environment"
echo "3. Ensure devices are discovered in Catalyst Center"
echo "4. Run 'terraform init && terraform plan' to validate"
echo "5. Run 'terraform apply' to execute provision workflows"
echo "6. Verify results in Catalyst Center UI under Provision > Device Provision"