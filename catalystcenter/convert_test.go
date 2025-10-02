package catalystcenter

import (
	"testing"
	"github.com/stretchr/testify/assert"
)

// TestInterfaceToString tests the interfaceToString function
func TestInterfaceToString(t *testing.T) {
	tests := []struct {
		name     string
		input    interface{}
		expected string
	}{
		{"string input", "test string", "test string"},
		{"integer input", 42, "42"},
		{"float input", 3.14, "3.14"},
		{"boolean true", true, "true"},
		{"boolean false", false, "false"},
		{"nil input", nil, "<nil>"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := interfaceToString(tt.input)
			assert.Equal(t, tt.expected, result)
		})
	}
}

// TestInterfaceToIntPtr tests the interfaceToIntPtr function
func TestInterfaceToIntPtr(t *testing.T) {
	val := 42
	tests := []struct {
		name     string
		input    interface{}
		expected *int
		isNil    bool
	}{
		{"valid string", "42", &val, false},
		{"integer", 42, &val, false},
		{"invalid string", "invalid", nil, true},
		{"nil input", nil, nil, true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := interfaceToIntPtr(tt.input)
			if tt.isNil {
				assert.Nil(t, result)
			} else {
				assert.NotNil(t, result)
				if result != nil && tt.expected != nil {
					assert.Equal(t, *tt.expected, *result)
				}
			}
		})
	}
}

// TestInterfaceToFloat64Ptr tests the interfaceToFloat64Ptr function
func TestInterfaceToFloat64Ptr(t *testing.T) {
	val := 3.14
	tests := []struct {
		name     string
		input    interface{}
		expected *float64
		isNil    bool
	}{
		{"valid string", "3.14", &val, false},
		{"float64", 3.14, &val, false},
		{"invalid string", "invalid", nil, true},
		{"nil input", nil, nil, true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := interfaceToFloat64Ptr(tt.input)
			if tt.isNil {
				assert.Nil(t, result)
			} else {
				assert.NotNil(t, result)
				if result != nil && tt.expected != nil {
					assert.InDelta(t, *tt.expected, *result, 0.001)
				}
			}
		})
	}
}

// TestInterfaceToBoolPtr tests the interfaceToBoolPtr function
func TestInterfaceToBoolPtr(t *testing.T) {
	trueVal := true
	falseVal := false
	tests := []struct {
		name     string
		input    interface{}
		expected *bool
		isNil    bool
	}{
		{"true string", "true", &trueVal, false},
		{"false string", "false", &falseVal, false},
		{"boolean true", true, &trueVal, false},
		{"boolean false", false, &falseVal, false},
		{"nil input", nil, nil, true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := interfaceToBoolPtr(tt.input)
			if tt.isNil {
				assert.Nil(t, result)
			} else {
				assert.NotNil(t, result)
				if result != nil && tt.expected != nil {
					assert.Equal(t, *tt.expected, *result)
				}
			}
		})
	}
}

// TestInterfaceToBool tests the interfaceToBool function
func TestInterfaceToBool(t *testing.T) {
	tests := []struct {
		name     string
		input    interface{}
		expected bool
	}{
		{"true string", "true", true},
		{"false string", "false", false},
		{"boolean true", true, true},
		{"boolean false", false, false},
		{"nil input", nil, false},
		{"other input", 1, false},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := interfaceToBool(tt.input)
			assert.Equal(t, tt.expected, result)
		})
	}
}

// TestBoolPtrToString tests the boolPtrToString function
func TestBoolPtrToString(t *testing.T) {
	trueVal := true
	falseVal := false
	tests := []struct {
		name     string
		input    *bool
		expected string
	}{
		{"true pointer", &trueVal, "true"},
		{"false pointer", &falseVal, "false"},
		{"nil pointer", nil, ""},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := boolPtrToString(tt.input)
			assert.Equal(t, tt.expected, result)
		})
	}
}

// TestInterfaceToSliceString tests the interfaceToSliceString function
func TestInterfaceToSliceString(t *testing.T) {
	tests := []struct {
		name     string
		input    interface{}
		expected []string
		isNil    bool
	}{
		{"slice of strings", []string{"a", "b", "c"}, []string{"a", "b", "c"}, false},
		{"slice of interfaces", []interface{}{"a", "b", 3}, []string{"a", "b", "3"}, false},
		{"nil input", nil, nil, true},
		{"non-slice input", "not a slice", nil, true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := interfaceToSliceString(tt.input)
			if tt.isNil {
				assert.Nil(t, result)
			} else {
				assert.Equal(t, tt.expected, result)
			}
		})
	}
}

// TestMapInterfaceToMapString tests the mapInterfaceToMapString function
func TestMapInterfaceToMapString(t *testing.T) {
	tests := []struct {
		name     string
		input    map[string]interface{}
		expected map[string]string
	}{
		{
			name:     "mixed types",
			input:    map[string]interface{}{"key1": "value1", "key2": 42, "key3": true},
			expected: map[string]string{"key1": "value1", "key2": "42", "key3": "true"},
		},
		{
			name:     "empty map",
			input:    map[string]interface{}{},
			expected: map[string]string{},
		},
		{
			name:     "nil map",
			input:    nil,
			expected: map[string]string{},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := mapInterfaceToMapString(tt.input)
			assert.Equal(t, tt.expected, result)
		})
	}
}

// TestGetResourceItem tests the getResourceItem function
func TestGetResourceItem(t *testing.T) {
	tests := []struct {
		name     string
		input    interface{}
		isNil    bool
	}{
		{"valid map", map[string]interface{}{"key": "value"}, false},
		{"nil input", nil, true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := getResourceItem(tt.input)
			if tt.isNil {
				assert.Nil(t, result)
			} else {
				assert.NotNil(t, result)
			}
		})
	}
}

// TestGetResourceItems tests the getResourceItems function
func TestGetResourceItems(t *testing.T) {
	tests := []struct {
		name     string
		input    interface{}
		expected int
		isNil    bool
	}{
		{"slice of maps", []interface{}{map[string]interface{}{"key": "value"}}, 1, false},
		{"empty slice", []interface{}{}, 0, false},
		{"nil input", nil, 0, true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := getResourceItems(tt.input)
			if tt.isNil {
				assert.Nil(t, result)
			} else {
				assert.NotNil(t, result)
				assert.Len(t, *result, tt.expected)
			}
		})
	}
}

// TestResponseInterfaceToFloat64 tests the responseInterfaceToFloat64 function
func TestResponseInterfaceToFloat64(t *testing.T) {
	tests := []struct {
		name     string
		input    interface{}
		expected float64
	}{
		{"float64", 3.14, 3.14},
		{"string float", "3.14", 3.14},
		{"integer", 42, 42.0},
		{"string integer", "42", 42.0},
		{"invalid string", "invalid", 0},
		{"nil", nil, 0},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := responseInterfaceToFloat64(tt.input)
			assert.InDelta(t, tt.expected, result, 0.001)
		})
	}
}

// Benchmark tests for performance measurement
func BenchmarkInterfaceToString(b *testing.B) {
	for i := 0; i < b.N; i++ {
		_ = interfaceToString("test")
	}
}

func BenchmarkMapInterfaceToMapString(b *testing.B) {
	testMap := map[string]interface{}{
		"key1": "value1",
		"key2": 42,
		"key3": true,
	}
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		_ = mapInterfaceToMapString(testMap)
	}
}