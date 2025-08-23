# Common Variables for Cisco Catalyst Center Terraform Provider
# This file contains variables that are commonly used across multiple use cases.
# Each use case can include this file to avoid duplicating common variable definitions.

variable "catalyst_username" {
  description = "Cisco Catalyst Center username"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "catalyst_password" {
  description = "Cisco Catalyst Center password"
  type        = string
  default     = "Maglev1@3"
  sensitive   = true
}

variable "catalyst_base_url" {
  description = "Cisco Catalyst Center base URL, FQDN or IP"
  type        = string
  default     = "https://10.22.40.189"
}

variable "catalyst_debug" {
  description = "Boolean to enable debugging"
  type        = string
  default     = "true"
}

variable "catalyst_ssl_verify" {
  description = "Boolean to enable or disable SSL certificate verification"
  type        = string
  default     = "false"
}