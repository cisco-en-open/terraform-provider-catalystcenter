# Software Image Management (SWIM) Workflow Configuration Example
# Copy this file to terraform.tfvars and customize for your environment

# Replace with your SWIM operations configuration
swim_operations = {
  # Query existing images in Catalyst Center
  query_existing_images = {
    enabled            = true
    image_name         = null                              # Replace with specific image name filter or leave null
    family             = "Cisco Catalyst 9300 Switch"     # Replace with your device family
    image_series       = null                              # Replace with image series filter or leave null
    is_cco_recommended = true                              # Filter for CCO recommended images
    is_tagged_golden   = null                              # Filter for golden tagged images or leave null
  }
  
  # Import images from remote URLs
  import_from_url = {
    enabled = true
    images = [
      {
        source_url       = "http://your-server.example.com/images/cat9k_lite_iosxe.17.12.01.SPA.bin"  # Replace with your image URL
        third_party      = false
        vendor           = null
        application_type = null
        image_family     = null
        schedule_at      = null
        schedule_desc    = "Import Catalyst 9300 IOS XE 17.12.01 image"
        schedule_origin  = "terraform-swim-workflow"
      },
      # Add more images as needed
      # {
      #   source_url       = "http://your-server.example.com/images/another_image.bin"
      #   third_party      = false
      #   schedule_desc    = "Import additional image"
      #   schedule_origin  = "terraform-swim-workflow"
      # }
    ]
  }
  
  # Import images from local file system
  import_from_file = {
    enabled = false    # Set to true if importing from local files
    images = [
      {
        file_name                    = "cat9k_lite_iosxe.17.12.01.SPA.bin"           # Replace with your image filename
        file_path                    = "/path/to/your/images/cat9k_lite_iosxe.17.12.01.SPA.bin"  # Replace with actual file path
        is_third_party               = false
        third_party_vendor           = null
        third_party_image_family     = null
        third_party_application_type = null
      }
      # Add more local files as needed
    ]
  }
  
  # Verify imported images
  verify_imports = {
    enabled           = true
    image_name_filter = null                            # Replace with specific image name to verify or leave null
    family_filter     = "Cisco Catalyst 9300 Switch"   # Replace with your device family
  }
}

# Replace with your site hierarchy
site_name_hierarchy = "Global/USA/SAN JOSE/BLD23"      # Replace with your actual site hierarchy

# Replace with your target devices information
target_devices = {
  device_family = "Switches and Hubs"                   # Replace with your device family
  device_role   = "ACCESS"                               # Replace with device role (ACCESS, DISTRIBUTION, CORE, etc.)
  site_name     = "Global/USA/SAN JOSE/BLD23"          # Replace with your site name
}

# Future image management configuration (not yet implemented in provider)
image_management = {
  golden_tag_enabled      = false    # Will be available when golden tagging resources are added
  distribution_enabled    = false    # Will be available when distribution resources are added  
  activation_enabled      = false    # Will be available when activation resources are added
  upgrade_mode           = "currentlyExists"
  activate_lower_version = false
  distribute_if_needed   = true
  schedule_validate      = false
}