# Device Reset Test for Error State Devices

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

# First, add a device to PnP that may encounter errors
resource "catalystcenter_pnp_device" "error_device" {
  parameters {
    device_info {
      serial_number = var.error_device.serial_number
      hostname      = var.error_device.hostname
      pid           = var.error_device.pid
      stack         = "false"
      sudi_required = "false"
      state         = var.error_device.state
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Reset the device when it's in error state
# This corresponds to device reset scenarios in the Ansible workflow
resource "catalystcenter_pnp_device_reset" "device_reset" {
  parameters {
    device_reset_list = [
      {
        config_list = [
          {
            config_id = "placeholder_config_id"
            config_parameters = [
              {
                key   = "hostname"
                value = var.error_device.hostname
              },
              {
                key   = "reset_reason"
                value = "Error state recovery"
              },
              {
                key   = "reset_type"
                value = "FACTORY_RESET"
              }
            ]
          }
        ]
        device_id = catalystcenter_pnp_device.error_device.id
        license_level = "ADVANTAGE"
        license_type = "Advantage"
        top_of_stack_serial_number = var.error_device.serial_number
      }
    ]
    populate_inventory = false
    project_id         = "placeholder_project_id"
    workflow_id        = "placeholder_workflow_id"
  }

  depends_on = [catalystcenter_pnp_device.error_device]
}

# After reset, re-add the device for retry
resource "catalystcenter_pnp_device" "retry_device" {
  parameters {
    device_info {
      serial_number = var.error_device.serial_number
      hostname      = "${var.error_device.hostname}-RETRY"
      pid           = var.error_device.pid
      stack         = "false"
      sudi_required = "false"
      state         = "Unclaimed"
    }
  }

  depends_on = [catalystcenter_pnp_device_reset.device_reset]

  lifecycle {
    create_before_destroy = true
  }
}

# Create a workflow for the retry attempt
resource "catalystcenter_pnp_workflow" "retry_workflow" {
  parameters {
    name        = "Retry-${var.error_device.hostname}-Workflow"
    description = "PnP workflow for retrying provisioning after reset for ${var.error_device.hostname}"
    type        = "Standard"
    
    tasks {
      name        = "Device Reset Recovery"
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

  depends_on = [
    catalystcenter_pnp_device.retry_device,
    catalystcenter_pnp_device_reset.device_reset
  ]
}

# Output original error device information
output "error_device_info" {
  description = "Original error device information"
  value = {
    id            = catalystcenter_pnp_device.error_device.id
    serial_number = catalystcenter_pnp_device.error_device.parameters[0].device_info[0].serial_number
    hostname      = catalystcenter_pnp_device.error_device.parameters[0].device_info[0].hostname
    pid           = catalystcenter_pnp_device.error_device.parameters[0].device_info[0].pid
    original_state = var.error_device.state
  }
}

# Output retry device information  
output "retry_device_info" {
  description = "Retry device information after reset"
  value = {
    id            = catalystcenter_pnp_device.retry_device.id
    serial_number = catalystcenter_pnp_device.retry_device.parameters[0].device_info[0].serial_number
    hostname      = catalystcenter_pnp_device.retry_device.parameters[0].device_info[0].hostname
    pid           = catalystcenter_pnp_device.retry_device.parameters[0].device_info[0].pid
    state         = catalystcenter_pnp_device.retry_device.parameters[0].device_info[0].state
  }
}

output "reset_operation_info" {
  description = "Device reset operation information"
  value = {
    reset_performed = true
    original_device_id = catalystcenter_pnp_device.error_device.id
    retry_device_id = catalystcenter_pnp_device.retry_device.id
    retry_workflow_id = catalystcenter_pnp_workflow.retry_workflow.id
  }
}

output "test_status" {
  description = "Test completion status"
  value = "Device ${var.error_device.hostname} was reset and retry workflow created successfully. Device is ready for another onboarding attempt."
}