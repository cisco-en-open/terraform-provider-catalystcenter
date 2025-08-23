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

# Switch-specific variables
variable "switch_device" {
  description = "Switch device information"
  type = object({
    serial_number = string
    hostname      = string
    pid           = string
    stack         = string
  })
  default = {
    serial_number = "FJC272127LW"
    hostname      = "DC-FR-9300.cisco.local"
    pid           = "C9300-48T"
    stack         = "false"
  }
}

variable "switch_config" {
  description = "Switch configuration parameters"
  type = object({
    site_name     = string
    project_name  = string
    template_name = string
    image_name    = string
    template_params = object({
      PNP_VLAN_ID  = string
      LOOPBACK_IP  = string
    })
    pnp_type = string
  })
  default = {
    site_name     = "Global/USA/SAN JOSE/SJ_BLD21"
    project_name  = "Onboarding Configuration"
    template_name = "PnP-Devices-SW"
    image_name    = "cat9k_iosxe.17.12.04.SPA.bin"
    template_params = {
      PNP_VLAN_ID = "2000"
      LOOPBACK_IP = "204.1.2.100"
    }
    pnp_type = "StackSwitch"
  }
}

# Alternative switch configuration for different site
variable "switch_device_alt" {
  description = "Alternative switch device information"
  type = object({
    serial_number = string
    hostname      = string
    pid           = string
    stack         = string
  })
  default = {
    serial_number = "FJC271925Q1"
    hostname      = "NY-EN-9300"
    pid           = "C9300-48UXM"
    stack         = "false"
  }
}

variable "switch_config_alt" {
  description = "Alternative switch configuration parameters"
  type = object({
    site_name     = string
    project_name  = string
    template_name = string
    image_name    = string
    template_params = object({
      PNP_VLAN_ID  = string
      LOOPBACK_IP  = string
    })
    pnp_type = string
  })
  default = {
    site_name     = "Global/USA/New York/NY_BLD1"
    project_name  = "Onboarding Configuration"
    template_name = "PnP-Devices-SW"
    image_name    = "cat9k_iosxe.17.12.02.SPA.bin"
    template_params = {
      PNP_VLAN_ID = "2005"
      LOOPBACK_IP = "204.1.2.2"
    }
    pnp_type = "StackSwitch"
  }
}