#!/bin/bash

# Consolidated PnP Test Suite Runner
# This script runs the consolidated PnP tests with various options

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test scenario names
declare -a TEST_NAMES=(
    "Single Device Onboarding"
    "Bulk Device Onboarding"
    "Router Claiming"
    "Switch Claiming"
    "Wireless Controller Claiming"
    "Access Point Claiming"
    "Device Reset"
    "Global Settings"
)

# Function to print colored output
print_status() {
    if [ "$1" = "success" ]; then
        echo -e "${GREEN}✓ $2${NC}"
    elif [ "$1" = "error" ]; then
        echo -e "${RED}✗ $2${NC}"
    elif [ "$1" = "warning" ]; then
        echo -e "${YELLOW}⚠ $2${NC}"
    elif [ "$1" = "info" ]; then
        echo -e "${BLUE}ℹ $2${NC}"
    fi
}

# Function to display help
show_help() {
    echo "Consolidated PnP Test Suite Runner"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --all                Run all enabled tests"
    echo "  --scenario <n>       Run specific test scenario (1-8)"
    echo "  --list               List all test scenarios"
    echo "  --validate           Validate configuration only"
    echo "  --plan               Run terraform plan only"
    echo "  --apply              Run terraform apply"
    echo "  --destroy            Destroy all resources"
    echo "  --output             Show test outputs"
    echo "  --debug              Enable debug mode"
    echo "  --help               Show this help message"
    echo ""
    echo "Test Scenarios:"
    for i in "${!TEST_NAMES[@]}"; do
        echo "  $((i+1)). ${TEST_NAMES[$i]}"
    done
    echo ""
    echo "Examples:"
    echo "  $0 --all                    # Run all enabled tests"
    echo "  $0 --scenario 1             # Run test scenario 1"
    echo "  $0 --plan --scenario 3      # Plan test scenario 3"
    echo "  $0 --validate               # Validate configuration"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "info" "Checking prerequisites..."
    
    # Check Terraform
    if ! command -v terraform &> /dev/null; then
        print_status "error" "Terraform is not installed"
        exit 1
    fi
    terraform_version=$(terraform version -json | jq -r '.terraform_version' 2>/dev/null || echo "unknown")
    print_status "success" "Terraform installed (version: $terraform_version)"
    
    # Check configuration files
    if [ ! -f "terraform.tfvars" ]; then
        print_status "warning" "terraform.tfvars not found"
        echo "Creating from example..."
        cp terraform.tfvars.example terraform.tfvars
        print_status "info" "Please configure terraform.tfvars before running tests"
        exit 1
    fi
    print_status "success" "Configuration files found"
    
    # Check if terraform is initialized
    if [ ! -d ".terraform" ]; then
        print_status "info" "Initializing Terraform..."
        terraform init > /dev/null 2>&1
        print_status "success" "Terraform initialized"
    fi
}

# Function to validate configuration
validate_config() {
    print_status "info" "Validating Terraform configuration..."
    if terraform validate > /dev/null 2>&1; then
        print_status "success" "Configuration is valid"
        return 0
    else
        print_status "error" "Configuration validation failed"
        terraform validate
        return 1
    fi
}

# Function to run terraform plan
run_plan() {
    local target=""
    if [ -n "$1" ]; then
        target="-target=$1"
    fi
    
    print_status "info" "Running Terraform plan..."
    if terraform plan $target -out=tfplan > /dev/null 2>&1; then
        print_status "success" "Plan completed successfully"
        
        # Show summary
        echo ""
        print_status "info" "Plan Summary:"
        terraform show -no-color tfplan | grep -E "will be created|will be updated|will be destroyed" | head -10
        return 0
    else
        print_status "error" "Plan failed"
        terraform plan $target
        return 1
    fi
}

# Function to run terraform apply
run_apply() {
    local target=""
    if [ -n "$1" ]; then
        target="-target=$1"
    fi
    
    print_status "info" "Running Terraform apply..."
    if terraform apply $target -auto-approve > terraform_apply.log 2>&1; then
        print_status "success" "Apply completed successfully"
        return 0
    else
        print_status "error" "Apply failed. Check terraform_apply.log for details"
        tail -20 terraform_apply.log
        return 1
    fi
}

# Function to run specific test scenario
run_scenario() {
    local scenario=$1
    local operation=$2
    
    if [ "$scenario" -lt 1 ] || [ "$scenario" -gt 8 ]; then
        print_status "error" "Invalid scenario number. Must be 1-8"
        return 1
    fi
    
    print_status "info" "Running Test Scenario $scenario: ${TEST_NAMES[$((scenario-1))]}"
    
    # Map scenario to Terraform resources
    case $scenario in
        1) target="catalystcenter_pnp_device.single_device_onboarding" ;;
        2) target="catalystcenter_pnp_device_import.bulk_device_import" ;;
        3) target="catalystcenter_pnp_device_site_claim.router_claim" ;;
        4) target="catalystcenter_pnp_device_site_claim.switch_claim" ;;
        5) target="catalystcenter_pnp_device_site_claim.wlc_claim" ;;
        6) target="catalystcenter_pnp_device_site_claim.ap_claim" ;;
        7) target="catalystcenter_pnp_device_reset.device_reset" ;;
        8) target="catalystcenter_pnp_global_settings.global_settings" ;;
    esac
    
    case $operation in
        plan)
            run_plan "$target"
            ;;
        apply)
            run_apply "$target"
            ;;
        *)
            run_plan "$target"
            echo ""
            echo -e "${YELLOW}Apply changes? (yes/no)${NC}"
            read -r response
            if [ "$response" = "yes" ]; then
                run_apply "$target"
            fi
            ;;
    esac
}

# Function to show outputs
show_outputs() {
    print_status "info" "Test Suite Outputs:"
    echo ""
    
    # Show summary
    if terraform output -json test_suite_summary > /dev/null 2>&1; then
        echo "Test Suite Summary:"
        terraform output -json test_suite_summary | jq '.'
        echo ""
    fi
    
    # Show validation status
    if terraform output -json test_validation_status > /dev/null 2>&1; then
        echo "Validation Status:"
        terraform output -json test_validation_status | jq '.'
        echo ""
    fi
    
    # Show individual test results
    for i in {1..8}; do
        output_name="test_${i}_*"
        if terraform output | grep -q "test_${i}_"; then
            echo "Test $i Results:"
            terraform output -json | jq ".[\"test_${i}_single_device\", \"test_${i}_bulk_devices\", \"test_${i}_router_claiming\", \"test_${i}_switch_claiming\", \"test_${i}_wlc_claiming\", \"test_${i}_ap_claiming\", \"test_${i}_device_reset\", \"test_${i}_global_settings\"] | select(. != null)"
            echo ""
        fi
    done
}

# Function to check which tests are enabled
check_enabled_tests() {
    print_status "info" "Checking enabled tests..."
    echo ""
    
    for i in {1..8}; do
        var_name="test_scenario_${i}_*"
        # Check if test is enabled in terraform.tfvars
        if grep -q "test_scenario_${i}.*enabled.*=.*true" terraform.tfvars 2>/dev/null; then
            print_status "success" "Test $i: ${TEST_NAMES[$((i-1))]} - ENABLED"
        else
            print_status "info" "Test $i: ${TEST_NAMES[$((i-1))]} - DISABLED"
        fi
    done
    echo ""
}

# Function to destroy resources
destroy_resources() {
    print_status "warning" "This will destroy all PnP resources!"
    echo -e "${YELLOW}Are you sure? (yes/no)${NC}"
    read -r response
    
    if [ "$response" = "yes" ]; then
        print_status "info" "Destroying resources..."
        if terraform destroy -auto-approve > terraform_destroy.log 2>&1; then
            print_status "success" "Resources destroyed successfully"
        else
            print_status "error" "Destroy failed. Check terraform_destroy.log"
            tail -20 terraform_destroy.log
            exit 1
        fi
    else
        print_status "info" "Destroy cancelled"
    fi
}

# Main execution
main() {
    echo "========================================="
    echo "Consolidated PnP Test Suite Runner"
    echo "========================================="
    echo ""
    
    # Default operation
    operation=""
    scenario=""
    debug=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --all)
                operation="all"
                shift
                ;;
            --scenario)
                scenario="$2"
                shift 2
                ;;
            --list)
                check_enabled_tests
                exit 0
                ;;
            --validate)
                operation="validate"
                shift
                ;;
            --plan)
                operation="plan"
                shift
                ;;
            --apply)
                operation="apply"
                shift
                ;;
            --destroy)
                operation="destroy"
                shift
                ;;
            --output)
                operation="output"
                shift
                ;;
            --debug)
                debug=true
                export TF_LOG=DEBUG
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                print_status "error" "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Check prerequisites
    check_prerequisites
    
    # Enable debug if requested
    if [ "$debug" = true ]; then
        print_status "info" "Debug mode enabled"
        export TF_LOG=DEBUG
    fi
    
    # Execute operation
    case $operation in
        validate)
            validate_config
            ;;
        plan)
            validate_config
            if [ -n "$scenario" ]; then
                run_scenario "$scenario" "plan"
            else
                run_plan
            fi
            ;;
        apply)
            validate_config
            if [ -n "$scenario" ]; then
                run_scenario "$scenario" "apply"
            else
                run_apply
            fi
            show_outputs
            ;;
        all)
            validate_config
            check_enabled_tests
            run_plan
            echo ""
            echo -e "${YELLOW}Apply all enabled tests? (yes/no)${NC}"
            read -r response
            if [ "$response" = "yes" ]; then
                run_apply
                show_outputs
            fi
            ;;
        destroy)
            destroy_resources
            ;;
        output)
            show_outputs
            ;;
        *)
            # Default: show status and options
            check_enabled_tests
            echo "Use --help to see available options"
            ;;
    esac
    
    echo ""
    print_status "success" "Test suite execution completed!"
}

# Run main function
main "$@"