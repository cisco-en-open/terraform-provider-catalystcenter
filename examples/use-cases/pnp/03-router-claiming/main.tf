# Router Device Claiming and Provisioning Test

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

# First, add the router device to PnP
resource "catalystcenter_pnp_device" "router_device" {
  parameters {
    device_info {
      serial_number = var.router_device.serial_number
      hostname      = var.router_device.hostname
      pid           = var.router_device.pid
      stack         = "false"
      sudi_required = "false"
      state         = "Unclaimed"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create a PnP workflow for router provisioning
# This corresponds to the "claim_router_devices" task in the Ansible workflow
resource "catalystcenter_pnp_workflow" "router_workflow" {
  parameters {
    name        = "Router-${var.router_device.hostname}-Workflow"
    description = "PnP workflow for provisioning router ${var.router_device.hostname}"
    type        = "Standard"
    
    tasks {
      name        = "Device Onboarding"
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

  depends_on = [catalystcenter_pnp_device.router_device]
}

# Claim the router device to a site
resource "catalystcenter_pnp_device_site_claim" "router_site_claim" {
  parameters {
    config_info {
      config_id                  = "placeholder_config_id"
      config_parameters = [
        {
          key   = "PROJECT_NAME" 
          value = var.router_config.project_name
        },
        {
          key   = "TEMPLATE_NAME"
          value = var.router_config.template_name
        },
        {
          key   = "IMAGE_NAME"
          value = var.router_config.image_name
        }
      ]
    }
    
    device_id   = catalystcenter_pnp_device.router_device.id
    site_id     = "placeholder_site_id"
    type        = "Default"
    
    image_info {
      image_id   = "placeholder_image_id"
      skip       = false
    }
    
    config_info {
      config_id = "placeholder_config_id"
    }
  }

  depends_on = [
    catalystcenter_pnp_device.router_device,
    catalystcenter_pnp_workflow.router_workflow
  ]
}

# Alternative approach using device claim resource
resource "catalystcenter_pnp_device_claim" "router_claim" {
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
                value = var.router_device.hostname
              },
              {
                key   = "project_name"
                value = var.router_config.project_name
              },
              {
                key   = "template_name"
                value = var.router_config.template_name
              }
            ]
          }
        ]
        device_id = catalystcenter_pnp_device.router_device.id
        license_level = "ADVANTAGE"
        license_type = "Advantage"
        top_of_stack_serial_number = var.router_device.serial_number
      }
    ]
    file_service_id = "placeholder_file_service_id"
    image_id       = "placeholder_image_id"
    image_url      = "placeholder_image_url" 
    populate_inventory = true
    project_id     = "placeholder_project_id"
    workflow_id    = catalystcenter_pnp_workflow.router_workflow.id
  }

  depends_on = [
    catalystcenter_pnp_device.router_device,
    catalystcenter_pnp_workflow.router_workflow
  ]
}

# Output router information
output "router_device_info" {
  description = "Router device information"
  value = {
    id            = catalystcenter_pnp_device.router_device.id
    serial_number = catalystcenter_pnp_device.router_device.parameters[0].device_info[0].serial_number
    hostname      = catalystcenter_pnp_device.router_device.parameters[0].device_info[0].hostname
    pid           = catalystcenter_pnp_device.router_device.parameters[0].device_info[0].pid
    state         = catalystcenter_pnp_device.router_device.parameters[0].device_info[0].state
  }
}

output "router_workflow_info" {
  description = "Router workflow information"
  value = {
    id          = catalystcenter_pnp_workflow.router_workflow.id
    name        = catalystcenter_pnp_workflow.router_workflow.parameters[0].name
    description = catalystcenter_pnp_workflow.router_workflow.parameters[0].description
    type        = catalystcenter_pnp_workflow.router_workflow.parameters[0].type
  }
}

output "router_configuration" {
  description = "Router configuration details"
  value = {
    site_name     = var.router_config.site_name
    project_name  = var.router_config.project_name
    template_name = var.router_config.template_name
    image_name    = var.router_config.image_name
  }
}

output "test_status" {
  description = "Test completion status"
  value       = "Router device ${var.router_device.hostname} claimed and workflow created successfully"
}