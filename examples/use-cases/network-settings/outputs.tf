# =============================================================================
# Network Settings Outputs
# =============================================================================
# This file defines outputs for the network settings configuration
# These outputs provide visibility into created resources and their attributes

# -----------------------------------------------------------------------------
# Site Information Outputs
# -----------------------------------------------------------------------------
output "site_information" {
  description = "Information about the configured sites"
  value = {
    global_site = try(data.catalystcenter_site.global_site, null)
    target_sites = try(data.catalystcenter_sites.target_sites, null)
  }
}

# -----------------------------------------------------------------------------
# Global IP Pools Outputs
# -----------------------------------------------------------------------------
output "global_pools" {
  description = "Global IP pools creation results"
  value = {
    underlay_pool = {
      id          = try(catalystcenter_global_pool.underlay_pool.id, null)
      name        = var.ip_pools.underlay.name
      cidr        = var.ip_pools.underlay.cidr
      gateway     = var.ip_pools.underlay.gateway
      pool_type   = var.ip_pools.underlay.pool_type
      dhcp_servers = var.ip_pools.underlay.dhcp_server_ips
      dns_servers  = var.ip_pools.underlay.dns_server_ips
    }
    sensor_pool = {
      id          = try(catalystcenter_global_pool.sensor_pool.id, null)
      name        = var.ip_pools.sensor.name
      cidr        = var.ip_pools.sensor.cidr
      gateway     = var.ip_pools.sensor.gateway
      pool_type   = var.ip_pools.sensor.pool_type
      dhcp_servers = var.ip_pools.sensor.dhcp_server_ips
      dns_servers  = var.ip_pools.sensor.dns_server_ips
    }
    sensor_pool_v6 = {
      id          = try(catalystcenter_global_pool.sensor_pool_v6.id, null)
      name        = var.ip_pools.sensor_v6.name
      cidr        = var.ip_pools.sensor_v6.cidr
      gateway     = var.ip_pools.sensor_v6.gateway
      pool_type   = var.ip_pools.sensor_v6.pool_type
      dhcp_servers = var.ip_pools.sensor_v6.dhcp_server_ips
      dns_servers  = var.ip_pools.sensor_v6.dns_server_ips
    }
  }
}

# -----------------------------------------------------------------------------
# Reserved IP Pools Outputs
# -----------------------------------------------------------------------------
output "reserved_pools" {
  description = "Reserved IP pools creation results"
  value = {
    underlay_sub = {
      id                 = try(catalystcenter_reserve_ip_subpool.underlay_sub.id, null)
      name               = var.reserved_pools.underlay_sub.name
      site_id            = try(catalystcenter_reserve_ip_subpool.underlay_sub.parameters[0].site_id, null)
      type               = var.reserved_pools.underlay_sub.type
      ipv4_subnet        = var.reserved_pools.underlay_sub.ipv4_subnet
      ipv4_gateway       = var.reserved_pools.underlay_sub.ipv4_gateway
      ipv4_prefix_length = var.reserved_pools.underlay_sub.ipv4_prefix_length
    }
    sensor_sub = {
      id                 = try(catalystcenter_reserve_ip_subpool.sensor_sub.id, null)
      name               = var.reserved_pools.sensor_sub.name
      site_id            = try(catalystcenter_reserve_ip_subpool.sensor_sub.parameters[0].site_id, null)
      type               = var.reserved_pools.sensor_sub.type
      ipv4_subnet        = var.reserved_pools.sensor_sub.ipv4_subnet
      ipv4_gateway       = var.reserved_pools.sensor_sub.ipv4_gateway
      ipv4_prefix_length = var.reserved_pools.sensor_sub.ipv4_prefix_length
      ipv6_subnet        = var.reserved_pools.sensor_sub.ipv6_subnet
      ipv6_gateway       = var.reserved_pools.sensor_sub.ipv6_gateway
      ipv6_prefix_length = var.reserved_pools.sensor_sub.ipv6_prefix_length
    }
  }
}

# -----------------------------------------------------------------------------
# Network Settings Outputs
# -----------------------------------------------------------------------------
output "network_settings" {
  description = "Network settings configuration results"
  value = {
    network_create = {
      id                = try(catalystcenter_network_create.site_network_settings.id, null)
      execution_id      = try(catalystcenter_network_create.site_network_settings.item[0].execution_id, null)
      execution_status  = try(catalystcenter_network_create.site_network_settings.item[0].execution_status_url, null)
      site_id          = try(data.catalystcenter_sites.target_sites.items[0].id, var.network_settings.site_id)
    }
    network_update = var.enable_network_update ? {
      id                = try(catalystcenter_network_update.site_network_update[0].id, null)
      execution_id      = try(catalystcenter_network_update.site_network_update[0].item[0].execution_id, null)
      execution_status  = try(catalystcenter_network_update.site_network_update[0].item[0].execution_status_url, null)
    } : null
  }
}

# -----------------------------------------------------------------------------
# AAA Settings Outputs
# -----------------------------------------------------------------------------
output "aaa_settings" {
  description = "AAA settings configuration results"
  value = {
    site_id = try(catalystcenter_sites_aaa_settings.site_aaa.site_id, null)
    aaa_network = {
      server_type       = var.aaa_settings.aaa_network.server_type
      protocol          = var.aaa_settings.aaa_network.protocol
      primary_server_ip = var.aaa_settings.aaa_network.primary_server_ip
      pan               = var.aaa_settings.aaa_network.pan
    }
    aaa_client = {
      server_type       = var.aaa_settings.aaa_client.server_type
      protocol          = var.aaa_settings.aaa_client.protocol
      primary_server_ip = var.aaa_settings.aaa_client.primary_server_ip
      pan               = var.aaa_settings.aaa_client.pan
    }
  }
  sensitive = true  # Contains server information that should be treated as sensitive
}

# -----------------------------------------------------------------------------
# Device Controllability Outputs
# -----------------------------------------------------------------------------
output "device_controllability" {
  description = "Device controllability settings results"
  value = {
    id             = try(catalystcenter_network_devices_device_controllability_settings.controllability.id, null)
    controllability = var.device_controllability.enable_controllability
  }
}

# -----------------------------------------------------------------------------
# Network Services Summary Output
# -----------------------------------------------------------------------------
output "network_services_summary" {
  description = "Summary of all configured network services"
  value = {
    dhcp_servers = var.network_settings.dhcp_server
    dns_servers = {
      domain_name = var.network_settings.dns_server.domain_name
      primary     = var.network_settings.dns_server.primary_ip_address
      secondary   = var.network_settings.dns_server.secondary_ip_address
    }
    ntp_servers        = var.network_settings.ntp_server
    snmp_servers       = var.network_settings.snmp_server.ip_addresses
    syslog_servers     = var.network_settings.syslog_server.ip_addresses
    netflow_collector  = var.network_settings.netflow_collector
    timezone          = var.network_settings.timezone
    banner_message    = var.network_settings.message_of_theday.banner_message
  }
}

# -----------------------------------------------------------------------------
# Workflow Summary Output
# -----------------------------------------------------------------------------
output "network_settings_workflow_summary" {
  description = "Comprehensive summary of the network settings workflow execution"
  value = {
    timestamp = timestamp()
    configuration_summary = {
      global_pools_created      = 3  # underlay, sensor, sensor_v6
      reserved_pools_created    = 2  # underlay_sub, sensor_sub
      network_settings_applied  = true
      aaa_settings_applied      = true
      device_controllability   = var.device_controllability.enable_controllability
      network_update_enabled   = var.enable_network_update
    }
    site_configuration = {
      target_site_name = var.site_hierarchy.target_site_name
      target_site_id   = try(data.catalystcenter_sites.target_sites.items[0].id, "not_found")
    }
    ip_addressing = {
      underlay_cidr     = var.ip_pools.underlay.cidr
      sensor_cidr       = var.ip_pools.sensor.cidr
      sensor_v6_cidr    = var.ip_pools.sensor_v6.cidr
      underlay_sub_net  = var.reserved_pools.underlay_sub.ipv4_subnet
      sensor_sub_net    = var.reserved_pools.sensor_sub.ipv4_subnet
      sensor_sub_v6_net = var.reserved_pools.sensor_sub.ipv6_subnet
    }
    service_endpoints = {
      dhcp_count    = length(var.network_settings.dhcp_server)
      ntp_count     = length(var.network_settings.ntp_server)
      snmp_count    = length(var.network_settings.snmp_server.ip_addresses)
      syslog_count  = length(var.network_settings.syslog_server.ip_addresses)
      aaa_configured = true
    }
  }
}

# -----------------------------------------------------------------------------
# Validation Outputs
# -----------------------------------------------------------------------------
output "validation_checks" {
  description = "Validation checks for network settings configuration"
  value = {
    ip_pool_validation = {
      underlay_pool_valid  = var.ip_pools.underlay.cidr != "" ? true : false
      sensor_pool_valid    = var.ip_pools.sensor.cidr != "" ? true : false
      sensor_v6_pool_valid = var.ip_pools.sensor_v6.cidr != "" ? true : false
    }
    network_services_validation = {
      dhcp_configured    = length(var.network_settings.dhcp_server) > 0
      dns_configured     = var.network_settings.dns_server.primary_ip_address != ""
      ntp_configured     = length(var.network_settings.ntp_server) > 0
      aaa_configured     = var.network_settings.network_aaa.ip_address != ""
      snmp_configured    = length(var.network_settings.snmp_server.ip_addresses) > 0
      syslog_configured  = length(var.network_settings.syslog_server.ip_addresses) > 0
    }
    aaa_validation = {
      ise_configured     = var.aaa_settings.aaa_network.server_type == "ISE"
      radius_protocol    = var.aaa_settings.aaa_network.protocol == "RADIUS"
      pan_configured     = var.aaa_settings.aaa_network.pan != ""
      shared_secret_set  = var.aaa_settings.aaa_network.shared_secret != ""
    }
  }
}

# -----------------------------------------------------------------------------
# Troubleshooting Output
# -----------------------------------------------------------------------------
output "troubleshooting_info" {
  description = "Information useful for troubleshooting network settings issues"
  value = {
    provider_configuration = {
      base_url    = var.catalyst_base_url
      ssl_verify  = var.catalyst_ssl_verify
      debug_mode  = var.catalyst_debug
    }
    timeout_settings = var.timeout_settings
    debug_enabled    = var.enable_debug
    site_lookup = {
      global_site_name = var.site_hierarchy.global_site_name
      target_site_name = var.site_hierarchy.target_site_name
    }
  }
  sensitive = false
}