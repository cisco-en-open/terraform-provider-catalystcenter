# Network Compliance Workflow Variables
# These variables define the network compliance configuration

#####################################
# Device Selection Variables
#####################################

variable "ip_address_list" {
  description = "List of IP addresses of devices to run compliance checks on or synchronize device configurations"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.ip_address_list) > 0 || var.site_name != ""
    error_message = "Either ip_address_list must contain at least one IP address or site_name must be specified."
  }
}

variable "site_name" {
  description = "Site name hierarchy to run compliance checks on all devices within the site"
  type        = string
  default     = ""
}

#####################################
# Compliance Check Variables
#####################################

variable "run_compliance" {
  description = "Determines if a compliance check should be triggered on the specified devices"
  type        = bool
  default     = true
}

variable "run_compliance_categories" {
  description = "List of compliance categories to check. Valid values: INTENT, RUNNING_CONFIG, IMAGE, PSIRT, EOX, NETWORK_SETTINGS"
  type        = list(string)
  default     = ["INTENT", "RUNNING_CONFIG"]

  validation {
    condition = alltrue([
      for category in var.run_compliance_categories :
      contains(["INTENT", "RUNNING_CONFIG", "IMAGE", "PSIRT", "EOX", "NETWORK_SETTINGS"], category)
    ])
    error_message = "Valid compliance categories are: INTENT, RUNNING_CONFIG, IMAGE, PSIRT, EOX, NETWORK_SETTINGS."
  }
}

variable "trigger_full_compliance" {
  description = "If true, compliance will be triggered for all categories. If false, only categories specified in run_compliance_categories will be checked"
  type        = bool
  default     = false
}

#####################################
# Remediation Variables
#####################################

variable "remediate_compliance_issues" {
  description = "Determines whether to remediate compliance issues found during compliance check"
  type        = bool
  default     = false
}

variable "sync_device_config" {
  description = "Determines whether to synchronize device configuration (startup config with running config)"
  type        = bool
  default     = false
}

#####################################
# Timeout Variables
#####################################

variable "compliance_timeout" {
  description = "Timeout for compliance check operations"
  type        = string
  default     = "30m"
}

variable "remediation_timeout" {
  description = "Timeout for remediation operations"
  type        = string
  default     = "45m"
}

variable "sync_timeout" {
  description = "Timeout for device configuration sync operations"
  type        = string
  default     = "15m"
}

#####################################
# Debugging Variables
#####################################

variable "enable_debug" {
  description = "Enable debug mode for detailed logging"
  type        = bool
  default     = false
}

#####################################
# Common Provider Variables (inherited from common)
#####################################

variable "catalystcenter_host" {
  description = "Cisco Catalyst Center host/IP address"
  type        = string
  sensitive   = true
}

variable "catalystcenter_username" {
  description = "Username for Cisco Catalyst Center authentication"
  type        = string
  sensitive   = true
}

variable "catalystcenter_password" {
  description = "Password for Cisco Catalyst Center authentication"
  type        = string
  sensitive   = true
}

variable "catalystcenter_port" {
  description = "Port for Cisco Catalyst Center API"
  type        = number
  default     = 443
}

variable "catalystcenter_version" {
  description = "Cisco Catalyst Center API version"
  type        = string
  default     = "2.3.7.6"
}

variable "catalystcenter_verify" {
  description = "Whether to verify SSL certificates"
  type        = bool
  default     = false
}

variable "catalystcenter_debug" {
  description = "Enable debug logging for provider"
  type        = bool
  default     = false
}