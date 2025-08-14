# CLI Credentials Variables
variable "cli_credentials" {
  description = "CLI credentials for device access"
  type = object({
    cli_1 = object({
      username        = string
      password        = string
      enable_password = string
    })
    cli_2 = object({
      username        = string
      password        = string
      enable_password = string
    })
  })
  default = {
    cli_1 = {
      username        = "cli-1"
      password        = "5!meh"
      enable_password = "q4^t^"
    }
    cli_2 = {
      username        = "cli-2"
      password        = "sbs2@"
      enable_password = "8b!rn"
    }
  }
  sensitive = true
}

# SNMPv2c Credentials Variables
variable "snmp_v2c_credentials" {
  description = "SNMPv2c credentials for device monitoring"
  type = object({
    read = object({
      community = string
    })
    write = object({
      community = string
    })
  })
  default = {
    read = {
      community = "@123"
    }
    write = {
      community = "#mea@"
    }
  }
  sensitive = true
}

# SNMPv3 Credentials Variables
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

# HTTPS Credentials Variables
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

# Netconf Credentials Variables
variable "netconf_credentials" {
  description = "Netconf credentials for device configuration"
  type = object({
    description = string
    username    = string
    password    = string
    port        = number
  })
  default = {
    description = "Netconf Sample 1"
    username    = "admin"
    password    = "netconf123!"
    port        = 830
  }
  sensitive = true
}

# Site IDs for credential assignment
variable "site_ids" {
  description = "Site IDs for credential assignment"
  type = object({
    india     = string
    bangalore = string
  })
  # These would need to be provided based on actual site hierarchy
  default = {
    india     = "site-id-india-placeholder"
    bangalore = "site-id-bangalore-placeholder"
  }
}