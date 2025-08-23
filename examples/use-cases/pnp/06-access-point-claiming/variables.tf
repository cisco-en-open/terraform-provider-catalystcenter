# Include common variables
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

# Access Point device information
variable "ap_device" {
  description = "Access point device information"
  type = object({
    serial_number = string
    hostname      = string
    pid           = string
  })
  default = {
    serial_number = "FGL2402LCYH"
    hostname      = "NY-AP1-C9120AXE"
    pid           = "C9120AXE-E"
  }
}

# Access Point configuration
variable "ap_config" {
  description = "Access point configuration parameters"
  type = object({
    site_name  = string
    rf_profile = string
    pnp_type   = string
  })
  default = {
    site_name  = "Global/USA/New York/NY_BLD2/FLOOR1"
    rf_profile = "HIGH"
    pnp_type   = "AccessPoint"
  }
}