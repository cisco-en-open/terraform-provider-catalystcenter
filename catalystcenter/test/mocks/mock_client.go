package mocks

import (
	"github.com/stretchr/testify/mock"
	catalystcentersdkgo "github.com/cisco-en-programmability/catalystcenter-go-sdk/v3/sdk"
	"github.com/go-resty/resty/v2"
)

// MockCatalystClient is a mock implementation of the Catalyst Center SDK client
type MockCatalystClient struct {
	mock.Mock
	TagService  *MockTagService
	TaskService *MockTaskService
}

// MockTagService mocks the Tag service
type MockTagService struct {
	mock.Mock
}

// MockTaskService mocks the Task service
type MockTaskService struct {
	mock.Mock
}

// GetTagByID mocks the GetTagByID method
func (m *MockTagService) GetTagByID(id string) (*catalystcentersdkgo.ResponseTagGetTagByID, *resty.Response, error) {
	args := m.Called(id)

	var resp *catalystcentersdkgo.ResponseTagGetTagByID
	if args.Get(0) != nil {
		resp = args.Get(0).(*catalystcentersdkgo.ResponseTagGetTagByID)
	}

	var restyResp *resty.Response
	if args.Get(1) != nil {
		restyResp = args.Get(1).(*resty.Response)
	}

	return resp, restyResp, args.Error(2)
}

// CreateTag mocks the CreateTag method
func (m *MockTagService) CreateTag(request *catalystcentersdkgo.RequestTagCreateTag) (*catalystcentersdkgo.ResponseTagCreateTag, *resty.Response, error) {
	args := m.Called(request)

	var resp *catalystcentersdkgo.ResponseTagCreateTag
	if args.Get(0) != nil {
		resp = args.Get(0).(*catalystcentersdkgo.ResponseTagCreateTag)
	}

	var restyResp *resty.Response
	if args.Get(1) != nil {
		restyResp = args.Get(1).(*resty.Response)
	}

	return resp, restyResp, args.Error(2)
}

// UpdateTag mocks the UpdateTag method
func (m *MockTagService) UpdateTag(request *catalystcentersdkgo.RequestTagUpdateTag) (*catalystcentersdkgo.ResponseTagUpdateTag, *resty.Response, error) {
	args := m.Called(request)

	var resp *catalystcentersdkgo.ResponseTagUpdateTag
	if args.Get(0) != nil {
		resp = args.Get(0).(*catalystcentersdkgo.ResponseTagUpdateTag)
	}

	var restyResp *resty.Response
	if args.Get(1) != nil {
		restyResp = args.Get(1).(*resty.Response)
	}

	return resp, restyResp, args.Error(2)
}

// DeleteTag mocks the DeleteTag method
func (m *MockTagService) DeleteTag(id string) (*catalystcentersdkgo.ResponseTagDeleteTag, *resty.Response, error) {
	args := m.Called(id)

	var resp *catalystcentersdkgo.ResponseTagDeleteTag
	if args.Get(0) != nil {
		resp = args.Get(0).(*catalystcentersdkgo.ResponseTagDeleteTag)
	}

	var restyResp *resty.Response
	if args.Get(1) != nil {
		restyResp = args.Get(1).(*resty.Response)
	}

	return resp, restyResp, args.Error(2)
}

// GetTag mocks the GetTag method
func (m *MockTagService) GetTag(params *catalystcentersdkgo.GetTagQueryParams) (*catalystcentersdkgo.ResponseTagGetTag, *resty.Response, error) {
	args := m.Called(params)

	var resp *catalystcentersdkgo.ResponseTagGetTag
	if args.Get(0) != nil {
		resp = args.Get(0).(*catalystcentersdkgo.ResponseTagGetTag)
	}

	var restyResp *resty.Response
	if args.Get(1) != nil {
		restyResp = args.Get(1).(*resty.Response)
	}

	return resp, restyResp, args.Error(2)
}

// GetTaskByID mocks the GetTaskByID method
func (m *MockTaskService) GetTaskByID(taskID string) (*catalystcentersdkgo.ResponseTaskGetTaskByID, *resty.Response, error) {
	args := m.Called(taskID)

	var resp *catalystcentersdkgo.ResponseTaskGetTaskByID
	if args.Get(0) != nil {
		resp = args.Get(0).(*catalystcentersdkgo.ResponseTaskGetTaskByID)
	}

	var restyResp *resty.Response
	if args.Get(1) != nil {
		restyResp = args.Get(1).(*resty.Response)
	}

	return resp, restyResp, args.Error(2)
}

// NewMockClient creates a new mock client with initialized services
func NewMockClient() *MockCatalystClient {
	client := &MockCatalystClient{}
	client.TagService = &MockTagService{}
	client.TaskService = &MockTaskService{}
	return client
}