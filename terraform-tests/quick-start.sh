#!/bin/bash

# Quick Start Script
# Provides an interactive setup experience for new users

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${CYAN}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║            Terraform Provider Catalyst Center               ║"
    echo "║                    Test Suite Quick Start                   ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_status() {
    if [ "$1" = "SUCCESS" ]; then
        echo -e "${GREEN}✓ $2${NC}"
    elif [ "$1" = "WARNING" ]; then
        echo -e "${YELLOW}⚠ $2${NC}"
    elif [ "$1" = "ERROR" ]; then
        echo -e "${RED}✗ $2${NC}"
    elif [ "$1" = "INFO" ]; then
        echo -e "${BLUE}ℹ $2${NC}"
    elif [ "$1" = "STEP" ]; then
        echo -e "${CYAN}${BOLD}▶ $2${NC}"
    else
        echo "  $2"
    fi
}

# Script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

print_header

echo "Welcome to the Terraform Provider Catalyst Center Test Suite!"
echo "This interactive setup will guide you through getting started."
echo ""

# Step 1: Choose environment
print_status "STEP" "Step 1: Choose Environment"
echo "Available environments:"
echo "  1) dev        - Development (recommended for first-time users)"
echo "  2) staging    - Staging"
echo "  3) production - Production (use with extreme caution)"
echo ""

while true; do
    read -p "Select environment (1-3): " choice
    case $choice in
        1)
            ENVIRONMENT="dev"
            print_status "INFO" "Selected: Development environment"
            break
            ;;
        2)
            ENVIRONMENT="staging"
            print_status "INFO" "Selected: Staging environment"
            break
            ;;
        3)
            ENVIRONMENT="production"
            print_status "WARNING" "Selected: Production environment"
            print_status "WARNING" "Production environment requires proper approvals!"
            read -p "Are you sure you want to use production? (yes/no): " confirm
            if [[ $confirm =~ ^[Yy][Ee][Ss]$ ]]; then
                break
            fi
            ;;
        *)
            print_status "ERROR" "Invalid selection. Please choose 1, 2, or 3."
            ;;
    esac
done

echo ""

# Step 2: Check prerequisites
print_status "STEP" "Step 2: Checking Prerequisites"

# Check Terraform
if command -v terraform &> /dev/null; then
    TERRAFORM_VERSION=$(terraform version | head -n1)
    print_status "SUCCESS" "Terraform found: $TERRAFORM_VERSION"
else
    print_status "ERROR" "Terraform not found!"
    echo "Please install Terraform from: https://www.terraform.io/downloads"
    echo "Or use your package manager:"
    echo "  macOS: brew install terraform"
    echo "  Ubuntu/Debian: apt-get install terraform"
    echo "  CentOS/RHEL: yum install terraform"
    exit 1
fi

# Check curl (for connectivity testing)
if command -v curl &> /dev/null; then
    print_status "SUCCESS" "curl found (for connectivity testing)"
else
    print_status "WARNING" "curl not found - connectivity testing will be limited"
fi

echo ""

# Step 3: Initialize environment
print_status "STEP" "Step 3: Initialize Environment"
print_status "INFO" "Initializing $ENVIRONMENT environment..."

if "$PROJECT_ROOT/scripts/setup-inventory.sh" "$ENVIRONMENT" --validate; then
    print_status "SUCCESS" "Environment initialized successfully"
else
    print_status "ERROR" "Environment initialization failed"
    exit 1
fi

echo ""

# Step 4: Configure credentials
print_status "STEP" "Step 4: Configure Catalyst Center Credentials"

ENV_DIR="$PROJECT_ROOT/inventories/$ENVIRONMENT"

if [ ! -f "$ENV_DIR/terraform.tfvars" ]; then
    print_status "INFO" "Creating terraform.tfvars from example..."
    cp "$ENV_DIR/terraform.tfvars.example" "$ENV_DIR/terraform.tfvars"
fi

echo "You need to configure your Catalyst Center credentials."
echo "Current configuration file: $ENV_DIR/terraform.tfvars"
echo ""

while true; do
    read -p "Do you want to configure credentials now? (yes/no): " configure
    if [[ $configure =~ ^[Yy][Ee][Ss]$ ]]; then
        echo ""
        echo "Please enter your Catalyst Center details:"
        
        read -p "Catalyst Center URL (e.g., https://catalyst-center.example.com): " base_url
        read -p "Username: " username
        read -s -p "Password: "
        password=$REPLY
        echo ""
        
        # Update terraform.tfvars
        sed -i.bak "s|catalyst_base_url = \".*\"|catalyst_base_url = \"$base_url\"|" "$ENV_DIR/terraform.tfvars"
        sed -i.bak "s|catalyst_username = \".*\"|catalyst_username = \"$username\"|" "$ENV_DIR/terraform.tfvars"
        sed -i.bak "s|catalyst_password = \".*\"|catalyst_password = \"$password\"|" "$ENV_DIR/terraform.tfvars"
        
        rm -f "$ENV_DIR/terraform.tfvars.bak"
        
        print_status "SUCCESS" "Credentials configured"
        break
    elif [[ $configure =~ ^[Nn][Oo]$ ]]; then
        print_status "INFO" "You can configure credentials later by editing:"
        print_status "INFO" "$ENV_DIR/terraform.tfvars"
        break
    else
        print_status "ERROR" "Please answer yes or no"
    fi
done

echo ""

# Step 5: Test connectivity (if configured)
if [[ $configure =~ ^[Yy][Ee][Ss]$ ]]; then
    print_status "STEP" "Step 5: Test Connectivity"
    print_status "INFO" "Testing connection to Catalyst Center..."
    
    if "$PROJECT_ROOT/scripts/validate-config.sh" "$ENVIRONMENT" --connectivity; then
        print_status "SUCCESS" "Connectivity test passed"
    else
        print_status "WARNING" "Connectivity test failed - please check your credentials and network"
    fi
    echo ""
fi

# Step 6: Choose first use case
print_status "STEP" "Step 6: Choose Your First Use Case"
echo "Available use cases:"
echo "  1) site-hierarchy     - Network site hierarchy (recommended for beginners)"
echo "  2) device-credentials - Device credential management"  
echo "  3) pnp                - Plug and Play device onboarding"
echo "  4) inventory          - Device inventory workflows"
echo "  5) Skip this step"
echo ""

while true; do
    read -p "Select use case to test (1-5): " use_case_choice
    case $use_case_choice in
        1)
            USE_CASE="site-hierarchy"
            break
            ;;
        2)
            USE_CASE="device-credentials"
            break
            ;;
        3)
            USE_CASE="pnp"
            break
            ;;
        4)
            USE_CASE="inventory"
            break
            ;;
        5)
            USE_CASE=""
            print_status "INFO" "Skipping use case testing"
            break
            ;;
        *)
            print_status "ERROR" "Invalid selection. Please choose 1-5."
            ;;
    esac
done

if [ -n "$USE_CASE" ]; then
    echo ""
    print_status "INFO" "Selected use case: $USE_CASE"
    
    # Ask about dry run
    read -p "Run in dry-run mode first? (recommended) (yes/no): " dry_run
    
    if [[ $dry_run =~ ^[Yy][Ee][Ss]$ ]]; then
        print_status "INFO" "Running dry-run for $USE_CASE..."
        if "$PROJECT_ROOT/scripts/run-test.sh" "$ENVIRONMENT" "$USE_CASE" --dry-run; then
            print_status "SUCCESS" "Dry run completed successfully"
            
            read -p "Execute for real? (yes/no): " execute
            if [[ $execute =~ ^[Yy][Ee][Ss]$ ]]; then
                print_status "INFO" "Executing $USE_CASE..."
                "$PROJECT_ROOT/scripts/run-test.sh" "$ENVIRONMENT" "$USE_CASE"
            else
                print_status "INFO" "Skipping execution"
            fi
        else
            print_status "ERROR" "Dry run failed - check your configuration"
        fi
    else
        print_status "INFO" "Executing $USE_CASE directly..."
        "$PROJECT_ROOT/scripts/run-test.sh" "$ENVIRONMENT" "$USE_CASE"
    fi
fi

echo ""

# Final instructions
print_status "STEP" "Setup Complete!"
echo ""
echo "🎉 Quick start setup is complete! Here's what you can do next:"
echo ""
echo "📝 Documentation:"
echo "   README.md                    - Main project documentation"
echo "   examples/basic-workflow.md   - Basic workflow examples"
echo "   examples/advanced-scenarios.md - Advanced scenarios"
echo ""
echo "🔧 Available commands:"
echo "   ./scripts/validate-config.sh $ENVIRONMENT              - Validate configuration"
echo "   ./scripts/run-test.sh $ENVIRONMENT <use-case>          - Run specific use case"
echo "   ./scripts/run-test.sh $ENVIRONMENT all                 - Run all use cases"
echo "   ./scripts/cleanup.sh $ENVIRONMENT                      - Clean up resources"
echo ""
echo "🧪 Available use cases:"
echo "   site-hierarchy, device-credentials, pnp, inventory,"
echo "   network-settings, device-discovery, provision, swim"
echo ""
echo "💡 Pro tips:"
echo "   • Always use --dry-run first to preview changes"
echo "   • Use --validate flag to run validation-only mode"
echo "   • Check work/ directory for detailed terraform output"
echo "   • Create backups before major operations"
echo ""
echo "🔐 Environment: $ENVIRONMENT"
echo "📁 Configuration: $ENV_DIR/terraform.tfvars"
echo ""

if [ "$ENVIRONMENT" = "production" ]; then
    print_status "WARNING" "Remember: You're using PRODUCTION environment!"
    print_status "WARNING" "Always follow change management procedures!"
fi

print_status "SUCCESS" "Happy testing! 🚀"