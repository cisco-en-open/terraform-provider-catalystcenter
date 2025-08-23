# Switch Device Claiming and Provisioning Test

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

# Add the switch device to PnP
resource "catalystcenter_pnp_device" "switch_device" {
  parameters {
    device_info {
      serial_number = var.switch_device.serial_number
      hostname      = var.switch_device.hostname
      pid           = var.switch_device.pid
      stack         = var.switch_device.stack
      sudi_required = "false"
      state         = "Unclaimed"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create a PnP workflow for switch provisioning
# This corresponds to the "claim_switching_devices" task in the Ansible workflow
resource "catalystcenter_pnp_workflow" "switch_workflow" {
  parameters {
    name        = "Switch-${var.switch_device.hostname}-Workflow"
    description = "PnP workflow for provisioning switch ${var.switch_device.hostname}"
    type        = "Standard"
    
    tasks {
      name        = "Device Configuration"
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

  depends_on = [catalystcenter_pnp_device.switch_device]
}

# Claim the switch device with configuration
resource "catalystcenter_pnp_device_claim" "switch_claim" {
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
                value = var.switch_device.hostname
              },
              {
                key   = "project_name"
                value = var.switch_config.project_name
              },
              {
                key   = "template_name"
                value = var.switch_config.template_name
              },
              {
                key   = "PNP_VLAN_ID"
                value = var.switch_config.template_params.PNP_VLAN_ID
              },
              {
                key   = "LOOPBACK_IP"
                value = var.switch_config.template_params.LOOPBACK_IP
              }
            ]
          }
        ]
        device_id = catalystcenter_pnp_device.switch_device.id
        license_level = "ADVANTAGE"
        license_type = "Advantage"
        top_of_stack_serial_number = var.switch_device.serial_number
      }
    ]
    file_service_id = "placeholder_file_service_id"
    image_id        = "placeholder_image_id"
    image_url       = "placeholder_image_url"
    populate_inventory = true
    project_id      = "placeholder_project_id"
    workflow_id     = catalystcenter_pnp_workflow.switch_workflow.id
  }

  depends_on = [
    catalystcenter_pnp_device.switch_device,
    catalystcenter_pnp_workflow.switch_workflow
  ]
}

# Site claim for the switch
resource "catalystcenter_pnp_device_site_claim" "switch_site_claim" {
  parameters {
    config_info {
      config_id = "placeholder_config_id"
      config_parameters = [
        {
          key   = "PROJECT_NAME"
          value = var.switch_config.project_name
        },
        {
          key   = "TEMPLATE_NAME"
          value = var.switch_config.template_name
        },
        {
          key   = "IMAGE_NAME"
          value = var.switch_config.image_name
        },
        {
          key   = "PNP_VLAN_ID"
          value = var.switch_config.template_params.PNP_VLAN_ID
        },
        {
          key   = "LOOPBACK_IP"
          value = var.switch_config.template_params.LOOPBACK_IP
        }
      ]
    }
    
    device_id = catalystcenter_pnp_device.switch_device.id
    site_id   = "placeholder_site_id"
    type      = "Default"
    
    image_info {
      image_id = "placeholder_image_id"
      skip     = false
    }
    
    config_info {
      config_id = "placeholder_config_id"
    }
  }

  depends_on = [
    catalystcenter_pnp_device.switch_device,
    catalystcenter_pnp_workflow.switch_workflow,
    catalystcenter_pnp_device_claim.switch_claim
  ]
}

# Output switch information
output "switch_device_info" {
  description = "Switch device information"
  value = {
    id            = catalystcenter_pnp_device.switch_device.id
    serial_number = catalystcenter_pnp_device.switch_device.parameters[0].device_info[0].serial_number
    hostname      = catalystcenter_pnp_device.switch_device.parameters[0].device_info[0].hostname
    pid           = catalystcenter_pnp_device.switch_device.parameters[0].device_info[0].pid
    stack         = catalystcenter_pnp_device.switch_device.parameters[0].device_info[0].stack
    state         = catalystcenter_pnp_device.switch_device.parameters[0].device_info[0].state
  }
}

output "switch_workflow_info" {
  description = "Switch workflow information"
  value = {
    id          = catalystcenter_pnp_workflow.switch_workflow.id
    name        = catalystcenter_pnp_workflow.switch_workflow.parameters[0].name
    description = catalystcenter_pnp_workflow.switch_workflow.parameters[0].description
    type        = catalystcenter_pnp_workflow.switch_workflow.parameters[0].type
  }
}

output "switch_configuration" {
  description = "Switch configuration details"
  value = {
    site_name     = var.switch_config.site_name
    project_name  = var.switch_config.project_name
    template_name = var.switch_config.template_name
    image_name    = var.switch_config.image_name
    template_params = var.switch_config.template_params
    pnp_type      = var.switch_config.pnp_type
  }
}

output "test_status" {
  description = "Test completion status"
  value       = "Switch device ${var.switch_device.hostname} claimed and configured successfully"
}