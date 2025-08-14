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
  default     = "false"
}

variable "catalyst_ssl_verify" {
  description = "Boolean to enable or disable SSL certificate verification"
  type        = string
  default     = "false"
}