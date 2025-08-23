#!/bin/bash

# SWIM Workflow Validation Script  
# This script performs additional validation checks for the SWIM workflow configuration

set -e

echo "=== SWIM Workflow Configuration Validation ==="
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
    
    # Check for required SWIM configurations
    if grep -q "swim_operations" "terraform.tfvars"; then
        print_status "SUCCESS" "SWIM operations configured"
    else
        print_status "WARNING" "SWIM operations may need configuration"
    fi
    
    if grep -q "import_from_url" "terraform.tfvars"; then
        print_status "SUCCESS" "URL import configuration found"
    else
        print_status "WARNING" "URL import configuration may need setup"
    fi
    
    if grep -q "site_name_hierarchy" "terraform.tfvars"; then
        print_status "SUCCESS" "Site hierarchy configured"  
    else
        print_status "WARNING" "Site hierarchy may need configuration"
    fi
    
    # Validate URL configurations
    if grep -q "http://" "terraform.tfvars" || grep -q "https://" "terraform.tfvars"; then
        print_status "SUCCESS" "Image source URLs configured"
        
        # Check if URLs are placeholder values
        if grep -q "your-server.example.com" "terraform.tfvars"; then
            print_status "WARNING" "Default example URLs detected - update with actual image server URLs"
        fi
    else
        print_status "INFO" "No HTTP/HTTPS URLs found - file-based import may be configured instead"
    fi
    
    # Check file path configurations
    if grep -q "file_path" "terraform.tfvars"; then
        print_status "INFO" "File-based import paths configured"
        
        # Check if paths are placeholder values  
        if grep -q "/path/to/your/images" "terraform.tfvars"; then
            print_status "WARNING" "Default example paths detected - update with actual file paths"
        fi
    fi
    
else
    print_status "WARNING" "terraform.tfvars not found. Copy from terraform.tfvars.example"
    print_status "INFO" "Run: cp terraform.tfvars.example terraform.tfvars"
fi

# Check for common terraform files
common_files=("terraform-common.tfvars" "variables-common.tf")
for file in "${common_files[@]}"; do
    if [ -f "$file" ]; then
        print_status "SUCCESS" "Found common file: $file"
    else
        print_status "INFO" "Optional common file not found: $file"
    fi
done

# Validate configuration structure
print_status "INFO" "Validating SWIM configuration structure..."

# Check that all workflow operations are defined
workflow_operations=("query_existing_images" "import_from_url" "import_from_file" "verify_imports")
for operation in "${workflow_operations[@]}"; do
    if grep -q "$operation" "variables.tf"; then
        print_status "SUCCESS" "Workflow operation defined: $operation"
    else
        print_status "ERROR" "Missing workflow operation: $operation"
    fi
done

# Check output definitions
output_definitions=("existing_images" "url_import_results" "file_import_results" "swim_workflow_summary")
for output in "${output_definitions[@]}"; do
    if grep -q "$output" "outputs.tf"; then
        print_status "SUCCESS" "Output defined: $output"
    else
        print_status "ERROR" "Missing output: $output"
    fi
done

# Validate supported image formats
print_status "INFO" "Checking documentation for supported image formats..."
supported_formats=("bin" "img" "tar" "smu" "pie" "aes" "iso" "ova" "tar_gz" "qcow2")
missing_formats=()

for format in "${supported_formats[@]}"; do
    if grep -q "$format" "README.md"; then
        continue
    else
        missing_formats+=("$format")
    fi
done

if [ ${#missing_formats[@]} -eq 0 ]; then
    print_status "SUCCESS" "All supported image formats documented"
else
    print_status "WARNING" "Some image formats may not be documented: ${missing_formats[*]}"
fi

# Check Ansible workflow compliance
print_status "INFO" "Checking Ansible workflow compliance..."

if grep -q "DNACENSolutions/dnac_ansible_workflows" "README.md"; then
    print_status "SUCCESS" "Ansible workflow reference found in documentation"
else
    print_status "WARNING" "Missing Ansible workflow reference"
fi

# Check for workflow mapping documentation
ansible_tasks=("import_images" "golden_tag_images" "distribute_images" "activate_images")
for task in "${ansible_tasks[@]}"; do
    if grep -q "$task" "README.md"; then
        print_status "SUCCESS" "Ansible task documented: $task"
    else
        print_status "WARNING" "Ansible task missing from documentation: $task"
    fi
done

# Configuration recommendations
echo ""
print_status "INFO" "Configuration recommendations:"
echo "1. Update terraform.tfvars with your actual image server URLs"
echo "2. Configure your site hierarchy path"
echo "3. Verify network connectivity to image servers"
echo "4. Test with a single image import first"
echo "5. Monitor import tasks via outputs after terraform apply"

echo ""
print_status "SUCCESS" "SWIM workflow validation completed!"
echo ""
print_status "INFO" "Ready for terraform init && terraform plan"