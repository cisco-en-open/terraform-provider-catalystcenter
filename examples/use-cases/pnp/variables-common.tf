# Common variable definitions for PnP test suite

variable "catalyst_center_host" {
  description = "Cisco Catalyst Center FQDN or IP address"
  type        = string
}

variable "catalyst_center_username" {
  description = "Cisco Catalyst Center username"
  type        = string
}

variable "catalyst_center_password" {
  description = "Cisco Catalyst Center password"
  type        = string
  sensitive   = true
}

variable "catalyst_center_port" {
  description = "Cisco Catalyst Center port"
  type        = number
  default     = 443
}

variable "catalyst_center_debug" {
  description = "Enable debugging"
  type        = string
  default     = "false"
}

variable "catalyst_center_ssl_verify" {
  description = "Enable SSL certificate verification"
  type        = string
  default     = "false"
}

variable "catalyst_center_version" {
  description = "Cisco Catalyst Center API version"
  type        = string
  default     = "2.3.7.6"
}

variable "site_hierarchy" {
  description = "Site hierarchy definitions"
  type        = map(string)
  default     = {}
}

variable "onboarding_project_name" {
  description = "Name of the onboarding project"
  type        = string
  default     = "Onboarding Configuration"
}

variable "images" {
  description = "Device image names"
  type        = map(string)
  default     = {}
}

variable "templates" {
  description = "Device template names"  
  type        = map(string)
  default     = {}
}

variable "rf_profiles" {
  description = "RF profile names for access points"
  type        = map(string)
  default     = {}
}