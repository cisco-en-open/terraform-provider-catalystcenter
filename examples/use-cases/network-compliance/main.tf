# Network Compliance Workflow for Cisco Catalyst Center
#
# This configuration implements the network compliance workflow including:
# - Device compliance checks by IP addresses or site
# - Support for different compliance categories
# - Device configuration synchronization
# - Network devices issues remediation

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
  username = var.catalystcenter_username
  password = var.catalystcenter_password
  base_url = "https://${var.catalystcenter_host}:${var.catalystcenter_port}"
  debug    = var.catalystcenter_debug
}

# Data source to get site information if site_name is specified
data "catalystcenter_sites" "target_site" {
  count          = var.site_name != "" ? 1 : 0
  name_hierarchy = var.site_name
}

# Data source to get devices by site if site_name is specified
data "catalystcenter_network_devices_assigned_to_site" "devices_by_site" {
  count   = var.site_name != "" ? 1 : 0
  site_id = data.catalystcenter_sites.target_site[0].items[0].id
}

# Data source to get device details by IP addresses
data "catalystcenter_network_device_by_ip" "devices_by_ip" {
  count      = length(var.ip_address_list)
  ip_address = var.ip_address_list[count.index]
}

# Local values to prepare device UUIDs
locals {
  # Get device UUIDs from IP addresses
  device_uuids_from_ips = var.ip_address_list != [] ? [
    for device in data.catalystcenter_network_device_by_ip.devices_by_ip :
    device.item[0].id if length(device.item) > 0
  ] : []

  # Get device UUIDs from site (if specified)
  device_uuids_from_site = var.site_name != "" && length(data.catalystcenter_network_devices_assigned_to_site.devices_by_site) > 0 ? [
    for device in data.catalystcenter_network_devices_assigned_to_site.devices_by_site[0].items :
    device.id
  ] : []

  # Combine all device UUIDs
  all_device_uuids = concat(local.device_uuids_from_ips, local.device_uuids_from_site)
}

# Run compliance check on devices
resource "catalystcenter_compliance" "network_compliance_check" {
  count = var.run_compliance && length(local.all_device_uuids) > 0 ? 1 : 0

  parameters {
    device_uuids = local.all_device_uuids
    categories   = var.run_compliance_categories
    trigger_full = var.trigger_full_compliance ? "true" : "false"
  }

  timeouts {
    create = var.compliance_timeout
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Get compliance details after running compliance check
data "catalystcenter_compliance_device_details" "compliance_results" {
  count       = var.run_compliance && length(local.all_device_uuids) > 0 ? 1 : 0
  device_uuid = local.all_device_uuids[0] # Get details for first device as example
  category    = "RUNNING_CONFIG"
  
  depends_on = [catalystcenter_compliance.network_compliance_check]
}

# Network devices issues remediation for each device with compliance issues
resource "catalystcenter_network_devices_issues_remediation_provision" "remediate_compliance_issues" {
  count = var.remediate_compliance_issues && length(local.all_device_uuids) > 0 ? length(local.all_device_uuids) : 0

  parameters {
    id = local.all_device_uuids[count.index]
  }

  timeouts {
    create = var.remediation_timeout
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [catalystcenter_compliance.network_compliance_check]
}

# Sync device configuration (sync startup config with running config)
# Note: This is conceptual as there's no direct sync resource, but remediation handles config sync
resource "catalystcenter_network_devices_issues_remediation_provision" "sync_device_config" {
  count = var.sync_device_config && length(local.all_device_uuids) > 0 ? length(local.all_device_uuids) : 0

  parameters {
    id = local.all_device_uuids[count.index]
  }

  timeouts {
    create = var.sync_timeout
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [catalystcenter_network_devices_issues_remediation_provision.remediate_compliance_issues]
}