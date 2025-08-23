# Production Inventory Configuration
# This file defines the Terraform configuration for the production environment

terraform {
  required_providers {
    catalystcenter = {
      version = "1.2.0-beta"
      source  = "cisco-en-programmability/catalystcenter"
    }
  }
}

# Configure provider with production environment settings
provider "catalystcenter" {
  username   = var.catalyst_username   # Catalyst Center user name
  password   = var.catalyst_password   # Catalyst Center password
  base_url   = var.catalyst_base_url   # Catalyst Center base URL, FQDN or IP
  debug      = var.catalyst_debug      # Boolean to enable debugging (optional)
  ssl_verify = var.catalyst_ssl_verify # Boolean to enable/disable SSL verification (optional)
}

# Local values for environment-specific configurations
locals {
  environment = var.environment
  prefix      = var.resource_prefix
  
  # Common tags for all resources
  common_tags = {
    Environment = local.environment
    ManagedBy   = "terraform-tests"
    Purpose     = "production-validation"
    CriticalPath = "true"
  }
  
  # Environment-specific naming conventions
  naming = {
    area_prefix     = "${local.prefix}-area"
    building_prefix = "${local.prefix}-bldg"
    floor_prefix    = "${local.prefix}-floor"
    device_prefix   = "${local.prefix}-device"
  }
  
  # Production-specific configurations
  production_config = {
    enable_monitoring      = true
    enable_alerting        = true
    enable_audit_logging   = true
    backup_retention       = "30d"
    change_management      = true
    require_approval       = true
    maintenance_window     = "02:00-04:00"
  }
}

# Data source to validate connectivity - critical for production
data "catalystcenter_global_credential" "test_connectivity" {
  count = var.enable_validation ? 1 : 0
}

# Production-specific validation checks
data "catalystcenter_network_device" "validation_check" {
  count = var.enable_validation ? 1 : 0
  # This will fail if there are no devices, which is expected for validation
  depends_on = [data.catalystcenter_global_credential.test_connectivity]
}