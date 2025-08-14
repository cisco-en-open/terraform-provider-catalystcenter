# Additional variables for unified credential approach

# Site IDs as a list for easier iteration
variable "site_ids_list" {
  description = "List of site IDs for credential assignment"
  type        = list(string)
  default     = [
    "site-id-india-placeholder",
    "site-id-bangalore-placeholder"
  ]
}

# Enhanced CLI credentials with descriptions
variable "cli_credentials" {
  description = "CLI credentials for device access"
  type = object({
    cli_1 = object({
      description     = string
      username        = string
      password        = string
      enable_password = string
    })
  })
  default = {
    cli_1 = {
      description     = "Primary CLI Credential"
      username        = "cli-1"
      password        = "5!meh"
      enable_password = "q4^t^"
    }
  }
  sensitive = true
}

# Enhanced SNMPv2c credentials with descriptions
variable "snmp_v2c_credentials" {
  description = "SNMPv2c credentials for device monitoring"
  type = object({
    read = object({
      description = string
      community   = string
    })
    write = object({
      description = string
      community   = string
    })
  })
  default = {
    read = {
      description = "SNMPv2c Read Community"
      community   = "@123"
    }
    write = {
      description = "SNMPv2c Write Community"
      community   = "#mea@"
    }
  }
  sensitive = true
}

# Same SNMPv3 credentials as main variables
variable "snmp_v3_credentials" {
  description = "SNMPv3 credentials for secure device monitoring"
  type = object({
    description      = string
    auth_password    = string
    auth_type        = string
    snmp_mode        = string
    privacy_password = string
    privacy_type     = string
    username         = string
  })
  default = {
    description      = "snmpV3 Sample 1"
    auth_password    = "hp!x6px&#@2xi5"
    auth_type        = "SHA"
    snmp_mode        = "AUTHPRIV"
    privacy_password = "ai7tpci3j@*j5g"
    privacy_type     = "AES128"
    username         = "admin"
  }
  sensitive = true
}

# Same HTTPS credentials as main variables
variable "https_credentials" {
  description = "HTTPS credentials for device management"
  type = object({
    read = object({
      description = string
      username    = string
      password    = string
      port        = number
    })
    write = object({
      description = string
      username    = string
      password    = string
      port        = number
    })
  })
  default = {
    read = {
      description = "httpsRead Sample 1"
      username    = "admin"
      password    = "2!x88yvqz*7"
      port        = 443
    }
    write = {
      description = "httpsWrite Sample 1"
      username    = "admin"
      password    = "j@5wgm%s2g%"
      port        = 443
    }
  }
  sensitive = true
}