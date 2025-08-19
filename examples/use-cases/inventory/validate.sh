#!/bin/bash

# Inventory Workflow Validation Script  
# This script performs additional validation checks for the inventory workflow configuration

set -e

echo "=== Inventory Workflow Configuration Validation ==="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Check if terraform.tfvars exists
if [ -f "terraform.tfvars" ]; then
    print_status "SUCCESS" "terraform.tfvars file found"
    
    # Check for required configurations
    if grep -q "site_name_hierarchy" "terraform.tfvars"; then
        print_status "SUCCESS" "Site hierarchy configured"
    else
        print_status "WARNING" "Site hierarchy may need configuration"
    fi
    
    if grep -q "device_onboarding" "terraform.tfvars"; then
        print_status "SUCCESS" "Device onboarding configuration found"
    else
        print_status "WARNING" "Device onboarding configuration may need setup"
    fi
    
else
    print_status "WARNING" "terraform.tfvars not found. Copy from terraform.tfvars.example"
    echo "Run: cp terraform.tfvars.example terraform.tfvars"
fi

# Terraform validation if available
if command -v terraform >/dev/null 2>&1; then
    print_status "INFO" "Running Terraform validation..."
    
    if terraform init -backend=false >/dev/null 2>&1; then
        print_status "SUCCESS" "Terraform initialization successful"
        
        if terraform validate >/dev/null 2>&1; then
            print_status "SUCCESS" "Terraform configuration is valid"
        else
            print_status "ERROR" "Terraform configuration validation failed"
        fi
        
        if terraform fmt -check=true >/dev/null 2>&1; then
            print_status "SUCCESS" "Terraform formatting is correct"
        else
            print_status "WARNING" "Run 'terraform fmt' to fix formatting"
        fi
        
    else
        print_status "ERROR" "Terraform initialization failed"
    fi
else
    print_status "INFO" "Terraform not available for validation"
fi

# Check for common configuration issues
print_status "INFO" "Checking for common configuration patterns..."

if grep -q "Global/USA" "terraform.tfvars.example"; then
    print_status "INFO" "Example uses sample site hierarchy - update with your sites"
fi

if grep -q "204.1.2" "terraform.tfvars.example"; then
    print_status "INFO" "Example uses sample IP addresses - update with your device IPs"
fi

if grep -q "FDO12345" "terraform.tfvars.example"; then
    print_status "INFO" "Example uses sample serial numbers - update with actual values"
fi

# Security and safety checks
print_status "INFO" "Performing safety checks..."

if grep -q "device_deletion.*enabled.*true" "terraform.tfvars" 2>/dev/null; then
    print_status "WARNING" "Device deletion is ENABLED - ensure you want to delete devices!"
elif grep -q "device_deletion.*enabled.*false" "terraform.tfvars" 2>/dev/null; then
    print_status "SUCCESS" "Device deletion is safely disabled"
else
    print_status "INFO" "Device deletion configuration not found in terraform.tfvars"
fi

if grep -q "enable_debug.*true" "terraform.tfvars" 2>/dev/null; then
    print_status "INFO" "Debug mode enabled - good for troubleshooting"
fi

echo ""
print_status "SUCCESS" "Validation completed!"

echo ""
echo "Configuration Summary:"
echo "- Inventory workflows: Device onboarding, provisioning, operations, deletion, maintenance"
echo "- Safety features: Conditional resource creation, validation checks"
echo "- Documentation: Comprehensive README with examples and troubleshooting"
echo ""

if [ -f "terraform.tfvars" ]; then
    echo "Ready to deploy! Next steps:"
    echo "1. terraform init"
    echo "2. terraform plan"
    echo "3. terraform apply"
else
    echo "Setup required:"
    echo "1. cp terraform.tfvars.example terraform.tfvars"
    echo "2. Edit terraform.tfvars with your environment details"
    echo "3. terraform init && terraform plan"
fi

echo ""
print_status "WARNING" "Always test in a non-production environment first!"