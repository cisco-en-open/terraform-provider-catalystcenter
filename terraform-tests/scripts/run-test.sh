#!/bin/bash

# Run Test Script
# Executes use cases against specified inventory environments

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    if [ "$1" = "SUCCESS" ]; then
        echo -e "${GREEN}✓ [$timestamp] $2${NC}"
    elif [ "$1" = "WARNING" ]; then
        echo -e "${YELLOW}⚠ [$timestamp] $2${NC}"
    elif [ "$1" = "ERROR" ]; then
        echo -e "${RED}✗ [$timestamp] $2${NC}"
    elif [ "$1" = "INFO" ]; then
        echo -e "${BLUE}ℹ [$timestamp] $2${NC}"
    elif [ "$1" = "RUNNING" ]; then
        echo -e "${CYAN}▶ [$timestamp] $2${NC}"
    else
        echo "  [$timestamp] $2"
    fi
}

# Script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
INVENTORY_DIR="$PROJECT_ROOT/inventories"
USE_CASES_DIR="$PROJECT_ROOT/use-cases"

# Function to display usage
usage() {
    echo "Usage: $0 <environment> [use-case] [options]"
    echo ""
    echo "Environments:"
    echo "  dev        - Development environment"
    echo "  staging    - Staging environment"  
    echo "  production - Production environment"
    echo ""
    echo "Use Cases:"
    echo "  all                - Run all available use cases"
    echo "  site-hierarchy     - Site hierarchy management"
    echo "  pnp                - Plug and Play device onboarding"
    echo "  inventory          - Device inventory workflows"
    echo "  device-credentials - Device credential management"
    echo "  network-settings   - Network configuration settings"
    echo "  device-discovery   - Device discovery processes"
    echo "  provision          - Device provisioning workflows"
    echo "  swim               - Software image management"
    echo "  network-compliance - Network compliance validation"
    echo ""
    echo "Options:"
    echo "  --dry-run     - Show what would be done without executing"
    echo "  --validate    - Run validation only, no apply"
    echo "  --plan-only   - Run terraform plan only"
    echo "  --auto-approve - Skip interactive approval for apply"
    echo "  --parallel    - Run multiple use cases in parallel (dev only)"
    echo "  --verbose     - Enable verbose output"
    echo "  --help        - Display this help message"
    echo ""
    echo "Examples:"
    echo "  $0 dev all                      # Run all use cases in dev"
    echo "  $0 staging site-hierarchy       # Run site-hierarchy in staging"
    echo "  $0 production pnp --dry-run     # Dry run pnp in production"
    echo "  $0 dev inventory --validate     # Validate inventory use case"
}

# Initialize variables
ENVIRONMENT=""
USE_CASE=""
DRY_RUN=false
VALIDATE_ONLY=false
PLAN_ONLY=false
AUTO_APPROVE=false
PARALLEL=false
VERBOSE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        dev|staging|production)
            ENVIRONMENT="$1"
            shift
            ;;
        all|site-hierarchy|pnp|inventory|device-credentials|network-settings|device-discovery|provision|swim|network-compliance)
            USE_CASE="$1"
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --validate)
            VALIDATE_ONLY=true
            shift
            ;;
        --plan-only)
            PLAN_ONLY=true
            shift
            ;;
        --auto-approve)
            AUTO_APPROVE=true
            shift
            ;;
        --parallel)
            PARALLEL=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Validate required arguments
if [ -z "$ENVIRONMENT" ]; then
    print_status "ERROR" "Environment is required"
    usage
    exit 1
fi

if [ -z "$USE_CASE" ]; then
    print_status "ERROR" "Use case is required"
    usage
    exit 1
fi

# Check if environment exists
ENV_DIR="$INVENTORY_DIR/$ENVIRONMENT"
if [ ! -d "$ENV_DIR" ]; then
    print_status "ERROR" "Environment '$ENVIRONMENT' does not exist"
    exit 1
fi

# Check if environment is initialized
if [ ! -f "$ENV_DIR/.terraform/terraform.tfstate" ]; then
    print_status "ERROR" "Environment '$ENVIRONMENT' not initialized. Run setup-inventory.sh first"
    exit 1
fi

# Production safety checks
if [ "$ENVIRONMENT" = "production" ]; then
    if [ "$DRY_RUN" != true ] && [ "$VALIDATE_ONLY" != true ] && [ "$PLAN_ONLY" != true ]; then
        print_status "WARNING" "PRODUCTION ENVIRONMENT DETECTED!"
        print_status "WARNING" "This will affect production systems!"
        print_status "WARNING" "Ensure you have proper approvals and change management approval"
        echo ""
        if [ "$AUTO_APPROVE" != true ]; then
            read -p "Do you have approval to proceed with production changes? (yes/no): " -r
            if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
                print_status "INFO" "Operation cancelled by user"
                exit 0
            fi
        fi
    fi
    
    # Disable parallel execution in production
    if [ "$PARALLEL" = true ]; then
        print_status "WARNING" "Parallel execution disabled in production for safety"
        PARALLEL=false
    fi
fi

# Verbose mode setup
if [ "$VERBOSE" = true ]; then
    set -x
fi

# Function to get available use cases
get_available_use_cases() {
    # First try to get from the examples directory
    if [ -d "$PROJECT_ROOT/../examples/use-cases" ]; then
        ls -1 "$PROJECT_ROOT/../examples/use-cases" | grep -v '\.tf' | grep -v '\.md' | sort
    else
        # Fallback list of known use cases
        echo "site-hierarchy
pnp
inventory
device-credentials
device-credentials-v2
network-settings
device-discovery
provision
swim
network-compliance"
    fi
}

# Function to run a single use case
run_use_case() {
    local use_case=$1
    local env_dir=$2
    
    print_status "RUNNING" "Starting use case: $use_case"
    
    # Create use case working directory
    local work_dir="$env_dir/work/$use_case"
    mkdir -p "$work_dir"
    
    # Copy use case files
    local source_dir="$PROJECT_ROOT/../examples/use-cases/$use_case"
    if [ ! -d "$source_dir" ]; then
        print_status "ERROR" "Use case '$use_case' not found in examples"
        return 1
    fi
    
    # Copy files to working directory
    cp -r "$source_dir"/* "$work_dir/" 2>/dev/null || true
    
    # Create symlinks to inventory configuration
    ln -sf "../../inventory.tf" "$work_dir/inventory.tf"
    ln -sf "../../variables.tf" "$work_dir/variables.tf"
    ln -sf "../../terraform.tfvars" "$work_dir/terraform.tfvars"
    
    # Change to working directory
    cd "$work_dir"
    
    # Initialize if needed
    if [ ! -d ".terraform" ]; then
        print_status "INFO" "Initializing Terraform for $use_case..."
        terraform init -no-color > init.log 2>&1 || {
            print_status "ERROR" "Terraform init failed for $use_case"
            cat init.log
            return 1
        }
    fi
    
    # Validate configuration
    print_status "INFO" "Validating configuration for $use_case..."
    if ! terraform validate -no-color; then
        print_status "ERROR" "Configuration validation failed for $use_case"
        return 1
    fi
    
    # Format files
    terraform fmt -no-color > /dev/null 2>&1 || true
    
    # Run terraform plan
    print_status "INFO" "Running terraform plan for $use_case..."
    local plan_args="-no-color -detailed-exitcode"
    if [ "$VERBOSE" != true ]; then
        plan_args="$plan_args -compact-warnings"
    fi
    
    if terraform plan $plan_args -out="$use_case.tfplan"; then
        local plan_exit=$?
        if [ $plan_exit -eq 0 ]; then
            print_status "INFO" "No changes needed for $use_case"
        elif [ $plan_exit -eq 2 ]; then
            print_status "INFO" "Changes planned for $use_case"
        fi
    else
        print_status "ERROR" "Terraform plan failed for $use_case"
        return 1
    fi
    
    # Stop here if only planning or validating
    if [ "$PLAN_ONLY" = true ] || [ "$VALIDATE_ONLY" = true ]; then
        print_status "SUCCESS" "Validation completed for $use_case"
        return 0
    fi
    
    # Stop here if dry run
    if [ "$DRY_RUN" = true ]; then
        print_status "INFO" "Dry run completed for $use_case"
        return 0
    fi
    
    # Apply changes
    print_status "RUNNING" "Applying changes for $use_case..."
    local apply_args="-no-color"
    if [ "$AUTO_APPROVE" = true ] || [ "$ENVIRONMENT" = "dev" ]; then
        apply_args="$apply_args -auto-approve"
    fi
    
    if terraform apply $apply_args "$use_case.tfplan"; then
        print_status "SUCCESS" "Successfully applied $use_case"
    else
        print_status "ERROR" "Terraform apply failed for $use_case"
        return 1
    fi
    
    # Show outputs if available
    if terraform output > /dev/null 2>&1; then
        print_status "INFO" "Outputs for $use_case:"
        terraform output -no-color | sed 's/^/    /'
    fi
    
    return 0
}

# Main execution
print_status "INFO" "Starting test execution..."
print_status "INFO" "Environment: $ENVIRONMENT"
print_status "INFO" "Use Case: $USE_CASE"

# Dry run mode indication
if [ "$DRY_RUN" = true ]; then
    print_status "INFO" "DRY RUN MODE - No changes will be applied"
fi

# Change to environment directory
cd "$ENV_DIR"

# Create work directory
mkdir -p work

# Determine use cases to run
declare -a USE_CASES_TO_RUN
if [ "$USE_CASE" = "all" ]; then
    mapfile -t USE_CASES_TO_RUN < <(get_available_use_cases)
    print_status "INFO" "Running all available use cases: ${USE_CASES_TO_RUN[*]}"
else
    USE_CASES_TO_RUN=("$USE_CASE")
fi

# Run use cases
TOTAL_CASES=${#USE_CASES_TO_RUN[@]}
SUCCESSFUL_CASES=0
FAILED_CASES=0

print_status "INFO" "Executing $TOTAL_CASES use case(s)..."

for use_case in "${USE_CASES_TO_RUN[@]}"; do
    if run_use_case "$use_case" "$ENV_DIR"; then
        ((SUCCESSFUL_CASES++))
    else
        ((FAILED_CASES++))
        if [ "$ENVIRONMENT" = "production" ]; then
            print_status "ERROR" "Production execution failed. Stopping for safety."
            break
        fi
    fi
done

# Summary
echo ""
print_status "INFO" "Execution Summary:"
echo "  Total use cases: $TOTAL_CASES"
echo "  Successful: $SUCCESSFUL_CASES"
echo "  Failed: $FAILED_CASES"

if [ $FAILED_CASES -eq 0 ]; then
    print_status "SUCCESS" "All use cases completed successfully!"
    exit 0
else
    print_status "ERROR" "$FAILED_CASES use case(s) failed"
    exit 1
fi