# Device Onboarding Test

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

# Add a single device to PnP without claiming
# This corresponds to the "add_network_device" task in the Ansible workflow
resource "catalystcenter_pnp_device" "single_device" {
  parameters {
    device_info {
      serial_number = var.test_device.serial_number
      hostname      = var.test_device.hostname
      pid           = var.test_device.pid
      stack         = "false"
      sudi_required = "false"
      state         = "Unclaimed"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Output the device information
output "device_onboarded" {
  description = "Information about the onboarded device"
  value = {
    id            = catalystcenter_pnp_device.single_device.id
    serial_number = catalystcenter_pnp_device.single_device.parameters[0].device_info[0].serial_number
    hostname      = catalystcenter_pnp_device.single_device.parameters[0].device_info[0].hostname
    pid           = catalystcenter_pnp_device.single_device.parameters[0].device_info[0].pid
    state         = catalystcenter_pnp_device.single_device.parameters[0].device_info[0].state
  }
}

output "test_status" {
  description = "Test completion status"
  value       = "Device onboarded successfully - ready for claiming and provisioning"
}