#!/bin/bash

# Device Credentials Test Script
# This script validates the Terraform configurations for device credentials

set -e  # Exit on any error

echo "=== Device Credentials Terraform Configuration Test ==="
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
            print_status "WARNING" "Terraform formatting issues detected"
        fi
        
        # Note: We can't run terraform validate without provider initialization
        print_status "INFO" "Note: Full terraform validation requires provider initialization"
        
        cd - >/dev/null
        rm -rf "$temp_dir"
    else
        print_status "WARNING" "Terraform not available for syntax validation"
    fi
}

# Function to check credential types in configuration
check_credential_types() {
    local main_file="$1"
    local expected_types=("cli" "snmpv2_read_community" "snmpv2_write_community" "snmpv3" "http_read" "http_write" "netconf")
    
    print_status "INFO" "Checking credential types in $main_file..."
    
    for cred_type in "${expected_types[@]}"; do
        if grep -q "global_credential_$cred_type" "$main_file"; then
            print_status "SUCCESS" "Found $cred_type credential resource"
        else
            print_status "WARNING" "Missing $cred_type credential resource"
        fi
    done
}

# Function to check variables
check_variables() {
    local variables_file="$1"
    
    print_status "INFO" "Checking variables in $variables_file..."
    
    # Check for sensitive marking
    if grep -q "sensitive = true" "$variables_file"; then
        print_status "SUCCESS" "Found sensitive variable declarations"
    else
        print_status "WARNING" "No sensitive variables marked - consider marking credential variables as sensitive"
    fi
    
    # Check for required variable types
    local required_vars=("cli" "snmp" "https")
    for var_type in "${required_vars[@]}"; do
        if grep -q "$var_type" "$variables_file"; then
            print_status "SUCCESS" "Found $var_type related variables"
        else
            print_status "WARNING" "Missing $var_type related variables"
        fi
    done
}

# Main test execution
echo "Testing Device Credentials Terraform Configurations"
echo "=================================================="

# Test 1: Individual Resources Configuration
check_terraform_files "Individual Resources" "main.tf" "variables.tf"
if [ -f "main.tf" ]; then
    check_credential_types "main.tf"
    check_variables "variables.tf"
fi

# Test 2: Unified Configuration
check_terraform_files "Unified Resources" "main-unified.tf" "variables-unified.tf"
if [ -f "main-unified.tf" ]; then
    if grep -q "global_credential_v2" "main-unified.tf"; then
        print_status "SUCCESS" "Found unified credential resource (v2)"
    else
        print_status "WARNING" "Unified configuration doesn't use v2 resource"
    fi
fi

# Test 3: Test-Only Configuration
check_terraform_files "Test-Only" "test-only.tf" "variables-test.tf"
if [ -f "test-only.tf" ]; then
    check_credential_types "test-only.tf"
    
    # Check for site dependencies (should not have any)
    if grep -q "sites_device_credentials" "test-only.tf"; then
        print_status "WARNING" "Test-only configuration has site dependencies"
    else
        print_status "SUCCESS" "Test-only configuration has no site dependencies"
    fi
fi

# Test 4: Validation Configuration
if [ -f "validation.tf" ]; then
    print_status "SUCCESS" "Found validation configuration"
    
    # Check for data sources
    if grep -q "data.*global_credential" "validation.tf"; then
        print_status "SUCCESS" "Found credential validation data sources"
    else
        print_status "WARNING" "Validation configuration missing credential data sources"
    fi
else
    print_status "WARNING" "validation.tf not found"
fi

# Test 5: Additional Files
echo ""
print_status "INFO" "Checking additional files..."

if [ -f "outputs.tf" ]; then
    print_status "SUCCESS" "Found outputs configuration"
else
    print_status "WARNING" "outputs.tf not found"
fi

if [ -f "terraform.tfvars.example" ]; then
    print_status "SUCCESS" "Found example terraform.tfvars file"
else
    print_status "WARNING" "terraform.tfvars.example not found"
fi

if [ -f "README.md" ]; then
    print_status "SUCCESS" "Found README documentation"
    
    # Check if README has basic sections
    if grep -q "## Usage" "README.md"; then
        print_status "SUCCESS" "README contains usage instructions"
    else
        print_status "WARNING" "README missing usage section"
    fi
else
    print_status "WARNING" "README.md not found"
fi

# Summary
echo ""
echo "=== Test Summary ==="
echo "Configuration files validated for device credentials use case"
print_status "INFO" "Remember to:"
echo "  - Update site IDs in variables before applying"
echo "  - Configure Catalyst Center provider authentication"
echo "  - Test in a non-production environment first"
echo "  - Review security considerations for credential management"

echo ""
print_status "SUCCESS" "Device credentials configuration test completed!"