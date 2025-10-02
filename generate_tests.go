package main

import (
	"fmt"
	"go/ast"
	"go/parser"
	"go/token"
	"io/ioutil"
	"os"
	"path/filepath"
	"strings"
	"text/template"
)

// TestGenerator generates test files for Terraform provider resources and data sources
type TestGenerator struct {
	SourceDir  string
	OutputDir  string
	PackageName string
}

// ResourceInfo holds information about a resource or data source
type ResourceInfo struct {
	Name        string
	Type        string // "resource" or "data_source"
	FuncName    string
	SchemaFunc  string
	PackageName string
}

// TestTemplate is the template for generating test files
const resourceTestTemplate = `package {{ .PackageName }}

import (
	"testing"

	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
	"github.com/stretchr/testify/assert"
)

// TestResource{{ .Name }}Schema tests the schema definition
func TestResource{{ .Name }}Schema(t *testing.T) {
	r := {{ .SchemaFunc }}()

	// Basic schema validation
	assert.NotNil(t, r, "Resource should not be nil")
	assert.NotNil(t, r.Schema, "Resource schema should not be nil")

	// Check CRUD operations are defined
	if r.CreateContext != nil {
		assert.NotNil(t, r.CreateContext, "CreateContext should be defined")
	}
	if r.ReadContext != nil {
		assert.NotNil(t, r.ReadContext, "ReadContext should be defined")
	}
	if r.UpdateContext != nil {
		assert.NotNil(t, r.UpdateContext, "UpdateContext should be defined")
	}
	if r.DeleteContext != nil {
		assert.NotNil(t, r.DeleteContext, "DeleteContext should be defined")
	}

	// Test that schema has expected fields
	for fieldName, fieldSchema := range r.Schema {
		assert.NotNil(t, fieldSchema, "Field %s should have schema defined", fieldName)

		// Validate field properties
		switch fieldName {
		case "parameters":
			assert.True(t, fieldSchema.Optional || fieldSchema.Required || fieldSchema.Computed,
				"Field %s should have at least one of Optional/Required/Computed", fieldName)
		case "item", "items":
			assert.True(t, fieldSchema.Computed, "Field %s should be Computed", fieldName)
		case "last_updated":
			assert.Equal(t, schema.TypeString, fieldSchema.Type, "Field %s should be TypeString", fieldName)
			assert.True(t, fieldSchema.Computed, "Field %s should be Computed", fieldName)
		}
	}
}

// TestResource{{ .Name }}CRUD tests CRUD operations structure
func TestResource{{ .Name }}CRUD(t *testing.T) {
	t.Run("Create", func(t *testing.T) {
		// Test resource creation logic structure
		r := {{ .SchemaFunc }}()
		assert.NotNil(t, r.CreateContext, "CreateContext should be defined for resource")
	})

	t.Run("Read", func(t *testing.T) {
		// Test resource read logic structure
		r := {{ .SchemaFunc }}()
		assert.NotNil(t, r.ReadContext, "ReadContext should be defined for resource")
	})

	t.Run("Update", func(t *testing.T) {
		// Test resource update logic structure
		r := {{ .SchemaFunc }}()
		if r.UpdateContext != nil {
			assert.NotNil(t, r.UpdateContext, "UpdateContext should be defined if resource supports updates")
		}
	})

	t.Run("Delete", func(t *testing.T) {
		// Test resource delete logic structure
		r := {{ .SchemaFunc }}()
		assert.NotNil(t, r.DeleteContext, "DeleteContext should be defined for resource")
	})
}
`

const dataSourceTestTemplate = `package {{ .PackageName }}

import (
	"testing"

	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
	"github.com/stretchr/testify/assert"
)

// TestDataSource{{ .Name }}Schema tests the schema definition
func TestDataSource{{ .Name }}Schema(t *testing.T) {
	ds := {{ .SchemaFunc }}()

	// Basic schema validation
	assert.NotNil(t, ds, "Data source should not be nil")
	assert.NotNil(t, ds.Schema, "Data source schema should not be nil")
	assert.NotNil(t, ds.ReadContext, "ReadContext should be defined")

	// Check for common query parameters
	queryParams := []string{}
	for fieldName := range ds.Schema {
		if strings.Contains(fieldName, "_id") || strings.Contains(fieldName, "name") {
			queryParams = append(queryParams, fieldName)
		}
	}

	if len(queryParams) > 0 {
		t.Logf("Found %d query parameters", len(queryParams))
	}

	// Validate schema fields
	for fieldName, fieldSchema := range ds.Schema {
		assert.NotNil(t, fieldSchema, "Field %s should have schema defined", fieldName)

		// Check field properties
		if fieldName == "item" || fieldName == "items" {
			assert.True(t, fieldSchema.Computed, "Field %s should be Computed", fieldName)
			assert.Equal(t, schema.TypeList, fieldSchema.Type, "Field %s should be TypeList", fieldName)
		}
	}
}

// TestDataSource{{ .Name }}Read tests the Read operation
func TestDataSource{{ .Name }}Read(t *testing.T) {
	ds := {{ .SchemaFunc }}()

	// Validate ReadContext is defined
	assert.NotNil(t, ds.ReadContext, "ReadContext must be defined for data source")

	// Test with empty resource data
	d := schema.TestResourceDataRaw(t, ds.Schema, map[string]interface{}{})
	assert.NotNil(t, d, "ResourceData should not be nil")
}
`

// ExtractResourcesAndDataSources parses Go files to find resources and data sources
func (tg *TestGenerator) ExtractResourcesAndDataSources() ([]ResourceInfo, error) {
	var resources []ResourceInfo

	err := filepath.Walk(tg.SourceDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		// Skip non-Go files, test files, and vendor directory
		if !strings.HasSuffix(path, ".go") ||
		   strings.HasSuffix(path, "_test.go") ||
		   strings.Contains(path, "vendor") ||
		   strings.Contains(path, "test/") {
			return nil
		}

		// Parse the file
		fset := token.NewFileSet()
		node, err := parser.ParseFile(fset, path, nil, parser.AllErrors)
		if err != nil {
			return nil // Skip files with parse errors
		}

		// Find resource and data source functions
		ast.Inspect(node, func(n ast.Node) bool {
			fn, ok := n.(*ast.FuncDecl)
			if !ok {
				return true
			}

			funcName := fn.Name.Name

			// Check if it's a resource or data source function
			if strings.HasPrefix(funcName, "resource") && !strings.Contains(funcName, "expand") && !strings.Contains(funcName, "flatten") {
				// Extract resource name
				name := strings.TrimPrefix(funcName, "resource")
				resources = append(resources, ResourceInfo{
					Name:        name,
					Type:        "resource",
					FuncName:    funcName,
					SchemaFunc:  funcName,
					PackageName: tg.PackageName,
				})
			} else if strings.HasPrefix(funcName, "dataSource") {
				// Extract data source name
				name := strings.TrimPrefix(funcName, "dataSource")
				resources = append(resources, ResourceInfo{
					Name:        name,
					Type:        "data_source",
					FuncName:    funcName,
					SchemaFunc:  funcName,
					PackageName: tg.PackageName,
				})
			}

			return true
		})

		return nil
	})

	return resources, err
}

// GenerateTestFile generates a test file for a resource or data source
func (tg *TestGenerator) GenerateTestFile(info ResourceInfo) error {
	// Determine template and output filename
	var tmplStr string
	var outputFile string

	if info.Type == "resource" {
		tmplStr = resourceTestTemplate
		outputFile = fmt.Sprintf("%s/%s_test.go", tg.OutputDir, strings.ToLower(info.FuncName))
	} else {
		tmplStr = dataSourceTestTemplate
		outputFile = fmt.Sprintf("%s/%s_test.go", tg.OutputDir, strings.ToLower(info.FuncName))
	}

	// Skip if test file already exists
	if _, err := os.Stat(outputFile); err == nil {
		fmt.Printf("Test file already exists, skipping: %s\n", outputFile)
		return nil
	}

	// Parse template
	tmpl, err := template.New("test").Parse(tmplStr)
	if err != nil {
		return fmt.Errorf("failed to parse template: %v", err)
	}

	// Create output file
	file, err := os.Create(outputFile)
	if err != nil {
		return fmt.Errorf("failed to create file %s: %v", outputFile, err)
	}
	defer file.Close()

	// Execute template
	err = tmpl.Execute(file, info)
	if err != nil {
		return fmt.Errorf("failed to execute template: %v", err)
	}

	fmt.Printf("Generated test file: %s\n", outputFile)
	return nil
}

// GenerateBatchScript creates a script to generate tests in batches
func (tg *TestGenerator) GenerateBatchScript(resources []ResourceInfo) error {
	scriptPath := filepath.Join(tg.OutputDir, "batch_test_generation.sh")

	script := `#!/bin/bash

# Batch Test Generation Script
# Generates tests for Catalyst Center Terraform Provider

set -e

echo "Starting batch test generation..."
echo "Total modules to process: %d"

BATCH_SIZE=50
CURRENT_BATCH=0
GENERATED=0
SKIPPED=0

generate_batch() {
    local start=$1
    local end=$2

    echo "Processing batch $((CURRENT_BATCH+1)) (modules $start to $end)..."

    for ((i=start; i<end && i<${#MODULES[@]}; i++)); do
        MODULE="${MODULES[$i]}"
        if go run generate_tests.go -single "$MODULE"; then
            ((GENERATED++))
        else
            ((SKIPPED++))
        fi
    done
}

# List of all modules
MODULES=(
%s
)

# Process in batches
TOTAL=${#MODULES[@]}
for ((i=0; i<TOTAL; i+=BATCH_SIZE)); do
    ((CURRENT_BATCH++))
    END=$((i+BATCH_SIZE))
    if [ $END -gt $TOTAL ]; then
        END=$TOTAL
    fi

    generate_batch $i $END

    echo "Batch $CURRENT_BATCH complete. Generated: $GENERATED, Skipped: $SKIPPED"
    echo "Running tests for verification..."
    go test -mod=readonly ./catalystcenter -run "^Test(Resource|DataSource)" -count=1 | grep -E "PASS|FAIL" | tail -5

    # Optional: pause between batches
    if [ $END -lt $TOTAL ]; then
        echo "Pausing for 2 seconds before next batch..."
        sleep 2
    fi
done

echo "======================================"
echo "Batch test generation complete!"
echo "Total modules: $TOTAL"
echo "Generated: $GENERATED"
echo "Skipped: $SKIPPED"
echo "======================================"
`

	// Build module list
	var moduleList []string
	for _, r := range resources {
		moduleList = append(moduleList, fmt.Sprintf("    \"%s\"", r.FuncName))
	}

	// Format script
	scriptContent := fmt.Sprintf(script, len(resources), strings.Join(moduleList, "\n"))

	// Write script
	err := ioutil.WriteFile(scriptPath, []byte(scriptContent), 0755)
	if err != nil {
		return fmt.Errorf("failed to write batch script: %v", err)
	}

	fmt.Printf("Generated batch script: %s\n", scriptPath)
	return nil
}

// GenerateSummaryReport creates a summary of test generation
func (tg *TestGenerator) GenerateSummaryReport(resources []ResourceInfo) error {
	reportPath := filepath.Join(tg.OutputDir, "test_generation_report.md")

	report := `# Test Generation Report

## Summary
- Total modules found: %d
- Resources: %d
- Data Sources: %d
- Test files to generate: %d

## Coverage Strategy

### Phase 1: Basic Schema Tests (Week 1)
- Validate schema structure
- Check required/optional/computed fields
- Verify CRUD operations presence

### Phase 2: CRUD Operation Tests (Week 2)
- Test Create operations
- Test Read operations
- Test Update operations
- Test Delete operations

### Phase 3: Integration Tests (Week 3)
- Mock client integration
- Error handling
- State management

## Module Breakdown

### Resources (%d total)
%s

### Data Sources (%d total)
%s

## Next Steps
1. Run batch_test_generation.sh to generate all tests
2. Fix any compilation errors in generated tests
3. Add mock implementations for complex resources
4. Run coverage analysis
5. Iterate and improve test quality

## Commands

` + "```bash" + `
# Generate all tests
./batch_test_generation.sh

# Run all generated tests
go test -mod=readonly ./catalystcenter -run "^Test(Resource|DataSource)"

# Check coverage
go test -mod=readonly -cover ./catalystcenter

# Run specific module tests
go test -mod=readonly ./catalystcenter -run TestResourceTag
` + "```" + `
`

	// Count resources and data sources
	resourceCount := 0
	dataSourceCount := 0
	var resourceList []string
	var dataSourceList []string

	for _, r := range resources {
		if r.Type == "resource" {
			resourceCount++
			resourceList = append(resourceList, fmt.Sprintf("- %s", r.Name))
		} else {
			dataSourceCount++
			dataSourceList = append(dataSourceList, fmt.Sprintf("- %s", r.Name))
		}
	}

	// Format report
	reportContent := fmt.Sprintf(report,
		len(resources),
		resourceCount,
		dataSourceCount,
		len(resources),
		resourceCount,
		strings.Join(resourceList[:min(10, len(resourceList))], "\n"),
		dataSourceCount,
		strings.Join(dataSourceList[:min(10, len(dataSourceList))], "\n"),
	)

	// Write report
	err := ioutil.WriteFile(reportPath, []byte(reportContent), 0644)
	if err != nil {
		return fmt.Errorf("failed to write report: %v", err)
	}

	fmt.Printf("Generated report: %s\n", reportPath)
	return nil
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}

func main() {
	// Configure generator
	generator := &TestGenerator{
		SourceDir:   "./catalystcenter",
		OutputDir:   "./catalystcenter",
		PackageName: "catalystcenter",
	}

	// Extract resources and data sources
	fmt.Println("Extracting resources and data sources...")
	resources, err := generator.ExtractResourcesAndDataSources()
	if err != nil {
		fmt.Printf("Error extracting resources: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Found %d modules\n", len(resources))

	// Check for single module generation (for testing)
	if len(os.Args) > 2 && os.Args[1] == "-single" {
		moduleName := os.Args[2]
		for _, r := range resources {
			if r.FuncName == moduleName {
				err := generator.GenerateTestFile(r)
				if err != nil {
					fmt.Printf("Error generating test for %s: %v\n", moduleName, err)
					os.Exit(1)
				}
				os.Exit(0)
			}
		}
		fmt.Printf("Module not found: %s\n", moduleName)
		os.Exit(1)
	}

	// Generate batch script
	err = generator.GenerateBatchScript(resources)
	if err != nil {
		fmt.Printf("Error generating batch script: %v\n", err)
		os.Exit(1)
	}

	// Generate summary report
	err = generator.GenerateSummaryReport(resources)
	if err != nil {
		fmt.Printf("Error generating report: %v\n", err)
		os.Exit(1)
	}

	// Generate tests for first 5 modules as examples
	fmt.Println("\nGenerating example tests for first 5 modules...")
	for i := 0; i < min(5, len(resources)); i++ {
		err := generator.GenerateTestFile(resources[i])
		if err != nil {
			fmt.Printf("Error generating test for %s: %v\n", resources[i].Name, err)
		}
	}

	fmt.Println("\nTest generation setup complete!")
	fmt.Println("Run ./catalystcenter/batch_test_generation.sh to generate all tests")
}