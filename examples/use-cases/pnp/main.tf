# Consolidated PnP (Plug and Play) Test Suite
# This configuration combines all 8 PnP test scenarios into a single comprehensive implementation
# Based on workflows from DNACENSolutions/dnac_ansible_workflows

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

# ================================================================================
# TEST SCENARIO 1: DEVICE ONBOARDING (SINGLE)
# Add single device to PnP without claiming
# ================================================================================
resource "catalystcenter_pnp_device" "single_device_onboarding" {
  count = var.device_onboarding.enabled ? 1 : 0
  
  parameters {
    device_info {
      serial_number = var.device_onboarding.device.serial_number
      hostname      = var.device_onboarding.device.hostname
      pid           = var.device_onboarding.device.pid
      mac_address   = var.device_onboarding.device.mac_address
      stack         = "false"
      sudi_required = "false"
      description   = "Test Device - Single Onboarding"
      
      # Optional Day Zero Config
      dynamic "day_zero_config" {
        for_each = var.device_onboarding.day_zero_config != "" ? [1] : []
        content {
          config = var.device_onboarding.day_zero_config
        }
      }
    }
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# ================================================================================
# TEST SCENARIO 2: BULK DEVICE ONBOARDING
# Import multiple devices simultaneously
# ================================================================================
resource "catalystcenter_pnp_device_import" "bulk_device_import" {
  count = var.bulk_onboarding.enabled ? 1 : 0
  
  parameters {
    dynamic "payload" {
      for_each = var.bulk_onboarding.devices
      content {
        device_info {
          serial_number = payload.value.serial_number
          hostname      = payload.value.hostname
          pid           = payload.value.pid
          mac_address   = payload.value.mac_address
          stack         = payload.value.is_stack ? "true" : "false"
          sudi_required = payload.value.sudi_required ? "true" : "false"
          description   = "Bulk Import - ${payload.value.hostname}"
          site_id       = payload.value.site_id
          
          # Stack configuration if applicable
          dynamic "stack_info" {
            for_each = payload.value.is_stack ? [1] : []
            content {
              is_full_ring             = payload.value.stack_is_full_ring
              stack_ring_protocol      = payload.value.stack_ring_protocol
              supports_stack_workflows = payload.value.supports_stack_workflows
              total_member_count       = payload.value.total_member_count
              valid_license_levels     = payload.value.valid_license_levels
            }
          }
        }
      }
    }
  }
}

# Alternative: Individual device resources for bulk onboarding (better tracking)
resource "catalystcenter_pnp_device" "bulk_devices_individual" {
  for_each = var.bulk_onboarding.enabled ? {
    for idx, device in var.bulk_onboarding.devices : 
    device.serial_number => device
  } : {}
  
  parameters {
    device_info {
      serial_number = each.value.serial_number
      hostname      = each.value.hostname
      pid           = each.value.pid
      mac_address   = each.value.mac_address
      stack         = each.value.is_stack ? "true" : "false"
      sudi_required = each.value.sudi_required ? "true" : "false"
      description   = "Bulk Device - ${each.value.hostname}"
    }
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# ================================================================================
# TEST SCENARIO 3: ROUTER CLAIMING
# Claim and provision router devices
# ================================================================================

# First, onboard the router
resource "catalystcenter_pnp_device" "router_device" {
  count = var.router_claiming.enabled ? 1 : 0
  
  parameters {
    device_info {
      serial_number = var.router_claiming.device.serial_number
      hostname      = var.router_claiming.device.hostname
      pid           = var.router_claiming.device.pid
      mac_address   = var.router_claiming.device.mac_address
      stack         = "false"
      sudi_required = var.router_claiming.device.sudi_required ? "true" : "false"
      description   = "Router Device for Claiming"
    }
  }
}

# Get site information for router claiming
data "catalystcenter_sites" "router_site" {
  count          = var.router_claiming.enabled ? 1 : 0
  name_hierarchy = var.router_claiming.site_name_hierarchy
}

# Claim the router to site
resource "catalystcenter_pnp_device_site_claim" "router_claim" {
  count = var.router_claiming.enabled ? 1 : 0
  
  parameters {
    site_id   = data.catalystcenter_sites.router_site[0].items[0].id
    device_id = catalystcenter_pnp_device.router_device[0].item[0].id
    type      = "Default"  # Router uses Default type
    
    # Configuration template
    dynamic "config_info" {
      for_each = var.router_claiming.config_id != "" ? [1] : []
      content {
        config_id = var.router_claiming.config_id
        
        dynamic "config_parameters" {
          for_each = var.router_claiming.config_parameters
          content {
            key   = config_parameters.value.key
            value = config_parameters.value.value
          }
        }
      }
    }
    
    # Image upgrade information
    dynamic "image_info" {
      for_each = var.router_claiming.skip_image ? [] : [1]
      content {
        image_id = var.router_claiming.image_id
        skip     = false
      }
    }
    
    dynamic "image_info" {
      for_each = var.router_claiming.skip_image ? [1] : []
      content {
        skip = true
      }
    }
  }
  
  depends_on = [catalystcenter_pnp_device.router_device]
}

# ================================================================================
# TEST SCENARIO 4: SWITCH CLAIMING
# Claim and provision switch devices (including stacks)
# ================================================================================

# Onboard the switch (or stack)
resource "catalystcenter_pnp_device" "switch_device" {
  count = var.switch_claiming.enabled ? 1 : 0
  
  parameters {
    device_info {
      serial_number = var.switch_claiming.device.serial_number
      hostname      = var.switch_claiming.device.hostname
      pid           = var.switch_claiming.device.pid
      mac_address   = var.switch_claiming.device.mac_address
      stack         = var.switch_claiming.device.is_stack ? "true" : "false"
      sudi_required = var.switch_claiming.device.sudi_required ? "true" : "false"
      description   = var.switch_claiming.device.is_stack ? "Stack Switch for Claiming" : "Switch for Claiming"
      
      # Stack configuration
      dynamic "stack_info" {
        for_each = var.switch_claiming.device.is_stack ? [1] : []
        content {
          is_full_ring             = var.switch_claiming.device.stack_is_full_ring
          stack_ring_protocol      = var.switch_claiming.device.stack_ring_protocol
          supports_stack_workflows = var.switch_claiming.device.supports_stack_workflows
          total_member_count       = var.switch_claiming.device.total_member_count
          valid_license_levels     = var.switch_claiming.device.valid_license_levels
        }
      }
    }
  }
}

# Get site information for switch claiming
data "catalystcenter_sites" "switch_site" {
  count          = var.switch_claiming.enabled ? 1 : 0
  name_hierarchy = var.switch_claiming.site_name_hierarchy
}

# Claim the switch to site
resource "catalystcenter_pnp_device_site_claim" "switch_claim" {
  count = var.switch_claiming.enabled ? 1 : 0
  
  parameters {
    site_id   = data.catalystcenter_sites.switch_site[0].items[0].id
    device_id = catalystcenter_pnp_device.switch_device[0].item[0].id
    type      = var.switch_claiming.device.is_stack ? "StackSwitch" : "Default"
    
    # Configuration template
    dynamic "config_info" {
      for_each = var.switch_claiming.config_id != "" ? [1] : []
      content {
        config_id = var.switch_claiming.config_id
        
        dynamic "config_parameters" {
          for_each = var.switch_claiming.config_parameters
          content {
            key   = config_parameters.value.key
            value = config_parameters.value.value
          }
        }
      }
    }
    
    # Image information
    dynamic "image_info" {
      for_each = var.switch_claiming.skip_image ? [1] : []
      content {
        skip = true
      }
    }
    
    # Static IP configuration (optional)
    dynamic "static_ip" {
      for_each = var.switch_claiming.use_static_ip ? [1] : []
      content {
        ip_address  = var.switch_claiming.static_ip_address
        subnet_mask = var.switch_claiming.subnet_mask
        gateway     = var.switch_claiming.gateway
        dns_server  = var.switch_claiming.dns_server
        domain      = var.switch_claiming.domain
      }
    }
  }
  
  depends_on = [catalystcenter_pnp_device.switch_device]
}

# ================================================================================
# TEST SCENARIO 5: WIRELESS CONTROLLER CLAIMING
# Claim and provision Catalyst 9800 wireless controllers
# ================================================================================

# Onboard the wireless controller
resource "catalystcenter_pnp_device" "wireless_controller" {
  count = var.wlc_claiming.enabled ? 1 : 0
  
  parameters {
    device_info {
      serial_number = var.wlc_claiming.device.serial_number
      hostname      = var.wlc_claiming.device.hostname
      pid           = var.wlc_claiming.device.pid
      mac_address   = var.wlc_claiming.device.mac_address
      stack         = "false"
      sudi_required = var.wlc_claiming.device.sudi_required ? "true" : "false"
      description   = "Catalyst 9800 Wireless Controller"
    }
  }
}

# Get site information for WLC claiming
data "catalystcenter_sites" "wlc_site" {
  count          = var.wlc_claiming.enabled ? 1 : 0
  name_hierarchy = var.wlc_claiming.site_name_hierarchy
}

# Claim the wireless controller to site
resource "catalystcenter_pnp_device_site_claim" "wlc_claim" {
  count = var.wlc_claiming.enabled ? 1 : 0
  
  parameters {
    site_id   = data.catalystcenter_sites.wlc_site[0].items[0].id
    device_id = catalystcenter_pnp_device.wireless_controller[0].item[0].id
    type      = "CatalystWLC"
    
    # WLC-specific configuration
    dynamic "config_info" {
      for_each = var.wlc_claiming.config_id != "" ? [1] : []
      content {
        config_id = var.wlc_claiming.config_id
        
        dynamic "config_parameters" {
          for_each = var.wlc_claiming.config_parameters
          content {
            key   = config_parameters.value.key
            value = config_parameters.value.value
          }
        }
      }
    }
    
    # Image information
    dynamic "image_info" {
      for_each = var.wlc_claiming.skip_image ? [1] : []
      content {
        skip = true
      }
    }
  }
  
  depends_on = [catalystcenter_pnp_device.wireless_controller]
}

# ================================================================================
# TEST SCENARIO 6: ACCESS POINT CLAIMING
# Claim and provision access points
# ================================================================================

# Onboard the access point
resource "catalystcenter_pnp_device" "access_point" {
  count = var.ap_claiming.enabled ? 1 : 0
  
  parameters {
    device_info {
      serial_number = var.ap_claiming.device.serial_number
      hostname      = var.ap_claiming.device.hostname
      pid           = var.ap_claiming.device.pid
      mac_address   = var.ap_claiming.device.mac_address
      stack         = "false"
      sudi_required = "false"
      description   = "Access Point for Claiming"
    }
  }
}

# Get site information for AP claiming
data "catalystcenter_sites" "ap_site" {
  count          = var.ap_claiming.enabled ? 1 : 0
  name_hierarchy = var.ap_claiming.site_name_hierarchy
}

# Claim the access point to site
resource "catalystcenter_pnp_device_site_claim" "ap_claim" {
  count = var.ap_claiming.enabled ? 1 : 0
  
  parameters {
    site_id   = data.catalystcenter_sites.ap_site[0].items[0].id
    device_id = catalystcenter_pnp_device.access_point[0].item[0].id
    type      = "AccessPoint"
    
    # AP-specific configuration
    dynamic "config_info" {
      for_each = var.ap_claiming.config_id != "" ? [1] : []
      content {
        config_id = var.ap_claiming.config_id
        
        dynamic "config_parameters" {
          for_each = var.ap_claiming.config_parameters
          content {
            key   = config_parameters.value.key
            value = config_parameters.value.value
          }
        }
      }
    }
    
    # RF Profile for AP
    dynamic "rf_profile" {
      for_each = var.ap_claiming.rf_profile_name != "" ? [1] : []
      content {
        rf_profile_name = var.ap_claiming.rf_profile_name
      }
    }
    
    # Image information
    dynamic "image_info" {
      for_each = var.ap_claiming.skip_image ? [1] : []
      content {
        skip = true
      }
    }
  }
  
  depends_on = [catalystcenter_pnp_device.access_point]
}

# ================================================================================
# TEST SCENARIO 7: DEVICE RESET
# Reset devices in error state
# ================================================================================

# First, create a device that might need resetting
resource "catalystcenter_pnp_device" "device_for_reset" {
  count = var.device_reset.enabled && var.device_reset.create_test_device ? 1 : 0
  
  parameters {
    device_info {
      serial_number = var.device_reset.test_device.serial_number
      hostname      = var.device_reset.test_device.hostname
      pid           = var.device_reset.test_device.pid
      mac_address   = var.device_reset.test_device.mac_address
      stack         = "false"
      sudi_required = "false"
      description   = "Device in error state for reset testing"
    }
  }
}

# Reset devices
resource "catalystcenter_pnp_device_reset" "device_reset" {
  count = var.device_reset.enabled ? 1 : 0
  
  parameters {
    dynamic "device_reset_list" {
      for_each = var.device_reset.devices_to_reset
      content {
        device_id            = device_reset_list.value.device_id
        license_level        = device_reset_list.value.license_level
        license_type         = device_reset_list.value.license_type
        top_of_stack_serial_number = device_reset_list.value.top_of_stack_serial_number
        
        dynamic "config_list" {
          for_each = device_reset_list.value.config_id != "" ? [1] : []
          content {
            config_id = device_reset_list.value.config_id
            
            dynamic "config_parameters" {
              for_each = device_reset_list.value.config_parameters
              content {
                key   = config_parameters.value.key
                value = config_parameters.value.value
              }
            }
          }
        }
      }
    }
    
    project_id  = var.device_reset.project_id
    workflow_id = var.device_reset.workflow_id
  }
  
  depends_on = [catalystcenter_pnp_device.device_for_reset]
}

# Unclaim devices (alternative to reset)
resource "catalystcenter_pnp_device_unclaim" "device_unclaim" {
  count = var.device_reset.enabled && var.device_reset.unclaim_devices ? 1 : 0
  
  parameters {
    device_id_list = var.device_reset.unclaim_device_ids
  }
}

# ================================================================================
# TEST SCENARIO 8: GLOBAL SETTINGS
# Manage PnP global configurations
# ================================================================================

# Configure PnP Global Settings
resource "catalystcenter_pnp_global_settings" "global_settings" {
  count = var.global_settings.enabled ? 1 : 0
  
  parameters {
    # AAA Credentials
    dynamic "aaa_credentials" {
      for_each = var.global_settings.aaa_username != "" ? [1] : []
      content {
        username = var.global_settings.aaa_username
        password = var.global_settings.aaa_password
      }
    }
    
    accept_eula = var.global_settings.accept_eula
    
    # Default Profile
    dynamic "default_profile" {
      for_each = var.global_settings.configure_default_profile ? [1] : []
      content {
        cert           = var.global_settings.default_cert
        fqdn_addresses = var.global_settings.fqdn_addresses
        ip_addresses   = var.global_settings.ip_addresses
        port           = var.global_settings.port
        proxy          = var.global_settings.use_proxy
      }
    }
    
    # Smart Account Integration
    dynamic "sava_mapping_list" {
      for_each = var.global_settings.configure_smart_account ? [1] : []
      content {
        cco_user         = var.global_settings.cco_user
        expiry           = var.global_settings.expiry
        
        profile {
          address_fqdn = var.global_settings.profile_address_fqdn
          address_ip_v4 = var.global_settings.profile_address_ipv4
          cert         = var.global_settings.profile_cert
          make_default = var.global_settings.profile_make_default
          name         = var.global_settings.profile_name
          port         = var.global_settings.profile_port
          profile_id   = var.global_settings.profile_id
          proxy        = var.global_settings.profile_proxy
        }
        
        smart_account_id   = var.global_settings.smart_account_id
        virtual_account_id = var.global_settings.virtual_account_id
        
      }
    }
  }
}

# Virtual Account Sync (Part of Global Settings)
resource "catalystcenter_pnp_virtual_account_devices_sync" "va_sync" {
  count = var.global_settings.enabled && var.global_settings.sync_virtual_account ? 1 : 0
  
  parameters {
    auto_sync_period = var.global_settings.auto_sync_period
    cco_user         = var.global_settings.cco_user
    expiry           = var.global_settings.expiry
    last_sync        = var.global_settings.last_sync
    
    profile {
      address_fqdn  = var.global_settings.profile_address_fqdn
      address_ip_v4 = var.global_settings.profile_address_ipv4
      cert          = var.global_settings.profile_cert
      make_default  = var.global_settings.profile_make_default
      name          = var.global_settings.profile_name
      port          = var.global_settings.profile_port
      profile_id    = var.global_settings.profile_id
      proxy         = var.global_settings.profile_proxy
    }
    
    smart_account_id   = var.global_settings.smart_account_id
    virtual_account_id = var.global_settings.virtual_account_id
    
    sync_result {
      sync_list {
        device_sn_list = var.global_settings.device_sn_list
        sync_type      = var.global_settings.sync_type
      }
      sync_msg = var.global_settings.sync_msg
    }
    
    sync_result_str = var.global_settings.sync_result_str
    sync_start_time = var.global_settings.sync_start_time
    sync_status     = var.global_settings.sync_status
    tenant_id       = var.global_settings.tenant_id
    token           = var.global_settings.token
  }
  
  depends_on = [catalystcenter_pnp_global_settings.global_settings]
}

# ================================================================================
# ADDITIONAL RESOURCES
# ================================================================================

# PnP Workflow Management (Used by multiple scenarios)
resource "catalystcenter_pnp_workflow" "custom_workflow" {
  count = var.pnp_workflow.enabled ? length(var.pnp_workflow.workflows) : 0
  
  parameters {
    name             = var.pnp_workflow.workflows[count.index].name
    description      = var.pnp_workflow.workflows[count.index].description
    add_to_inventory = var.pnp_workflow.workflows[count.index].add_to_inventory
    
    dynamic "tasks" {
      for_each = var.pnp_workflow.workflows[count.index].tasks
      content {
        name        = tasks.value.name
        type        = tasks.value.type
        task_seq_no = tasks.value.task_seq_no
        
        dynamic "work_item_list" {
          for_each = tasks.value.work_items
          content {
            command    = work_item_list.value.command
            output_str = work_item_list.value.output_str
            state      = work_item_list.value.state
          }
        }
      }
    }
    
    tenant_id = var.pnp_workflow.workflows[count.index].tenant_id
    type      = var.pnp_workflow.workflows[count.index].type
    version   = var.pnp_workflow.workflows[count.index].version
  }
}

# Configuration Preview (Available for all claiming scenarios)
resource "catalystcenter_pnp_device_config_preview" "config_preview" {
  count = var.config_preview.enabled ? length(var.config_preview.device_ids) : 0
  
  parameters {
    device_id = var.config_preview.device_ids[count.index]
    site_id   = var.config_preview.site_id
    type      = var.config_preview.device_type
  }
}

# ================================================================================
# DATA SOURCES FOR VALIDATION AND QUERYING
# ================================================================================

# Query all PnP devices
data "catalystcenter_pnp_device" "all_devices" {
  provider = catalystcenter
  
  depends_on = [
    catalystcenter_pnp_device.single_device_onboarding,
    catalystcenter_pnp_device.bulk_devices_individual,
    catalystcenter_pnp_device.router_device,
    catalystcenter_pnp_device.switch_device,
    catalystcenter_pnp_device.wireless_controller,
    catalystcenter_pnp_device.access_point
  ]
}

# Query PnP device count
data "catalystcenter_pnp_device_count" "device_count" {
  provider = catalystcenter
  
  depends_on = [data.catalystcenter_pnp_device.all_devices]
}

# Query PnP workflows
data "catalystcenter_pnp_workflow" "workflows" {
  provider = catalystcenter
  
  depends_on = [catalystcenter_pnp_workflow.custom_workflow]
}

# Query virtual accounts
data "catalystcenter_pnp_virtual_accounts" "virtual_accounts" {
  provider = catalystcenter

  domain = "cisco.com"
  
  depends_on = [catalystcenter_pnp_virtual_account_devices_sync.va_sync]
}

# Query smart account domains
data "catalystcenter_pnp_smart_account_domains" "smart_domains" {
  provider = catalystcenter
  
  depends_on = [catalystcenter_pnp_global_settings.global_settings]
}

# Query global settings
data "catalystcenter_pnp_global_settings" "current_settings" {
  provider = catalystcenter
  
  depends_on = [catalystcenter_pnp_global_settings.global_settings]
}