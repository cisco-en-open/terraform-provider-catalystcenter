# Inventory Workflow Outputs
# These outputs provide information about the inventory operations performed

# Device Onboarding Outputs
output "device_onboarding_results" {
  description = "Results of device onboarding operations"
  value = var.device_onboarding.enabled ? {
    enabled = true
    devices_onboarded = length(catalystcenter_pnp_device.device_onboarding)
    device_details = [
      for device in catalystcenter_pnp_device.device_onboarding : {
        id          = device.id
        hostname    = device.parameters[0].device_info[0].hostname
        mac_address = device.parameters[0].device_info[0].mac_address
        serial_number = device.parameters[0].device_info[0].serial_number
      }
    ]
  } : {
    enabled = false
    devices_onboarded = 0
    message = "Device onboarding is disabled"
  }
}

# Site Assignment and Provisioning Outputs
output "site_assignment_provision_results" {
  description = "Results of site assignment and provisioning operations"
  value = var.site_assignment_provision.enabled ? {
    enabled = true
    devices_provisioned = length(catalystcenter_sda_provision_devices.site_assignment_provision)
    site_hierarchy = var.site_name_hierarchy
    device_ips = var.site_assignment_provision.device_ips
  } : {
    enabled = false
    devices_provisioned = 0
    message = "Site assignment and provisioning is disabled"
  }
}

# Device Operations Outputs
output "device_operations_results" {
  description = "Results of device operations (resync, reboot)"
  value = {
    resync = var.device_operations.resync_enabled ? {
      enabled = true
      force_sync = var.device_operations.force_sync
      devices_synced = length(var.device_operations.device_ids)
      operation_id = var.device_operations.resync_enabled ? catalystcenter_network_device_sync.device_resync[0].id : null
    } : {
      enabled = false
      message = "Device resync is disabled"
    }
    
    reboot = var.device_operations.reboot_enabled ? {
      enabled = true
      aps_rebooted = length(var.device_operations.ap_mac_addresses)
      operation_id = var.device_operations.reboot_enabled ? catalystcenter_device_reboot_apreboot.ap_reboot[0].id : null
    } : {
      enabled = false
      message = "Device reboot is disabled"
    }
  }
}

# Device Deletion Outputs
output "device_deletion_results" {
  description = "Results of device deletion operations"
  value = var.device_deletion.enabled ? {
    enabled = true
    cleanup_mode = var.device_deletion.clean_config ? "with_cleanup" : "without_cleanup"
    devices_deleted = length(var.device_deletion.device_ids)
    deletion_operations = var.device_deletion.clean_config ? [
      for deletion in catalystcenter_network_devices_delete_with_cleanup.device_deletion_cleanup : {
        id = deletion.id
        device_id = deletion.parameters[0].id
      }
    ] : [
      for deletion in catalystcenter_network_devices_delete_without_cleanup.device_deletion_no_cleanup : {
        id = deletion.id
        device_id = deletion.parameters[0].id
      }
    ]
  } : {
    enabled = false
    message = "Device deletion is disabled"
  }
}

# Maintenance Scheduling Outputs
output "maintenance_scheduling_results" {
  description = "Results of maintenance scheduling operations"
  value = var.maintenance_scheduling.enabled ? {
    enabled = true
    schedules_created = length(var.maintenance_scheduling.schedules)
    maintenance_details = [
      for idx, schedule in catalystcenter_network_device_maintenance_schedules.maintenance_schedule : {
        schedule_id = schedule.id
        description = var.maintenance_scheduling.schedules[idx].description
        device_count = length(var.maintenance_scheduling.schedules[idx].device_ids)
        start_time = var.maintenance_scheduling.schedules[idx].start_time
        end_time = var.maintenance_scheduling.schedules[idx].end_time
        has_recurrence = var.maintenance_scheduling.schedules[idx].recurrence_interval != null
      }
    ]
  } : {
    enabled = false
    message = "Maintenance scheduling is disabled"
  }
}

# Summary Output
output "inventory_workflow_summary" {
  description = "Summary of all inventory workflow operations"
  value = {
    site_hierarchy = var.site_name_hierarchy
    workflows_enabled = {
      device_onboarding = var.device_onboarding.enabled
      site_assignment_provision = var.site_assignment_provision.enabled
      device_operations = var.device_operations.resync_enabled || var.device_operations.reboot_enabled
      device_deletion = var.device_deletion.enabled
      maintenance_scheduling = var.maintenance_scheduling.enabled
    }
    total_operations = (
      (var.device_onboarding.enabled ? length(var.device_onboarding.devices) : 0) +
      (var.site_assignment_provision.enabled ? length(var.site_assignment_provision.device_ips) : 0) +
      (var.device_operations.resync_enabled ? 1 : 0) +
      (var.device_operations.reboot_enabled ? 1 : 0) +
      (var.device_deletion.enabled ? length(var.device_deletion.device_ids) : 0) +
      (var.maintenance_scheduling.enabled ? length(var.maintenance_scheduling.schedules) : 0)
    )
    debug_enabled = var.enable_debug
    configuration_valid = true
  }
}