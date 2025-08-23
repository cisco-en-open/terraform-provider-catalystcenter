#!/bin/bash

# PnP (Plug and Play) Test Suite Runner
# This script validates the Terraform configurations for PnP functionality

set -e  # Exit on any error

echo "=== PnP (Plug and Play) Terraform Configuration Test Suite ==="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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
    elif [ "$1" = "HEADER" ]; then
        echo -e "${PURPLE}=== $2 ===${NC}"
    else
        echo "  $2"
    fi
}

# Function to check Terraform files
check_terraform_files() {
    local config_name="$1"
    local directory="$2"
    
    echo ""
    print_status "INFO" "Checking $config_name configuration in $directory..."
    
    # Check if directory exists
    if [ ! -d "$directory" ]; then
        print_status "ERROR" "Directory $directory not found"
        return 1
    fi
    
    # Check if main.tf exists
    if [ ! -f "$directory/main.tf" ]; then
        print_status "ERROR" "$directory/main.tf not found"
        return 1
    fi
    
    # Check if variables.tf exists  
    if [ ! -f "$directory/variables.tf" ]; then
        print_status "ERROR" "$directory/variables.tf not found"
        return 1
    fi
    
    print_status "SUCCESS" "Files exist: main.tf, variables.tf"
    
    # Check for basic terraform syntax (if terraform is available)
    if command -v terraform >/dev/null 2>&1; then
        # Create a temporary directory for validation
        temp_dir=$(mktemp -d)
        cp "$directory/main.tf" "$temp_dir/main.tf"
        cp "$directory/variables.tf" "$temp_dir/variables.tf"
        cp "terraform-common.tfvars.example" "$temp_dir/terraform.tfvars" 2>/dev/null || true
        
        cd "$temp_dir"
        
        # Initialize Terraform
        if terraform init >/dev/null 2>&1; then
            print_status "SUCCESS" "Terraform initialization successful"
        else
            print_status "WARNING" "Terraform initialization failed - this may be due to missing provider"
        fi
        
        # Check formatting
        if terraform fmt -check=true -diff=true >/dev/null 2>&1; then
            print_status "SUCCESS" "Terraform formatting is correct"
        else
            print_status "WARNING" "Terraform formatting could be improved"
        fi
        
        # Validate configuration
        if terraform validate >/dev/null 2>&1; then
            print_status "SUCCESS" "Terraform configuration is valid"
        else
            print_status "WARNING" "Terraform configuration validation failed - this may be due to missing provider"
        fi
        
        cd - >/dev/null
        rm -rf "$temp_dir"
    else
        print_status "WARNING" "Terraform not found, skipping validation"
    fi
}

# Function to check PnP test configurations
check_pnp_test_configuration() {
    local config_file="$1"
    local test_type="$2"
    
    echo ""
    print_status "INFO" "Checking $test_type test configuration in $config_file..."
    
    case $test_type in
        "device-onboarding")
            if grep -q "catalystcenter_pnp_device.*single_device" "$config_file"; then
                print_status "SUCCESS" "Found single device onboarding configuration"
            else
                print_status "ERROR" "Single device onboarding configuration not found"
            fi
            ;;
        "bulk-device-onboarding")
            if grep -q "catalystcenter_pnp_device_import.*bulk_devices" "$config_file" || 
               grep -q "catalystcenter_pnp_device.*router_device" "$config_file"; then
                print_status "SUCCESS" "Found bulk device onboarding configuration"
            else
                print_status "ERROR" "Bulk device onboarding configuration not found"
            fi
            ;;
        "router-claiming")
            if grep -q "catalystcenter_pnp_workflow.*router_workflow" "$config_file" &&
               grep -q "catalystcenter_pnp_device_claim.*router_claim" "$config_file"; then
                print_status "SUCCESS" "Found router claiming and workflow configuration"
            else
                print_status "ERROR" "Router claiming configuration not complete"
            fi
            ;;
        "switch-claiming")
            if grep -q "catalystcenter_pnp_workflow.*switch_workflow" "$config_file" &&
               grep -q "catalystcenter_pnp_device_claim.*switch_claim" "$config_file"; then
                print_status "SUCCESS" "Found switch claiming and workflow configuration"
            else
                print_status "ERROR" "Switch claiming configuration not complete"
            fi
            ;;
        "wireless-controller-claiming")
            if grep -q "catalystcenter_pnp_workflow.*wlc_workflow" "$config_file" &&
               grep -q "catalystcenter_pnp_device_claim.*wlc_claim" "$config_file"; then
                print_status "SUCCESS" "Found wireless controller claiming and workflow configuration"
            else
                print_status "ERROR" "Wireless controller claiming configuration not complete"
            fi
            ;;
        "access-point-claiming")
            if grep -q "catalystcenter_pnp_workflow.*ap_workflow" "$config_file" &&
               grep -q "catalystcenter_pnp_device_claim.*ap_claim" "$config_file"; then
                print_status "SUCCESS" "Found access point claiming and workflow configuration"
            else
                print_status "ERROR" "Access point claiming configuration not complete"
            fi
            ;;
        "device-reset")
            if grep -q "catalystcenter_pnp_device_reset.*device_reset" "$config_file"; then
                print_status "SUCCESS" "Found device reset configuration"
            else
                print_status "ERROR" "Device reset configuration not found"
            fi
            ;;
        "global-settings")
            if grep -q "catalystcenter_pnp_global_settings.*pnp_global_config" "$config_file"; then
                print_status "SUCCESS" "Found global settings configuration"
            else
                print_status "ERROR" "Global settings configuration not found"
            fi
            ;;
    esac
}

# Function to check for required variables
check_required_variables() {
    local variables_file="$1"
    local test_type="$2"
    
    echo ""
    print_status "INFO" "Checking required variables for $test_type..."
    
    # Common variables
    if grep -q "catalyst_center_host" "$variables_file" &&
       grep -q "catalyst_center_username" "$variables_file" &&
       grep -q "catalyst_center_password" "$variables_file"; then
        print_status "SUCCESS" "Found required Catalyst Center connection variables"
    else
        print_status "ERROR" "Missing required Catalyst Center connection variables"
    fi
    
    # Test-specific variable checks
    case $test_type in
        "device-onboarding")
            if grep -q "test_device" "$variables_file"; then
                print_status "SUCCESS" "Found device onboarding specific variables"
            fi
            ;;
        "bulk-device-onboarding")
            if grep -q "test_devices" "$variables_file"; then
                print_status "SUCCESS" "Found bulk device onboarding specific variables"
            fi
            ;;
        "router-claiming"|"switch-claiming")
            if grep -q "_device" "$variables_file" && grep -q "_config" "$variables_file"; then
                print_status "SUCCESS" "Found device and configuration specific variables"
            fi
            ;;
        "wireless-controller-claiming")
            if grep -q "wlc_device" "$variables_file" && grep -q "wlc_config" "$variables_file"; then
                print_status "SUCCESS" "Found wireless controller specific variables"
            fi
            ;;
        "access-point-claiming")
            if grep -q "ap_device" "$variables_file" && grep -q "ap_config" "$variables_file"; then
                print_status "SUCCESS" "Found access point specific variables"
            fi
            ;;
        "device-reset")
            if grep -q "error_device" "$variables_file"; then
                print_status "SUCCESS" "Found device reset specific variables"
            fi
            ;;
        "global-settings")
            if grep -q "global_settings" "$variables_file"; then
                print_status "SUCCESS" "Found global settings specific variables"
            fi
            ;;
    esac
}

# Main test execution function
run_test_category() {
    local category="$1"
    local directory=""
    local test_name=""
    
    case $category in
        "device-onboarding")
            directory="01-device-onboarding"
            test_name="Device Onboarding"
            ;;
        "bulk-device-onboarding")
            directory="02-bulk-device-onboarding"
            test_name="Bulk Device Onboarding"
            ;;
        "router-claiming")
            directory="03-router-claiming"
            test_name="Router Claiming"
            ;;
        "switch-claiming")
            directory="04-switch-claiming"
            test_name="Switch Claiming"
            ;;
        "wireless-controller-claiming")
            directory="05-wireless-controller-claiming"
            test_name="Wireless Controller Claiming"
            ;;
        "access-point-claiming")
            directory="06-access-point-claiming"
            test_name="Access Point Claiming"
            ;;
        "device-reset")
            directory="07-device-reset"
            test_name="Device Reset"
            ;;
        "global-settings")
            directory="08-global-settings"
            test_name="Global Settings"
            ;;
        *)
            print_status "ERROR" "Unknown test category: $category"
            return 1
            ;;
    esac
    
    print_status "HEADER" "Testing $test_name"
    
    # Check terraform files
    check_terraform_files "$test_name" "$directory"
    
    # Check test-specific configurations
    check_pnp_test_configuration "$directory/main.tf" "$category"
    
    # Check required variables
    check_required_variables "$directory/variables.tf" "$category"
    
    print_status "SUCCESS" "$test_name tests completed"
}

# Function to display usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --category CATEGORY    Run tests for a specific category"
    echo "  --list-categories      List all available test categories"
    echo "  --help                 Show this help message"
    echo ""
    echo "Available categories:"
    echo "  device-onboarding                Basic device onboarding"
    echo "  bulk-device-onboarding          Bulk device onboarding"
    echo "  router-claiming                  Router claiming and provisioning"
    echo "  switch-claiming                  Switch claiming and provisioning"
    echo "  wireless-controller-claiming     Wireless controller claiming"
    echo "  access-point-claiming            Access point claiming"
    echo "  device-reset                     Device reset and error handling"
    echo "  global-settings                  PnP global settings management"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Run all tests"
    echo "  $0 --category device-onboarding       # Run only device onboarding tests"
    echo "  $0 --category switch-claiming          # Run only switch claiming tests"
}

# Main execution
main() {
    local category=""
    local run_all=true
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --category)
                category="$2"
                run_all=false
                shift 2
                ;;
            --list-categories)
                echo "Available test categories:"
                echo "  device-onboarding"
                echo "  bulk-device-onboarding"
                echo "  router-claiming"
                echo "  switch-claiming"
                echo "  wireless-controller-claiming"
                echo "  access-point-claiming"
                echo "  device-reset"
                echo "  global-settings"
                exit 0
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                print_status "ERROR" "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Check for common files
    echo ""
    print_status "INFO" "Checking common configuration files..."
    
    if [ -f "terraform-common.tfvars.example" ]; then
        print_status "SUCCESS" "Found terraform-common.tfvars.example"
    else
        print_status "ERROR" "terraform-common.tfvars.example not found"
    fi
    
    if [ -f "variables-common.tf" ]; then
        print_status "SUCCESS" "Found variables-common.tf"
    else
        print_status "ERROR" "variables-common.tf not found"
    fi
    
    if [ -f "README.md" ]; then
        print_status "SUCCESS" "Found README.md"
    else
        print_status "WARNING" "README.md not found"
    fi
    
    # Run specific category or all tests
    if [ "$run_all" = true ]; then
        print_status "HEADER" "Running All PnP Tests"
        
        run_test_category "device-onboarding"
        run_test_category "bulk-device-onboarding"
        run_test_category "router-claiming"
        run_test_category "switch-claiming"
        run_test_category "wireless-controller-claiming"
        run_test_category "access-point-claiming"
        run_test_category "device-reset"
        run_test_category "global-settings"
        
        print_status "HEADER" "All PnP Tests Completed"
    else
        run_test_category "$category"
    fi
    
    echo ""
    print_status "INFO" "Test suite execution completed"
    echo ""
    print_status "INFO" "Next steps:"
    echo "  1. Copy terraform-common.tfvars.example to terraform-common.tfvars"
    echo "  2. Update terraform-common.tfvars with your Catalyst Center details"
    echo "  3. Navigate to a specific test directory (e.g., cd 01-device-onboarding)"
    echo "  4. Run 'terraform init && terraform plan -var-file=../terraform-common.tfvars'"
    echo "  5. Run 'terraform apply -var-file=../terraform-common.tfvars' to execute the tests"
    echo "  6. Verify results in Catalyst Center UI under Device > Plug and Play"
    echo ""
}

# Execute main function with all arguments
main "$@"