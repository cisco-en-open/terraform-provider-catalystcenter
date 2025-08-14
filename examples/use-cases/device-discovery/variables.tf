# Global Credential IDs
# These should reference existing global credentials in Catalyst Center
variable "global_credential_id_list" {
  description = "List of global credential IDs for device discovery"
  type        = list(string)
  default = [
    # These are placeholder IDs - replace with actual global credential IDs from your Catalyst Center
    "credential-id-cli-1",
    "credential-id-snmp-1",
    "credential-id-https-1"
  ]
}

# CDP Discovery Configuration
variable "cdp_discovery" {
  description = "CDP-based device discovery configuration"
  type = object({
    discovery_name   = string
    discovery_type   = string
    ip_address_list  = list(string)
    protocol_order   = string
    retry           = number
    cdp_level       = number
    net_conf_port   = string
  })
  default = {
    discovery_name   = "CDP Based Discovery1"
    discovery_type   = "CDP"
    ip_address_list  = ["204.101.16.1"]
    protocol_order   = "ssh"
    retry           = 2
    cdp_level       = 3
    net_conf_port   = "830"
  }
}

# Single IP Discovery 1 Configuration
variable "single_ip_discovery_1" {
  description = "Single IP discovery configuration with basic credentials"
  type = object({
    discovery_name = string
    discovery_type = string
    ip_address_list = list(string)
    protocol_order = string
    retry = number
    net_conf_port = string
    http_read_credential = object({
      username = string
      password = string
      port = number
      secure = bool
    })
    http_write_credential = object({
      username = string
      password = string
      port = number
      secure = bool
    })
  })
  default = {
    discovery_name   = "Single IP Discovery11"
    discovery_type   = "Single"
    ip_address_list  = ["204.101.16.1"]
    protocol_order   = "ssh"
    retry           = 2
    net_conf_port   = "830"
    http_read_credential = {
      username = "wlcaccess"
      password = "Lablab#123"
      port = 443
      secure = true
    }
    http_write_credential = {
      username = "wlcaccess"
      password = "Lablab#123"
      port = 443
      secure = true
    }
  }
  sensitive = true
}

# Single IP Discovery 2 Configuration
variable "single_ip_discovery_2" {
  description = "Single IP discovery configuration with SNMPv3 credentials"
  type = object({
    discovery_name = string
    discovery_type = string
    ip_address_list = list(string)
    protocol_order = string
    retry = number
    net_conf_port = string
    snmp_v3_credential = object({
      description = string
      username = string
      snmp_mode = string
      auth_password = string
      auth_type = string
      privacy_type = string
      privacy_password = string
    })
    http_read_credential = object({
      username = string
      password = string
      port = number
      secure = bool
    })
    http_write_credential = object({
      username = string
      password = string
      port = number
      secure = bool
    })
  })
  default = {
    discovery_name   = "Single IP Discovery12"
    discovery_type   = "Single"
    ip_address_list  = ["204.101.16.2"]
    protocol_order   = "ssh"
    retry           = 2
    net_conf_port   = "830"
    snmp_v3_credential = {
      description = "snmpv3Credentials"
      username = "wlcaccess"
      snmp_mode = "AUTHPRIV"
      auth_password = "Lablab#123"
      auth_type = "SHA"
      privacy_type = "AES128"
      privacy_password = "Lablab#123"
    }
    http_read_credential = {
      username = "wlcaccess"
      password = "Lablab#123"
      port = 443
      secure = true
    }
    http_write_credential = {
      username = "wlcaccess"
      password = "Lablab#123"
      port = 443
      secure = true
    }
  }
  sensitive = true
}

# Range IP Discovery Configuration
variable "range_ip_discovery" {
  description = "Range IP discovery configuration"
  type = object({
    discovery_name = string
    discovery_type = string
    ip_address_list = list(string)
    protocol_order = string
    retry = number
    net_conf_port = string
    snmp_v3_credential = object({
      description = string
      username = string
      snmp_mode = string
      auth_password = string
      auth_type = string
      privacy_type = string
      privacy_password = string
    })
    http_read_credential = object({
      username = string
      password = string
      port = number
      secure = bool
    })
    http_write_credential = object({
      username = string
      password = string
      port = number
      secure = bool
    })
  })
  default = {
    discovery_name   = "Range IP Discovery11"
    discovery_type   = "Range"
    ip_address_list  = ["204.101.16.2-204.101.16.2"]
    protocol_order   = "ssh"
    retry           = 2
    net_conf_port   = "830"
    snmp_v3_credential = {
      description = "snmpV3 Sample 1"
      username = "wlcaccess"
      snmp_mode = "AUTHPRIV"
      auth_password = "Lablab#123"
      auth_type = "SHA"
      privacy_type = "AES128"
      privacy_password = "Lablab#123"
    }
    http_read_credential = {
      username = "wlcaccess"
      password = "Lablab#123"
      port = 443
      secure = true
    }
    http_write_credential = {
      username = "wlcaccess"
      password = "Lablab#123"
      port = 443
      secure = true
    }
  }
  sensitive = true
}

# Multi Range IP Discovery Configuration
variable "multi_range_ip_discovery" {
  description = "Multi Range IP discovery configuration"
  type = object({
    discovery_name = string
    discovery_type = string
    ip_address_list = list(string)
    protocol_order = string
    retry = number
    timeout = number
    net_conf_port = string
    snmp_v3_credential = object({
      description = string
      username = string
      snmp_mode = string
      auth_password = string
      auth_type = string
      privacy_type = string
      privacy_password = string
    })
    http_read_credential = object({
      username = string
      password = string
      port = number
      secure = bool
    })
    http_write_credential = object({
      username = string
      password = string
      port = number
      secure = bool
    })
  })
  default = {
    discovery_name   = "Multi Range Discovery 11"
    discovery_type   = "Multi Range"
    ip_address_list  = ["204.101.16.2-204.101.16.3", "204.101.16.4-204.101.16.4"]
    protocol_order   = "ssh"
    retry           = 2
    timeout         = 30
    net_conf_port   = "830"
    snmp_v3_credential = {
      description = "snmpV3 Sample 1"
      username = "wlcaccess"
      snmp_mode = "AUTHPRIV"
      auth_password = "Lablab#123"
      auth_type = "SHA"
      privacy_type = "AES128"
      privacy_password = "Lablab#123"
    }
    http_read_credential = {
      username = "wlcaccess"
      password = "Lablab#123"
      port = 443
      secure = true
    }
    http_write_credential = {
      username = "wlcaccess"
      password = "Lablab#123"
      port = 443
      secure = true
    }
  }
  sensitive = true
}