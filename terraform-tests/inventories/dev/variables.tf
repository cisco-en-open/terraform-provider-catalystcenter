# Development Environment Variables

# Catalyst Center connection variables
variable "catalyst_username" {
  description = "Cisco Catalyst Center username"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "catalyst_password" {
  description = "Cisco Catalyst Center password"
  type        = string
  sensitive   = true
}

variable "catalyst_base_url" {
  description = "Cisco Catalyst Center base URL, FQDN or IP"
  type        = string
}

variable "catalyst_debug" {
  description = "Boolean to enable debugging"
  type        = bool
  default     = true
}

variable "catalyst_ssl_verify" {
  description = "Boolean to enable or disable SSL certificate verification"
  type        = bool
  default     = false
}

# Environment-specific variables
variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "dev"
}

variable "resource_prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "dev"
}

# Resource limits for development environment
variable "max_areas" {
  description = "Maximum number of areas to create"
  type        = number
  default     = 10
}

variable "max_buildings" {
  description = "Maximum number of buildings to create"
  type        = number
  default     = 20
}

variable "max_floors" {
  description = "Maximum number of floors to create"
  type        = number
  default     = 50
}

variable "max_devices" {
  description = "Maximum number of devices to manage"
  type        = number
  default     = 100
}

# Development-specific feature flags
variable "enable_validation" {
  description = "Enable validation checks"
  type        = bool
  default     = true
}

variable "auto_cleanup" {
  description = "Enable automatic cleanup of resources"
  type        = bool
  default     = true
}

variable "backup_configs" {
  description = "Enable configuration backups"
  type        = bool
  default     = false
}

# Testing configuration
variable "test_timeout" {
  description = "Timeout for test operations"
  type        = string
  default     = "30m"
}

variable "retry_attempts" {
  description = "Number of retry attempts for failed operations"
  type        = number
  default     = 3
}

variable "parallel_tests" {
  description = "Number of parallel test executions"
  type        = number
  default     = 2
}