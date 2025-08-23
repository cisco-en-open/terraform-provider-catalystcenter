# Software Image Management (SWIM) Workflow Terraform Configuration
# This configuration demonstrates SWIM operations including image import and management

terraform {
  required_providers {
    catalystcenter = {
      version = "1.2.0-beta"
      source  = "cisco-en-programmability/catalystcenter"
    }
  }
}

provider "catalystcenter" {
  username   = var.catalyst_username   
  password   = var.catalyst_password   
  base_url   = var.catalyst_base_url   
  debug      = var.catalyst_debug      
  ssl_verify = var.catalyst_ssl_verify 
}

# Data source to retrieve existing software image details
data "catalystcenter_swim_image_details" "existing_images" {
  provider = catalystcenter
  count    = var.swim_operations.query_existing_images.enabled ? 1 : 0

  # Optional filters for querying images
  image_name         = var.swim_operations.query_existing_images.image_name
  family             = var.swim_operations.query_existing_images.family
  image_series       = var.swim_operations.query_existing_images.image_series
  is_cco_recommended = var.swim_operations.query_existing_images.is_cco_recommended
  is_tagged_golden   = var.swim_operations.query_existing_images.is_tagged_golden
}

# Import software image from remote URL
resource "catalystcenter_swim_image_url" "import_from_url" {
  provider = catalystcenter
  count    = var.swim_operations.import_from_url.enabled ? length(var.swim_operations.import_from_url.images) : 0

  parameters {
    # Optional scheduling parameters
    schedule_at     = var.swim_operations.import_from_url.images[count.index].schedule_at
    schedule_desc   = var.swim_operations.import_from_url.images[count.index].schedule_desc
    schedule_origin = var.swim_operations.import_from_url.images[count.index].schedule_origin
    
    payload {
      source_url       = var.swim_operations.import_from_url.images[count.index].source_url
      third_party      = var.swim_operations.import_from_url.images[count.index].third_party
      vendor           = var.swim_operations.import_from_url.images[count.index].vendor
      application_type = var.swim_operations.import_from_url.images[count.index].application_type
      image_family     = var.swim_operations.import_from_url.images[count.index].image_family
    }
  }
}

# Import software image from local file system  
resource "catalystcenter_swim_image_file" "import_from_file" {
  provider = catalystcenter
  count    = var.swim_operations.import_from_file.enabled ? length(var.swim_operations.import_from_file.images) : 0

  parameters {
    file_name                    = var.swim_operations.import_from_file.images[count.index].file_name
    file_path                    = var.swim_operations.import_from_file.images[count.index].file_path
    is_third_party               = var.swim_operations.import_from_file.images[count.index].is_third_party
    third_party_vendor           = var.swim_operations.import_from_file.images[count.index].third_party_vendor
    third_party_image_family     = var.swim_operations.import_from_file.images[count.index].third_party_image_family
    third_party_application_type = var.swim_operations.import_from_file.images[count.index].third_party_application_type
  }
}

# Data source to verify imported images
data "catalystcenter_swim_image_details" "verify_imported_images" {
  provider = catalystcenter
  count    = var.swim_operations.verify_imports.enabled ? 1 : 0
  
  depends_on = [
    catalystcenter_swim_image_url.import_from_url,
    catalystcenter_swim_image_file.import_from_file
  ]

  # Query for recently imported images
  image_name = var.swim_operations.verify_imports.image_name_filter
  family     = var.swim_operations.verify_imports.family_filter
}