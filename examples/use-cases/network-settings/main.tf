terraform {
  required_providers {
    catalystcenter = {
      version = "1.2.0-beta"
      source  = "cisco-en-programmability/catalystcenter"
    }
  }
}

# Configure provider with your Cisco Catalyst Center SDK credentials
provider "catalystcenter" {
  username = var.catalyst_username
  password = var.catalyst_password
  base_url = var.catalyst_base_url
  debug    = var.catalyst_debug
  ssl_verify = var.catalyst_ssl_verify
}

# Data source to get site information
data "catalystcenter_site" "global_site" {
  provider = catalystcenter
  name     = var.site_hierarchy.global_site_name
}

data "catalystcenter_sites" "target_sites" {
  provider = catalystcenter
  name     = var.site_hierarchy.target_site_name
}

# 1. GLOBAL IP POOLS - Create global pools for different network types
resource "catalystcenter_global_pool" "underlay_pool" {
  provider = catalystcenter
  parameters {
    settings {
      ip_pool {
        gateway            = var.ip_pools.underlay.gateway
        ip_address_space   = var.ip_pools.underlay.ip_address_space
        cidr               = var.ip_pools.underlay.cidr
        name               = var.ip_pools.underlay.name
        type               = var.ip_pools.underlay.pool_type
        dhcp_server_ips    = var.ip_pools.underlay.dhcp_server_ips
        dns_server_ips     = var.ip_pools.underlay.dns_server_ips
      }
    }
  }
}

resource "catalystcenter_global_pool" "sensor_pool" {
  provider = catalystcenter
  parameters {
    settings {
      ip_pool {
        gateway            = var.ip_pools.sensor.gateway
        ip_address_space   = var.ip_pools.sensor.ip_address_space
        cidr               = var.ip_pools.sensor.cidr
        name               = var.ip_pools.sensor.name
        type               = var.ip_pools.sensor.pool_type
        dhcp_server_ips    = var.ip_pools.sensor.dhcp_server_ips
        dns_server_ips     = var.ip_pools.sensor.dns_server_ips
      }
    }
  }
}

resource "catalystcenter_global_pool" "sensor_pool_v6" {
  provider = catalystcenter
  parameters {
    settings {
      ip_pool {
        gateway            = var.ip_pools.sensor_v6.gateway
        ip_address_space   = var.ip_pools.sensor_v6.ip_address_space
        cidr               = var.ip_pools.sensor_v6.cidr
        name               = var.ip_pools.sensor_v6.name
        type               = var.ip_pools.sensor_v6.pool_type
        dhcp_server_ips    = var.ip_pools.sensor_v6.dhcp_server_ips
        dns_server_ips     = var.ip_pools.sensor_v6.dns_server_ips
      }
    }
  }
}

# 2. RESERVE IP SUBPOOLS - Reserve portions of global pools for specific sites
resource "catalystcenter_reserve_ip_subpool" "underlay_sub" {
  provider = catalystcenter
  parameters {
    name                = var.reserved_pools.underlay_sub.name
    site_id             = try(data.catalystcenter_sites.target_sites.items[0].id, var.reserved_pools.underlay_sub.site_id)
    type                = var.reserved_pools.underlay_sub.type
    ipv6_address_space  = var.reserved_pools.underlay_sub.ipv6_address_space
    ipv4_global_pool    = var.reserved_pools.underlay_sub.ipv4_global_pool
    ipv4_prefix         = var.reserved_pools.underlay_sub.ipv4_prefix
    ipv4_prefix_length  = var.reserved_pools.underlay_sub.ipv4_prefix_length
    ipv4_subnet         = var.reserved_pools.underlay_sub.ipv4_subnet
    ipv4_gateway        = var.reserved_pools.underlay_sub.ipv4_gateway
    slaac_support       = var.reserved_pools.underlay_sub.slaac_support
  }
  depends_on = [catalystcenter_global_pool.underlay_pool]
}

resource "catalystcenter_reserve_ip_subpool" "sensor_sub" {
  provider = catalystcenter
  parameters {
    name                = var.reserved_pools.sensor_sub.name
    site_id             = try(data.catalystcenter_sites.target_sites.items[0].id, var.reserved_pools.sensor_sub.site_id)
    type                = var.reserved_pools.sensor_sub.type
    ipv6_address_space  = var.reserved_pools.sensor_sub.ipv6_address_space
    ipv4_global_pool    = var.reserved_pools.sensor_sub.ipv4_global_pool
    ipv4_prefix         = var.reserved_pools.sensor_sub.ipv4_prefix
    ipv4_prefix_length  = var.reserved_pools.sensor_sub.ipv4_prefix_length
    ipv4_subnet         = var.reserved_pools.sensor_sub.ipv4_subnet
    ipv4_gateway        = var.reserved_pools.sensor_sub.ipv4_gateway
    ipv6_prefix         = var.reserved_pools.sensor_sub.ipv6_prefix
    ipv6_prefix_length  = var.reserved_pools.sensor_sub.ipv6_prefix_length
    ipv6_global_pool    = var.reserved_pools.sensor_sub.ipv6_global_pool
    ipv6_subnet         = var.reserved_pools.sensor_sub.ipv6_subnet
    ipv6_gateway        = var.reserved_pools.sensor_sub.ipv6_gateway
    ipv4_dhcp_servers   = var.reserved_pools.sensor_sub.ipv4_dhcp_servers
    ipv4_dns_servers    = var.reserved_pools.sensor_sub.ipv4_dns_servers
    ipv6_dhcp_servers   = var.reserved_pools.sensor_sub.ipv6_dhcp_servers
    ipv6_dns_servers    = var.reserved_pools.sensor_sub.ipv6_dns_servers
    slaac_support       = var.reserved_pools.sensor_sub.slaac_support
  }
  depends_on = [catalystcenter_global_pool.sensor_pool, catalystcenter_global_pool.sensor_pool_v6]
}

# 3. NETWORK SETTINGS - Configure network services at site level using network_create
resource "catalystcenter_network_create" "site_network_settings" {
  provider = catalystcenter
  
  parameters {
    site_id = try(data.catalystcenter_sites.target_sites.items[0].id, var.network_settings.site_id)
    
    settings {
      # AAA Configuration for both Network and Client/Endpoint
      network_aaa {
        ip_address    = var.network_settings.network_aaa.ip_address
        network       = var.network_settings.network_aaa.network
        protocol      = var.network_settings.network_aaa.protocol
        servers       = var.network_settings.network_aaa.servers
        shared_secret = var.network_settings.network_aaa.shared_secret
      }
      
      client_and_endpoint_aaa {
        ip_address    = var.network_settings.client_and_endpoint_aaa.ip_address
        network       = var.network_settings.client_and_endpoint_aaa.network
        protocol      = var.network_settings.client_and_endpoint_aaa.protocol
        servers       = var.network_settings.client_and_endpoint_aaa.servers
        shared_secret = var.network_settings.client_and_endpoint_aaa.shared_secret
      }
      
      # DHCP Server Configuration
      dhcp_server = var.network_settings.dhcp_server
      
      # DNS Server Configuration
      dns_server {
        domain_name          = var.network_settings.dns_server.domain_name
        primary_ip_address   = var.network_settings.dns_server.primary_ip_address
        secondary_ip_address = var.network_settings.dns_server.secondary_ip_address
      }
      
      # NTP Server Configuration
      ntp_server = var.network_settings.ntp_server
      
      # SNMP Server Configuration
      snmp_server {
        configure_dnac_ip = var.network_settings.snmp_server.configure_dnac_ip
        ip_addresses      = var.network_settings.snmp_server.ip_addresses
      }
      
      # Syslog Server Configuration
      syslog_server {
        configure_dnac_ip = var.network_settings.syslog_server.configure_dnac_ip
        ip_addresses      = var.network_settings.syslog_server.ip_addresses
      }
      
      # NetFlow Collector Configuration
      netflowcollector {
        ip_address = var.network_settings.netflow_collector.ip_address
        port       = var.network_settings.netflow_collector.port
      }
      
      # Message of the Day (Banner)
      message_of_theday {
        banner_message         = var.network_settings.message_of_theday.banner_message
        retain_existing_banner = var.network_settings.message_of_theday.retain_existing_banner
      }
      
      # Time Zone
      timezone = var.network_settings.timezone
    }
  }
}

# 4. SITES AAA SETTINGS - Alternative approach using dedicated AAA resource
resource "catalystcenter_sites_aaa_settings" "site_aaa" {
  provider = catalystcenter
  site_id  = try(data.catalystcenter_sites.target_sites.items[0].id, var.aaa_settings.site_id)
  
  parameters {
    # Network AAA Settings  
    aaa_network {
      pan                   = var.aaa_settings.aaa_network.pan
      primary_server_ip     = var.aaa_settings.aaa_network.primary_server_ip
      protocol              = var.aaa_settings.aaa_network.protocol
      secondary_server_ip   = var.aaa_settings.aaa_network.secondary_server_ip
      server_type          = var.aaa_settings.aaa_network.server_type
      shared_secret        = var.aaa_settings.aaa_network.shared_secret
    }
    
    # Client AAA Settings
    aaa_client {
      pan                   = var.aaa_settings.aaa_client.pan
      primary_server_ip     = var.aaa_settings.aaa_client.primary_server_ip
      protocol              = var.aaa_settings.aaa_client.protocol
      secondary_server_ip   = var.aaa_settings.aaa_client.secondary_server_ip
      server_type          = var.aaa_settings.aaa_client.server_type
      shared_secret        = var.aaa_settings.aaa_client.shared_secret
    }
  }
}

# 5. NETWORK UPDATE - Update existing network settings (separate resource for updates)
resource "catalystcenter_network_update" "site_network_update" {
  count    = var.enable_network_update ? 1 : 0
  provider = catalystcenter
  
  parameters {
    site_id = try(data.catalystcenter_sites.target_sites.items[0].id, var.network_update_settings.site_id)
    
    settings {
      # Updated DHCP servers
      dhcp_server = var.network_update_settings.dhcp_server
      
      # Updated NTP servers
      ntp_server = var.network_update_settings.ntp_server
      
      # Updated Time Zone
      timezone = var.network_update_settings.timezone
    }
  }
  
  depends_on = [catalystcenter_network_create.site_network_settings]
}

# 6. DEVICE CONTROLLABILITY SETTINGS
resource "catalystcenter_network_devices_device_controllability_settings" "controllability" {
  provider = catalystcenter
  
  parameters {
    device_controllability = var.device_controllability.enable_controllability
  }
}