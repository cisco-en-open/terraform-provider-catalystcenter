# Software Image Management (SWIM) Workflow Variables
# Variables for SWIM operations including image import, querying, and management

# SWIM Operations Configuration
variable "swim_operations" {
  description = "Configuration for SWIM (Software Image Management) operations"
  type = object({
    # Query existing images configuration
    query_existing_images = object({
      enabled            = bool
      image_name         = optional(string)
      family             = optional(string) 
      image_series       = optional(string)
      is_cco_recommended = optional(bool)
      is_tagged_golden   = optional(bool)
    })
    
    # Import images from URL configuration
    import_from_url = object({
      enabled = bool
      images = list(object({
        source_url       = string
        third_party      = optional(bool, false)
        vendor           = optional(string)
        application_type = optional(string)
        image_family     = optional(string)
        schedule_at      = optional(string)
        schedule_desc    = optional(string)
        schedule_origin  = optional(string)
      }))
    })
    
    # Import images from local file configuration
    import_from_file = object({
      enabled = bool
      images = list(object({
        file_name                    = string
        file_path                    = string
        is_third_party               = optional(bool, false)
        third_party_vendor           = optional(string)
        third_party_image_family     = optional(string)
        third_party_application_type = optional(string)
      }))
    })
    
    # Verify imports configuration
    verify_imports = object({
      enabled           = bool
      image_name_filter = optional(string)
      family_filter     = optional(string)
    })
  })
  
  default = {
    query_existing_images = {
      enabled            = true
      image_name         = null
      family             = "Cisco Catalyst 9300 Switch"
      image_series       = null
      is_cco_recommended = true
      is_tagged_golden   = null
    }
    
    import_from_url = {
      enabled = true
      images = [
        {
          source_url       = "http://example.com/images/cat9k_lite_iosxe.17.12.01.SPA.bin"
          third_party      = false
          vendor           = null
          application_type = null
          image_family     = null
          schedule_at      = null
          schedule_desc    = "Import Catalyst 9300 IOS XE image"
          schedule_origin  = "terraform"
        }
      ]
    }
    
    import_from_file = {
      enabled = false
      images = [
        {
          file_name                    = "cat9k_lite_iosxe.17.12.01.SPA.bin"
          file_path                    = "/path/to/images/cat9k_lite_iosxe.17.12.01.SPA.bin"
          is_third_party               = false
          third_party_vendor           = null
          third_party_image_family     = null
          third_party_application_type = null
        }
      ]
    }
    
    verify_imports = {
      enabled           = true
      image_name_filter = null
      family_filter     = "Cisco Catalyst 9300 Switch"
    }
  }
}

# Site Configuration for SWIM Operations
variable "site_name_hierarchy" {
  description = "Site hierarchy path for SWIM operations (used in documentation examples)"
  type        = string
  default     = "Global/USA/SAN JOSE/BLD23"
}

# Device Information for SWIM Operations
variable "target_devices" {
  description = "Target devices for future SWIM operations (golden tagging, distribution, activation)"
  type = object({
    device_family = string
    device_role   = string
    site_name     = string
  })
  default = {
    device_family = "Switches and Hubs"
    device_role   = "ACCESS"
    site_name     = "Global/USA/SAN JOSE/BLD23"
  }
}

# Image Management Configuration
variable "image_management" {
  description = "Configuration for image management operations (future use)"
  type = object({
    golden_tag_enabled      = bool
    distribution_enabled    = bool
    activation_enabled      = bool
    upgrade_mode           = string
    activate_lower_version = bool
    distribute_if_needed   = bool
    schedule_validate      = bool
  })
  default = {
    golden_tag_enabled      = false
    distribution_enabled    = false
    activation_enabled      = false
    upgrade_mode           = "currentlyExists"
    activate_lower_version = false
    distribute_if_needed   = true
    schedule_validate      = false
  }
}