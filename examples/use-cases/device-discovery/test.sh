#!/bin/bash

# Device Discovery Test Script
# This script validates the Terraform configurations for device discovery

set -e  # Exit on any error

echo "=== Device Discovery Terraform Configuration Test ==="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    if [ "$1" = "SUCCESS" ]; then
        echo -e "${GREEN}✓ $2${NC}"
    elif [ "$1" = "WARNING" ]; then
        echo -e "${YELLOW}⚠ $2${NC}"
    elif [ "$1" = "ERROR" ]; then
        echo -e "${RED}✗ $2${NC}"
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

# Function to check discovery types
check_discovery_types() {
    local config_file="$1"
    
    echo ""
    print_status "INFO" "Checking discovery types in $config_file..."
    
    # Check for all required discovery types
    if grep -q "cdp_discovery" "$config_file"; then
        print_status "SUCCESS" "Found CDP discovery configuration"
    else
        print_status "ERROR" "CDP discovery configuration not found"
    fi
    
    if grep -q "single_ip_discovery_1" "$config_file"; then
        print_status "SUCCESS" "Found Single IP discovery 1 configuration"
    else
        print_status "ERROR" "Single IP discovery 1 configuration not found"
    fi
    
    if grep -q "single_ip_discovery_2" "$config_file"; then
        print_status "SUCCESS" "Found Single IP discovery 2 configuration"
    else
        print_status "ERROR" "Single IP discovery 2 configuration not found"
    fi
    
    if grep -q "range_ip_discovery" "$config_file"; then
        print_status "SUCCESS" "Found Range IP discovery configuration"
    else
        print_status "ERROR" "Range IP discovery configuration not found"
    fi
    
    if grep -q "multi_range_ip_discovery" "$config_file"; then
        print_status "SUCCESS" "Found Multi Range IP discovery configuration"
    else
        print_status "ERROR" "Multi Range IP discovery configuration not found"
    fi
}

# Function to check credential configurations
check_credential_configurations() {
    local config_file="$1"
    
    echo ""
    print_status "INFO" "Checking credential configurations in $config_file..."
    
    # Check for HTTP credentials
    if grep -q "http_read_credential" "$config_file"; then
        print_status "SUCCESS" "Found HTTP read credential configuration"
    else
        print_status "WARNING" "HTTP read credential configuration not found"
    fi
    
    if grep -q "http_write_credential" "$config_file"; then
        print_status "SUCCESS" "Found HTTP write credential configuration"
    else
        print_status "WARNING" "HTTP write credential configuration not found"
    fi
    
    # Check for SNMP credentials
    if grep -q "snmp_v3_credential" "$config_file"; then
        print_status "SUCCESS" "Found SNMPv3 credential configuration"
    else
        print_status "WARNING" "SNMPv3 credential configuration not found"
    fi
    
    # Check for global credentials
    if grep -q "global_credential_id_list" "$config_file"; then
        print_status "SUCCESS" "Found global credential list configuration"
    else
        print_status "ERROR" "Global credential list configuration not found"
    fi
}

# Function to check variable definitions
check_variables() {
    local variables_file="$1"
    
    echo ""
    print_status "INFO" "Checking variable definitions..."
    
    # Check for required variable blocks
    variables=("cdp_discovery" "single_ip_discovery_1" "single_ip_discovery_2" "range_ip_discovery" "multi_range_ip_discovery" "global_credential_id_list")
    
    for var in "${variables[@]}"; do
        if grep -q "variable \"$var\"" "$variables_file"; then
            print_status "SUCCESS" "Found variable definition: $var"
        else
            print_status "ERROR" "Variable definition not found: $var"
        fi
    done
}

# Function to check IP address formats
check_ip_formats() {
    local variables_file="$1"
    
    echo ""
    print_status "INFO" "Checking IP address formats..."
    
    # Check for different IP formats in default values
    if grep -q "204.101.16.1" "$variables_file"; then
        print_status "SUCCESS" "Found single IP format (CDP/Single)"
    else
        print_status "WARNING" "Single IP format examples not found"
    fi
    
    if grep -q "204.101.16.2-204.101.16.2" "$variables_file"; then
        print_status "SUCCESS" "Found IP range format"
    else
        print_status "WARNING" "IP range format examples not found"
    fi
    
    if grep -q "204.101.16.2-204.101.16.3" "$variables_file"; then
        print_status "SUCCESS" "Found multi-range IP format"
    else
        print_status "WARNING" "Multi-range IP format examples not found"
    fi
}

# Test 1: Main Configuration
check_terraform_files "Main" "main.tf" "variables.tf"
if [ -f "main.tf" ]; then
    check_discovery_types "main.tf"
    check_credential_configurations "main.tf"
fi

if [ -f "variables.tf" ]; then
    check_variables "variables.tf"
    check_ip_formats "variables.tf"
fi

# Test 2: Output Configuration
echo ""
print_status "INFO" "Checking outputs configuration..."

if [ -f "outputs.tf" ]; then
    print_status "SUCCESS" "Found outputs configuration"
    
    # Check for discovery outputs
    if grep -q "cdp_discovery" "outputs.tf"; then
        print_status "SUCCESS" "Found CDP discovery output"
    else
        print_status "WARNING" "CDP discovery output not found"
    fi
    
    if grep -q "discovery_summary" "outputs.tf"; then
        print_status "SUCCESS" "Found discovery summary output"
    else
        print_status "WARNING" "Discovery summary output not found"
    fi
    
    if grep -q "discovery_test_results" "outputs.tf"; then
        print_status "SUCCESS" "Found discovery test results output"
    else
        print_status "WARNING" "Discovery test results output not found"
    fi
else
    print_status "WARNING" "outputs.tf not found"
fi

# Test 3: Additional Files
echo ""
print_status "INFO" "Checking additional files..."

if [ -f "terraform.tfvars.example" ]; then
    print_status "SUCCESS" "Found terraform.tfvars.example"
    
    # Check if example has customizable values
    if grep -q "Replace with your" "terraform.tfvars.example"; then
        print_status "SUCCESS" "Example file contains customization guidance"
    else
        print_status "WARNING" "Example file may need more customization guidance"
    fi
else
    print_status "WARNING" "terraform.tfvars.example not found"
fi

if [ -f "README.md" ]; then
    print_status "SUCCESS" "Found README.md"
    
    # Check README content
    if grep -q "Device Discovery Use Case" "README.md"; then
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
    print_status "ERROR" "README.md not found"
fi

# Test 4: Discovery Types Validation
echo ""
print_status "INFO" "Validating discovery types against YAML source..."

discovery_types=("CDP" "Single" "Range" "Multi Range")
yaml_names=("CDP Based Discovery1" "Single IP Discovery11" "Range IP Discovery11" "Multi Range Discovery 11")

for i in "${!discovery_types[@]}"; do
    type="${discovery_types[$i]}"
    name="${yaml_names[$i]}"
    
    if grep -q "$name" "variables.tf" 2>/dev/null; then
        print_status "SUCCESS" "Found YAML-sourced discovery: $type ($name)"
    else
        print_status "WARNING" "YAML-sourced discovery name not found: $type"
    fi
done

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

# Count discovery resources
if [ -f "main.tf" ]; then
    discovery_count=$(grep -c "resource \"catalystcenter_discovery\"" main.tf 2>/dev/null || echo "0")
    if [ "$discovery_count" -eq 5 ]; then
        print_status "SUCCESS" "All 5 discovery types implemented ($discovery_count resources)"
    else
        print_status "WARNING" "Expected 5 discovery resources, found: $discovery_count"
    fi
fi

echo ""
print_status "INFO" "Device Discovery configuration test completed!"
echo ""
echo "Next steps:"
echo "1. Copy terraform.tfvars.example to terraform.tfvars"
echo "2. Update credential IDs and IP addresses for your environment"
echo "3. Run 'terraform init && terraform plan' to validate"
echo "4. Run 'terraform apply' to create discoveries"