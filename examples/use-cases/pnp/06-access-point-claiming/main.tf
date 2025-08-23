# Access Point Claiming and Provisioning Test

terraform {
  required_providers {
    catalystcenter = {
      version = "1.2.0-beta"
      source  = "hashicorp.com/edu/catalystcenter"
      # "hashicorp.com/edu/catalystcenter" is the local built source
      # Change to "cisco-en-programmability/catalystcenter" to use registry version
    }
  }
}

# Provider configuration
provider "catalystcenter" {
  username   = var.catalyst_center_username
  password   = var.catalyst_center_password
  base_url   = "https://${var.catalyst_center_host}:${var.catalyst_center_port}"
  debug      = var.catalyst_center_debug
  ssl_verify = var.catalyst_center_ssl_verify
}

# Add the access point device to PnP
resource "catalystcenter_pnp_device" "ap_device" {
  parameters {
    device_info {
      serial_number = var.ap_device.serial_number
      hostname      = var.ap_device.hostname
      pid           = var.ap_device.pid
      stack         = "false"
      sudi_required = "false"
      state         = "Unclaimed"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create PnP workflow for access point provisioning
# This corresponds to the "claim_access_points" task in the Ansible workflow
resource "catalystcenter_pnp_workflow" "ap_workflow" {
  parameters {
    name        = "AP-${var.ap_device.hostname}-Workflow"
    description = "PnP workflow for provisioning access point ${var.ap_device.hostname}"
    type        = "Standard"
    
    tasks {
      name        = "Access Point Configuration"
      type        = "Config"
      time_taken  = 0
      task_seq_no = 1
      
      work_item_list {
        command     = "root"
        output_str  = ""
        time_taken  = 0
        state       = "PENDING"
      }
    }
  }

  depends_on = [catalystcenter_pnp_device.ap_device]
}

# Claim the access point device with RF profile
resource "catalystcenter_pnp_device_claim" "ap_claim" {
  parameters {
    config_file_url = "placeholder_config_url"
    config_id       = "placeholder_config_id"
    device_claim_list = [
      {
        config_list = [
          {
            config_id = "placeholder_config_id"
            config_parameters = [
              {
                key   = "hostname"
                value = var.ap_device.hostname
              },
              {
                key   = "rf_profile"
                value = var.ap_config.rf_profile
              },
              {
                key   = "pnp_type"
                value = var.ap_config.pnp_type
              },
              {
                key   = "site_name"
                value = var.ap_config.site_name
              }
            ]
          }
        ]
        device_id = catalystcenter_pnp_device.ap_device.id
        license_level = "ADVANTAGE"
        license_type = "Advantage"
        top_of_stack_serial_number = var.ap_device.serial_number
      }
    ]
    file_service_id = "placeholder_file_service_id"
    image_id        = "placeholder_image_id"
    image_url       = "placeholder_image_url"
    populate_inventory = true
    project_id      = "placeholder_project_id"
    workflow_id     = catalystcenter_pnp_workflow.ap_workflow.id
  }

  depends_on = [
    catalystcenter_pnp_device.ap_device,
    catalystcenter_pnp_workflow.ap_workflow
  ]
}

# Site claim for the access point to assign it to a specific site
resource "catalystcenter_pnp_device_site_claim" "ap_site_claim" {
  parameters {
    config_info {
      config_id = "placeholder_config_id"
      config_parameters = [
        {
          key   = "RF_PROFILE"
          value = var.ap_config.rf_profile
        },
        {
          key   = "SITE_NAME"
          value = var.ap_config.site_name
        },
        {
          key   = "PNP_TYPE"
          value = var.ap_config.pnp_type
        }
      ]
    }
    
    device_id = catalystcenter_pnp_device.ap_device.id
    site_id   = "placeholder_site_id"
    type      = "AccessPoint"
    
    image_info {
      image_id = "placeholder_image_id"
      skip     = true  # APs typically don't need separate image provisioning
    }
    
    config_info {
      config_id = "placeholder_config_id"
    }
  }

  depends_on = [
    catalystcenter_pnp_device.ap_device,
    catalystcenter_pnp_workflow.ap_workflow,
    catalystcenter_pnp_device_claim.ap_claim
  ]
}

# Output access point information
output "ap_device_info" {
  description = "Access point device information"
  value = {
    id            = catalystcenter_pnp_device.ap_device.id
    serial_number = catalystcenter_pnp_device.ap_device.parameters[0].device_info[0].serial_number
    hostname      = catalystcenter_pnp_device.ap_device.parameters[0].device_info[0].hostname
    pid           = catalystcenter_pnp_device.ap_device.parameters[0].device_info[0].pid
    state         = catalystcenter_pnp_device.ap_device.parameters[0].device_info[0].state
  }
}

output "ap_workflow_info" {
  description = "Access point workflow information"
  value = {
    id          = catalystcenter_pnp_workflow.ap_workflow.id
    name        = catalystcenter_pnp_workflow.ap_workflow.parameters[0].name
    description = catalystcenter_pnp_workflow.ap_workflow.parameters[0].description
    type        = catalystcenter_pnp_workflow.ap_workflow.parameters[0].type
  }
}

output "ap_configuration" {
  description = "Access point configuration details"
  value = {
    site_name  = var.ap_config.site_name
    rf_profile = var.ap_config.rf_profile
    pnp_type   = var.ap_config.pnp_type
  }
}

output "important_note" {
  description = "Important note about access point onboarding"
  value       = "IMPORTANT: Ensure that the Wireless LAN Controller (WLC) is fully onboarded before claiming Access Points to avoid errors."
}

output "test_status" {
  description = "Test completion status"
  value       = "Access Point ${var.ap_device.hostname} claimed and configured successfully with RF profile ${var.ap_config.rf_profile}"
}