# Provision Workflow Use Case
# This configuration demonstrates various device provision workflows:
# - Site assignment (without provisioning)
# - Device provision (assign + provision)
# - Device re-provision 
# - Device un-provision
# - Wireless device provisioning

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

  debug = var.catalyst_debug

  ssl_verify = var.catalyst_ssl_verify
}

# Data sources to get site and device information
data "catalystcenter_sites" "target_site" {
  name_hierarchy = var.site_name_hierarchy
}

# 1. Site Assignment Only (without provisioning)
# This assigns a device to a site without provisioning it
resource "catalystcenter_sda_provision_devices" "site_assignment" {
  count = var.site_assignment_only.enabled ? 1 : 0
  
  parameters {
    payload {
      network_device_id = data.catalystcenter_network_device_by_ip.site_assign[0].item[0].id
      site_id          = data.catalystcenter_sites.target_site.items[0].id
    }
  }

  # Lifecycle to prevent provisioning
  lifecycle {
    ignore_changes = [
      parameters[0].payload[0].network_device_id,
      parameters[0].payload[0].site_id
    ]
  }
}

# Data source to get device by IP for site assignment
data "catalystcenter_network_device_by_ip" "site_assign" {
  count = var.site_assignment_only.enabled ? 1 : 0
  ip_address    = var.site_assignment_only.management_ip
}

# 2. Device Provision (assign device to site and provision)
# This is the primary provisioning workflow
resource "catalystcenter_sda_provision_devices" "wired_provision" {
  count = var.wired_device_provision.enabled ? 1 : 0

  parameters {
    force_provisioning = var.wired_device_provision.force_provisioning
    payload {
      network_device_id = data.catalystcenter_network_device_by_ip.wired_device[0].item[0].id
      site_id          = data.catalystcenter_sites.target_site.items[0].id
    }
  }
}

# Data source to get wired device by IP
data "catalystcenter_network_device_by_ip" "wired_device" {
  count = var.wired_device_provision.enabled ? 1 : 0
  ip_address    = var.wired_device_provision.management_ip
}

# 3. Device Re-provision
# This re-provisions a device that is already provisioned
resource "catalystcenter_sda_provision_devices" "device_reprovision" {
  count = var.device_reprovision.enabled ? 1 : 0

  parameters {
    force_provisioning = true
    payload {
      network_device_id = data.catalystcenter_network_device_by_ip.reprovision_device[0].item[0].id
      site_id          = data.catalystcenter_sites.target_site.items[0].id
    }
  }
}

# Data source to get device by IP for re-provisioning
data "catalystcenter_network_device_by_ip" "reprovision_device" {
  count = var.device_reprovision.enabled ? 1 : 0
  ip_address    = var.device_reprovision.management_ip
}

# 4. Wireless Device Provision
# Provisions wireless controllers with managed AP locations
resource "catalystcenter_wireless_provision_device_create" "wireless_provision" {
  count = var.wireless_device_provision.enabled ? 1 : 0

  parameters {
    payload {
      device_name = data.catalystcenter_network_device_by_ip.wireless_device[0].item[0].hostname
      site        = var.site_name_hierarchy
      managed_aplocations = var.wireless_device_provision.managed_ap_locations
      
      # Optional dynamic interfaces configuration
      dynamic "dynamic_interfaces" {
        for_each = [] # Add interface configurations if needed
        content {
          interface_gateway          = dynamic_interfaces.value.gateway
          interface_ipaddress        = dynamic_interfaces.value.ip_address
          interface_name             = dynamic_interfaces.value.name
          interface_netmask_in_cid_r = dynamic_interfaces.value.netmask_cidr
          lag_or_port_number         = dynamic_interfaces.value.port_number
          vlan_id                    = dynamic_interfaces.value.vlan_id
        }
      }
    }
  }
}

# Data source to get wireless device by IP
data "catalystcenter_network_device_by_ip" "wireless_device" {
  count = var.wireless_device_provision.enabled ? 1 : 0
  ip_address    = var.wireless_device_provision.management_ip
}

# 5. Provisioning Settings Configuration
# Sets global provisioning settings
resource "catalystcenter_provisioning_settings" "global_settings" {
  parameters {
    require_itsm_approval = "false"
    require_preview       = "false"
  }
}

# Local values for device management
locals {
  all_device_ips = concat(
    var.wired_device_provision.enabled ? [var.wired_device_provision.management_ip] : [],
    var.site_assignment_only.enabled ? [var.site_assignment_only.management_ip] : [],
    var.device_reprovision.enabled ? [var.device_reprovision.management_ip] : [],
    var.wireless_device_provision.enabled ? [var.wireless_device_provision.management_ip] : []
  )
  
  provisioned_device_count = length([
    for config in [
      var.wired_device_provision.enabled,
      var.wireless_device_provision.enabled,
      var.device_reprovision.enabled
    ] : config if config
  ])
  
  site_assigned_count = var.site_assignment_only.enabled ? 1 : 0
}

# Validation rules
resource "terraform_data" "validation" {
  lifecycle {
    precondition {
      condition     = length(var.site_name_hierarchy) > 0
      error_message = "Site name hierarchy must not be empty."
    }
    
    precondition {
      condition     = var.wired_device_provision.enabled || var.site_assignment_only.enabled || var.device_reprovision.enabled || var.wireless_device_provision.enabled
      error_message = "At least one provision workflow must be enabled."
    }
  }
}