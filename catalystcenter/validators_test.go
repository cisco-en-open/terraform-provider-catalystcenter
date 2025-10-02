package catalystcenter

import (
	"testing"
	"github.com/stretchr/testify/assert"
)

func TestValidateStringIsValueFunc(t *testing.T) {
	tests := []struct {
		name          string
		requiredValue string
		inputValue    interface{}
		inputKey      string
		expectError   bool
	}{
		{
			name:          "valid matching value",
			requiredValue: "true",
			inputValue:    "true",
			inputKey:      "test_field",
			expectError:   false,
		},
		{
			name:          "invalid non-matching value",
			requiredValue: "true",
			inputValue:    "false",
			inputKey:      "test_field",
			expectError:   true,
		},
		{
			name:          "case sensitive validation",
			requiredValue: "True",
			inputValue:    "true",
			inputKey:      "test_field",
			expectError:   true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			validator := validateStringIsValueFunc(tt.requiredValue)
			warnings, errors := validator(tt.inputValue, tt.inputKey)

			assert.Empty(t, warnings, "unexpected warnings")

			if tt.expectError {
				assert.NotEmpty(t, errors, "expected error but got none")
			} else {
				assert.Empty(t, errors, "unexpected error")
			}
		})
	}
}

func TestValidateStringHasValueFunc(t *testing.T) {
	tests := []struct {
		name          string
		allowedValues []string
		inputValue    interface{}
		inputKey      string
		expectError   bool
	}{
		{
			name:          "valid value in list",
			allowedValues: []string{"value1", "value2", "value3"},
			inputValue:    "value2",
			inputKey:      "test_field",
			expectError:   false,
		},
		{
			name:          "invalid value not in list",
			allowedValues: []string{"value1", "value2", "value3"},
			inputValue:    "value4",
			inputKey:      "test_field",
			expectError:   true,
		},
		{
			name:          "empty allowed values",
			allowedValues: []string{},
			inputValue:    "any",
			inputKey:      "test_field",
			expectError:   true,
		},
		{
			name:          "case sensitive check",
			allowedValues: []string{"Value1", "Value2"},
			inputValue:    "value1",
			inputKey:      "test_field",
			expectError:   true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			validator := validateStringHasValueFunc(tt.allowedValues)
			warnings, errors := validator(tt.inputValue, tt.inputKey)

			assert.Empty(t, warnings, "unexpected warnings")

			if tt.expectError {
				assert.NotEmpty(t, errors, "expected error but got none")
			} else {
				assert.Empty(t, errors, "unexpected error")
			}
		})
	}
}

func TestValidateIntegerInRange(t *testing.T) {
	tests := []struct {
		name        string
		min         int
		max         int
		inputValue  interface{}
		inputKey    string
		expectError bool
	}{
		{
			name:        "valid value in range",
			min:         1,
			max:         10,
			inputValue:  5,
			inputKey:    "test_field",
			expectError: false,
		},
		{
			name:        "valid value at min boundary",
			min:         1,
			max:         10,
			inputValue:  1,
			inputKey:    "test_field",
			expectError: false,
		},
		{
			name:        "valid value at max boundary",
			min:         1,
			max:         10,
			inputValue:  10,
			inputKey:    "test_field",
			expectError: false,
		},
		{
			name:        "invalid value below range",
			min:         1,
			max:         10,
			inputValue:  0,
			inputKey:    "test_field",
			expectError: true,
		},
		{
			name:        "invalid value above range",
			min:         1,
			max:         10,
			inputValue:  11,
			inputKey:    "test_field",
			expectError: true,
		},
		{
			name:        "string input convertible to int",
			min:         1,
			max:         10,
			inputValue:  "5",
			inputKey:    "test_field",
			expectError: false,
		},
		{
			name:        "invalid string input",
			min:         1,
			max:         10,
			inputValue:  "not_a_number",
			inputKey:    "test_field",
			expectError: true,
		},
		{
			name:        "negative range",
			min:         -10,
			max:         -1,
			inputValue:  -5,
			inputKey:    "test_field",
			expectError: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			validator := validateIntegerInRange(tt.min, tt.max)
			warnings, errors := validator(tt.inputValue, tt.inputKey)

			assert.Empty(t, warnings, "unexpected warnings")

			if tt.expectError {
				assert.NotEmpty(t, errors, "expected error but got none")
			} else {
				assert.Empty(t, errors, "unexpected error")
			}
		})
	}
}

// TestListNicely tests the listNicely helper function
func TestListNicely(t *testing.T) {
	tests := []struct {
		name     string
		input    []string
		expected string
	}{
		{
			name:     "single item",
			input:    []string{"item1"},
			expected: "item1",
		},
		{
			name:     "two items",
			input:    []string{"item1", "item2"},
			expected: "item1 or item2",
		},
		{
			name:     "three items",
			input:    []string{"item1", "item2", "item3"},
			expected: "item1, item2 or item3",
		},
		{
			name:     "many items",
			input:    []string{"a", "b", "c", "d", "e"},
			expected: "a, b, c, d or e",
		},
		{
			name:     "empty list",
			input:    []string{},
			expected: "",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := listNicely(tt.input)
			assert.Equal(t, tt.expected, result)
		})
	}
}

// Benchmark tests for performance measurement
func BenchmarkValidateStringIsValueFunc(b *testing.B) {
	validator := validateStringIsValueFunc("true")
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		_, _ = validator("true", "test_field")
	}
}

func BenchmarkValidateStringHasValueFunc(b *testing.B) {
	validator := validateStringHasValueFunc([]string{"val1", "val2", "val3", "val4", "val5"})
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		_, _ = validator("val3", "test_field")
	}
}

func BenchmarkValidateIntegerInRange(b *testing.B) {
	validator := validateIntegerInRange(1, 100)
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		_, _ = validator(50, "test_field")
	}
}