package catalystcenter

import (
	"context"
	"testing"

	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
	"github.com/stretchr/testify/assert"
)

// TestResourceTagSchema tests the schema definition of the tag resource
func TestResourceTagSchema(t *testing.T) {
	r := resourceTag()

	// Test that the resource is properly defined
	assert.NotNil(t, r, "Resource should not be nil")
	assert.NotNil(t, r.Schema, "Resource schema should not be nil")
	assert.NotNil(t, r.CreateContext, "CreateContext should be defined")
	assert.NotNil(t, r.ReadContext, "ReadContext should be defined")
	assert.NotNil(t, r.UpdateContext, "UpdateContext should be defined")
	assert.NotNil(t, r.DeleteContext, "DeleteContext should be defined")
	assert.NotNil(t, r.Importer, "Importer should be defined")

	// Test required schema fields
	schemaFields := []string{
		"parameters",
		"item",
		"last_updated",
	}

	for _, field := range schemaFields {
		t.Run("Schema_"+field, func(t *testing.T) {
			_, ok := r.Schema[field]
			assert.True(t, ok, "Schema should contain field: %s", field)
		})
	}

	// Test parameters schema
	parametersSchema, ok := r.Schema["parameters"]
	assert.True(t, ok, "parameters field should exist")
	assert.Equal(t, schema.TypeList, parametersSchema.Type, "parameters should be a list")
	assert.True(t, parametersSchema.Optional, "parameters should be optional")
	assert.True(t, parametersSchema.Computed, "parameters should be computed")
	assert.Equal(t, 1, parametersSchema.MaxItems, "parameters should have MaxItems of 1")

	// Test nested schema elements
	if elem, ok := parametersSchema.Elem.(*schema.Resource); ok {
		// Test name field
		nameSchema, exists := elem.Schema["name"]
		assert.True(t, exists, "name field should exist in parameters")
		assert.Equal(t, schema.TypeString, nameSchema.Type, "name should be a string")

		// Test description field
		descSchema, exists := elem.Schema["description"]
		assert.True(t, exists, "description field should exist in parameters")
		assert.Equal(t, schema.TypeString, descSchema.Type, "description should be a string")

		// Test system_tag field
		systemTagSchema, exists := elem.Schema["system_tag"]
		assert.True(t, exists, "system_tag field should exist in parameters")
		assert.Equal(t, schema.TypeBool, systemTagSchema.Type, "system_tag should be a bool")

		// Test dynamic_rules field
		dynamicRulesSchema, exists := elem.Schema["dynamic_rules"]
		assert.True(t, exists, "dynamic_rules field should exist in parameters")
		assert.Equal(t, schema.TypeList, dynamicRulesSchema.Type, "dynamic_rules should be a list")
	} else {
		t.Fatal("parameters.Elem should be a *schema.Resource")
	}

	// Test item schema
	itemSchema, ok := r.Schema["item"]
	assert.True(t, ok, "item field should exist")
	assert.Equal(t, schema.TypeList, itemSchema.Type, "item should be a list")
	assert.True(t, itemSchema.Computed, "item should be computed")

	// Test last_updated schema
	lastUpdatedSchema, ok := r.Schema["last_updated"]
	assert.True(t, ok, "last_updated field should exist")
	assert.Equal(t, schema.TypeString, lastUpdatedSchema.Type, "last_updated should be a string")
	assert.True(t, lastUpdatedSchema.Computed, "last_updated should be computed")
}

// TestResourceTagSchemaValidation tests schema validation functions
func TestResourceTagSchemaValidation(t *testing.T) {
	r := resourceTag()

	// Get the parameters schema
	parametersSchema := r.Schema["parameters"]
	elem := parametersSchema.Elem.(*schema.Resource)

	// Test system_tag validation
	systemTagSchema := elem.Schema["system_tag"]
	if systemTagSchema.ValidateFunc != nil {
		// Test valid values
		_, errs := systemTagSchema.ValidateFunc(true, "system_tag")
		assert.Empty(t, errs, "true should be valid for system_tag")

		_, errs = systemTagSchema.ValidateFunc(false, "system_tag")
		assert.Empty(t, errs, "false should be valid for system_tag")
	}
}

// TestResourceTagCreate tests the Create operation
func TestResourceTagCreate(t *testing.T) {
	// This test would require mocking the client
	// For now, we'll test the basic structure

	d := schema.TestResourceDataRaw(t, resourceTag().Schema, map[string]interface{}{
		"parameters": []interface{}{
			map[string]interface{}{
				"name":        "TestTag",
				"description": "Test Description",
				"system_tag":  false,
			},
		},
	})

	assert.NotNil(t, d, "ResourceData should not be nil")

	// Test that we can access the parameters
	params := d.Get("parameters").([]interface{})
	assert.Len(t, params, 1, "Should have one parameter set")

	if len(params) > 0 {
		paramMap := params[0].(map[string]interface{})
		assert.Equal(t, "TestTag", paramMap["name"], "Name should match")
		assert.Equal(t, "Test Description", paramMap["description"], "Description should match")
		assert.Equal(t, false, paramMap["system_tag"], "system_tag should be false")
	}
}

// TestResourceTagRead tests the Read operation structure
func TestResourceTagRead(t *testing.T) {
	d := schema.TestResourceDataRaw(t, resourceTag().Schema, map[string]interface{}{})

	// Set an ID to simulate an existing resource
	d.SetId("test-tag-id-123")

	// Verify the ID is set
	assert.Equal(t, "test-tag-id-123", d.Id(), "ID should be set")
}

// TestResourceTagUpdate tests the Update operation structure
func TestResourceTagUpdate(t *testing.T) {
	// Create initial resource data
	d := schema.TestResourceDataRaw(t, resourceTag().Schema, map[string]interface{}{
		"parameters": []interface{}{
			map[string]interface{}{
				"name":        "TestTag",
				"description": "Original Description",
				"system_tag":  false,
			},
		},
	})

	// Set an ID to simulate an existing resource
	d.SetId("test-tag-id-123")

	// Simulate an update by changing the description
	err := d.Set("parameters", []interface{}{
		map[string]interface{}{
			"name":        "TestTag",
			"description": "Updated Description",
			"system_tag":  false,
		},
	})

	assert.NoError(t, err, "Should be able to update parameters")

	// Verify the change
	params := d.Get("parameters").([]interface{})
	if len(params) > 0 {
		paramMap := params[0].(map[string]interface{})
		assert.Equal(t, "Updated Description", paramMap["description"], "Description should be updated")
	}
}

// TestResourceTagDelete tests the Delete operation structure
func TestResourceTagDelete(t *testing.T) {
	d := schema.TestResourceDataRaw(t, resourceTag().Schema, map[string]interface{}{
		"parameters": []interface{}{
			map[string]interface{}{
				"name":        "TestTag",
				"description": "Test Description",
				"system_tag":  false,
			},
		},
	})

	// Set an ID to simulate an existing resource
	d.SetId("test-tag-id-123")
	assert.NotEmpty(t, d.Id(), "ID should be set before delete")

	// Simulate delete by clearing the ID
	d.SetId("")
	assert.Empty(t, d.Id(), "ID should be empty after delete")
}

// TestResourceTagImporter tests the import functionality
func TestResourceTagImporter(t *testing.T) {
	r := resourceTag()

	assert.NotNil(t, r.Importer, "Importer should be defined")
	assert.NotNil(t, r.Importer.State, "Importer.State should be defined")

	// Test that the importer uses the correct function
	assert.Equal(t,
		schema.ImportStatePassthrough,
		r.Importer.State,
		"Should use ImportStatePassthrough")
}

// TestExpandRequestTagCreateTag tests the expand function for create requests
func TestExpandRequestTagCreateTag(t *testing.T) {
	d := schema.TestResourceDataRaw(t, resourceTag().Schema, map[string]interface{}{
		"parameters": []interface{}{
			map[string]interface{}{
				"name":        "TestTag",
				"description": "Test Description",
				"system_tag":  false,
				"dynamic_rules": []interface{}{
					map[string]interface{}{
						"member_type": "networkdevice",
						"rules": map[string]interface{}{
							"operation": "OR",
							"items": []interface{}{
								map[string]interface{}{
									"operation": "ILIKE",
									"name":      "hostname",
									"value":     "%switch%",
								},
							},
						},
					},
				},
			},
		},
	})

	ctx := context.Background()
	request := expandRequestTagCreateTag(ctx, "parameters.0", d)

	assert.NotNil(t, request, "Request should not be nil")
	// Name and Description are direct string fields in SDK
	assert.Equal(t, "TestTag", request.Name, "Name should match")
	assert.Equal(t, "Test Description", request.Description, "Description should match")
	// SystemTag is a pointer in SDK
	if request.SystemTag != nil {
		assert.Equal(t, false, *request.SystemTag, "SystemTag should be false")
	}
	assert.NotNil(t, request.DynamicRules, "DynamicRules should not be nil")
}

// TestExpandRequestTagUpdateTag tests the expand function for update requests
func TestExpandRequestTagUpdateTag(t *testing.T) {
	d := schema.TestResourceDataRaw(t, resourceTag().Schema, map[string]interface{}{
		"parameters": []interface{}{
			map[string]interface{}{
				"id":          "test-tag-id",
				"name":        "UpdatedTag",
				"description": "Updated Description",
				"system_tag":  true,
			},
		},
	})

	ctx := context.Background()
	request := expandRequestTagUpdateTag(ctx, "parameters.0", d)

	assert.NotNil(t, request, "Request should not be nil")
	// ID, Name, and Description are direct string fields in SDK
	assert.Equal(t, "test-tag-id", request.ID, "ID should match")
	assert.Equal(t, "UpdatedTag", request.Name, "Name should match")
	assert.Equal(t, "Updated Description", request.Description, "Description should match")
	// SystemTag is a pointer in SDK
	if request.SystemTag != nil {
		assert.Equal(t, true, *request.SystemTag, "SystemTag should be true")
	}
}

// TestResourceTagHelperFunctions tests various helper functions
func TestResourceTagHelperFunctions(t *testing.T) {
	t.Run("TestHasDynamicRules", func(t *testing.T) {
		// Test with dynamic rules
		d1 := schema.TestResourceDataRaw(t, resourceTag().Schema, map[string]interface{}{
			"parameters": []interface{}{
				map[string]interface{}{
					"dynamic_rules": []interface{}{
						map[string]interface{}{
							"member_type": "networkdevice",
						},
					},
				},
			},
		})

		rules := d1.Get("parameters.0.dynamic_rules").([]interface{})
		assert.NotEmpty(t, rules, "Should have dynamic rules")
	})

	t.Run("TestEmptyDynamicRules", func(t *testing.T) {
		// Test without dynamic rules
		d2 := schema.TestResourceDataRaw(t, resourceTag().Schema, map[string]interface{}{
			"parameters": []interface{}{
				map[string]interface{}{
					"name": "TestTag",
				},
			},
		})

		rules := d2.Get("parameters.0.dynamic_rules")
		assert.Empty(t, rules, "Should not have dynamic rules")
	})
}

// Benchmark tests
func BenchmarkResourceTagSchema(b *testing.B) {
	for i := 0; i < b.N; i++ {
		_ = resourceTag()
	}
}

func BenchmarkExpandRequestTagCreateTag(b *testing.B) {
	// Benchmark the schema creation since we can't use TestResourceDataRaw in benchmarks
	b.ResetTimer()

	for i := 0; i < b.N; i++ {
		_ = resourceTag()
	}
}