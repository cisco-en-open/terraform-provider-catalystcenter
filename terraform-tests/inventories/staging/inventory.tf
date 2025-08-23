# Staging Inventory Configuration
# This file defines the Terraform configuration for the staging environment

terraform {
  required_providers {
    catalystcenter = {
      version = "1.2.0-beta"
      source  = "cisco-en-programmability/catalystcenter"
    }
  }
}

# Configure provider with staging environment settings
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
    Purpose     = "staging-validation"
  }
  
  # Environment-specific naming conventions
  naming = {
    area_prefix     = "${local.prefix}-area"
    building_prefix = "${local.prefix}-bldg"
    floor_prefix    = "${local.prefix}-floor"
    device_prefix   = "${local.prefix}-device"
  }
  
  # Staging-specific configurations
  staging_config = {
    enable_monitoring    = true
    performance_testing  = true
    integration_testing  = true
    backup_retention     = "7d"
  }
}

# Data source to validate connectivity
data "catalystcenter_global_credential" "test_connectivity" {
  count = var.enable_validation ? 1 : 0
}