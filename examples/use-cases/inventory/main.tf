# Inventory Workflow Use Case
# This configuration demonstrates various inventory management workflows:
# - Device Onboarding: Add new devices into inventory with automated workflows
# - Site Assignment: Assign devices to specific sites or zones within the fabric  
# - Provisioning: Apply configurations and provision devices based on site policies
# - Device Operations: Support update, resync, and reboot operations for managed devices
# - Role Management: Change or assign device roles such as border, access, etc.
# - Device Deletion: Remove devices cleanly from the fabric inventory
# - Maintenance Scheduling: Schedule periodic or one-time maintenance or device restarts

terraform {
  required_providers {
    catalystcenter = {
      version = "1.2.0-beta"
      source  = "cisco-en-programmability/catalystcenter"
      # Change to "cisco-en-programmability/catalystcenter" to use downloaded version from registry
    }
  }
}

provider "catalystcenter" {
  debug = var.enable_debug
}

# Data sources to get site and device information
data "catalystcenter_sites" "target_site" {
  name_hierarchy = var.site_name_hierarchy
}

# Data source to get network devices by IP for provisioning
data "catalystcenter_network_device_by_ip" "provision_devices" {
  count            = var.site_assignment_provision.enabled ? length(var.site_assignment_provision.device_ips) : 0
  management_ip_address = var.site_assignment_provision.device_ips[count.index]
}

# 1. Device Onboarding - Add new devices to PnP database
resource "catalystcenter_pnp_device" "device_onboarding" {
  count = var.device_onboarding.enabled ? length(var.device_onboarding.devices) : 0
  
  parameters {
    device_info {
      description   = var.device_onboarding.devices[count.index].description
      hostname      = var.device_onboarding.devices[count.index].hostname  
      mac_address   = var.device_onboarding.devices[count.index].mac_address
      pid           = var.device_onboarding.devices[count.index].pid
      serial_number = var.device_onboarding.devices[count.index].serial_number
      site_id       = data.catalystcenter_sites.target_site.items[0].id
      stack         = "false"
    }
  }
}

# 2. Site Assignment and Provisioning - Provision devices to sites
resource "catalystcenter_sda_provision_devices" "site_assignment_provision" {
  count = var.site_assignment_provision.enabled ? length(var.site_assignment_provision.device_ips) : 0
  
  parameters {
    payload {
      network_device_id = data.catalystcenter_network_device_by_ip.provision_devices[count.index].item[0].id
      site_id          = data.catalystcenter_sites.target_site.items[0].id
    }
  }
}

# 3. Device Operations - Resync devices
resource "catalystcenter_network_device_sync" "device_resync" {
  count = var.device_operations.resync_enabled ? 1 : 0
  
  parameters {
    force_sync = var.device_operations.force_sync
    payload    = var.device_operations.device_ids
  }
}

# 4. Device Operations - Reboot Access Points 
resource "catalystcenter_device_reboot_apreboot" "ap_reboot" {
  count = var.device_operations.reboot_enabled && length(var.device_operations.ap_mac_addresses) > 0 ? 1 : 0
  
  parameters {
    ap_mac_addresses = var.device_operations.ap_mac_addresses
  }
}

# 5. Device Deletion - Clean removal from inventory
resource "catalystcenter_network_devices_delete_with_cleanup" "device_deletion_cleanup" {
  count = var.device_deletion.enabled && var.device_deletion.clean_config ? length(var.device_deletion.device_ids) : 0
  
  parameters {
    id = var.device_deletion.device_ids[count.index]
  }
}

# 6. Device Deletion - Without configuration cleanup
resource "catalystcenter_network_devices_delete_without_cleanup" "device_deletion_no_cleanup" {
  count = var.device_deletion.enabled && !var.device_deletion.clean_config ? length(var.device_deletion.device_ids) : 0
  
  parameters {
    id = var.device_deletion.device_ids[count.index] 
  }
}

# 7. Maintenance Scheduling - Schedule maintenance windows
resource "catalystcenter_network_device_maintenance_schedules" "maintenance_schedule" {
  count = var.maintenance_scheduling.enabled ? length(var.maintenance_scheduling.schedules) : 0
  
  parameters {
    description        = var.maintenance_scheduling.schedules[count.index].description
    network_device_ids = var.maintenance_scheduling.schedules[count.index].device_ids
    
    maintenance_schedule {
      start_time = var.maintenance_scheduling.schedules[count.index].start_time
      end_time   = var.maintenance_scheduling.schedules[count.index].end_time
      
      dynamic "recurrence" {
        for_each = var.maintenance_scheduling.schedules[count.index].recurrence_interval != null ? [1] : []
        
        content {
          interval            = var.maintenance_scheduling.schedules[count.index].recurrence_interval
          recurrence_end_time = var.maintenance_scheduling.schedules[count.index].recurrence_end_time
        }
      }
    }
  }
}