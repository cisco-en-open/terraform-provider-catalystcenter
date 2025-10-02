package catalystcenter

import (
	"os"
	"testing"

	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
)

var testAccProviders map[string]*schema.Provider
var testAccProvider *schema.Provider

func init() {
	testAccProvider = Provider()
	testAccProviders = map[string]*schema.Provider{
		"catalystcenter": testAccProvider,
	}
}

func TestProvider(t *testing.T) {
	if err := Provider().InternalValidate(); err != nil {
		t.Fatalf("err: %s", err)
	}
}

func TestProvider_impl(t *testing.T) {
	var _ *schema.Provider = Provider()
}

func testAccPreCheck(t *testing.T) {
	if v := os.Getenv("CATALYST_BASE_URL"); v == "" {
		t.Skip("CATALYST_BASE_URL must be set for acceptance tests")
	}
	if v := os.Getenv("CATALYST_USERNAME"); v == "" {
		t.Skip("CATALYST_USERNAME must be set for acceptance tests")
	}
	if v := os.Getenv("CATALYST_PASSWORD"); v == "" {
		t.Skip("CATALYST_PASSWORD must be set for acceptance tests")
	}
}

// Helper function to create test resource data
func testResourceData(t *testing.T, resourceSchema map[string]*schema.Schema, configMap map[string]interface{}) *schema.ResourceData {
	return schema.TestResourceDataRaw(t, resourceSchema, configMap)
}

// Helper function for testing schema validation
func testSchemaValidation(t *testing.T, s *schema.Schema, value interface{}, expectError bool) {
	if s.ValidateFunc == nil {
		t.Skip("No validation function defined")
		return
	}

	_, errors := s.ValidateFunc(value, "test_field")

	if expectError && len(errors) == 0 {
		t.Errorf("expected validation error for value %v, but got none", value)
	}

	if !expectError && len(errors) > 0 {
		t.Errorf("unexpected validation error for value %v: %v", value, errors)
	}
}

// Helper to test required fields in schema
func testRequiredFields(t *testing.T, s map[string]*schema.Schema, requiredFields []string) {
	for _, field := range requiredFields {
		if schema, ok := s[field]; !ok {
			t.Errorf("missing required field in schema: %s", field)
		} else if !schema.Required {
			t.Errorf("field %s should be marked as required", field)
		}
	}
}

// Helper to test optional fields in schema
func testOptionalFields(t *testing.T, s map[string]*schema.Schema, optionalFields []string) {
	for _, field := range optionalFields {
		if schema, ok := s[field]; !ok {
			t.Errorf("missing optional field in schema: %s", field)
		} else if !schema.Optional {
			t.Errorf("field %s should be marked as optional", field)
		}
	}
}

// Helper to test computed fields in schema
func testComputedFields(t *testing.T, s map[string]*schema.Schema, computedFields []string) {
	for _, field := range computedFields {
		if schema, ok := s[field]; !ok {
			t.Errorf("missing computed field in schema: %s", field)
		} else if !schema.Computed {
			t.Errorf("field %s should be marked as computed", field)
		}
	}
}

// Mock configuration for testing
type MockConfig struct {
	BaseURL  string
	Username string
	Password string
	Debug    string
	SSLVerify string
}