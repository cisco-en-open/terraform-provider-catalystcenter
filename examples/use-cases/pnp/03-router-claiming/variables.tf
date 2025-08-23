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

# Router-specific variables
variable "router_device" {
  description = "Router device information"
  type = object({
    serial_number = string
    hostname      = string
    pid           = string
  })
  default = {
    serial_number = "FXS2502Q2HC"
    hostname      = "SF-BN-2-ASR.cisco.local"
    pid           = "ASR1001-X"
  }
}

variable "router_config" {
  description = "Router configuration parameters"
  type = object({
    site_name     = string
    project_name  = string
    template_name = string
    image_name    = string
  })
  default = {
    site_name     = "Global/USA/SAN-FRANCISCO/BLD_SF1"
    project_name  = "Onboarding Configuration"
    template_name = "PnP-Devices_SF-ISR_No-Vars"
    image_name    = "isr4400-universalk9.17.12.02.SPA.bin"
  }
}