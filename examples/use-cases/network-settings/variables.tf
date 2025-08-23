# =============================================================================
# Network Settings Terraform Variables
# =============================================================================
# This file defines all variables used for network settings configuration
# Based on Ansible workflow: workflows/network_settings/playbook/network_settings_playbook.yml

# -----------------------------------------------------------------------------
# Catalyst Center Provider Configuration  
# -----------------------------------------------------------------------------
variable "catalyst_username" {
  description = "Catalyst Center username"
  type        = string
  default     = "admin"
}

variable "catalyst_password" {
  description = "Catalyst Center password"
  type        = string
  sensitive   = true
}

variable "catalyst_base_url" {
  description = "Catalyst Center base URL"
  type        = string
  default     = "https://sandboxdnac.cisco.com"
}

variable "catalyst_debug" {
  description = "Enable debug mode for Catalyst Center SDK"
  type        = bool
  default     = false
}

variable "catalyst_ssl_verify" {
  description = "Enable SSL certificate verification"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Site Hierarchy Configuration
# -----------------------------------------------------------------------------
variable "site_hierarchy" {
  description = "Site hierarchy configuration for network settings"
  type = object({
    global_site_name = string
    target_site_name = string
  })
  default = {
    global_site_name = "Global"
    target_site_name = "Global/USA/SAN JOSE"
  }
}

# -----------------------------------------------------------------------------
# Global IP Pools Configuration
# -----------------------------------------------------------------------------
variable "ip_pools" {
  description = "Global IP pools configuration based on Ansible workflow"
  type = object({
    underlay = object({
      name               = string
      gateway            = string
      ip_address_space   = string
      cidr               = string
      pool_type          = string
      dhcp_server_ips    = list(string)
      dns_server_ips     = list(string)
    })
    sensor = object({
      name               = string
      gateway            = string
      ip_address_space   = string
      cidr               = string
      pool_type          = string
      dhcp_server_ips    = list(string)
      dns_server_ips     = list(string)
    })
    sensor_v6 = object({
      name               = string
      gateway            = string
      ip_address_space   = string
      cidr               = string
      pool_type          = string
      dhcp_server_ips    = list(string)
      dns_server_ips     = list(string)
    })
  })
  default = {
    underlay = {
      name               = "underlay"
      gateway            = "204.1.1.1"
      ip_address_space   = "IPv4"
      cidr               = "204.1.1.0/24"
      pool_type          = "Generic"
      dhcp_server_ips    = ["204.192.3.40"]
      dns_server_ips     = ["171.70.168.183"]
    }
    sensor = {
      name               = "SENSORPool"
      gateway            = "204.1.48.1"
      ip_address_space   = "IPv4"
      cidr               = "204.1.48.0/20"
      pool_type          = "Generic"
      dhcp_server_ips    = ["204.192.3.40"]
      dns_server_ips     = ["171.70.168.183"]
    }
    sensor_v6 = {
      name               = "SENSORPool_V6"
      gateway            = "2004:1:48::1"
      ip_address_space   = "IPv6"
      cidr               = "2004:1:48::/64"
      pool_type          = "Generic"
      dhcp_server_ips    = ["2004:192:3::40"]
      dns_server_ips     = ["2006:1:1::1"]
    }
  }
}

# -----------------------------------------------------------------------------
# Reserved IP Pools Configuration
# -----------------------------------------------------------------------------
variable "reserved_pools" {
  description = "Reserved IP pools configuration for specific sites"
  type = object({
    underlay_sub = object({
      name                = string
      site_id             = string
      type                = string
      ipv6_address_space  = bool
      ipv4_global_pool    = string
      ipv4_prefix         = bool
      ipv4_prefix_length  = number
      ipv4_subnet         = string
      ipv4_gateway        = string
      slaac_support       = bool
    })
    sensor_sub = object({
      name                = string
      site_id             = string
      type                = string
      ipv6_address_space  = bool
      ipv4_global_pool    = string
      ipv4_prefix         = bool
      ipv4_prefix_length  = number
      ipv4_subnet         = string
      ipv4_gateway        = string
      ipv6_prefix         = bool
      ipv6_prefix_length  = number
      ipv6_global_pool    = string
      ipv6_subnet         = string
      ipv6_gateway        = string
      ipv4_dhcp_servers   = list(string)
      ipv4_dns_servers    = list(string)
      ipv6_dhcp_servers   = list(string)
      ipv6_dns_servers    = list(string)
      slaac_support       = bool
    })
  })
  default = {
    underlay_sub = {
      name                = "underlay_sub"
      site_id             = ""  # Will be populated from site data source
      type                = "LAN"
      ipv6_address_space  = false
      ipv4_global_pool    = "204.1.1.0/24"
      ipv4_prefix         = true
      ipv4_prefix_length  = 25
      ipv4_subnet         = "204.1.1.0"
      ipv4_gateway        = "204.1.1.1"
      slaac_support       = false
    }
    sensor_sub = {
      name                = "SENSORPool_sub"
      site_id             = ""  # Will be populated from site data source
      type                = "Generic"
      ipv6_address_space  = true
      ipv4_global_pool    = "204.1.48.0/20"
      ipv4_prefix         = true
      ipv4_prefix_length  = 24
      ipv4_subnet         = "204.1.48.0/24"
      ipv4_gateway        = "204.1.48.1"
      ipv6_prefix         = true
      ipv6_prefix_length  = 112
      ipv6_global_pool    = "2004:1:48::/64"
      ipv6_subnet         = "2004:1:48::1:0"
      ipv6_gateway        = "2004:1:48::1:1"
      ipv4_dhcp_servers   = ["204.192.3.40"]
      ipv4_dns_servers    = ["204.192.3.40"]
      ipv6_dhcp_servers   = ["2004:192:3::40"]
      ipv6_dns_servers    = ["2006:1:1::1"]
      slaac_support       = false
    }
  }
}

# -----------------------------------------------------------------------------
# Network Settings Configuration
# -----------------------------------------------------------------------------
variable "network_settings" {
  description = "Network settings configuration for servers and services"
  type = object({
    site_id = string
    network_aaa = object({
      ip_address    = string
      network       = string
      protocol      = string
      servers       = string
      shared_secret = string
    })
    client_and_endpoint_aaa = object({
      ip_address    = string
      network       = string
      protocol      = string
      servers       = string
      shared_secret = string
    })
    dhcp_server = list(string)
    dns_server = object({
      domain_name          = string
      primary_ip_address   = string
      secondary_ip_address = string
    })
    ntp_server = list(string)
    snmp_server = object({
      configure_dnac_ip = string
      ip_addresses      = list(string)
    })
    syslog_server = object({
      configure_dnac_ip = string
      ip_addresses      = list(string)
    })
    netflow_collector = object({
      ip_address = string
      port       = number
    })
    message_of_theday = object({
      banner_message         = string
      retain_existing_banner = string
    })
    timezone = string
  })
  default = {
    site_id = ""  # Will be populated from site data source
    network_aaa = {
      ip_address    = "204.192.1.249"
      network       = "204.192.1.0/24"
      protocol      = "RADIUS"
      servers       = "AAA"
      shared_secret = "Maglev123"
    }
    client_and_endpoint_aaa = {
      ip_address    = "204.192.1.252"
      network       = "204.192.1.0/24"
      protocol      = "RADIUS"
      servers       = "AAA"
      shared_secret = "Maglev123"
    }
    dhcp_server = ["204.192.3.40", "2004:192:3::40"]
    dns_server = {
      domain_name          = "cisco.local"
      primary_ip_address   = "204.192.3.40"
      secondary_ip_address = "2040:50:0::0"
    }
    ntp_server = ["204.192.3.40", "204.192.3.41"]
    snmp_server = {
      configure_dnac_ip = "true"
      ip_addresses      = ["204.192.3.42"]
    }
    syslog_server = {
      configure_dnac_ip = "true"
      ip_addresses      = ["204.192.3.43"]
    }
    netflow_collector = {
      ip_address = "204.192.3.44"
      port       = 9995
    }
    message_of_theday = {
      banner_message         = "Welcome to Cisco Catalyst Center Network"
      retain_existing_banner = "false"
    }
    timezone = "America/Los_Angeles"
  }
}

# -----------------------------------------------------------------------------
# AAA Settings Configuration (Alternative Resource)
# -----------------------------------------------------------------------------
variable "aaa_settings" {
  description = "AAA settings configuration using dedicated resource"
  type = object({
    site_id = string
    aaa_network = object({
      pan                 = string
      primary_server_ip   = string
      protocol            = string
      secondary_server_ip = string
      server_type         = string
      shared_secret       = string
    })
    aaa_client = object({
      pan                 = string
      primary_server_ip   = string
      protocol            = string
      secondary_server_ip = string
      server_type         = string
      shared_secret       = string
    })
  })
  default = {
    site_id = ""  # Will be populated from site data source
    aaa_network = {
      pan                 = "82.2.2.3"
      primary_server_ip   = "10.195.243.31"
      protocol            = "RADIUS"
      secondary_server_ip = ""
      server_type         = "ISE"
      shared_secret       = "Maglev123"
    }
    aaa_client = {
      pan                 = "82.2.2.3"
      primary_server_ip   = "10.195.243.31"
      protocol            = "RADIUS"
      secondary_server_ip = ""
      server_type         = "ISE"
      shared_secret       = "Maglev123"
    }
  }
}

# -----------------------------------------------------------------------------
# Network Update Settings (For Testing Updates)
# -----------------------------------------------------------------------------
variable "enable_network_update" {
  description = "Enable network settings update testing"
  type        = bool
  default     = false
}

variable "network_update_settings" {
  description = "Updated network settings for testing update operations"
  type = object({
    site_id     = string
    dhcp_server = list(string)
    ntp_server  = list(string)
    timezone    = string
  })
  default = {
    site_id     = ""  # Will be populated from site data source
    dhcp_server = ["204.192.3.50", "2004:192:3::50"]
    ntp_server  = ["204.192.3.51", "204.192.3.52"]
    timezone    = "America/New_York"
  }
}

# -----------------------------------------------------------------------------
# Device Controllability Configuration
# -----------------------------------------------------------------------------
variable "device_controllability" {
  description = "Device controllability settings"
  type = object({
    enable_controllability = bool
  })
  default = {
    enable_controllability = true
  }
}

# -----------------------------------------------------------------------------
# Testing and Validation Configuration
# -----------------------------------------------------------------------------
variable "enable_debug" {
  description = "Enable debug mode for testing"
  type        = bool
  default     = false
}

variable "timeout_settings" {
  description = "Timeout settings for operations"
  type = object({
    create_timeout = string
    update_timeout = string
    delete_timeout = string
  })
  default = {
    create_timeout = "20m"
    update_timeout = "20m"
    delete_timeout = "20m"
  }
}