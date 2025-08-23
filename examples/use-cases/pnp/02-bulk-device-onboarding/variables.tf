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

# Test-specific variables for bulk onboarding
variable "test_devices" {
  description = "List of test devices for bulk onboarding"
  type = list(object({
    serial_number = string
    hostname      = string
    pid           = string
    type          = string
  }))
  default = [
    {
      serial_number = "FXS2502Q2HC"
      hostname      = "SF-BN-2-ASR.cisco.local"
      pid           = "ASR1001-X"
      type          = "router"
    },
    {
      serial_number = "FJC271923AK"
      hostname      = "NY-EN-9300"
      pid           = "C9300-48UXM"
      type          = "switch"
    },
    {
      serial_number = "FOX2639PAYD"
      hostname      = "SJ-EWLC-1.cisco.local"
      pid           = "C9800-40-K9"
      type          = "wireless_controller"
    }
  ]
}