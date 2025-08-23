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

# Device in error state that needs to be reset
variable "error_device" {
  description = "Device in error state that needs to be reset"
  type = object({
    serial_number = string
    hostname      = string
    pid           = string
    state         = string
  })
  default = {
    serial_number = "FOX2639PAYD"
    hostname      = "SJ-EWLC-1"
    pid           = "C9800-40-K9"
    state         = "Error"
  }
}