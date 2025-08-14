# Provision Workflow Variables
# Variables for device provision, re-provision, un-provision, and site assignment operations

# Site hierarchy for provisioning
variable "site_name_hierarchy" {
  description = "Site hierarchy path for device assignment and provisioning"
  type        = string
  default     = "Global/USA/SAN JOSE/SJ_BLD23"
}

# Wired Device Provision Configuration
variable "wired_device_provision" {
  description = "Configuration for wired device provision workflow"
  type = object({
    enabled             = bool
    management_ip       = string
    provisioning        = optional(bool, true)
    force_provisioning  = optional(bool, false)
  })
  default = {
    enabled         = true
    management_ip   = "204.1.2.5"
    provisioning    = true
    force_provisioning = false
  }
}

# Site Assignment Only Configuration (no provisioning)
variable "site_assignment_only" {
  description = "Configuration for site assignment without provisioning"
  type = object({
    enabled       = bool
    management_ip = string
  })
  default = {
    enabled       = true
    management_ip = "204.1.2.6"
  }
}

# Device Re-provision Configuration
variable "device_reprovision" {
  description = "Configuration for device re-provision workflow"
  type = object({
    enabled       = bool
    management_ip = string
  })
  default = {
    enabled       = false
    management_ip = "204.1.2.7"
  }
}

# Wireless Device Provision Configuration
variable "wireless_device_provision" {
  description = "Configuration for wireless device provision workflow"
  type = object({
    enabled              = bool
    management_ip        = string
    managed_ap_locations = list(string)
    force_provisioning   = optional(bool, false)
  })
  default = {
    enabled       = false
    management_ip = "204.192.4.200"
    managed_ap_locations = [
      "Global/USA/SAN JOSE/SJ_BLD23/FLOOR1",
      "Global/USA/SAN JOSE/SJ_BLD23/FLOOR2",
      "Global/USA/SAN JOSE/SJ_BLD23/FLOOR3",
      "Global/USA/SAN JOSE/SJ_BLD23/FLOOR4"
    ]
    force_provisioning = false
  }
}

# Application Telemetry Configuration
variable "application_telemetry" {
  description = "Configuration for application telemetry on devices"
  type = object({
    enabled    = bool
    device_ips = list(string)
    wired_config = object({
      telemetry = string
    })
    wireless_config = optional(object({
      telemetry          = string
      wlan_mode          = string
      include_guest_ssid = bool
    }))
  })
  default = {
    enabled = true
    device_ips = [
      "204.1.2.1",
      "204.1.2.3"
    ]
    wired_config = {
      telemetry = "enable"
    }
    wireless_config = {
      telemetry          = "enable"
      wlan_mode          = "LOCAL"
      include_guest_ssid = true
    }
  }
}

# Common Variables for Cisco Catalyst Center Provider
variable "catalyst_username" {
  description = "Cisco Catalyst Center username"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "catalyst_password" {
  description = "Cisco Catalyst Center password"
  type        = string
  default     = "admin123"
  sensitive   = true
}

variable "catalyst_base_url" {
  description = "Cisco Catalyst Center base URL, FQDN or IP"
  type        = string
  default     = "https://172.168.196.2"
}

variable "catalyst_debug" {
  description = "Boolean to enable debugging"
  type        = string
  default     = "true"  # Default to true for provision workflows as they can be complex
}

variable "catalyst_ssl_verify" {
  description = "Boolean to enable or disable SSL certificate verification"
  type        = string
  default     = "false"
}

variable "timeout_settings" {
  description = "Timeout settings for provisioning operations"
  type = object({
    provision_timeout   = number
    unprovision_timeout = number
  })
  default = {
    provision_timeout   = 600  # 10 minutes
    unprovision_timeout = 300  # 5 minutes
  }
}