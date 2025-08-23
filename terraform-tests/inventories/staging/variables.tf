# Staging Environment Variables

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
  default     = false
}

variable "catalyst_ssl_verify" {
  description = "Boolean to enable or disable SSL certificate verification"
  type        = bool
  default     = true
}

# Environment-specific variables
variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "staging"
}

variable "resource_prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "stg"
}

# Resource limits for staging environment
variable "max_areas" {
  description = "Maximum number of areas to create"
  type        = number
  default     = 50
}

variable "max_buildings" {
  description = "Maximum number of buildings to create"
  type        = number
  default     = 100
}

variable "max_floors" {
  description = "Maximum number of floors to create"
  type        = number
  default     = 200
}

variable "max_devices" {
  description = "Maximum number of devices to manage"
  type        = number
  default     = 500
}

# Staging-specific feature flags
variable "enable_validation" {
  description = "Enable validation checks"
  type        = bool
  default     = true
}

variable "auto_cleanup" {
  description = "Enable automatic cleanup of resources"
  type        = bool
  default     = false
}

variable "backup_configs" {
  description = "Enable configuration backups"
  type        = bool
  default     = true
}

# Testing configuration
variable "test_timeout" {
  description = "Timeout for test operations"
  type        = string
  default     = "60m"
}

variable "retry_attempts" {
  description = "Number of retry attempts for failed operations"
  type        = number
  default     = 5
}

variable "parallel_tests" {
  description = "Number of parallel test executions"
  type        = number
  default     = 4
}