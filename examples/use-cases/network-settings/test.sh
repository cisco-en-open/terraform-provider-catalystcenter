#!/bin/bash

# Network Settings Test Script
# This script validates the Terraform configurations for network settings functionality
# Based on Ansible workflow: workflows/network_settings/playbook/network_settings_playbook.yml

set -e  # Exit on any error

echo "=== Network Settings Terraform Configuration Test ==="
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
    
    echo ""
    print_status "INFO" "Checking $config_name configuration..."
    
    # Check if main files exist
    if [ ! -f "main.tf" ]; then
        print_status "ERROR" "main.tf not found"
        return 1
    fi
    
    if [ ! -f "variables.tf" ]; then
        print_status "ERROR" "variables.tf not found"
        return 1
    fi
    
    if [ ! -f "terraform.tfvars.example" ]; then
        print_status "ERROR" "terraform.tfvars.example not found"
        return 1
    fi
    
    print_status "SUCCESS" "Core Terraform files exist: main.tf, variables.tf, terraform.tfvars.example"
}

# Function to check network settings resources
check_network_resources() {
    local main_file="$1"
    
    echo ""
    print_status "INFO" "Checking network settings resources in $main_file..."
    
    # Network settings resources
    resources=(
        "catalystcenter_global_pool"
        "catalystcenter_reserve_ip_subpool" 
        "catalystcenter_network_create"
        "catalystcenter_sites_aaa_settings"
        "catalystcenter_network_update"
        "catalystcenter_network_devices_device_controllability_settings"
    )
    
    for resource in "${resources[@]}"; do
        if grep -q "resource \"$resource\"" "$main_file"; then
            print_status "SUCCESS" "Found resource: $resource"
        else
            print_status "WARNING" "Resource not found: $resource"
        fi
    done
}

# Function to check Ansible workflow compatibility
check_workflow_compatibility() {
    local main_file="$1"
    
    echo ""
    print_status "INFO" "Validating against Ansible workflow requirements..."
    
    # Check for workflow components based on network_settings_playbook.yml
    workflows=(
        "Global IP Pool Creation"
        "Reserved IP Pool Creation" 
        "Network Settings Configuration"
        "AAA Settings Configuration"
        "Device Controllability Settings"
    )
    
    resources=(
        "catalystcenter_global_pool"
        "catalystcenter_reserve_ip_subpool"
        "catalystcenter_network_create"
        "catalystcenter_sites_aaa_settings"
        "catalystcenter_network_devices_device_controllability_settings"
    )
    
    for i in "${!workflows[@]}"; do
        workflow="${workflows[$i]}"
        resource="${resources[$i]}"
        
        if grep -q "$resource" "$main_file" 2>/dev/null; then
            print_status "SUCCESS" "Found required workflow: $workflow"
        else
            print_status "ERROR" "Required workflow missing: $workflow"
        fi
    done
}

# Function to check variable configurations
check_variables() {
    local variables_file="$1"
    
    echo ""
    print_status "INFO" "Checking variable configurations..."
    
    # Check for required variable blocks based on Ansible vars
    variables=(
        "catalyst_username"
        "catalyst_password"
        "catalyst_base_url"
        "site_hierarchy"
        "ip_pools"
        "reserved_pools"
        "network_settings"
        "aaa_settings"
        "device_controllability"
    )
    
    for var in "${variables[@]}"; do
        if grep -q "variable \"$var\"" "$variables_file"; then
            print_status "SUCCESS" "Found variable definition: $var"
        else
            print_status "ERROR" "Variable definition not found: $var"
        fi
    done
}

# Function to check network service configurations
check_network_services() {
    local variables_file="$1"
    
    echo ""
    print_status "INFO" "Checking network service configurations..."
    
    # Check for network services based on Ansible workflow
    services=(
        "network_aaa"
        "client_and_endpoint_aaa"
        "dhcp_server"
        "dns_server"
        "ntp_server"
        "snmp_server"
        "syslog_server"
        "netflow_collector"
        "message_of_theday"
        "timezone"
    )
    
    for service in "${services[@]}"; do
        if grep -q "$service" "$variables_file"; then
            print_status "SUCCESS" "Found service configuration: $service"
        else
            print_status "WARNING" "Service configuration not found: $service"
        fi
    done
}

# Function to check IP pool configurations
check_ip_pools() {
    local variables_file="$1"
    
    echo ""
    print_status "INFO" "Checking IP pool configurations..."
    
    # Check for IP pool types
    if grep -q "underlay" "$variables_file"; then
        print_status "SUCCESS" "Found underlay pool configuration"
    else
        print_status "WARNING" "Underlay pool configuration not found"
    fi
    
    if grep -q "SENSORPool" "$variables_file"; then
        print_status "SUCCESS" "Found sensor pool configuration"
    else
        print_status "WARNING" "Sensor pool configuration not found"
    fi
    
    if grep -q "IPv6" "$variables_file"; then
        print_status "SUCCESS" "Found IPv6 pool configuration"
    else
        print_status "WARNING" "IPv6 pool configuration not found"
    fi
    
    # Check for reserved pools
    if grep -q "reserved_pools" "$variables_file"; then
        print_status "SUCCESS" "Found reserved pool configuration"
    else
        print_status "ERROR" "Reserved pool configuration not found"
    fi
}

# Function to check AAA configurations
check_aaa_configurations() {
    local variables_file="$1"
    
    echo ""
    print_status "INFO" "Checking AAA configurations..."
    
    # Check for AAA server types from aaa_servers_vars.yml
    if grep -q "ISE" "$variables_file"; then
        print_status "SUCCESS" "Found ISE server configuration"
    else
        print_status "WARNING" "ISE server configuration not found"
    fi
    
    if grep -q "RADIUS" "$variables_file"; then
        print_status "SUCCESS" "Found RADIUS protocol configuration"
    else
        print_status "WARNING" "RADIUS protocol configuration not found"
    fi
    
    if grep -q "shared_secret" "$variables_file"; then
        print_status "SUCCESS" "Found shared secret configuration"
    else
        print_status "WARNING" "Shared secret configuration not found"
    fi
    
    if grep -q "pan" "$variables_file"; then
        print_status "SUCCESS" "Found PAN (Primary Administration Node) configuration"
    else
        print_status "WARNING" "PAN configuration not found"
    fi
}

# Function to check example configuration
check_example_configuration() {
    echo ""
    print_status "INFO" "Checking example configuration file..."
    
    if [ -f "terraform.tfvars.example" ]; then
        if grep -q "catalyst_username" "terraform.tfvars.example"; then
            print_status "SUCCESS" "Example contains Catalyst Center connection configuration"
        else
            print_status "WARNING" "Example missing Catalyst Center connection configuration"
        fi
        
        if grep -q "site_hierarchy" "terraform.tfvars.example"; then
            print_status "SUCCESS" "Example contains site hierarchy configuration"
        else
            print_status "WARNING" "Example missing site hierarchy configuration"
        fi
        
        if grep -q "ip_pools" "terraform.tfvars.example"; then
            print_status "SUCCESS" "Example contains IP pool configuration"
        else
            print_status "WARNING" "Example missing IP pool configuration"
        fi
        
        if grep -q "aaa_settings" "terraform.tfvars.example"; then
            print_status "SUCCESS" "Example contains AAA settings configuration"
        else
            print_status "WARNING" "Example missing AAA settings configuration"
        fi
        
        if grep -q "INSTRUCTIONS FOR CUSTOMIZATION" "terraform.tfvars.example"; then
            print_status "SUCCESS" "Example contains customization instructions"
        else
            print_status "WARNING" "Example missing customization instructions"
        fi
        
        if grep -q "IMPORTANT SECURITY NOTES" "terraform.tfvars.example"; then
            print_status "SUCCESS" "Example contains security notes"
        else
            print_status "WARNING" "Example missing security notes"
        fi
    else
        print_status "ERROR" "terraform.tfvars.example file missing"
    fi
}

# Function to check data sources
check_data_sources() {
    local main_file="$1"
    
    echo ""
    print_status "INFO" "Checking data sources..."
    
    if grep -q "data.*catalystcenter_site" "$main_file"; then
        print_status "SUCCESS" "Found site data source configuration"
    else
        print_status "WARNING" "Site data source configuration not found"
    fi
    
    if grep -q "data.*catalystcenter_sites" "$main_file"; then
        print_status "SUCCESS" "Found sites data source configuration"
    else
        print_status "WARNING" "Sites data source configuration not found"
    fi
}

# Function to check provider configuration
check_provider_configuration() {
    local main_file="$1"
    
    echo ""
    print_status "INFO" "Checking provider configuration..."
    
    if grep -q "provider \"catalystcenter\"" "$main_file"; then
        print_status "SUCCESS" "Found Catalyst Center provider configuration"
    else
        print_status "ERROR" "Catalyst Center provider configuration not found"
    fi
    
    if grep -q "required_providers" "$main_file"; then
        print_status "SUCCESS" "Found required providers configuration"
    else
        print_status "ERROR" "Required providers configuration not found"
    fi
    
    # Check for provider version
    if grep -q "1.2.0-beta" "$main_file"; then
        print_status "SUCCESS" "Found correct provider version"
    else
        print_status "WARNING" "Provider version may need updating"
    fi
}

# Function to check resource dependencies
check_resource_dependencies() {
    local main_file="$1"
    
    echo ""
    print_status "INFO" "Checking resource dependencies..."
    
    if grep -q "depends_on" "$main_file"; then
        print_status "SUCCESS" "Found resource dependencies configuration"
    else
        print_status "WARNING" "No explicit resource dependencies found"
    fi
    
    # Check for proper IP pool dependencies
    if grep -A 10 "catalystcenter_reserve_ip_subpool" "$main_file" | grep -q "catalystcenter_global_pool"; then
        print_status "SUCCESS" "Found proper IP pool dependencies"
    else
        print_status "WARNING" "IP pool dependencies may need review"
    fi
}

# Function to validate configuration structure
validate_configuration_structure() {
    echo ""
    print_status "INFO" "Validating overall configuration structure..."
    
    # Count resources
    resource_count=$(grep -c "^resource " main.tf 2>/dev/null || echo 0)
    print_status "INFO" "Found $resource_count Terraform resources"
    
    # Count variables
    variable_count=$(grep -c "^variable " variables.tf 2>/dev/null || echo 0)
    print_status "INFO" "Found $variable_count variable definitions"
    
    # Count data sources
    data_count=$(grep -c "^data " main.tf 2>/dev/null || echo 0)
    print_status "INFO" "Found $data_count data sources"
    
    if [ $resource_count -ge 6 ]; then
        print_status "SUCCESS" "Sufficient number of resources for comprehensive testing"
    else
        print_status "WARNING" "May need more resources for complete workflow coverage"
    fi
    
    if [ $variable_count -ge 10 ]; then
        print_status "SUCCESS" "Comprehensive variable configuration"
    else
        print_status "WARNING" "May need more variables for full configuration"
    fi
}

# Main test execution
main() {
    echo "Starting Network Settings Terraform configuration validation..."
    echo "This test validates against Ansible workflow requirements from:"
    echo "- workflows/network_settings/README.md"
    echo "- workflows/network_settings/playbook/network_settings_playbook.yml"
    echo "- workflows/network_settings/vars/aaa_servers_vars.yml"
    echo ""
    
    # Test 1: Basic file structure
    check_terraform_files "Network Settings"
    
    # Test 2: Network resources
    if [ -f "main.tf" ]; then
        check_network_resources "main.tf"
        check_data_sources "main.tf"
        check_provider_configuration "main.tf"
        check_resource_dependencies "main.tf"
    fi
    
    # Test 3: Variable configuration
    if [ -f "variables.tf" ]; then
        check_variables "variables.tf"
        check_network_services "variables.tf"
        check_ip_pools "variables.tf"
        check_aaa_configurations "variables.tf"
    fi
    
    # Test 4: Workflow compatibility
    check_workflow_compatibility "main.tf"
    
    # Test 5: Example configuration
    check_example_configuration
    
    # Test 6: Overall validation
    validate_configuration_structure
    
    echo ""
    print_status "SUCCESS" "Network Settings configuration test completed!"
    echo ""
    print_status "INFO" "Next steps:"
    echo "  1. Copy terraform.tfvars.example to terraform.tfvars"
    echo "  2. Update terraform.tfvars with your Catalyst Center details"
    echo "  3. Run 'terraform init' to initialize the configuration"
    echo "  4. Run 'terraform plan' to review the planned changes"
    echo "  5. Run 'terraform apply' to create the network settings"
    echo ""
    print_status "INFO" "For testing updates, set enable_network_update = true in terraform.tfvars"
}

# Additional files check
echo ""
print_status "INFO" "Checking for additional files..."

if [ -f "outputs.tf" ]; then
    print_status "SUCCESS" "Found outputs configuration"
else
    print_status "WARNING" "outputs.tf not found - consider adding output values"
fi

if [ -f "README.md" ]; then
    print_status "SUCCESS" "Found documentation"
else
    print_status "WARNING" "README.md not found - consider adding documentation"
fi

if [ -f "terraform-common.tfvars" ]; then
    print_status "SUCCESS" "Found common Terraform variables"
else
    print_status "WARNING" "terraform-common.tfvars not found"
fi

# Run main test function
main