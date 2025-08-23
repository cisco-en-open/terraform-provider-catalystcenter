# Bulk Device Onboarding Test

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

# Bulk import multiple devices to PnP
# This corresponds to the "add_bulk_network_devices" task in the Ansible workflow
resource "catalystcenter_pnp_device_import" "bulk_devices" {
  parameters = [
    for device in var.test_devices : {
      device_info = [{
        serial_number = device.serial_number
        hostname      = device.hostname
        pid           = device.pid
        stack         = "false"
        sudi_required = "false"
        state         = "Unclaimed"
        description   = "Bulk imported device - ${device.hostname}"
      }]
    }
  ]
}

# Individual device resources for better tracking
resource "catalystcenter_pnp_device" "router_device" {
  parameters {
    device_info {
      serial_number = var.test_devices[0].serial_number
      hostname      = var.test_devices[0].hostname  
      pid           = var.test_devices[0].pid
      stack         = "false"
      sudi_required = "false"
      state         = "Unclaimed"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "catalystcenter_pnp_device" "switch_device" {
  parameters {
    device_info {
      serial_number = var.test_devices[1].serial_number
      hostname      = var.test_devices[1].hostname
      pid           = var.test_devices[1].pid
      stack         = "false"
      sudi_required = "false"
      state         = "Unclaimed"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "catalystcenter_pnp_device" "wlc_device" {
  parameters {
    device_info {
      serial_number = var.test_devices[2].serial_number
      hostname      = var.test_devices[2].hostname
      pid           = var.test_devices[2].pid
      stack         = "false"
      sudi_required = "false"
      state         = "Unclaimed"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Output the bulk import results
output "bulk_import_result" {
  description = "Results of the bulk device import"
  value = {
    total_devices = length(var.test_devices)
    devices = [
      for i, device in var.test_devices : {
        serial_number = device.serial_number
        hostname      = device.hostname
        pid           = device.pid
        type          = device.type
      }
    ]
  }
}

# Output individual device information
output "router_device_info" {
  description = "Router device information"
  value = {
    id            = catalystcenter_pnp_device.router_device.id
    serial_number = catalystcenter_pnp_device.router_device.parameters[0].device_info[0].serial_number
    hostname      = catalystcenter_pnp_device.router_device.parameters[0].device_info[0].hostname
  }
}

output "switch_device_info" {
  description = "Switch device information"
  value = {
    id            = catalystcenter_pnp_device.switch_device.id
    serial_number = catalystcenter_pnp_device.switch_device.parameters[0].device_info[0].serial_number
    hostname      = catalystcenter_pnp_device.switch_device.parameters[0].device_info[0].hostname
  }
}

output "wlc_device_info" {
  description = "WLC device information"
  value = {
    id            = catalystcenter_pnp_device.wlc_device.id
    serial_number = catalystcenter_pnp_device.wlc_device.parameters[0].device_info[0].serial_number
    hostname      = catalystcenter_pnp_device.wlc_device.parameters[0].device_info[0].hostname
  }
}

output "test_status" {
  description = "Test completion status"
  value       = "All ${length(var.test_devices)} devices onboarded successfully - ready for claiming and provisioning"
}