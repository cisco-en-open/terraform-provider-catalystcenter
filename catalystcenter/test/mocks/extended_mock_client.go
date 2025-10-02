package mocks

import (
    "github.com/stretchr/testify/mock"
)

// ExtendedMockClient provides mocks for all services
type ExtendedMockClient struct {
    mock.Mock
}

// Generic mock response generator
func (m *ExtendedMockClient) ExecuteOperation(operation string, params interface{}) (interface{}, error) {
    args := m.Called(operation, params)
    return args.Get(0), args.Error(1)
}

// CreateMockResponse generates mock responses
func CreateMockResponse(resourceType string) interface{} {
    responses := map[string]interface{}{
        "tag": map[string]interface{}{
            "id": "mock-id",
            "name": "mock-name",
        },
        "device": map[string]interface{}{
            "id": "device-id",
            "hostname": "mock-device",
        },
        "default": map[string]interface{}{
            "status": "success",
        },
    }

    if resp, ok := responses[resourceType]; ok {
        return resp
    }
    return responses["default"]
}
