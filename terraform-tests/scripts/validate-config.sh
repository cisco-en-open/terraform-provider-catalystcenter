#!/bin/bash

# Validate Configuration Script
# Validates inventory configurations and connectivity

set -e

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

# Script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
INVENTORY_DIR="$PROJECT_ROOT/inventories"

# Function to display usage
usage() {
    echo "Usage: $0 <environment> [options]"
    echo ""
    echo "Environments:"
    echo "  dev        - Development environment"
    echo "  staging    - Staging environment"  
    echo "  production - Production environment"
    echo "  all        - All environments"
    echo ""
    echo "Options:"
    echo "  --connectivity - Test Catalyst Center connectivity"
    echo "  --syntax-only  - Check Terraform syntax only"
    echo "  --verbose      - Enable verbose output"
    echo "  --help         - Display this help message"
    echo ""
    echo "Examples:"
    echo "  $0 dev                    # Validate dev environment"
    echo "  $0 all --connectivity     # Test connectivity for all environments"
    echo "  $0 staging --syntax-only  # Check staging syntax only"
}

# Initialize variables
ENVIRONMENT=""
CHECK_CONNECTIVITY=false
SYNTAX_ONLY=false
VERBOSE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        dev|staging|production|all)
            ENVIRONMENT="$1"
            shift
            ;;
        --connectivity)
            CHECK_CONNECTIVITY=true
            shift
            ;;
        --syntax-only)
            SYNTAX_ONLY=true
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

# Function to validate a single environment
validate_environment() {
    local env=$1
    local env_dir="$INVENTORY_DIR/$env"
    
    print_status "INFO" "Validating environment: $env"
    
    # Check if environment directory exists
    if [ ! -d "$env_dir" ]; then
        print_status "ERROR" "Environment '$env' directory not found"
        return 1
    fi
    
    cd "$env_dir"
    
    # Check for required files
    local required_files=("inventory.tf" "variables.tf")
    for file in "${required_files[@]}"; do
        if [ -f "$file" ]; then
            print_status "SUCCESS" "Found required file: $file"
        else
            print_status "ERROR" "Missing required file: $file"
            return 1
        fi
    done
    
    # Check for terraform.tfvars
    if [ -f "terraform.tfvars" ]; then
        print_status "SUCCESS" "Found terraform.tfvars"
        
        # Validate required variables
        local required_vars=("catalyst_username" "catalyst_password" "catalyst_base_url")
        for var in "${required_vars[@]}"; do
            if grep -q "^${var}\s*=" terraform.tfvars; then
                print_status "SUCCESS" "Found required variable: $var"
            else
                print_status "ERROR" "Missing required variable: $var"
                return 1
            fi
        done
    elif [ -f "terraform.tfvars.example" ]; then
        print_status "WARNING" "terraform.tfvars not found, but example exists"
        print_status "INFO" "Run: cp terraform.tfvars.example terraform.tfvars"
    else
        print_status "ERROR" "No terraform.tfvars or example file found"
        return 1
    fi
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        print_status "ERROR" "Terraform is not installed or not in PATH"
        return 1
    fi
    
    # Check if initialized
    if [ ! -d ".terraform" ]; then
        print_status "WARNING" "Terraform not initialized"
        print_status "INFO" "Run: ../scripts/setup-inventory.sh $env"
    else
        print_status "SUCCESS" "Terraform initialized"
    fi
    
    # Validate Terraform syntax
    print_status "INFO" "Validating Terraform syntax..."
    if terraform validate -no-color > /dev/null 2>&1; then
        print_status "SUCCESS" "Terraform syntax is valid"
    else
        print_status "ERROR" "Terraform syntax validation failed"
        if [ "$VERBOSE" = true ]; then
            terraform validate -no-color
        fi
        return 1
    fi
    
    # Format check
    if terraform fmt -check -no-color > /dev/null 2>&1; then
        print_status "SUCCESS" "Terraform formatting is correct"
    else
        print_status "WARNING" "Terraform files need formatting"
        if [ "$VERBOSE" = true ]; then
            terraform fmt -check -no-color
        fi
    fi
    
    # Stop here if syntax-only
    if [ "$SYNTAX_ONLY" = true ]; then
        print_status "SUCCESS" "Syntax validation completed for $env"
        return 0
    fi
    
    # Test Terraform plan (dry run)
    print_status "INFO" "Testing Terraform plan..."
    if terraform plan -no-color -detailed-exitcode > /dev/null 2>&1; then
        local plan_exit=$?
        if [ $plan_exit -eq 0 ]; then
            print_status "SUCCESS" "Terraform plan successful (no changes)"
        elif [ $plan_exit -eq 2 ]; then
            print_status "SUCCESS" "Terraform plan successful (changes detected)"
        fi
    else
        print_status "ERROR" "Terraform plan failed"
        if [ "$VERBOSE" = true ]; then
            terraform plan -no-color
        fi
        return 1
    fi
    
    # Connectivity test
    if [ "$CHECK_CONNECTIVITY" = true ] && [ -f "terraform.tfvars" ]; then
        print_status "INFO" "Testing Catalyst Center connectivity..."
        
        # Extract connection details
        local base_url=$(grep '^catalyst_base_url' terraform.tfvars | cut -d'"' -f2)
        local username=$(grep '^catalyst_username' terraform.tfvars | cut -d'"' -f2)
        local ssl_verify=$(grep '^catalyst_ssl_verify' terraform.tfvars | cut -d'=' -f2 | tr -d ' "')
        
        if [ -n "$base_url" ]; then
            print_status "INFO" "Testing connectivity to: $base_url"
            
            # Basic connectivity test
            local curl_args="-s -w %{http_code} -o /dev/null --connect-timeout 10"
            if [ "$ssl_verify" = "false" ]; then
                curl_args="$curl_args -k"
            fi
            
            local http_code=$(curl $curl_args "$base_url/dna/system/api/v1/auth/token" 2>/dev/null || echo "000")
            
            case $http_code in
                200|401|403)
                    print_status "SUCCESS" "Catalyst Center is reachable (HTTP $http_code)"
                    ;;
                000)
                    print_status "ERROR" "Cannot connect to Catalyst Center"
                    ;;
                *)
                    print_status "WARNING" "Catalyst Center responded with HTTP $http_code"
                    ;;
            esac
        else
            print_status "WARNING" "No base URL found for connectivity test"
        fi
    fi
    
    # Environment-specific validations
    case $env in
        "dev")
            # Check dev-specific settings
            if grep -q 'catalyst_debug.*=.*true' terraform.tfvars; then
                print_status "SUCCESS" "Debug mode enabled for development"
            else
                print_status "WARNING" "Consider enabling debug mode for development"
            fi
            ;;
        "staging")
            # Check staging-specific settings
            if grep -q 'catalyst_ssl_verify.*=.*true' terraform.tfvars; then
                print_status "SUCCESS" "SSL verification enabled for staging"
            else
                print_status "WARNING" "Consider enabling SSL verification for staging"
            fi
            ;;
        "production")
            # Check production-specific settings
            if grep -q 'catalyst_debug.*=.*false' terraform.tfvars; then
                print_status "SUCCESS" "Debug mode disabled for production"
            else
                print_status "ERROR" "Debug mode should be disabled in production"
                return 1
            fi
            
            if grep -q 'catalyst_ssl_verify.*=.*true' terraform.tfvars; then
                print_status "SUCCESS" "SSL verification enabled for production"
            else
                print_status "ERROR" "SSL verification must be enabled in production"
                return 1
            fi
            ;;
    esac
    
    print_status "SUCCESS" "Environment '$env' validation completed"
    return 0
}

# Main execution
print_status "INFO" "Starting configuration validation..."

# Determine environments to validate
declare -a ENVIRONMENTS
if [ "$ENVIRONMENT" = "all" ]; then
    mapfile -t ENVIRONMENTS < <(ls -1 "$INVENTORY_DIR")
    print_status "INFO" "Validating all environments: ${ENVIRONMENTS[*]}"
else
    ENVIRONMENTS=("$ENVIRONMENT")
fi

# Validate environments
TOTAL_ENVS=${#ENVIRONMENTS[@]}
SUCCESSFUL_ENVS=0
FAILED_ENVS=0

for env in "${ENVIRONMENTS[@]}"; do
    echo ""
    if validate_environment "$env"; then
        ((SUCCESSFUL_ENVS++))
    else
        ((FAILED_ENVS++))
    fi
done

# Summary
echo ""
print_status "INFO" "Validation Summary:"
echo "  Total environments: $TOTAL_ENVS"
echo "  Successful: $SUCCESSFUL_ENVS"
echo "  Failed: $FAILED_ENVS"

if [ $FAILED_ENVS -eq 0 ]; then
    print_status "SUCCESS" "All environments validated successfully!"
    exit 0
else
    print_status "ERROR" "$FAILED_ENVS environment(s) failed validation"
    exit 1
fi