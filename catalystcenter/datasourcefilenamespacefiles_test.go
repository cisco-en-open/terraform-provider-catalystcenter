package catalystcenter

import (
	"testing"
	"strings"

	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
	"github.com/stretchr/testify/assert"
)

// TestDataSourceFileNamespaceFilesSchema tests the schema definition
func TestDataSourceFileNamespaceFilesSchema(t *testing.T) {
	ds := dataSourceFileNamespaceFiles()

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

// TestDataSourceFileNamespaceFilesRead tests the Read operation
func TestDataSourceFileNamespaceFilesRead(t *testing.T) {
	ds := dataSourceFileNamespaceFiles()

	// Validate ReadContext is defined
	assert.NotNil(t, ds.ReadContext, "ReadContext must be defined for data source")

	// Test with empty resource data
	d := schema.TestResourceDataRaw(t, ds.Schema, map[string]interface{}{})
	assert.NotNil(t, d, "ResourceData should not be nil")
}
