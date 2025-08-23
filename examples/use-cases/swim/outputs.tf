# Software Image Management (SWIM) Workflow Outputs
# Outputs from SWIM operations for monitoring and verification

# Output existing images information
output "existing_images" {
  description = "Information about existing software images in Catalyst Center"
  value = var.swim_operations.query_existing_images.enabled ? {
    images_found = length(try(data.catalystcenter_swim_image_details.existing_images[0].items, []))
    images_details = try(data.catalystcenter_swim_image_details.existing_images[0].items, [])
  } : null
}

# Output URL import results
output "url_import_results" {
  description = "Results from URL-based image imports"
  value = var.swim_operations.import_from_url.enabled ? {
    imports_initiated = length(catalystcenter_swim_image_url.import_from_url)
    import_tasks = [
      for idx, import_task in catalystcenter_swim_image_url.import_from_url : {
        index       = idx
        task_id     = try(import_task.item[0].task_id, null)
        url         = try(import_task.item[0].url, null)
        source_url  = var.swim_operations.import_from_url.images[idx].source_url
        description = var.swim_operations.import_from_url.images[idx].schedule_desc
      }
    ]
  } : null
}

# Output file import results
output "file_import_results" {
  description = "Results from file-based image imports"
  value = var.swim_operations.import_from_file.enabled ? {
    imports_initiated = length(catalystcenter_swim_image_file.import_from_file)
    import_tasks = [
      for idx, import_task in catalystcenter_swim_image_file.import_from_file : {
        index     = idx
        task_id   = try(import_task.item[0].task_id, null)
        url       = try(import_task.item[0].url, null)
        file_name = var.swim_operations.import_from_file.images[idx].file_name
        file_path = var.swim_operations.import_from_file.images[idx].file_path
      }
    ]
  } : null
}

# Output verification results
output "import_verification" {
  description = "Verification of imported images"
  value = var.swim_operations.verify_imports.enabled ? {
    verified_images_count = length(try(data.catalystcenter_swim_image_details.verify_imported_images[0].items, []))
    verified_images = try(data.catalystcenter_swim_image_details.verify_imported_images[0].items, [])
  } : null
}

# Output SWIM workflow summary
output "swim_workflow_summary" {
  description = "Summary of all SWIM workflow operations"
  value = {
    query_existing_images_enabled = var.swim_operations.query_existing_images.enabled
    import_from_url_enabled       = var.swim_operations.import_from_url.enabled
    import_from_file_enabled      = var.swim_operations.import_from_file.enabled
    verify_imports_enabled        = var.swim_operations.verify_imports.enabled
    
    url_imports_count  = var.swim_operations.import_from_url.enabled ? length(var.swim_operations.import_from_url.images) : 0
    file_imports_count = var.swim_operations.import_from_file.enabled ? length(var.swim_operations.import_from_file.images) : 0
    
    target_site   = var.site_name_hierarchy
    target_family = var.target_devices.device_family
    target_role   = var.target_devices.device_role
    
    # Future workflow capabilities (not yet implemented in provider)
    future_capabilities = {
      golden_tagging_available = false
      distribution_available   = false  
      activation_available     = false
      note = "Golden tagging, distribution, and activation require additional Terraform resources not yet available in the provider"
    }
  }
}

# Output for debugging and troubleshooting
output "debug_info" {
  description = "Debug information for troubleshooting SWIM operations"
  value = {
    timestamp = timestamp()
    
    configurations = {
      query_config = var.swim_operations.query_existing_images
      url_import_config = var.swim_operations.import_from_url
      file_import_config = var.swim_operations.import_from_file
      verification_config = var.swim_operations.verify_imports
    }
    
    resource_counts = {
      url_imports_planned  = var.swim_operations.import_from_url.enabled ? length(var.swim_operations.import_from_url.images) : 0
      file_imports_planned = var.swim_operations.import_from_file.enabled ? length(var.swim_operations.import_from_file.images) : 0
      data_sources_active  = (var.swim_operations.query_existing_images.enabled ? 1 : 0) + (var.swim_operations.verify_imports.enabled ? 1 : 0)
    }
  }
}