# Provision Workflow Outputs
# Outputs to display results of provisioning operations

# Site Assignment Outputs
output "site_assignment_results" {
  description = "Results from site assignment operations (without provisioning)"
  value = var.site_assignment_only.enabled ? {
    enabled      = var.site_assignment_only.enabled
    device_ip    = var.site_assignment_only.management_ip
    site_hierarchy = var.site_name_hierarchy
    assignment_id = var.site_assignment_only.enabled ? catalystcenter_sda_provision_devices.site_assignment[0].id : null
    status       = "Site assigned (not provisioned)"
  } : null
}

# Wired Device Provision Outputs
output "wired_provision_results" {
  description = "Results from wired device provisioning operations"
  value = var.wired_device_provision.enabled ? {
    enabled          = var.wired_device_provision.enabled
    device_ip        = var.wired_device_provision.management_ip
    site_hierarchy   = var.site_name_hierarchy
    provisioning     = var.wired_device_provision.provisioning
    force_provisioning = var.wired_device_provision.force_provisioning
    provision_id     = var.wired_device_provision.enabled ? catalystcenter_sda_provision_devices.wired_provision[0].id : null
    device_details   = var.wired_device_provision.enabled ? catalystcenter_sda_provision_devices.wired_provision[0].item : null
    status          = "Wired device provisioned"
  } : null
}

# Device Re-provision Outputs
output "reprovision_results" {
  description = "Results from device re-provisioning operations"
  value = var.device_reprovision.enabled ? {
    enabled      = var.device_reprovision.enabled
    device_ip    = var.device_reprovision.management_ip
    site_hierarchy = var.site_name_hierarchy
    provision_id = var.device_reprovision.enabled ? catalystcenter_sda_provision_devices.device_reprovision[0].id : null
    device_details = var.device_reprovision.enabled ? catalystcenter_sda_provision_devices.device_reprovision[0].item : null
    status       = "Device re-provisioned"
  } : null
}

# Wireless Device Provision Outputs
output "wireless_provision_results" {
  description = "Results from wireless device provisioning operations"
  value = var.wireless_device_provision.enabled ? {
    enabled              = var.wireless_device_provision.enabled
    device_ip            = var.wireless_device_provision.management_ip
    site_hierarchy       = var.site_name_hierarchy
    managed_ap_locations = var.wireless_device_provision.managed_ap_locations
    force_provisioning   = var.wireless_device_provision.force_provisioning
    provision_id         = var.wireless_device_provision.enabled ? catalystcenter_wireless_provision_device_create.wireless_provision[0].id : null
    status              = "Wireless device provisioned"
  } : null
}

# Provisioning Settings Outputs
output "provisioning_settings" {
  description = "Global provisioning settings applied"
  value = {
    id                    = catalystcenter_provisioning_settings.global_settings.id
    require_itsm_approval = catalystcenter_provisioning_settings.global_settings.item[0].require_itsm_approval
    require_preview       = catalystcenter_provisioning_settings.global_settings.item[0].require_preview
    last_updated          = catalystcenter_provisioning_settings.global_settings.last_updated
  }
  sensitive = false
}

# Application Telemetry Outputs (if implemented)
output "application_telemetry_status" {
  description = "Status of application telemetry configuration"
  value = var.application_telemetry.enabled ? {
    enabled     = var.application_telemetry.enabled
    device_ips  = var.application_telemetry.device_ips
    wired_config = var.application_telemetry.wired_config
    wireless_config = var.application_telemetry.wireless_config
    status      = "Telemetry configuration ready (manual setup required)"
  } : null
}

# Summary Outputs
output "provision_workflow_summary" {
  description = "Summary of all provision workflow operations"
  value = {
    site_hierarchy          = var.site_name_hierarchy
    total_devices_processed = local.provisioned_device_count + local.site_assigned_count
    
    operations_summary = {
      site_assignments_only = local.site_assigned_count
      devices_provisioned   = local.provisioned_device_count
      wired_provisions      = var.wired_device_provision.enabled ? 1 : 0
      wireless_provisions   = var.wireless_device_provision.enabled ? 1 : 0
      re_provisions        = var.device_reprovision.enabled ? 1 : 0
    }
    
    device_ips = local.all_device_ips
    
    next_steps = [
      "Verify device status in Catalyst Center UI under Inventory > Devices",
      "Check provisioning status under Provision > Device Provision",
      "Monitor device connectivity and configuration compliance",
      var.application_telemetry.enabled ? "Configure application telemetry manually if needed" : null
    ]
  }
}

# Test Results Output for Validation
output "provision_test_results" {
  description = "Test validation results for provision workflows"
  value = {
    validation_passed = alltrue([
      var.wired_device_provision.enabled || var.site_assignment_only.enabled || var.device_reprovision.enabled || var.wireless_device_provision.enabled,
      length(var.site_name_hierarchy) > 0,
      var.timeout_settings.provision_timeout > 0,
      var.timeout_settings.unprovision_timeout > 0
    ])
    
    enabled_workflows = [
      var.site_assignment_only.enabled ? "site_assignment" : null,
      var.wired_device_provision.enabled ? "wired_provision" : null, 
      var.device_reprovision.enabled ? "device_reprovision" : null,
      var.wireless_device_provision.enabled ? "wireless_provision" : null
    ]
    
    configuration_status = {
      site_configured         = length(var.site_name_hierarchy) > 0
      timeouts_configured     = var.timeout_settings.provision_timeout > 0 && var.timeout_settings.unprovision_timeout > 0
      debug_enabled          = var.enable_debug
      provisioning_settings_applied = true
    }
    
    recommendations = compact([
      !var.wired_device_provision.enabled && !var.wireless_device_provision.enabled ? "Consider enabling at least one device provision workflow" : null,
      var.timeout_settings.provision_timeout < 300 ? "Consider increasing provision timeout for complex configurations" : null,
      !var.enable_debug ? "Enable debug mode for troubleshooting if needed" : null
    ])
  }
}