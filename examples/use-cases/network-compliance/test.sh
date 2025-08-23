#!/bin/bash

# Network Compliance Workflow Test Script
# This script validates the Terraform configurations for network compliance workflows

set -e  # Exit on any error

echo "=== Network Compliance Workflow Terraform Configuration Test ==="
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

# Function to check network compliance workflows
check_compliance_workflows() {
    local config_file="$1"
    
    echo ""
    print_status "INFO" "Checking compliance workflows in $config_file..."
    
    # Check for compliance check resource
    if grep -q "catalystcenter_compliance.*network_compliance_check" "$config_file"; then
        print_status "SUCCESS" "Found compliance check resource"
    else
        print_status "ERROR" "Compliance check resource not found"
    fi
    
    # Check for remediation resources
    if grep -q "catalystcenter_network_devices_issues_remediation_provision.*remediate_compliance_issues" "$config_file"; then
        print_status "SUCCESS" "Found compliance remediation resource"
    else
        print_status "WARNING" "Compliance remediation resource not found"
    fi
    
    if grep -q "catalystcenter_network_devices_issues_remediation_provision.*sync_device_config" "$config_file"; then
        print_status "SUCCESS" "Found device config sync resource"
    else
        print_status "WARNING" "Device config sync resource not found"
    fi
    
    # Check for data sources
    if grep -q "data.*catalystcenter_network_device_by_ip" "$config_file"; then
        print_status "SUCCESS" "Found network device by IP data source"
    else
        print_status "ERROR" "Network device by IP data source not found"
    fi
    
    if grep -q "data.*catalystcenter_network_devices_assigned_to_site" "$config_file"; then
        print_status "SUCCESS" "Found network devices assigned to site data source"
    else
        print_status "WARNING" "Network devices assigned to site data source not found"
    fi
    
    if grep -q "data.*catalystcenter_compliance_device_details" "$config_file"; then
        print_status "SUCCESS" "Found compliance device details data source"
    else
        print_status "WARNING" "Compliance device details data source not found"
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
    
    # Check for local values (device UUID processing)
    if grep -q "locals" "$config_file" && grep -q "all_device_uuids" "$config_file"; then
        print_status "SUCCESS" "Found device UUID processing logic"
    else
        print_status "ERROR" "Device UUID processing logic not found"
    fi
}

# Function to check variable definitions
check_variables() {
    local variables_file="$1"
    
    echo ""
    print_status "INFO" "Checking variable definitions..."
    
    # Check for required variable blocks
    variables=(
        "ip_address_list"
        "site_name"
        "run_compliance"
        "run_compliance_categories"
        "trigger_full_compliance"
        "remediate_compliance_issues"
        "sync_device_config"
        "compliance_timeout"
        "remediation_timeout"
        "sync_timeout"
        "catalystcenter_host"
        "catalystcenter_username"
        "catalystcenter_password"
    )
    
    for var in "${variables[@]}"; do
        if grep -q "variable \"$var\"" "$variables_file"; then
            print_status "SUCCESS" "Found variable definition: $var"
        else
            print_status "ERROR" "Variable definition not found: $var"
        fi
    done
    
    # Check for compliance category validation
    if grep -q "INTENT.*RUNNING_CONFIG.*IMAGE.*PSIRT.*EOX" "$variables_file"; then
        print_status "SUCCESS" "Found compliance category validation"
    else
        print_status "WARNING" "Compliance category validation not found"
    fi
    
    # Check for device selection validation
    if grep -q "ip_address_list.*site_name" "$variables_file"; then
        print_status "SUCCESS" "Found device selection validation"
    else
        print_status "WARNING" "Device selection validation not found"
    fi
}

# Function to check outputs
check_outputs() {
    local outputs_file="$1"
    
    echo ""
    print_status "INFO" "Checking output definitions..."
    
    if [ ! -f "$outputs_file" ]; then
        print_status "ERROR" "$outputs_file not found"
        return 1
    fi
    
    # Check for key output blocks
    outputs=(
        "target_devices_from_ips"
        "target_devices_from_site"
        "all_target_device_uuids"
        "compliance_check_results"
        "compliance_details"
        "remediation_results"
        "config_sync_results"
        "workflow_summary"
    )
    
    for output in "${outputs[@]}"; do
        if grep -q "output \"$output\"" "$outputs_file"; then
            print_status "SUCCESS" "Found output definition: $output"
        else
            print_status "ERROR" "Output definition not found: $output"
        fi
    done
    
    # Check for conditional outputs
    if grep -q "length.*> 0" "$outputs_file"; then
        print_status "SUCCESS" "Found conditional output logic"
    else
        print_status "WARNING" "Conditional output logic not found"
    fi
}

# Function to check example file
check_example_file() {
    local example_file="$1"
    
    echo ""
    print_status "INFO" "Checking example configuration..."
    
    if [ ! -f "$example_file" ]; then
        print_status "ERROR" "$example_file not found"
        return 1
    fi
    
    # Check for key configuration sections
    if grep -q "ip_address_list" "$example_file"; then
        print_status "SUCCESS" "Found IP address list configuration"
    else
        print_status "WARNING" "IP address list configuration not found"
    fi
    
    if grep -q "site_name" "$example_file"; then
        print_status "SUCCESS" "Found site name configuration"
    else
        print_status "WARNING" "Site name configuration not found"
    fi
    
    if grep -q "run_compliance_categories" "$example_file"; then
        print_status "SUCCESS" "Found compliance categories configuration"
    else
        print_status "WARNING" "Compliance categories configuration not found"
    fi
    
    # Check for example values matching Ansible workflow
    if grep -q "204.1.2" "$example_file"; then
        print_status "SUCCESS" "Found example IP addresses from Ansible workflow"
    else
        print_status "WARNING" "Example IP addresses from Ansible workflow not found"
    fi
    
    if grep -q "Global/USA/SAN JOSE/BLD23" "$example_file"; then
        print_status "SUCCESS" "Found example site name from Ansible workflow"
    else
        print_status "WARNING" "Example site name from Ansible workflow not found"
    fi
}

# Function to check README documentation
check_readme() {
    local readme_file="$1"
    
    echo ""
    print_status "INFO" "Checking README documentation..."
    
    if [ ! -f "$readme_file" ]; then
        print_status "ERROR" "$readme_file not found"
        return 1
    fi
    
    # Check for key documentation sections
    sections=(
        "Network Compliance Workflow"
        "Prerequisites"
        "Configuration"
        "Usage Examples"
        "Compliance Categories"
        "Important Notes"
        "Network Impact Warning"
    )
    
    for section in "${sections[@]}"; do
        if grep -q "$section" "$readme_file"; then
            print_status "SUCCESS" "Found documentation section: $section"
        else
            print_status "WARNING" "Documentation section not found: $section"
        fi
    done
    
    # Check for workflow reference
    if grep -q "DNACENSolutions.*network_compliance" "$readme_file"; then
        print_status "SUCCESS" "Found reference to Ansible workflow"
    else
        print_status "WARNING" "Reference to Ansible workflow not found"
    fi
}

# Main test execution
echo "Starting Network Compliance Workflow validation..."

# Test 1: Main Configuration
check_terraform_files "Network Compliance Workflow" "main.tf" "variables.tf"
if [ -f "main.tf" ]; then
    check_compliance_workflows "main.tf"
fi

# Test 2: Variables
if [ -f "variables.tf" ]; then
    check_variables "variables.tf"
fi

# Test 3: Outputs
check_outputs "outputs.tf"

# Test 4: Example Configuration
check_example_file "terraform.tfvars.example"

# Test 5: Documentation
check_readme "README.md"

# Test 6: Additional Files
echo ""
print_status "INFO" "Checking additional files..."

if [ -f "terraform-common.tfvars" ]; then
    print_status "SUCCESS" "Found common terraform vars link"
else
    print_status "WARNING" "terraform-common.tfvars not found"
fi

if [ -f "variables-common.tf" ]; then
    print_status "SUCCESS" "Found common variables link"
else
    print_status "WARNING" "variables-common.tf not found"
fi

# Test 7: Compliance Categories Validation
echo ""
print_status "INFO" "Validating compliance categories against Ansible workflow..."

categories=("INTENT" "RUNNING_CONFIG" "IMAGE" "PSIRT" "EOX")
for category in "${categories[@]}"; do
    if grep -q "$category" "variables.tf" 2>/dev/null; then
        print_status "SUCCESS" "Found compliance category: $category"
    else
        print_status "WARNING" "Compliance category not found: $category"
    fi
done

# Final Summary
echo ""
echo "=== Test Summary ==="

files_exist=0
if [ -f "main.tf" ] && [ -f "variables.tf" ] && [ -f "outputs.tf" ] && [ -f "README.md" ]; then
    files_exist=1
fi

if [ $files_exist -eq 1 ]; then
    print_status "SUCCESS" "All required configuration files present"
else
    print_status "ERROR" "Missing required configuration files"
fi

# Count compliance resources
if [ -f "main.tf" ]; then
    compliance_count=$(grep -c "catalystcenter_compliance" main.tf 2>/dev/null || echo "0")
    remediation_count=$(grep -c "catalystcenter_network_devices_issues_remediation_provision" main.tf 2>/dev/null || echo "0")
    data_source_count=$(grep -c "data.*catalystcenter_" main.tf 2>/dev/null || echo "0")
    
    print_status "INFO" "Resource counts: Compliance($compliance_count), Remediation($remediation_count), Data Sources($data_source_count)"
    
    if [ "$compliance_count" -gt 0 ] && [ "$remediation_count" -gt 0 ] && [ "$data_source_count" -gt 0 ]; then
        print_status "SUCCESS" "All expected resource types implemented"
    else
        print_status "WARNING" "Some expected resource types may be missing"
    fi
fi

echo ""
print_status "INFO" "Network Compliance Workflow validation completed!"
echo ""