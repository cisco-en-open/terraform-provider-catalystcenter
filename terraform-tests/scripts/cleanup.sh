#!/bin/bash

# Cleanup Script
# Cleans up resources in specified inventory environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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
    else
        echo "  [$timestamp] $2"
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
    echo "  --dry-run        - Show what would be destroyed without executing"
    echo "  --auto-approve   - Skip interactive approval for destroy"
    echo "  --use-case <name> - Clean up specific use case only"
    echo "  --state-only     - Clean up state files only (no resource destroy)"
    echo "  --force          - Force cleanup even with errors"
    echo "  --backup         - Create backup before cleanup"
    echo "  --help           - Display this help message"
    echo ""
    echo "Examples:"
    echo "  $0 dev                         # Clean up dev environment"
    echo "  $0 staging --dry-run           # Show what would be cleaned"
    echo "  $0 dev --use-case site-hierarchy # Clean specific use case"
    echo "  $0 production --backup --dry-run # Backup and show cleanup plan"
    echo ""
    echo "⚠️  WARNING: This will destroy Terraform resources!"
    echo "   Always run with --dry-run first to review what will be destroyed."
}

# Initialize variables
ENVIRONMENT=""
DRY_RUN=false
AUTO_APPROVE=false
USE_CASE=""
STATE_ONLY=false
FORCE=false
BACKUP=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        dev|staging|production)
            ENVIRONMENT="$1"
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --auto-approve)
            AUTO_APPROVE=true
            shift
            ;;
        --use-case)
            USE_CASE="$2"
            shift 2
            ;;
        --state-only)
            STATE_ONLY=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --backup)
            BACKUP=true
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

# Check if environment exists
ENV_DIR="$INVENTORY_DIR/$ENVIRONMENT"
if [ ! -d "$ENV_DIR" ]; then
    print_status "ERROR" "Environment '$ENVIRONMENT' does not exist"
    exit 1
fi

# Production safety checks
if [ "$ENVIRONMENT" = "production" ]; then
    if [ "$DRY_RUN" != true ]; then
        print_status "WARNING" "⚠️  PRODUCTION ENVIRONMENT CLEANUP ⚠️"
        print_status "WARNING" "This will DESTROY production resources!"
        print_status "WARNING" "Ensure you have proper approvals and change management approval"
        echo ""
        
        if [ "$AUTO_APPROVE" != true ]; then
            read -p "Do you have approval to proceed with production resource destruction? (yes/no): " -r
            if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
                print_status "INFO" "Operation cancelled by user"
                exit 0
            fi
            
            read -p "Type 'DESTROY PRODUCTION' to confirm: " -r
            if [ "$REPLY" != "DESTROY PRODUCTION" ]; then
                print_status "INFO" "Operation cancelled - confirmation text did not match"
                exit 0
            fi
        fi
    fi
    
    # Force backup in production
    BACKUP=true
fi

print_status "INFO" "Starting cleanup for environment: $ENVIRONMENT"

# Change to environment directory
cd "$ENV_DIR"

# Create backup if requested
if [ "$BACKUP" = true ]; then
    local backup_dir="backups/$(date '+%Y%m%d_%H%M%S')"
    mkdir -p "$backup_dir"
    
    print_status "INFO" "Creating backup in: $backup_dir"
    
    # Backup terraform.tfvars
    if [ -f "terraform.tfvars" ]; then
        cp "terraform.tfvars" "$backup_dir/"
        print_status "SUCCESS" "Backed up terraform.tfvars"
    fi
    
    # Backup state files
    if [ -d ".terraform" ]; then
        cp -r ".terraform" "$backup_dir/"
        print_status "SUCCESS" "Backed up .terraform directory"
    fi
    
    # Backup work directory
    if [ -d "work" ]; then
        cp -r "work" "$backup_dir/"
        print_status "SUCCESS" "Backed up work directory"
    fi
fi

# Function to cleanup a use case
cleanup_use_case() {
    local use_case=$1
    local work_dir="work/$use_case"
    
    if [ ! -d "$work_dir" ]; then
        print_status "WARNING" "Use case '$use_case' work directory not found"
        return 0
    fi
    
    print_status "INFO" "Cleaning up use case: $use_case"
    
    cd "$work_dir"
    
    # Check if there's a terraform state
    if [ ! -f "terraform.tfstate" ] && [ ! -f ".terraform/terraform.tfstate" ]; then
        print_status "INFO" "No state found for $use_case, skipping terraform destroy"
    else
        if [ "$STATE_ONLY" != true ]; then
            # Run terraform destroy
            print_status "INFO" "Running terraform destroy for $use_case..."
            
            local destroy_args="-no-color"
            if [ "$AUTO_APPROVE" = true ] || [ "$ENVIRONMENT" = "dev" ]; then
                destroy_args="$destroy_args -auto-approve"
            fi
            
            if [ "$DRY_RUN" = true ]; then
                print_status "INFO" "DRY RUN: Would run terraform destroy for $use_case"
                terraform plan -destroy -no-color | head -20
                print_status "INFO" "... (output truncated for dry run)"
            else
                if terraform destroy $destroy_args; then
                    print_status "SUCCESS" "Successfully destroyed resources for $use_case"
                else
                    print_status "ERROR" "Failed to destroy resources for $use_case"
                    if [ "$FORCE" != true ]; then
                        return 1
                    fi
                fi
            fi
        fi
    fi
    
    # Clean up state files
    if [ "$DRY_RUN" = true ]; then
        print_status "INFO" "DRY RUN: Would remove state files for $use_case"
    else
        if [ -f "terraform.tfstate" ]; then
            rm -f terraform.tfstate terraform.tfstate.backup
            print_status "SUCCESS" "Removed state files for $use_case"
        fi
        
        if [ -d ".terraform" ]; then
            rm -rf ".terraform"
            print_status "SUCCESS" "Removed .terraform directory for $use_case"
        fi
        
        # Remove plan files
        rm -f *.tfplan
        rm -f *.log
    fi
    
    cd - > /dev/null
    
    # Remove work directory
    if [ "$DRY_RUN" = true ]; then
        print_status "INFO" "DRY RUN: Would remove work directory for $use_case"
    else
        rm -rf "$work_dir"
        print_status "SUCCESS" "Removed work directory for $use_case"
    fi
    
    return 0
}

# Determine use cases to clean up
if [ -n "$USE_CASE" ]; then
    # Clean up specific use case
    if cleanup_use_case "$USE_CASE"; then
        print_status "SUCCESS" "Cleanup completed for use case: $USE_CASE"
    else
        print_status "ERROR" "Cleanup failed for use case: $USE_CASE"
        exit 1
    fi
else
    # Clean up all use cases
    if [ -d "work" ]; then
        local use_cases=($(ls -1 work/ 2>/dev/null || true))
        
        if [ ${#use_cases[@]} -eq 0 ]; then
            print_status "INFO" "No use cases found to clean up"
        else
            print_status "INFO" "Found ${#use_cases[@]} use case(s) to clean up"
            
            local successful=0
            local failed=0
            
            for use_case in "${use_cases[@]}"; do
                if cleanup_use_case "$use_case"; then
                    ((successful++))
                else
                    ((failed++))
                    if [ "$FORCE" != true ] && [ "$ENVIRONMENT" = "production" ]; then
                        print_status "ERROR" "Stopping cleanup due to failure in production"
                        break
                    fi
                fi
            done
            
            echo ""
            print_status "INFO" "Cleanup Summary:"
            echo "  Total use cases: ${#use_cases[@]}"
            echo "  Successful: $successful"
            echo "  Failed: $failed"
        fi
        
        # Remove work directory if empty or dry run
        if [ "$DRY_RUN" = true ]; then
            print_status "INFO" "DRY RUN: Would remove work directory"
        elif [ -z "$(ls -A work/ 2>/dev/null)" ]; then
            rmdir work
            print_status "SUCCESS" "Removed empty work directory"
        fi
    else
        print_status "INFO" "No work directory found"
    fi
fi

# Clean up environment-level files if requested
if [ "$STATE_ONLY" = true ] || [ -z "$USE_CASE" ]; then
    if [ "$DRY_RUN" = true ]; then
        print_status "INFO" "DRY RUN: Would clean up environment-level state files"
    else
        # Clean up .terraform directory
        if [ -d ".terraform" ]; then
            rm -rf ".terraform"
            print_status "SUCCESS" "Removed environment .terraform directory"
        fi
        
        # Clean up log files
        rm -f *.log
        print_status "SUCCESS" "Removed log files"
    fi
fi

# Final status
if [ "$DRY_RUN" = true ]; then
    print_status "SUCCESS" "Dry run completed - no resources were actually destroyed"
    print_status "INFO" "Review the output above and run without --dry-run to execute cleanup"
else
    print_status "SUCCESS" "Cleanup completed for environment: $ENVIRONMENT"
fi

# Environment-specific post-cleanup advice
case $ENVIRONMENT in
    "production")
        print_status "INFO" "Production cleanup completed"
        print_status "WARNING" "Verify all resources were properly destroyed in Catalyst Center UI"
        print_status "INFO" "Document this cleanup operation in change management system"
        ;;
    "staging")
        print_status "INFO" "Staging cleanup completed"
        print_status "INFO" "Environment is ready for fresh testing"
        ;;
    "dev")
        print_status "INFO" "Development cleanup completed"
        print_status "INFO" "Auto-cleanup is enabled, but manual cleanup provides more control"
        ;;
esac