# Outputs for Consolidated PnP Test Suite

# ================================================================================
# TEST SCENARIO 1: SINGLE DEVICE ONBOARDING OUTPUTS
# ================================================================================
output "single_device" {
  description = "Test 1: Single device onboarding results"
  value = var.device_onboarding.enabled ? {
    device_id     = try(catalystcenter_pnp_device.single_device_onboarding[0].item[0].id, null)
    serial_number = try(catalystcenter_pnp_device.single_device_onboarding[0].parameters[0].device_info[0].serial_number, null)
    hostname      = try(catalystcenter_pnp_device.single_device_onboarding[0].parameters[0].device_info[0].hostname, null)
  } : null
}

# ================================================================================
# TEST SCENARIO 2: BULK DEVICE ONBOARDING OUTPUTS
# ================================================================================
output "bulk_devices" {
  description = "Test 2: Bulk device onboarding results"
  value = var.bulk_onboarding.enabled ? {
    import_result = try(catalystcenter_pnp_device_import.bulk_device_import[0], null)
    individual_devices = {
      for serial, device in catalystcenter_pnp_device.bulk_devices_individual :
      serial => {
        device_id = device.item[0].id
        hostname  = device.parameters[0].device_info[0].hostname
        state     = device.parameters[0].device_info[0].state
      }
    }
    device_count = length(var.bulk_onboarding.devices)
  } : null
}

# ================================================================================
# TEST SCENARIO 3: ROUTER CLAIMING OUTPUTS
# ================================================================================
output "router_claiming" {
  description = "Test 3: Router claiming results"
  value = var.router_claiming.enabled ? {
    device_id     = try(catalystcenter_pnp_device.router_device[0].item[0].id, null)
    serial_number = var.router_claiming.device.serial_number
    hostname      = var.router_claiming.device.hostname
    site_id       = try(data.catalystcenter_sites.router_site[0].items[0].id, null)
    claim_status  = try(catalystcenter_pnp_device_site_claim.router_claim[0].item[0].response, null)
  } : null
}

# ================================================================================
# TEST SCENARIO 4: SWITCH CLAIMING OUTPUTS
# ================================================================================
output "switch_claiming" {
  description = "Test 4: Switch claiming results"
  value = var.switch_claiming.enabled ? {
    device_id     = try(catalystcenter_pnp_device.switch_device[0].item[0].id, null)
    serial_number = var.switch_claiming.device.serial_number
    hostname      = var.switch_claiming.device.hostname
    is_stack      = var.switch_claiming.device.is_stack
    site_id       = try(data.catalystcenter_sites.switch_site[0].items[0].id, null)
    claim_status  = try(catalystcenter_pnp_device_site_claim.switch_claim[0].item[0].response, null)
  } : null
}

# ================================================================================
# TEST SCENARIO 5: WIRELESS CONTROLLER CLAIMING OUTPUTS
# ================================================================================
output "wlc_claiming" {
  description = "Test 5: Wireless controller claiming results"
  value = var.wlc_claiming.enabled ? {
    device_id     = try(catalystcenter_pnp_device.wireless_controller[0].item[0].id, null)
    serial_number = var.wlc_claiming.device.serial_number
    hostname      = var.wlc_claiming.device.hostname
    site_id       = try(data.catalystcenter_sites.wlc_site[0].items[0].id, null)
    claim_status  = try(catalystcenter_pnp_device_site_claim.wlc_claim[0].item[0].response, null)
  } : null
}

# ================================================================================
# TEST SCENARIO 6: ACCESS POINT CLAIMING OUTPUTS
# ================================================================================
output "ap_claiming" {
  description = "Test 6: Access point claiming results"
  value = var.ap_claiming.enabled ? {
    device_id       = try(catalystcenter_pnp_device.access_point[0].item[0].id, null)
    serial_number   = var.ap_claiming.device.serial_number
    hostname        = var.ap_claiming.device.hostname
    site_id         = try(data.catalystcenter_sites.ap_site[0].items[0].id, null)
    rf_profile_name = var.ap_claiming.rf_profile_name
    claim_status    = try(catalystcenter_pnp_device_site_claim.ap_claim[0].item[0].response, null)
  } : null
}

# ================================================================================
# TEST SCENARIO 7: DEVICE RESET OUTPUTS
# ================================================================================
output "device_reset" {
  description = "Test 7: Device reset results"
  value = var.device_reset.enabled ? {
    test_device_created = var.device_reset.create_test_device ? {
      device_id     = try(catalystcenter_pnp_device.device_for_reset[0].item[0].id, null)
      serial_number = var.device_reset.test_device.serial_number
    } : null
    reset_results     = try(catalystcenter_pnp_device_reset.device_reset[0], null)
    unclaim_results   = var.device_reset.unclaim_devices ? try(catalystcenter_pnp_device_unclaim.device_unclaim[0], null) : null
    devices_reset     = length(var.device_reset.devices_to_reset)
    devices_unclaimed = var.device_reset.unclaim_devices ? length(var.device_reset.unclaim_device_ids) : 0
  } : null
}

# ================================================================================
# TEST SCENARIO 8: GLOBAL SETTINGS OUTPUTS
# ================================================================================
output "global_settings" {
  description = "Test 8: Global settings results"
  value = var.global_settings.enabled ? {
    global_settings_configured = try(catalystcenter_pnp_global_settings.global_settings[0] != null, false)
    aaa_configured            = var.global_settings.aaa_username != ""
    default_profile_configured = var.global_settings.configure_default_profile
    smart_account_configured  = var.global_settings.configure_smart_account
    virtual_account_synced    = var.global_settings.sync_virtual_account
    tenant_id                 = var.global_settings.tenant_id
  } : null
  sensitive = true
}

# ================================================================================
# SUMMARY OUTPUTS
# ================================================================================
output "test_suite_summary" {
  description = "Summary of all test scenarios"
  value = {
    enabled_tests = compact([
      var.device_onboarding.enabled ? "1-device-onboarding" : "",
      var.bulk_onboarding.enabled ? "2-bulk-onboarding" : "",
      var.router_claiming.enabled ? "3-router-claiming" : "",
      var.switch_claiming.enabled ? "4-switch-claiming" : "",
      var.wlc_claiming.enabled ? "5-wlc-claiming" : "",
      var.ap_claiming.enabled ? "6-ap-claiming" : "",
      var.device_reset.enabled ? "7-device-reset" : "",
      var.global_settings.enabled ? "8-global-settings" : ""
    ])
    
    total_tests_enabled = sum([
      var.device_onboarding.enabled ? 1 : 0,
      var.bulk_onboarding.enabled ? 1 : 0,
      var.router_claiming.enabled ? 1 : 0,
      var.switch_claiming.enabled ? 1 : 0,
      var.wlc_claiming.enabled ? 1 : 0,
      var.ap_claiming.enabled ? 1 : 0,
      var.device_reset.enabled ? 1 : 0,
      var.global_settings.enabled ? 1 : 0
    ])
    
    total_devices_onboarded = sum([
      var.device_onboarding.enabled ? 1 : 0,
      var.bulk_onboarding.enabled ? length(var.bulk_onboarding.devices) : 0,
      var.router_claiming.enabled ? 1 : 0,
      var.switch_claiming.enabled ? 1 : 0,
      var.wlc_claiming.enabled ? 1 : 0,
      var.ap_claiming.enabled ? 1 : 0
    ])
    
    total_devices_claimed = sum([
      var.router_claiming.enabled ? 1 : 0,
      var.switch_claiming.enabled ? 1 : 0,
      var.wlc_claiming.enabled ? 1 : 0,
      var.ap_claiming.enabled ? 1 : 0
    ])
  }
}

# ================================================================================
# DATA SOURCE OUTPUTS
# ================================================================================
output "all_pnp_devices" {
  description = "All PnP devices from data source"
  value       = data.catalystcenter_pnp_device.all_devices
}

output "pnp_device_count" {
  description = "Total count of PnP devices"
  value       = data.catalystcenter_pnp_device_count.device_count
}

output "pnp_workflows" {
  description = "All PnP workflows"
  value       = data.catalystcenter_pnp_workflow.workflows
}

# output "virtual_accounts" {
#   description = "Virtual accounts information"
#   value       = data.catalystcenter_pnp_virtual_accounts.virtual_accounts
# }

output "smart_account_domains" {
  description = "Smart account domains"
  value       = data.catalystcenter_pnp_smart_account_domains.smart_domains
}

output "current_global_settings" {
  description = "Current PnP global settings"
  value       = data.catalystcenter_pnp_global_settings.current_settings
  sensitive   = true
}

# ================================================================================
# CUSTOM WORKFLOW OUTPUTS
# ================================================================================
output "custom_workflows" {
  description = "Custom PnP workflows created"
  value = var.pnp_workflow.enabled ? {
    workflow_count = length(var.pnp_workflow.workflows)
    workflow_names = [for w in var.pnp_workflow.workflows : w.name]
    workflow_ids   = [for w in catalystcenter_pnp_workflow.custom_workflow : try(w.item[0].id, null)]
  } : null
}

# ================================================================================
# VALIDATION OUTPUT
# ================================================================================
output "test_validation_status" {
  description = "Validation status for each test scenario"
  value = {
    test_1_valid = var.device_onboarding.enabled ? try(catalystcenter_pnp_device.single_device_onboarding[0].item[0].id != null, false) : null
    
    test_2_valid = var.bulk_onboarding.enabled ? try(length(catalystcenter_pnp_device.bulk_devices_individual) > 0, false) : null
    
    test_3_valid = var.router_claiming.enabled ? try(catalystcenter_pnp_device_site_claim.router_claim[0].item[0].response != null, false) : null
    
    test_4_valid = var.switch_claiming.enabled ? try(catalystcenter_pnp_device_site_claim.switch_claim[0].item[0].response != null, false) : null
    
    test_5_valid = var.wlc_claiming.enabled ? try(catalystcenter_pnp_device_site_claim.wlc_claim[0].item[0].response != null, false) : null
    
    test_6_valid = var.ap_claiming.enabled ? try(catalystcenter_pnp_device_site_claim.ap_claim[0].item[0].response != null, false) : null
    
    test_7_valid = var.device_reset.enabled ? try(catalystcenter_pnp_device_reset.device_reset[0] != null, false) : null
    
    test_8_valid = var.global_settings.enabled ? try(catalystcenter_pnp_global_settings.global_settings[0] != null, false) : null
  }
}