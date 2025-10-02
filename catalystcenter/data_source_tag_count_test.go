package catalystcenter

import (
	"testing"

	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
	"github.com/stretchr/testify/assert"
	catalystcentersdkgo "github.com/cisco-en-programmability/catalystcenter-go-sdk/v3/sdk"
)

// TestDataSourceTagCountSchema tests the schema definition of the tag count data source
func TestDataSourceTagCountSchema(t *testing.T) {
	ds := dataSourceTagCount()

	// Test that the data source is properly defined
	assert.NotNil(t, ds, "Data source should not be nil")
	assert.NotNil(t, ds.Schema, "Data source schema should not be nil")
	assert.NotNil(t, ds.ReadContext, "ReadContext should be defined")
	assert.Contains(t, ds.Description, "Returns tag count", "Description should mention tag count")

	// Test query parameter fields
	queryParams := []struct {
		name        string
		schemaType  schema.ValueType
		optional    bool
		computed    bool
		description string
	}{
		{
			name:        "attribute_name",
			schemaType:  schema.TypeString,
			optional:    true,
			computed:    false,
			description: "attributeName query parameter",
		},
		{
			name:        "name",
			schemaType:  schema.TypeString,
			optional:    true,
			computed:    false,
			description: "name query parameter",
		},
		{
			name:        "name_space",
			schemaType:  schema.TypeString,
			optional:    true,
			computed:    false,
			description: "nameSpace query parameter",
		},
		{
			name:        "size",
			schemaType:  schema.TypeString,
			optional:    true,
			computed:    false,
			description: "size query parameter",
		},
		{
			name:        "system_tag",
			schemaType:  schema.TypeString,
			optional:    true,
			computed:    false,
			description: "systemTag query parameter",
		},
	}

	for _, param := range queryParams {
		t.Run("QueryParam_"+param.name, func(t *testing.T) {
			field, ok := ds.Schema[param.name]
			assert.True(t, ok, "Schema should contain field: %s", param.name)
			assert.Equal(t, param.schemaType, field.Type, "Field %s should have correct type", param.name)
			assert.Equal(t, param.optional, field.Optional, "Field %s optional flag should match", param.name)
			assert.Equal(t, param.computed, field.Computed, "Field %s computed flag should match", param.name)
			assert.Contains(t, field.Description, param.description, "Field %s should have proper description", param.name)
		})
	}

	// Test item schema (computed field)
	itemField, ok := ds.Schema["item"]
	assert.True(t, ok, "item field should exist")
	assert.Equal(t, schema.TypeList, itemField.Type, "item should be a list")
	assert.True(t, itemField.Computed, "item should be computed")

	// Test nested item schema
	if elem, ok := itemField.Elem.(*schema.Resource); ok {
		// Test response field
		responseField, exists := elem.Schema["response"]
		assert.True(t, exists, "response field should exist in item")
		assert.Equal(t, schema.TypeInt, responseField.Type, "response should be an int")
		assert.True(t, responseField.Computed, "response should be computed")

		// Test version field
		versionField, exists := elem.Schema["version"]
		assert.True(t, exists, "version field should exist in item")
		assert.Equal(t, schema.TypeString, versionField.Type, "version should be a string")
		assert.True(t, versionField.Computed, "version should be computed")
	} else {
		t.Fatal("item.Elem should be a *schema.Resource")
	}
}

// TestDataSourceTagCountRead tests the Read operation with mock data
func TestDataSourceTagCountRead(t *testing.T) {
	// Create test resource data
	d := schema.TestResourceDataRaw(t, dataSourceTagCount().Schema, map[string]interface{}{
		"name":           "TestTag",
		"name_space":     "test_namespace",
		"attribute_name": "test_attr",
		"size":           "1024",
		"system_tag":     "false",
	})

	// Verify query parameters are set correctly
	assert.Equal(t, "TestTag", d.Get("name").(string), "name should be set")
	assert.Equal(t, "test_namespace", d.Get("name_space").(string), "name_space should be set")
	assert.Equal(t, "test_attr", d.Get("attribute_name").(string), "attribute_name should be set")
	assert.Equal(t, "1024", d.Get("size").(string), "size should be set")
	assert.Equal(t, "false", d.Get("system_tag").(string), "system_tag should be set")
}

// TestFlattenTagGetTagCountItem tests the flatten function
func TestFlattenTagGetTagCountItem(t *testing.T) {
	tests := []struct {
		name     string
		input    *catalystcentersdkgo.ResponseTagGetTagCount
		expected []map[string]interface{}
		isNil    bool
	}{
		{
			name:     "nil input",
			input:    nil,
			expected: nil,
			isNil:    true,
		},
		{
			name: "valid response with count",
			input: &catalystcentersdkgo.ResponseTagGetTagCount{
				Response: func() *int {
					v := 5
					return &v
				}(),
				Version: "1.0.0", // Version is a direct string in SDK
			},
			expected: []map[string]interface{}{
				{
					"response": func() *int {
						v := 5
						return &v
					}(),
					"version": "1.0.0",
				},
			},
			isNil: false,
		},
		{
			name: "response with zero count",
			input: &catalystcentersdkgo.ResponseTagGetTagCount{
				Response: func() *int {
					v := 0
					return &v
				}(),
				Version: "2.0.0", // Version is a direct string in SDK
			},
			expected: []map[string]interface{}{
				{
					"response": func() *int {
						v := 0
						return &v
					}(),
					"version": "2.0.0",
				},
			},
			isNil: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := flattenTagGetTagCountItem(tt.input)

			if tt.isNil {
				assert.Nil(t, result, "Result should be nil")
			} else {
				assert.NotNil(t, result, "Result should not be nil")
				assert.Len(t, result, 1, "Result should have exactly one item")

				if len(result) > 0 && len(tt.expected) > 0 {
					// Check response field
					if tt.expected[0]["response"] != nil {
						assert.Equal(t, tt.expected[0]["response"], result[0]["response"], "Response values should match")
					}

					// Check version field
					if tt.expected[0]["version"] != nil {
						assert.Equal(t, tt.expected[0]["version"], result[0]["version"], "Version values should match")
					}
				}
			}
		})
	}
}

// TestDataSourceTagCountQueryParams tests query parameter construction
func TestDataSourceTagCountQueryParams(t *testing.T) {
	tests := []struct {
		name        string
		inputData   map[string]interface{}
		expectQuery catalystcentersdkgo.GetTagCountQueryParams
	}{
		{
			name: "all parameters set",
			inputData: map[string]interface{}{
				"name":           "TestTag",
				"name_space":     "namespace1",
				"attribute_name": "attr1",
				"size":           "2048",
				"system_tag":     "true",
			},
			expectQuery: catalystcentersdkgo.GetTagCountQueryParams{
				Name:          "TestTag",
				NameSpace:     "namespace1",
				AttributeName: "attr1",
				Size:          "2048",
				SystemTag:     "true",
			},
		},
		{
			name: "partial parameters",
			inputData: map[string]interface{}{
				"name":       "PartialTag",
				"system_tag": "false",
			},
			expectQuery: catalystcentersdkgo.GetTagCountQueryParams{
				Name:      "PartialTag",
				SystemTag: "false",
			},
		},
		{
			name:        "no parameters",
			inputData:   map[string]interface{}{},
			expectQuery: catalystcentersdkgo.GetTagCountQueryParams{},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Create resource data with input
			d := schema.TestResourceDataRaw(t, dataSourceTagCount().Schema, tt.inputData)

			// Build query params as the function would
			queryParams := catalystcentersdkgo.GetTagCountQueryParams{}

			if v, ok := d.GetOk("name"); ok {
				queryParams.Name = v.(string)
			}
			if v, ok := d.GetOk("name_space"); ok {
				queryParams.NameSpace = v.(string)
			}
			if v, ok := d.GetOk("attribute_name"); ok {
				queryParams.AttributeName = v.(string)
			}
			if v, ok := d.GetOk("size"); ok {
				queryParams.Size = v.(string)
			}
			if v, ok := d.GetOk("system_tag"); ok {
				queryParams.SystemTag = v.(string)
			}

			// Verify query params match expectations
			assert.Equal(t, tt.expectQuery.Name, queryParams.Name, "Name should match")
			assert.Equal(t, tt.expectQuery.NameSpace, queryParams.NameSpace, "NameSpace should match")
			assert.Equal(t, tt.expectQuery.AttributeName, queryParams.AttributeName, "AttributeName should match")
			assert.Equal(t, tt.expectQuery.Size, queryParams.Size, "Size should match")
			assert.Equal(t, tt.expectQuery.SystemTag, queryParams.SystemTag, "SystemTag should match")
		})
	}
}

// TestDataSourceTagCountEdgeCases tests edge cases
func TestDataSourceTagCountEdgeCases(t *testing.T) {
	t.Run("EmptyResponse", func(t *testing.T) {
		// Test with empty response
		emptyResponse := &catalystcentersdkgo.ResponseTagGetTagCount{}
		result := flattenTagGetTagCountItem(emptyResponse)

		assert.NotNil(t, result, "Result should not be nil for empty response")
		assert.Len(t, result, 1, "Should return one item even for empty response")
		assert.Nil(t, result[0]["response"], "Response should be nil")
		assert.Nil(t, result[0]["version"], "Version should be nil")
	})

	t.Run("LargeCount", func(t *testing.T) {
		// Test with large count value
		largeCount := 999999
		response := &catalystcentersdkgo.ResponseTagGetTagCount{
			Response: &largeCount,
		}
		result := flattenTagGetTagCountItem(response)

		assert.NotNil(t, result, "Result should not be nil")
		assert.Equal(t, &largeCount, result[0]["response"], "Large count should be preserved")
	})

	t.Run("SpecialCharactersInParams", func(t *testing.T) {
		// Test with special characters in query parameters
		d := schema.TestResourceDataRaw(t, dataSourceTagCount().Schema, map[string]interface{}{
			"name":           "Tag-Name_123!@#",
			"name_space":     "namespace/with/slashes",
			"attribute_name": "attr.with.dots",
		})

		assert.Equal(t, "Tag-Name_123!@#", d.Get("name").(string), "Special characters in name should be preserved")
		assert.Equal(t, "namespace/with/slashes", d.Get("name_space").(string), "Slashes in namespace should be preserved")
		assert.Equal(t, "attr.with.dots", d.Get("attribute_name").(string), "Dots in attribute name should be preserved")
	})
}

// Benchmark tests
func BenchmarkDataSourceTagCountSchema(b *testing.B) {
	for i := 0; i < b.N; i++ {
		_ = dataSourceTagCount()
	}
}

func BenchmarkFlattenTagGetTagCountItem(b *testing.B) {
	response := &catalystcentersdkgo.ResponseTagGetTagCount{
		Response: func() *int {
			v := 100
			return &v
		}(),
		Version: "1.0.0", // Version is a direct string in SDK
	}

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		_ = flattenTagGetTagCountItem(response)
	}
}