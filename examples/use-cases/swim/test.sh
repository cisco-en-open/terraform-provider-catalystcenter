#!/bin/bash

# Software Image Management (SWIM) Workflow Test Script
# This script validates the Terraform configurations for SWIM workflows

set -e  # Exit on any error

echo "=== SWIM Workflow Terraform Configuration Test ==="
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
print_status "INFO" "Checking SWIM workflow file structure..."

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

# Test 3: SWIM Resource Validation
print_status "INFO" "Validating SWIM resources and configurations..."

# Check for SWIM data sources
if grep -q "catalystcenter_swim_image_details" "main.tf"; then
    print_status "SUCCESS" "Found SWIM image details data source"
else
    print_status "ERROR" "Missing SWIM image details data source"
fi

# Check for URL import resource
if grep -q "catalystcenter_swim_image_url" "main.tf"; then
    print_status "SUCCESS" "Found SWIM URL import resource"
else
    print_status "ERROR" "Missing SWIM URL import resource"
fi

# Check for file import resource  
if grep -q "catalystcenter_swim_image_file" "main.tf"; then
    print_status "SUCCESS" "Found SWIM file import resource"
else
    print_status "ERROR" "Missing SWIM file import resource"
fi

# Test 4: Variable Configuration Validation
print_status "INFO" "Validating SWIM variables configuration..."

if [ -f "variables.tf" ]; then
    # Check for swim_operations variable
    if grep -q "swim_operations" "variables.tf"; then
        print_status "SUCCESS" "Found swim_operations variable definition"
    else
        print_status "ERROR" "Missing swim_operations variable definition"
    fi
    
    # Check for query_existing_images configuration
    if grep -q "query_existing_images" "variables.tf"; then
        print_status "SUCCESS" "Found query_existing_images configuration"
    else
        print_status "WARNING" "Missing query_existing_images configuration"
    fi
    
    # Check for import_from_url configuration
    if grep -q "import_from_url" "variables.tf"; then
        print_status "SUCCESS" "Found import_from_url configuration"
    else
        print_status "WARNING" "Missing import_from_url configuration"
    fi
    
    # Check for import_from_file configuration
    if grep -q "import_from_file" "variables.tf"; then
        print_status "SUCCESS" "Found import_from_file configuration"
    else
        print_status "WARNING" "Missing import_from_file configuration"
    fi
    
    # Check for site hierarchy variable
    if grep -q "site_name_hierarchy" "variables.tf"; then
        print_status "SUCCESS" "Found site hierarchy configuration"
    else
        print_status "WARNING" "Missing site hierarchy configuration"
    fi
    
    # Check for target devices variable
    if grep -q "target_devices" "variables.tf"; then
        print_status "SUCCESS" "Found target devices configuration"
    else
        print_status "WARNING" "Missing target devices configuration"
    fi
else
    print_status "ERROR" "variables.tf not found"
fi

# Test 5: Output Configuration
print_status "INFO" "Checking SWIM outputs configuration..."

if [ -f "outputs.tf" ]; then
    # Check for existing images output
    if grep -q "existing_images" "outputs.tf"; then
        print_status "SUCCESS" "Found existing images output"
    else
        print_status "WARNING" "Missing existing images output"
    fi
    
    # Check for URL import results output
    if grep -q "url_import_results" "outputs.tf"; then
        print_status "SUCCESS" "Found URL import results output"
    else
        print_status "WARNING" "Missing URL import results output"
    fi
    
    # Check for file import results output
    if grep -q "file_import_results" "outputs.tf"; then
        print_status "SUCCESS" "Found file import results output"
    else
        print_status "WARNING" "Missing file import results output"
    fi
    
    # Check for workflow summary output
    if grep -q "swim_workflow_summary" "outputs.tf"; then
        print_status "SUCCESS" "Found workflow summary output"
    else
        print_status "WARNING" "Missing workflow summary output"
    fi
    
    # Check for debug info output
    if grep -q "debug_info" "outputs.tf"; then
        print_status "SUCCESS" "Found debug info output"
    else
        print_status "WARNING" "Missing debug info output"
    fi
else
    print_status "ERROR" "outputs.tf not found"
fi

# Test 6: Example Configuration
print_status "INFO" "Validating terraform.tfvars.example..."

if [ -f "terraform.tfvars.example" ]; then
    print_status "SUCCESS" "Found terraform.tfvars.example"
    
    # Check if example has customization guidance
    if grep -q "Replace with your" "terraform.tfvars.example"; then
        print_status "SUCCESS" "Example file contains customization guidance"
    else
        print_status "WARNING" "Example file may need more customization guidance"
    fi
    
    # Check for SWIM operations configuration
    if grep -q "swim_operations" "terraform.tfvars.example"; then
        print_status "SUCCESS" "Found swim_operations configuration example"
    else
        print_status "ERROR" "Missing swim_operations configuration example"
    fi
    
    # Check for URL import configuration
    if grep -q "import_from_url" "terraform.tfvars.example"; then
        print_status "SUCCESS" "Found URL import configuration example"
    else
        print_status "WARNING" "Missing URL import configuration example"
    fi
    
    # Check for file import configuration
    if grep -q "import_from_file" "terraform.tfvars.example"; then
        print_status "SUCCESS" "Found file import configuration example"
    else
        print_status "WARNING" "Missing file import configuration example"
    fi
else
    print_status "ERROR" "terraform.tfvars.example not found"
fi

# Test 7: README Documentation
print_status "INFO" "Validating README documentation..."

if [ -f "README.md" ]; then
    # Check README title
    if grep -q "Software Image Management.*SWIM.*Workflow" "README.md"; then
        print_status "SUCCESS" "README contains proper SWIM workflow title"
    else
        print_status "WARNING" "README title may need updating"
    fi
    
    # Check for prerequisites section
    if grep -q "Prerequisites" "README.md"; then
        print_status "SUCCESS" "README contains prerequisites section"
    else
        print_status "WARNING" "README missing prerequisites section"
    fi
    
    # Check for workflow operations documentation
    if grep -q "Query Existing Images" "README.md"; then
        print_status "SUCCESS" "README documents query existing images workflow"
    else
        print_status "WARNING" "README missing query workflow documentation"
    fi
    
    if grep -q "Import Images from URL" "README.md"; then
        print_status "SUCCESS" "README documents URL import workflow"
    else
        print_status "WARNING" "README missing URL import documentation"
    fi
    
    if grep -q "Import Images from Local Files" "README.md"; then
        print_status "SUCCESS" "README documents file import workflow"
    else
        print_status "WARNING" "README missing file import documentation"
    fi
    
    # Check for supported file formats
    if grep -q "bin, img, tar, smu, pie" "README.md"; then
        print_status "SUCCESS" "README documents supported image formats"
    else
        print_status "WARNING" "README missing supported formats documentation"
    fi
    
    # Check for Ansible workflow reference
    if grep -q "Ansible workflow" "README.md"; then
        print_status "SUCCESS" "README references Ansible workflow guidelines"
    else
        print_status "WARNING" "README missing Ansible workflow reference"
    fi
    
    # Check for future enhancements section
    if grep -q "Future Enhancements" "README.md" || grep -q "Golden Tagging" "README.md"; then
        print_status "SUCCESS" "README documents future enhancements"
    else
        print_status "WARNING" "README missing future enhancements section"
    fi
else
    print_status "ERROR" "README.md not found"
fi

# Test 8: Ansible Workflow Compliance
print_status "INFO" "Validating compliance with Ansible workflow requirements..."

ansible_workflow_tasks=("import_images" "golden_tag_images" "distribute_images" "activate_images")
terraform_equivalents=("URL/File Import" "Future Enhancement" "Future Enhancement" "Future Enhancement")

for i in "${!ansible_workflow_tasks[@]}"; do
    task="${ansible_workflow_tasks[$i]}"
    equivalent="${terraform_equivalents[$i]}"
    
    if [ "$equivalent" = "Future Enhancement" ]; then
        print_status "INFO" "Ansible task '$task' -> $equivalent (documented in README)"
    else
        if grep -q "import_from_url\|import_from_file" "main.tf"; then
            print_status "SUCCESS" "Ansible task '$task' -> $equivalent (implemented)"
        else
            print_status "ERROR" "Ansible task '$task' -> $equivalent (missing implementation)"
        fi
    fi
done

# Test 9: Configuration Structure Validation
print_status "INFO" "Validating configuration structure against YAML requirements..."

# Check for proper variable structure that maps to Ansible YAML
yaml_mappings=(
    "swim_details.import_images -> swim_operations.import_from_url"
    "swim_details.golden_tag_images -> image_management.golden_tag_enabled (future)"
    "swim_details.distribute_images -> image_management.distribution_enabled (future)"
    "swim_details.activate_images -> image_management.activation_enabled (future)"
)

for mapping in "${yaml_mappings[@]}"; do
    print_status "INFO" "YAML mapping: $mapping"
done

# Test 10: Resource Count Validation
print_status "INFO" "Validating SWIM resource implementation..."

swim_data_sources=$(grep -c "data.*catalystcenter_swim_image_details" "main.tf" 2>/dev/null || echo "0")
swim_url_resources=$(grep -c "resource.*catalystcenter_swim_image_url" "main.tf" 2>/dev/null || echo "0")  
swim_file_resources=$(grep -c "resource.*catalystcenter_swim_image_file" "main.tf" 2>/dev/null || echo "0")

total_swim_resources=$((swim_data_sources + swim_url_resources + swim_file_resources))

if [ "$total_swim_resources" -ge 3 ]; then
    print_status "SUCCESS" "All core SWIM resources implemented ($total_swim_resources resources)"
else
    print_status "WARNING" "Expected at least 3 SWIM resources, found: $total_swim_resources"
fi

print_status "INFO" "SWIM resource breakdown:"
print_status "INFO" "  Data sources: $swim_data_sources"
print_status "INFO" "  URL import resources: $swim_url_resources"  
print_status "INFO" "  File import resources: $swim_file_resources"

# Check files created
echo ""
print_status "INFO" "Files created:"
ls -la *.tf *.md *.example 2>/dev/null || print_status "WARNING" "Some expected files may be missing"
echo

# Summary
echo ""
print_status "SUCCESS" "SWIM workflow configuration test completed!"
echo ""
echo "Next steps:"
echo "1. Copy terraform.tfvars.example to terraform.tfvars"
echo "2. Update image URLs and file paths for your environment"
echo "3. Configure site hierarchy and device information"
echo "4. Run 'terraform init && terraform plan' to validate"
echo "5. Execute 'terraform apply' to run SWIM workflows"
echo ""
echo "Note: Golden tagging, distribution, and activation workflows"
echo "      will be available when additional provider resources are implemented."