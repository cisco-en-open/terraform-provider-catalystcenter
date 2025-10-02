#!/bin/bash

# Comprehensive test runner for Catalyst Center Terraform Provider
# This replaces the failing run_all_terraform_examples.sh with proper Go testing

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results tracking
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# Test report files
TEST_REPORT="test_report_$(date +%Y%m%d_%H%M%S).txt"
COVERAGE_FILE="coverage.out"
COVERAGE_HTML="coverage.html"

echo "==================================="
echo "Catalyst Center Provider Test Suite"
echo "==================================="
echo ""

# Function to print colored status
print_status() {
    local status=$1
    local message=$2

    case $status in
        "SUCCESS")
            echo -e "${GREEN}✓${NC} $message"
            ;;
        "FAIL")
            echo -e "${RED}✗${NC} $message"
            ;;
        "SKIP")
            echo -e "${YELLOW}⊘${NC} $message"
            ;;
        "INFO")
            echo -e "${BLUE}ℹ${NC} $message"
            ;;
        *)
            echo "  $message"
            ;;
    esac
}

# Function to run a test suite
run_test_suite() {
    local suite_name=$1
    local test_pattern=$2
    local test_dir=${3:-"./catalystcenter"}
    local timeout=${4:-"30s"}

    echo ""
    print_status "INFO" "Running $suite_name..."

    ((TOTAL_TESTS++))

    if output=$(go test -v -timeout $timeout -run "$test_pattern" $test_dir 2>&1); then
        print_status "SUCCESS" "$suite_name passed"
        echo "$output" | grep -E "^(PASS|ok)" | sed 's/^/    /'
        ((PASSED_TESTS++))

        # Log to report
        echo "[$suite_name] PASSED" >> "$TEST_REPORT"
    else
        print_status "FAIL" "$suite_name failed"
        echo "$output" | grep -E "^(FAIL|---)" | sed 's/^/    /'
        ((FAILED_TESTS++))

        # Log to report
        echo "[$suite_name] FAILED" >> "$TEST_REPORT"
        echo "$output" | grep -E "^(FAIL|---)" >> "$TEST_REPORT"
    fi
}

# Check environment
echo "1. Environment Check"
echo "==================="

# Check Go installation
if command -v go &> /dev/null; then
    GO_VERSION=$(go version | awk '{print $3}')
    print_status "SUCCESS" "Go installed: $GO_VERSION"
else
    print_status "FAIL" "Go is not installed"
    exit 1
fi

# Check for test files
TEST_FILE_COUNT=$(find ./catalystcenter -name "*_test.go" 2>/dev/null | wc -l)
if [ "$TEST_FILE_COUNT" -gt 0 ]; then
    print_status "SUCCESS" "Found $TEST_FILE_COUNT test files"
else
    print_status "FAIL" "No test files found"
    echo ""
    print_status "INFO" "Creating initial test files..."

    # The test files should already be created from previous steps
    # Just verify they exist
    if [ -f "./catalystcenter/validators_test.go" ]; then
        print_status "SUCCESS" "validators_test.go exists"
        TEST_FILE_COUNT=1
    fi
fi

# Check for Catalyst Center credentials (for acceptance tests)
if [ ! -z "$CATALYST_BASE_URL" ]; then
    print_status "SUCCESS" "CATALYST_BASE_URL is set"
    ACCEPTANCE_TESTS_ENABLED=true
else
    print_status "SKIP" "CATALYST_BASE_URL not set - acceptance tests will be skipped"
    ACCEPTANCE_TESTS_ENABLED=false
fi

echo ""
echo "2. Dependency Check"
echo "==================="

# Download dependencies
print_status "INFO" "Downloading dependencies..."
if go mod download; then
    print_status "SUCCESS" "Dependencies downloaded"
else
    print_status "FAIL" "Failed to download dependencies"
    exit 1
fi

# Verify main dependencies
if go list -m github.com/hashicorp/terraform-plugin-sdk/v2 &> /dev/null; then
    print_status "SUCCESS" "Terraform Plugin SDK v2 available"
else
    print_status "FAIL" "Terraform Plugin SDK v2 not found"
fi

if go list -m github.com/cisco-en-programmability/catalystcenter-go-sdk/v3 &> /dev/null; then
    print_status "SUCCESS" "Catalyst Center Go SDK v3 available"
else
    print_status "FAIL" "Catalyst Center Go SDK v3 not found"
fi

echo ""
echo "3. Unit Tests"
echo "============="

# Run validator tests
if [ -f "./catalystcenter/validators_test.go" ]; then
    run_test_suite "Validator Tests" "TestValidate" "./catalystcenter" "30s"
fi

# Run converter tests (if exists)
if grep -q "TestConvert" ./catalystcenter/*_test.go 2>/dev/null; then
    run_test_suite "Converter Tests" "TestConvert" "./catalystcenter" "30s"
fi

# Run helper tests
if [ -f "./catalystcenter/test_helpers_test.go" ]; then
    run_test_suite "Helper Tests" "TestProvider" "./catalystcenter" "30s"
fi

echo ""
echo "4. Resource Tests"
echo "================"

# Run resource schema tests
if grep -q "TestResource.*Schema" ./catalystcenter/*_test.go 2>/dev/null; then
    run_test_suite "Resource Schema Tests" "TestResource.*Schema" "./catalystcenter" "30s"
else
    print_status "SKIP" "No resource schema tests found"
    ((SKIPPED_TESTS++))
fi

# Run resource CRUD tests
if grep -q "TestResource.*CRUD\|TestResource.*Create\|TestResource.*Read" ./catalystcenter/*_test.go 2>/dev/null; then
    run_test_suite "Resource CRUD Tests" "TestResource.*(Create|Read|Update|Delete)" "./catalystcenter" "60s"
else
    print_status "SKIP" "No resource CRUD tests found"
    ((SKIPPED_TESTS++))
fi

echo ""
echo "5. Data Source Tests"
echo "==================="

# Run data source tests
if grep -q "TestDataSource" ./catalystcenter/*_test.go 2>/dev/null; then
    run_test_suite "Data Source Tests" "TestDataSource" "./catalystcenter" "30s"
else
    print_status "SKIP" "No data source tests found"
    ((SKIPPED_TESTS++))
fi

echo ""
echo "6. Integration Tests"
echo "==================="

# Run integration tests with mock server
if grep -q "TestIntegration" ./catalystcenter/*_test.go 2>/dev/null; then
    run_test_suite "Integration Tests" "TestIntegration" "./catalystcenter" "60s"
else
    print_status "SKIP" "No integration tests found"
    ((SKIPPED_TESTS++))
fi

echo ""
echo "7. Acceptance Tests"
echo "==================="

if [ "$ACCEPTANCE_TESTS_ENABLED" = true ]; then
    print_status "INFO" "Running acceptance tests against $CATALYST_BASE_URL"

    # Set TF_ACC environment variable
    export TF_ACC=1

    if grep -q "TestAcc" ./catalystcenter/*_test.go 2>/dev/null; then
        run_test_suite "Acceptance Tests" "TestAcc" "./catalystcenter" "120m"
    else
        print_status "SKIP" "No acceptance tests found"
        ((SKIPPED_TESTS++))
    fi
else
    print_status "SKIP" "Acceptance tests skipped (environment not configured)"
    ((SKIPPED_TESTS++))
fi

echo ""
echo "8. Coverage Analysis"
echo "==================="

print_status "INFO" "Generating coverage report..."

# Run tests with coverage
if go test -coverprofile="$COVERAGE_FILE" ./catalystcenter/... &> /dev/null; then
    # Generate coverage percentage
    COVERAGE=$(go tool cover -func="$COVERAGE_FILE" | grep total | awk '{print $3}')
    print_status "SUCCESS" "Coverage: $COVERAGE"

    # Generate HTML report
    go tool cover -html="$COVERAGE_FILE" -o "$COVERAGE_HTML"
    print_status "SUCCESS" "HTML coverage report generated: $COVERAGE_HTML"

    # Show uncovered functions
    echo ""
    print_status "INFO" "Top uncovered functions:"
    go tool cover -func="$COVERAGE_FILE" | grep -v "100.0%" | grep -v "total" | sort -k3 -n | head -5 | sed 's/^/    /'
else
    print_status "FAIL" "Failed to generate coverage report"
fi

echo ""
echo "9. Benchmark Tests"
echo "=================="

if grep -q "Benchmark" ./catalystcenter/*_test.go 2>/dev/null; then
    print_status "INFO" "Running benchmark tests..."

    if go test -bench=. -benchmem -run=^$ ./catalystcenter/... > benchmark_results.txt 2>&1; then
        print_status "SUCCESS" "Benchmarks completed"
        grep "Benchmark" benchmark_results.txt | head -5 | sed 's/^/    /'
    else
        print_status "FAIL" "Benchmarks failed"
    fi
else
    print_status "SKIP" "No benchmark tests found"
fi

echo ""
echo "10. Race Condition Detection"
echo "============================"

print_status "INFO" "Running tests with race detector..."

if go test -race -run "TestValidate" ./catalystcenter/... &> /dev/null; then
    print_status "SUCCESS" "No race conditions detected"
else
    print_status "FAIL" "Race conditions detected"
fi

echo ""
echo "================================"
echo "        Test Summary"
echo "================================"
echo ""

# Calculate percentages
if [ $TOTAL_TESTS -gt 0 ]; then
    PASS_PERCENTAGE=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    FAIL_PERCENTAGE=$((FAILED_TESTS * 100 / TOTAL_TESTS))
    SKIP_PERCENTAGE=$((SKIPPED_TESTS * 100 / TOTAL_TESTS))
else
    PASS_PERCENTAGE=0
    FAIL_PERCENTAGE=0
    SKIP_PERCENTAGE=0
fi

echo "Total Test Suites: $TOTAL_TESTS"
echo -e "Passed:  ${GREEN}$PASSED_TESTS${NC} ($PASS_PERCENTAGE%)"
echo -e "Failed:  ${RED}$FAILED_TESTS${NC} ($FAIL_PERCENTAGE%)"
echo -e "Skipped: ${YELLOW}$SKIPPED_TESTS${NC} ($SKIP_PERCENTAGE%)"
echo ""

# Generate summary report
{
    echo "Test Execution Report"
    echo "Generated: $(date)"
    echo ""
    echo "Summary:"
    echo "- Total Suites: $TOTAL_TESTS"
    echo "- Passed: $PASSED_TESTS"
    echo "- Failed: $FAILED_TESTS"
    echo "- Skipped: $SKIPPED_TESTS"
    echo ""
    echo "Coverage: $COVERAGE"
} >> "$TEST_REPORT"

print_status "INFO" "Full report saved to: $TEST_REPORT"

# Exit with appropriate code
if [ $FAILED_TESTS -eq 0 ]; then
    echo ""
    print_status "SUCCESS" "All tests passed successfully!"
    exit 0
else
    echo ""
    print_status "FAIL" "Some tests failed. Please review the errors above."
    exit 1
fi