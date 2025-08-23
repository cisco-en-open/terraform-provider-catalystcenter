#!/bin/bash

# Setup Inventory Script
# Initializes a specific inventory environment for testing

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
    echo ""
    echo "Options:"
    echo "  --force    - Force initialization even if already initialized"
    echo "  --validate - Run validation checks after initialization"
    echo "  --help     - Display this help message"
    echo ""
    echo "Examples:"
    echo "  $0 dev                    # Initialize development environment"
    echo "  $0 staging --validate     # Initialize staging and validate"
    echo "  $0 production --force     # Force re-initialize production"
}

# Parse arguments
ENVIRONMENT=""
FORCE=false
VALIDATE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        dev|staging|production)
            ENVIRONMENT="$1"
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --validate)
            VALIDATE=true
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

# Check if environment directory exists
ENV_DIR="$INVENTORY_DIR/$ENVIRONMENT"
if [ ! -d "$ENV_DIR" ]; then
    print_status "ERROR" "Environment '$ENVIRONMENT' does not exist"
    print_status "INFO" "Available environments: $(ls -1 "$INVENTORY_DIR" | tr '\n' ' ')"
    exit 1
fi

print_status "INFO" "Setting up $ENVIRONMENT environment..."

# Check if already initialized (unless force is specified)
if [ -f "$ENV_DIR/.terraform/terraform.tfstate" ] && [ "$FORCE" != true ]; then
    print_status "WARNING" "Environment already initialized. Use --force to re-initialize"
    exit 0
fi

# Check for terraform.tfvars file
if [ ! -f "$ENV_DIR/terraform.tfvars" ]; then
    print_status "WARNING" "terraform.tfvars not found"
    if [ -f "$ENV_DIR/terraform.tfvars.example" ]; then
        print_status "INFO" "Creating terraform.tfvars from example..."
        cp "$ENV_DIR/terraform.tfvars.example" "$ENV_DIR/terraform.tfvars"
        print_status "WARNING" "Please edit $ENV_DIR/terraform.tfvars with your Catalyst Center details"
        print_status "INFO" "Required fields: catalyst_username, catalyst_password, catalyst_base_url"
    else
        print_status "ERROR" "No terraform.tfvars.example found"
        exit 1
    fi
fi

# Change to environment directory
cd "$ENV_DIR"

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    print_status "ERROR" "Terraform is not installed or not in PATH"
    exit 1
fi

# Initialize Terraform
print_status "INFO" "Initializing Terraform..."
if terraform init -no-color; then
    print_status "SUCCESS" "Terraform initialized successfully"
else
    print_status "ERROR" "Terraform initialization failed"
    exit 1
fi

# Validate Terraform configuration
print_status "INFO" "Validating Terraform configuration..."
if terraform validate -no-color; then
    print_status "SUCCESS" "Terraform configuration is valid"
else
    print_status "ERROR" "Terraform configuration validation failed"
    exit 1
fi

# Format Terraform files
print_status "INFO" "Formatting Terraform files..."
if terraform fmt -recursive -no-color; then
    print_status "SUCCESS" "Terraform files formatted"
else
    print_status "WARNING" "Terraform formatting had issues"
fi

# Run validation if requested
if [ "$VALIDATE" = true ]; then
    print_status "INFO" "Running validation checks..."
    
    # Check terraform plan
    if terraform plan -no-color -detailed-exitcode > /dev/null 2>&1; then
        print_status "SUCCESS" "Terraform plan validation passed"
    elif [ $? -eq 2 ]; then
        print_status "INFO" "Terraform plan shows changes (expected for new environment)"
    else
        print_status "ERROR" "Terraform plan validation failed"
        exit 1
    fi
    
    # Additional validation for production
    if [ "$ENVIRONMENT" = "production" ]; then
        print_status "WARNING" "PRODUCTION ENVIRONMENT DETECTED"
        print_status "WARNING" "Ensure you have proper approvals before making changes"
        print_status "WARNING" "Follow change management procedures"
    fi
fi

# Create state backup directory if it doesn't exist
mkdir -p "$ENV_DIR/backups"

# Display setup summary
print_status "SUCCESS" "Environment '$ENVIRONMENT' setup completed"
echo ""
print_status "INFO" "Setup Summary:"
echo "  Environment: $ENVIRONMENT"
echo "  Directory: $ENV_DIR"
echo "  Terraform: $(terraform version | head -n1)"
echo "  Configuration: terraform.tfvars"
echo "  State: .terraform/terraform.tfstate"
echo ""

# Next steps
print_status "INFO" "Next steps:"
echo "1. Edit terraform.tfvars with your Catalyst Center details"
echo "2. Run: ../scripts/validate-config.sh $ENVIRONMENT"
echo "3. Run: ../scripts/run-test.sh $ENVIRONMENT <use-case>"
echo ""

# Environment-specific warnings
case $ENVIRONMENT in
    "production")
        print_status "WARNING" "PRODUCTION ENVIRONMENT WARNINGS:"
        echo "  ⚠ All changes affect production systems"
        echo "  ⚠ Follow change management procedures"
        echo "  ⚠ Ensure proper approvals before execution"
        echo "  ⚠ Test in dev/staging first"
        ;;
    "staging")
        print_status "INFO" "Staging environment best practices:"
        echo "  • Test complete workflows before production"
        echo "  • Validate SSL and security configurations"
        echo "  • Run performance and scale tests"
        ;;
    "dev")
        print_status "INFO" "Development environment tips:"
        echo "  • Debug mode is enabled for troubleshooting"
        echo "  • SSL verification is disabled for lab environments"
        echo "  • Auto-cleanup is enabled to prevent resource accumulation"
        ;;
esac

print_status "SUCCESS" "Environment setup complete!"