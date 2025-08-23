# Advanced Scenarios

This document covers advanced testing scenarios and complex workflows for the Terraform Provider Catalyst Center Test Suite.

## Scenario 1: Multi-Environment Orchestration

Coordinating tests across multiple environments with dependencies.

### Setup Multi-Environment Pipeline

```bash
#!/bin/bash
# advanced-pipeline.sh

set -e

ENVIRONMENTS=("dev" "staging")
USE_CASES=("site-hierarchy" "device-credentials" "pnp")

# Initialize all environments
for env in "${ENVIRONMENTS[@]}"; do
    echo "Setting up $env environment..."
    ./scripts/setup-inventory.sh $env --validate
done

# Progressive testing
for use_case in "${USE_CASES[@]}"; do
    for env in "${ENVIRONMENTS[@]}"; do
        echo "Testing $use_case in $env..."
        
        # Run with validation
        ./scripts/run-test.sh $env $use_case --validate
        
        # Wait for manual approval for staging
        if [ "$env" = "staging" ]; then
            read -p "Approve staging deployment of $use_case? (y/n): " -r
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo "Skipping $use_case in staging"
                continue
            fi
        fi
        
        # Execute
        ./scripts/run-test.sh $env $use_case
        
        # Validate results
        echo "Validating $use_case results in $env..."
        # Add custom validation logic here
    done
done
```

### Environment Dependency Management

```bash
# Check if development tests pass before staging
if ./scripts/run-test.sh dev site-hierarchy --validate; then
    echo "Dev tests passed, proceeding to staging..."
    ./scripts/run-test.sh staging site-hierarchy --validate
else
    echo "Dev tests failed, stopping pipeline"
    exit 1
fi
```

## Scenario 2: Custom Validation and Testing

Creating custom validation scripts and test cases.

### Custom Validation Script

```bash
#!/bin/bash
# custom-validation.sh

validate_site_hierarchy() {
    local env=$1
    local work_dir="inventories/$env/work/site-hierarchy"
    
    if [ ! -d "$work_dir" ]; then
        echo "Site hierarchy not deployed in $env"
        return 1
    fi
    
    cd "$work_dir"
    
    # Check if outputs exist
    if ! terraform output > /dev/null 2>&1; then
        echo "No terraform outputs found"
        return 1
    fi
    
    # Validate specific outputs
    local area_count=$(terraform output -json | jq '.areas.value | length')
    local building_count=$(terraform output -json | jq '.buildings.value | length')
    
    echo "Found $area_count areas and $building_count buildings"
    
    # Custom validation logic
    if [ "$area_count" -lt 3 ]; then
        echo "Expected at least 3 areas, found $area_count"
        return 1
    fi
    
    if [ "$building_count" -lt 5 ]; then
        echo "Expected at least 5 buildings, found $building_count"
        return 1
    fi
    
    echo "Site hierarchy validation passed"
    return 0
}

# Usage
validate_site_hierarchy dev
```

### Performance Testing Script

```bash
#!/bin/bash
# performance-test.sh

performance_test() {
    local env=$1
    local use_case=$2
    
    echo "Starting performance test for $use_case in $env"
    
    # Record start time
    local start_time=$(date +%s)
    
    # Run the use case
    if ./scripts/run-test.sh $env $use_case; then
        # Record end time
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        echo "Performance Result:"
        echo "  Use Case: $use_case"
        echo "  Environment: $env"
        echo "  Duration: ${duration}s"
        
        # Log to performance file
        echo "$(date),$env,$use_case,$duration" >> performance.log
        
        return 0
    else
        echo "Performance test failed for $use_case in $env"
        return 1
    fi
}

# Run performance tests
for use_case in site-hierarchy pnp device-credentials; do
    performance_test dev $use_case
done
```

## Scenario 3: Integration Testing

Testing interactions between multiple use cases and dependencies.

### Dependency Testing

```bash
#!/bin/bash
# integration-test.sh

integration_test_sequence() {
    local env=$1
    
    echo "Starting integration test sequence in $env"
    
    # Step 1: Setup site hierarchy (prerequisite)
    echo "Step 1: Setting up site hierarchy..."
    if ! ./scripts/run-test.sh $env site-hierarchy; then
        echo "Failed to setup site hierarchy"
        return 1
    fi
    
    # Step 2: Setup device credentials (depends on sites)
    echo "Step 2: Setting up device credentials..."
    if ! ./scripts/run-test.sh $env device-credentials; then
        echo "Failed to setup device credentials"
        return 1
    fi
    
    # Step 3: Test device discovery (depends on credentials and sites)
    echo "Step 3: Testing device discovery..."
    if ! ./scripts/run-test.sh $env device-discovery; then
        echo "Failed device discovery test"
        return 1
    fi
    
    # Step 4: Test PnP (depends on everything above)
    echo "Step 4: Testing PnP workflow..."
    if ! ./scripts/run-test.sh $env pnp; then
        echo "Failed PnP test"
        return 1
    fi
    
    echo "Integration test sequence completed successfully"
    return 0
}

# Run integration tests
integration_test_sequence dev
```

### Cross-Use-Case Validation

```bash
#!/bash
# cross-validation.sh

validate_integration() {
    local env=$1
    
    echo "Validating integration between use cases..."
    
    # Check that sites exist before credentials are assigned
    if [ -d "inventories/$env/work/site-hierarchy" ] && [ -d "inventories/$env/work/device-credentials" ]; then
        cd "inventories/$env/work/site-hierarchy"
        local site_ids=$(terraform output -json | jq -r '.sites.value[].id')
        
        cd "../device-credentials"
        local assigned_sites=$(terraform output -json | jq -r '.credential_assignments.value[].site_id')
        
        # Validate that all assigned sites exist
        for site_id in $assigned_sites; do
            if ! echo "$site_ids" | grep -q "$site_id"; then
                echo "Warning: Credential assigned to non-existent site: $site_id"
            fi
        done
    fi
}
```

## Scenario 4: Disaster Recovery and Rollback

Handling failures and implementing recovery procedures.

### Backup Strategy

```bash
#!/bin/bash
# backup-strategy.sh

create_comprehensive_backup() {
    local env=$1
    local backup_name="backup_$(date +%Y%m%d_%H%M%S)"
    local backup_dir="inventories/$env/backups/$backup_name"
    
    mkdir -p "$backup_dir"
    
    echo "Creating comprehensive backup: $backup_name"
    
    # Backup configurations
    cp "inventories/$env/terraform.tfvars" "$backup_dir/"
    cp "inventories/$env/inventory.tf" "$backup_dir/"
    cp "inventories/$env/variables.tf" "$backup_dir/"
    
    # Backup all use case states
    if [ -d "inventories/$env/work" ]; then
        cp -r "inventories/$env/work" "$backup_dir/"
    fi
    
    # Export terraform states to JSON
    for use_case_dir in inventories/$env/work/*/; do
        if [ -d "$use_case_dir" ]; then
            use_case=$(basename "$use_case_dir")
            cd "$use_case_dir"
            
            if [ -f "terraform.tfstate" ]; then
                terraform show -json > "$backup_dir/work/$use_case/state.json" 2>/dev/null || true
            fi
            
            cd - > /dev/null
        fi
    done
    
    echo "Backup created: $backup_dir"
    return 0
}

restore_from_backup() {
    local env=$1
    local backup_name=$2
    local backup_dir="inventories/$env/backups/$backup_name"
    
    if [ ! -d "$backup_dir" ]; then
        echo "Backup not found: $backup_dir"
        return 1
    fi
    
    echo "Restoring from backup: $backup_name"
    
    # Confirm restore operation
    read -p "This will overwrite current configuration. Continue? (yes/no): " -r
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        echo "Restore cancelled"
        return 1
    fi
    
    # Restore configurations
    cp "$backup_dir/terraform.tfvars" "inventories/$env/"
    cp "$backup_dir/inventory.tf" "inventories/$env/"
    cp "$backup_dir/variables.tf" "inventories/$env/"
    
    # Restore work directory
    if [ -d "$backup_dir/work" ]; then
        rm -rf "inventories/$env/work"
        cp -r "$backup_dir/work" "inventories/$env/"
    fi
    
    echo "Restore completed from: $backup_name"
    return 0
}
```

### Rollback Procedures

```bash
#!/bin/bash
# rollback.sh

rollback_use_case() {
    local env=$1
    local use_case=$2
    local work_dir="inventories/$env/work/$use_case"
    
    echo "Rolling back $use_case in $env environment..."
    
    if [ ! -d "$work_dir" ]; then
        echo "No deployment found for $use_case"
        return 1
    fi
    
    cd "$work_dir"
    
    # Check if there's a previous state backup
    if [ -f "terraform.tfstate.backup" ]; then
        echo "Found previous state backup"
        
        # Create current state backup before rollback
        cp terraform.tfstate terraform.tfstate.pre-rollback
        
        # Restore previous state
        cp terraform.tfstate.backup terraform.tfstate
        
        # Apply the previous state
        terraform apply -auto-approve -refresh=false
        
        echo "Rollback completed for $use_case"
        return 0
    else
        echo "No previous state backup found"
        
        # Alternative: destroy current resources
        read -p "No backup found. Destroy current resources? (yes/no): " -r
        if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
            terraform destroy -auto-approve
            echo "Resources destroyed for $use_case"
            return 0
        else
            echo "Rollback cancelled"
            return 1
        fi
    fi
}
```

## Scenario 5: Load Testing and Scale Validation

Testing provider performance under load.

### Concurrent Testing Script

```bash
#!/bin/bash
# load-test.sh

concurrent_test() {
    local env=$1
    local concurrent_limit=${2:-3}
    
    echo "Starting concurrent load test (limit: $concurrent_limit)"
    
    # List of use cases to test concurrently
    local use_cases=("site-hierarchy" "device-credentials" "network-settings")
    
    # Function to run a single use case
    run_single_test() {
        local use_case=$1
        local test_id=$2
        
        echo "Starting test $test_id for $use_case"
        
        # Create unique working directory
        local work_dir="inventories/$env/work/${use_case}_${test_id}"
        mkdir -p "$work_dir"
        
        # Copy use case files
        cp -r ../examples/use-cases/$use_case/* "$work_dir/"
        
        # Modify resource names to avoid conflicts
        sed -i "s/\"${use_case}\"/\"${use_case}_${test_id}\"/g" "$work_dir/main.tf"
        
        cd "$work_dir"
        
        # Run terraform
        terraform init > init_${test_id}.log 2>&1
        terraform plan -out=plan_${test_id}.tfplan > plan_${test_id}.log 2>&1
        terraform apply plan_${test_id}.tfplan > apply_${test_id}.log 2>&1
        
        local result=$?
        echo "Test $test_id for $use_case completed with exit code: $result"
        
        cd - > /dev/null
        return $result
    }
    
    # Start concurrent tests
    local pids=()
    local test_counter=1
    
    for use_case in "${use_cases[@]}"; do
        for ((i=1; i<=concurrent_limit; i++)); do
            run_single_test "$use_case" "${test_counter}" &
            pids+=($!)
            ((test_counter++))
            
            # Slight delay to stagger starts
            sleep 5
        done
    done
    
    # Wait for all tests to complete
    local failed_tests=0
    for pid in "${pids[@]}"; do
        if ! wait "$pid"; then
            ((failed_tests++))
        fi
    done
    
    echo "Concurrent test completed. Failed tests: $failed_tests"
    return $failed_tests
}
```

### Resource Usage Monitoring

```bash
#!/bin/bash
# monitor-resources.sh

monitor_test_execution() {
    local env=$1
    local use_case=$2
    local work_dir="inventories/$env/work/$use_case"
    local monitor_file="resource_usage_${env}_${use_case}.log"
    
    echo "Starting resource monitoring for $use_case in $env"
    
    # Start monitoring in background
    (
        echo "timestamp,cpu_percent,memory_mb,disk_io" > "$monitor_file"
        
        while true; do
            local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
            local cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
            local memory=$(free -m | awk 'NR==2{printf "%.2f", $3*100/$2}')
            local disk_io=$(iostat -d 1 1 | awk 'NR==4 {print $4}')
            
            echo "$timestamp,$cpu,$memory,$disk_io" >> "$monitor_file"
            
            sleep 10
        done
    ) &
    
    local monitor_pid=$!
    
    # Run the actual test
    ./scripts/run-test.sh "$env" "$use_case"
    local test_result=$?
    
    # Stop monitoring
    kill $monitor_pid 2>/dev/null
    
    echo "Resource monitoring completed. Log: $monitor_file"
    return $test_result
}
```

## Scenario 6: Custom Use Case Development

Creating and testing custom use cases.

### Use Case Template

```bash
#!/bin/bash
# create-custom-use-case.sh

create_use_case() {
    local use_case_name=$1
    local use_case_dir="../examples/use-cases/$use_case_name"
    
    if [ -d "$use_case_dir" ]; then
        echo "Use case $use_case_name already exists"
        return 1
    fi
    
    mkdir -p "$use_case_dir"
    
    # Create main.tf
    cat > "$use_case_dir/main.tf" << EOF
terraform {
  required_providers {
    catalystcenter = {
      version = "1.2.0-beta"
      source  = "cisco-en-programmability/catalystcenter"
    }
  }
}

provider "catalystcenter" {
  username   = var.catalyst_username
  password   = var.catalyst_password
  base_url   = var.catalyst_base_url
  debug      = var.catalyst_debug
  ssl_verify = var.catalyst_ssl_verify
}

# Custom resource definitions go here
resource "catalystcenter_example" "test" {
  # Add your resource configuration
}
EOF
    
    # Create variables.tf
    cat > "$use_case_dir/variables.tf" << EOF
# Include common variables
variable "catalyst_username" {
  description = "Cisco Catalyst Center username"
  type        = string
  sensitive   = true
}

variable "catalyst_password" {
  description = "Cisco Catalyst Center password"
  type        = string
  sensitive   = true
}

variable "catalyst_base_url" {
  description = "Cisco Catalyst Center base URL"
  type        = string
}

variable "catalyst_debug" {
  description = "Enable debugging"
  type        = bool
  default     = false
}

variable "catalyst_ssl_verify" {
  description = "Enable SSL verification"
  type        = bool
  default     = true
}

# Custom variables for this use case
variable "custom_parameter" {
  description = "Custom parameter for $use_case_name"
  type        = string
  default     = "default_value"
}
EOF
    
    # Create outputs.tf
    cat > "$use_case_dir/outputs.tf" << EOF
output "example_output" {
  description = "Example output from $use_case_name"
  value       = catalystcenter_example.test.id
}
EOF
    
    # Create README.md
    cat > "$use_case_dir/README.md" << EOF
# $use_case_name Use Case

Description of this custom use case.

## Overview

What this use case demonstrates...

## Prerequisites

- Catalyst Center access
- Specific requirements...

## Usage

\`\`\`bash
# Initialize environment
../../scripts/setup-inventory.sh dev

# Run this use case
../../scripts/run-test.sh dev $use_case_name
\`\`\`

## Validation

How to validate this use case...
EOF
    
    echo "Created custom use case: $use_case_name"
    echo "Edit the files in: $use_case_dir"
    
    return 0
}

# Usage
create_use_case "my-custom-use-case"
```

### Custom Validation for Use Cases

```bash
#!/bin/bash
# custom-use-case-validator.sh

validate_custom_use_case() {
    local use_case_name=$1
    local use_case_dir="../examples/use-cases/$use_case_name"
    
    if [ ! -d "$use_case_dir" ]; then
        echo "Use case $use_case_name not found"
        return 1
    fi
    
    echo "Validating custom use case: $use_case_name"
    
    # Check required files
    local required_files=("main.tf" "variables.tf" "outputs.tf" "README.md")
    for file in "${required_files[@]}"; do
        if [ ! -f "$use_case_dir/$file" ]; then
            echo "Missing required file: $file"
            return 1
        fi
    done
    
    # Validate Terraform syntax
    cd "$use_case_dir"
    terraform init > /dev/null 2>&1
    terraform validate > /dev/null 2>&1
    local validate_result=$?
    
    if [ $validate_result -eq 0 ]; then
        echo "Terraform validation passed for $use_case_name"
    else
        echo "Terraform validation failed for $use_case_name"
        return 1
    fi
    
    # Check provider configuration
    if grep -q "required_providers" main.tf && grep -q "catalystcenter" main.tf; then
        echo "Provider configuration found"
    else
        echo "Missing or incorrect provider configuration"
        return 1
    fi
    
    echo "Custom use case validation completed successfully"
    return 0
}
```

## Scenario 7: CI/CD Integration

Advanced continuous integration patterns.

### GitHub Actions Workflow

```yaml
# .github/workflows/terraform-tests.yml
name: Terraform Provider Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        environment: [dev, staging]
        use-case: [site-hierarchy, device-credentials, pnp]
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v1
      with:
        terraform_version: 1.5.0
    
    - name: Configure Environment
      run: |
        cd terraform-tests
        ./scripts/setup-inventory.sh ${{ matrix.environment }}
        
        # Configure with secrets
        cat > inventories/${{ matrix.environment }}/terraform.tfvars << EOF
        catalyst_username = "${{ secrets.CATALYST_USERNAME }}"
        catalyst_password = "${{ secrets.CATALYST_PASSWORD }}"
        catalyst_base_url = "${{ secrets.CATALYST_BASE_URL_${{ matrix.environment }} }}"
        EOF
    
    - name: Validate Configuration
      run: |
        cd terraform-tests
        ./scripts/validate-config.sh ${{ matrix.environment }} --connectivity
    
    - name: Run Tests
      run: |
        cd terraform-tests
        ./scripts/run-test.sh ${{ matrix.environment }} ${{ matrix.use-case }} --auto-approve
    
    - name: Cleanup
      if: always()
      run: |
        cd terraform-tests
        ./scripts/cleanup.sh ${{ matrix.environment }} --auto-approve
```

### Jenkins Pipeline

```groovy
pipeline {
    agent any
    
    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'staging'],
            description: 'Target environment'
        )
        choice(
            name: 'USE_CASE',
            choices: ['all', 'site-hierarchy', 'pnp', 'device-credentials'],
            description: 'Use case to test'
        )
        booleanParam(
            name: 'DRY_RUN',
            defaultValue: true,
            description: 'Run in dry-run mode'
        )
    }
    
    stages {
        stage('Setup') {
            steps {
                sh 'cd terraform-tests && ./scripts/setup-inventory.sh ${ENVIRONMENT}'
                
                withCredentials([
                    string(credentialsId: 'catalyst-username', variable: 'CATALYST_USERNAME'),
                    string(credentialsId: 'catalyst-password', variable: 'CATALYST_PASSWORD'),
                    string(credentialsId: 'catalyst-base-url-${ENVIRONMENT}', variable: 'CATALYST_BASE_URL')
                ]) {
                    sh '''
                        cd terraform-tests
                        cat > inventories/${ENVIRONMENT}/terraform.tfvars << EOF
catalyst_username = "${CATALYST_USERNAME}"
catalyst_password = "${CATALYST_PASSWORD}"
catalyst_base_url = "${CATALYST_BASE_URL}"
EOF
                    '''
                }
            }
        }
        
        stage('Validate') {
            steps {
                sh 'cd terraform-tests && ./scripts/validate-config.sh ${ENVIRONMENT} --connectivity'
            }
        }
        
        stage('Test') {
            steps {
                script {
                    def dryRunFlag = params.DRY_RUN ? '--dry-run' : ''
                    sh "cd terraform-tests && ./scripts/run-test.sh ${ENVIRONMENT} ${USE_CASE} ${dryRunFlag}"
                }
            }
        }
        
        stage('Cleanup') {
            when {
                not { params.DRY_RUN }
            }
            steps {
                sh 'cd terraform-tests && ./scripts/cleanup.sh ${ENVIRONMENT} --auto-approve'
            }
        }
    }
    
    post {
        always {
            archiveArtifacts artifacts: 'terraform-tests/inventories/**/work/**/logs/*.log', allowEmptyArchive: true
        }
        failure {
            mail to: 'team@example.com',
                 subject: "Terraform Test Failed: ${env.BUILD_URL}",
                 body: "Test failed for ${params.ENVIRONMENT} environment, use case: ${params.USE_CASE}"
        }
    }
}
```

These advanced scenarios provide sophisticated testing capabilities for complex environments and requirements. They can be adapted and extended based on specific organizational needs and infrastructure requirements.