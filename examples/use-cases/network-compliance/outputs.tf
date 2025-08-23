# Network Compliance Workflow Outputs

#####################################
# Device Information Outputs
#####################################

output "target_devices_from_ips" {
  description = "List of devices retrieved by IP addresses"
  value = {
    for idx, device_data in data.catalystcenter_network_device_by_ip.devices_by_ip :
    var.ip_address_list[idx] => length(device_data.item) > 0 ? {
      id               = device_data.item[0].id
      hostname         = device_data.item[0].hostname
      management_ip    = device_data.item[0].management_ip_address
      platform_id      = device_data.item[0].platform_id
      software_version = device_data.item[0].software_version
      device_type      = device_data.item[0].type
      series          = device_data.item[0].series
      reachability    = device_data.item[0].reachability_status
    } : null
  }
}

output "target_devices_from_site" {
  description = "List of devices retrieved by site name"
  value = var.site_name != "" && length(data.catalystcenter_network_devices_assigned_to_site.devices_by_site) > 0 ? {
    site_name = var.site_name
    site_id   = data.catalystcenter_sites.target_site[0].items[0].id
    devices = [
      for device in data.catalystcenter_network_devices_assigned_to_site.devices_by_site[0].items : {
        id               = device.id
        hostname         = device.hostname
        management_ip    = device.management_ip_address
        platform_id      = device.platform_id
        software_version = device.software_version
        device_type      = device.type
        series          = device.series
        reachability    = device.reachability_status
      }
    ]
  } : null
}

output "all_target_device_uuids" {
  description = "Combined list of all target device UUIDs"
  value       = local.all_device_uuids
}

#####################################
# Compliance Check Outputs
#####################################

output "compliance_check_results" {
  description = "Results of the compliance check operation"
  value = length(catalystcenter_compliance.network_compliance_check) > 0 ? {
    task_id           = catalystcenter_compliance.network_compliance_check[0].item[0].task_id
    task_url          = catalystcenter_compliance.network_compliance_check[0].item[0].url
    categories_checked = var.run_compliance_categories
    trigger_full      = var.trigger_full_compliance
    device_count      = length(local.all_device_uuids)
  } : null
}

output "compliance_details" {
  description = "Detailed compliance results for devices"
  value = length(data.catalystcenter_compliance_device_details.compliance_results) > 0 ? {
    device_uuid = local.all_device_uuids[0]
    details     = data.catalystcenter_compliance_device_details.compliance_results[0].item
  } : null
}

#####################################
# Remediation Outputs
#####################################

output "remediation_results" {
  description = "Results of compliance issues remediation"
  value = var.remediate_compliance_issues && length(catalystcenter_network_devices_issues_remediation_provision.remediate_compliance_issues) > 0 ? [
    for idx, remediation in catalystcenter_network_devices_issues_remediation_provision.remediate_compliance_issues : {
      device_uuid = local.all_device_uuids[idx]
      task_id     = remediation.item[0].task_id
      task_url    = remediation.item[0].url
    }
  ] : []
}

output "config_sync_results" {
  description = "Results of device configuration synchronization"
  value = var.sync_device_config && length(catalystcenter_network_devices_issues_remediation_provision.sync_device_config) > 0 ? [
    for idx, sync in catalystcenter_network_devices_issues_remediation_provision.sync_device_config : {
      device_uuid = local.all_device_uuids[idx]
      task_id     = sync.item[0].task_id
      task_url    = sync.item[0].url
    }
  ] : []
}

#####################################
# Summary Outputs
#####################################

output "workflow_summary" {
  description = "Summary of the network compliance workflow execution"
  value = {
    # Input configuration
    ip_addresses_provided    = length(var.ip_address_list)
    site_name_provided      = var.site_name != "" ? var.site_name : null
    
    # Target devices
    total_target_devices = length(local.all_device_uuids)
    
    # Operations performed
    compliance_check_performed    = var.run_compliance
    remediation_performed        = var.remediate_compliance_issues
    config_sync_performed        = var.sync_device_config
    
    # Categories checked
    compliance_categories = var.run_compliance_categories
    full_compliance_triggered = var.trigger_full_compliance
    
    # Task IDs for tracking
    compliance_task_id = length(catalystcenter_compliance.network_compliance_check) > 0 ? 
                        catalystcenter_compliance.network_compliance_check[0].item[0].task_id : null
    
    remediation_task_count = length(catalystcenter_network_devices_issues_remediation_provision.remediate_compliance_issues)
    sync_task_count       = length(catalystcenter_network_devices_issues_remediation_provision.sync_device_config)
  }
}

#####################################
# Debug Outputs
#####################################

output "debug_info" {
  description = "Debug information for troubleshooting"
  value = var.enable_debug ? {
    ip_device_lookup_count = length(data.catalystcenter_network_device_by_ip.devices_by_ip)
    site_device_lookup     = length(data.catalystcenter_network_devices_assigned_to_site.devices_by_site)
    device_uuids_from_ips  = local.device_uuids_from_ips
    device_uuids_from_site = local.device_uuids_from_site
    combined_device_uuids  = local.all_device_uuids
  } : null
}