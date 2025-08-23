# Wireless Controller (EWLC) Claiming and Provisioning Test

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

# Add the primary wireless controller device to PnP
resource "catalystcenter_pnp_device" "wlc_device_1" {
  parameters {
    device_info {
      serial_number = var.wlc_device_1.serial_number
      hostname      = var.wlc_device_1.hostname
      pid           = var.wlc_device_1.pid
      stack         = "false"
      sudi_required = "false"
      state         = "Unclaimed"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Add the secondary wireless controller device for HA setup
resource "catalystcenter_pnp_device" "wlc_device_2" {
  parameters {
    device_info {
      serial_number = var.wlc_device_2.serial_number
      hostname      = var.wlc_device_2.hostname
      pid           = var.wlc_device_2.pid
      stack         = "false"
      sudi_required = "false"
      state         = "Unclaimed"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create PnP workflow for wireless controller 1
resource "catalystcenter_pnp_workflow" "wlc_workflow_1" {
  parameters {
    name        = "WLC-${var.wlc_device_1.hostname}-Workflow"
    description = "PnP workflow for provisioning wireless controller ${var.wlc_device_1.hostname}"
    type        = "Standard"
    
    tasks {
      name        = "Wireless Controller Configuration"
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

  depends_on = [catalystcenter_pnp_device.wlc_device_1]
}

# Create PnP workflow for wireless controller 2
resource "catalystcenter_pnp_workflow" "wlc_workflow_2" {
  parameters {
    name        = "WLC-${var.wlc_device_2.hostname}-Workflow"
    description = "PnP workflow for provisioning wireless controller ${var.wlc_device_2.hostname}"
    type        = "Standard"
    
    tasks {
      name        = "Wireless Controller Configuration"
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

  depends_on = [catalystcenter_pnp_device.wlc_device_2]
}

# Claim wireless controller 1 with specific configuration
resource "catalystcenter_pnp_device_claim" "wlc_claim_1" {
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
                value = var.wlc_device_1.hostname
              },
              {
                key   = "project_name"
                value = var.wlc_config_1.project_name
              },
              {
                key   = "template_name"
                value = var.wlc_config_1.template_name
              },
              {
                key   = "MGMT_IP"
                value = var.wlc_config_1.template_params.MGMT_IP
              },
              {
                key   = "MGMT_SUBNET"
                value = var.wlc_config_1.template_params.MGMT_SUBNET
              },
              {
                key   = "NTP_SERVER_IP"
                value = var.wlc_config_1.template_params.NTP_SERVER_IP
              }
            ]
          }
        ]
        device_id = catalystcenter_pnp_device.wlc_device_1.id
        license_level = "ADVANTAGE"
        license_type = "Advantage"
        top_of_stack_serial_number = var.wlc_device_1.serial_number
      }
    ]
    file_service_id = "placeholder_file_service_id"
    image_id        = "placeholder_image_id"
    image_url       = "placeholder_image_url"
    populate_inventory = true
    project_id      = "placeholder_project_id"
    workflow_id     = catalystcenter_pnp_workflow.wlc_workflow_1.id
  }

  depends_on = [
    catalystcenter_pnp_device.wlc_device_1,
    catalystcenter_pnp_workflow.wlc_workflow_1
  ]
}

# Claim wireless controller 2 with specific configuration
resource "catalystcenter_pnp_device_claim" "wlc_claim_2" {
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
                value = var.wlc_device_2.hostname
              },
              {
                key   = "project_name"
                value = var.wlc_config_2.project_name
              },
              {
                key   = "template_name"
                value = var.wlc_config_2.template_name
              }
            ]
          }
        ]
        device_id = catalystcenter_pnp_device.wlc_device_2.id
        license_level = "ADVANTAGE"
        license_type = "Advantage"
        top_of_stack_serial_number = var.wlc_device_2.serial_number
      }
    ]
    file_service_id = "placeholder_file_service_id"
    image_id        = "placeholder_image_id"
    image_url       = "placeholder_image_url"
    populate_inventory = true
    project_id      = "placeholder_project_id"
    workflow_id     = catalystcenter_pnp_workflow.wlc_workflow_2.id
  }

  depends_on = [
    catalystcenter_pnp_device.wlc_device_2,
    catalystcenter_pnp_workflow.wlc_workflow_2
  ]
}

# Output wireless controller 1 information
output "wlc_device_1_info" {
  description = "Wireless controller 1 device information"
  value = {
    id            = catalystcenter_pnp_device.wlc_device_1.id
    serial_number = catalystcenter_pnp_device.wlc_device_1.parameters[0].device_info[0].serial_number
    hostname      = catalystcenter_pnp_device.wlc_device_1.parameters[0].device_info[0].hostname
    pid           = catalystcenter_pnp_device.wlc_device_1.parameters[0].device_info[0].pid
    state         = catalystcenter_pnp_device.wlc_device_1.parameters[0].device_info[0].state
  }
}

# Output wireless controller 2 information
output "wlc_device_2_info" {
  description = "Wireless controller 2 device information"
  value = {
    id            = catalystcenter_pnp_device.wlc_device_2.id
    serial_number = catalystcenter_pnp_device.wlc_device_2.parameters[0].device_info[0].serial_number
    hostname      = catalystcenter_pnp_device.wlc_device_2.parameters[0].device_info[0].hostname
    pid           = catalystcenter_pnp_device.wlc_device_2.parameters[0].device_info[0].pid
    state         = catalystcenter_pnp_device.wlc_device_2.parameters[0].device_info[0].state
  }
}

output "wlc_workflow_1_info" {
  description = "Wireless controller 1 workflow information"
  value = {
    id          = catalystcenter_pnp_workflow.wlc_workflow_1.id
    name        = catalystcenter_pnp_workflow.wlc_workflow_1.parameters[0].name
    description = catalystcenter_pnp_workflow.wlc_workflow_1.parameters[0].description
  }
}

output "wlc_workflow_2_info" {
  description = "Wireless controller 2 workflow information"
  value = {
    id          = catalystcenter_pnp_workflow.wlc_workflow_2.id
    name        = catalystcenter_pnp_workflow.wlc_workflow_2.parameters[0].name
    description = catalystcenter_pnp_workflow.wlc_workflow_2.parameters[0].description
  }
}

output "wlc_configuration_1" {
  description = "Wireless controller 1 configuration details"
  value = {
    site_name       = var.wlc_config_1.site_name
    project_name    = var.wlc_config_1.project_name
    template_name   = var.wlc_config_1.template_name
    image_name      = var.wlc_config_1.image_name
    pnp_type        = var.wlc_config_1.pnp_type
    static_ip       = var.wlc_config_1.static_ip
    subnet_mask     = var.wlc_config_1.subnet_mask
    gateway         = var.wlc_config_1.gateway
    ip_interface_name = var.wlc_config_1.ip_interface_name
    vlan_id         = var.wlc_config_1.vlan_id
    template_params = var.wlc_config_1.template_params
  }
}

output "wlc_configuration_2" {
  description = "Wireless controller 2 configuration details"
  value = {
    site_name       = var.wlc_config_2.site_name
    project_name    = var.wlc_config_2.project_name
    template_name   = var.wlc_config_2.template_name
    image_name      = var.wlc_config_2.image_name
    pnp_type        = var.wlc_config_2.pnp_type
    static_ip       = var.wlc_config_2.static_ip
    subnet_mask     = var.wlc_config_2.subnet_mask
    gateway         = var.wlc_config_2.gateway
    ip_interface_name = var.wlc_config_2.ip_interface_name
    vlan_id         = var.wlc_config_2.vlan_id
  }
}

output "test_status" {
  description = "Test completion status"
  value       = "Wireless controllers ${var.wlc_device_1.hostname} and ${var.wlc_device_2.hostname} claimed and configured successfully for HA setup"
}