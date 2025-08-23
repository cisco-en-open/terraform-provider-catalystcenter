# Variables for Consolidated PnP Test Suite
# This file defines variables for all 8 test scenarios

# ================================================================================
# TEST SCENARIO 1: SINGLE DEVICE ONBOARDING
# ================================================================================
variable "device_onboarding" {
  description = "Test Scenario 1: Single device onboarding configuration"
  type = object({
    enabled = bool
    device = object({
      serial_number = string
      hostname      = string
      pid           = string
      mac_address   = string
    })
    day_zero_config = string
  })
  default = {
    enabled = false
    device = {
      serial_number = "FJC2721271T"
      hostname      = "single-test-device"
      pid           = "C9300-48T"
      mac_address   = "00:1B:44:11:3A:B7"
    }
    day_zero_config = ""
  }
}

# ================================================================================
# TEST SCENARIO 2: BULK DEVICE ONBOARDING
# ================================================================================
variable "bulk_onboarding" {
  description = "Test Scenario 2: Bulk device onboarding configuration"
  type = object({
    enabled = bool
    devices = list(object({
      serial_number            = string
      hostname                = string
      pid                     = string
      mac_address             = string
      is_stack                = bool
      sudi_required           = bool
      site_id                 = string
      stack_is_full_ring      = bool
      stack_ring_protocol     = string
      supports_stack_workflows = bool
      total_member_count      = number
      valid_license_levels    = list(string)
    }))
  })
  default = {
    enabled = false
    devices = [
      {
        serial_number            = "FJC2721271U"
        hostname                = "bulk-device-01"
        pid                     = "C9300-24T"
        mac_address             = "00:1B:44:11:3A:B8"
        is_stack                = false
        sudi_required           = false
        site_id                 = ""
        stack_is_full_ring      = false
        stack_ring_protocol     = ""
        supports_stack_workflows = false
        total_member_count      = 1
        valid_license_levels    = ["essentials"]
      },
      {
        serial_number            = "FJC2721271V"
        hostname                = "bulk-device-02"
        pid                     = "C9300-48UXM"
        mac_address             = "00:1B:44:11:3A:B9"
        is_stack                = false
        sudi_required           = false
        site_id                 = ""
        stack_is_full_ring      = false
        stack_ring_protocol     = ""
        supports_stack_workflows = false
        total_member_count      = 1
        valid_license_levels    = ["essentials", "advantage"]
      },
      {
        serial_number            = "FJC2721271W"
        hostname                = "bulk-stack-01"
        pid                     = "C9300-48P"
        mac_address             = "00:1B:44:11:3A:BA"
        is_stack                = true
        sudi_required           = false
        site_id                 = ""
        stack_is_full_ring      = true
        stack_ring_protocol     = "FlexStack"
        supports_stack_workflows = true
        total_member_count      = 2
        valid_license_levels    = ["essentials", "advantage"]
      }
    ]
  }
}

# ================================================================================
# TEST SCENARIO 3: ROUTER CLAIMING
# ================================================================================
variable "router_claiming" {
  description = "Test Scenario 3: Router claiming and provisioning"
  type = object({
    enabled              = bool
    site_name_hierarchy  = string
    device = object({
      serial_number = string
      hostname      = string
      pid           = string
      mac_address   = string
      sudi_required = bool
    })
    config_id        = string
    config_parameters = list(object({
      key   = string
      value = string
    }))
    skip_image = bool
    image_id   = string
  })
  default = {
    enabled             = false
    site_name_hierarchy = "Global/USA/San Francisco/Building1"
    device = {
      serial_number = "FGL222290LB"
      hostname      = "test-router-01"
      pid           = "ASR1001-X"
      mac_address   = "00:C8:8B:80:BB:00"
      sudi_required = true
    }
    config_id = ""
    config_parameters = [
      {
        key   = "HOSTNAME"
        value = "test-router-01"
      },
      {
        key   = "LOOPBACK0"
        value = "192.168.1.1"
      }
    ]
    skip_image = true
    image_id   = ""
  }
}

# ================================================================================
# TEST SCENARIO 4: SWITCH CLAIMING (INCLUDING STACKS)
# ================================================================================
variable "switch_claiming" {
  description = "Test Scenario 4: Switch claiming and provisioning"
  type = object({
    enabled              = bool
    site_name_hierarchy  = string
    device = object({
      serial_number            = string
      hostname                = string
      pid                     = string
      mac_address             = string
      is_stack                = bool
      sudi_required           = bool
      stack_is_full_ring      = bool
      stack_ring_protocol     = string
      supports_stack_workflows = bool
      total_member_count      = number
      valid_license_levels    = list(string)
    })
    config_id        = string
    config_parameters = list(object({
      key   = string
      value = string
    }))
    skip_image        = bool
    image_id          = string
    use_static_ip     = bool
    static_ip_address = string
    subnet_mask       = string
    gateway           = string
    dns_server        = string
    domain            = string
  })
  default = {
    enabled             = false
    site_name_hierarchy = "Global/USA/San Francisco/Floor1"
    device = {
      serial_number            = "FCW2225C0WK"
      hostname                = "test-switch-01"
      pid                     = "C9300-48UXM"
      mac_address             = "D4:AD:BD:C1:67:00"
      is_stack                = false
      sudi_required           = false
      stack_is_full_ring      = false
      stack_ring_protocol     = ""
      supports_stack_workflows = false
      total_member_count      = 1
      valid_license_levels    = ["essentials", "advantage"]
    }
    config_id = ""
    config_parameters = [
      {
        key   = "HOSTNAME"
        value = "test-switch-01"
      },
      {
        key   = "MANAGEMENT_VLAN"
        value = "100"
      }
    ]
    skip_image        = true
    image_id          = ""
    use_static_ip     = false
    static_ip_address = ""
    subnet_mask       = ""
    gateway           = ""
    dns_server        = ""
    domain            = ""
  }
}

# ================================================================================
# TEST SCENARIO 5: WIRELESS CONTROLLER CLAIMING
# ================================================================================
variable "wlc_claiming" {
  description = "Test Scenario 5: Wireless controller claiming and provisioning"
  type = object({
    enabled              = bool
    site_name_hierarchy  = string
    device = object({
      serial_number = string
      hostname      = string
      pid           = string
      mac_address   = string
      sudi_required = bool
    })
    config_id        = string
    config_parameters = list(object({
      key   = string
      value = string
    }))
    skip_image = bool
    image_id   = string
  })
  default = {
    enabled             = false
    site_name_hierarchy = "Global/USA/San Francisco/DataCenter"
    device = {
      serial_number = "FCW2242M0EP"
      hostname      = "test-wlc-01"
      pid           = "C9800-40-K9"
      mac_address   = "F8:7B:20:67:62:80"
      sudi_required = true
    }
    config_id = ""
    config_parameters = [
      {
        key   = "HOSTNAME"
        value = "test-wlc-01"
      },
      {
        key   = "MANAGEMENT_IP"
        value = "10.0.0.50"
      },
      {
        key   = "HA_MODE"
        value = "primary"
      }
    ]
    skip_image = true
    image_id   = ""
  }
}

# ================================================================================
# TEST SCENARIO 6: ACCESS POINT CLAIMING
# ================================================================================
variable "ap_claiming" {
  description = "Test Scenario 6: Access point claiming and provisioning"
  type = object({
    enabled              = bool
    site_name_hierarchy  = string
    device = object({
      serial_number = string
      hostname      = string
      pid           = string
      mac_address   = string
    })
    config_id        = string
    config_parameters = list(object({
      key   = string
      value = string
    }))
    rf_profile_name = string
    skip_image      = bool
    image_id        = string
  })
  default = {
    enabled             = false
    site_name_hierarchy = "Global/USA/San Francisco/Floor1"
    device = {
      serial_number = "KWC23400E7K"
      hostname      = "test-ap-01"
      pid           = "C9120AXE-E"
      mac_address   = "90:E9:5E:03:F3:40"
    }
    config_id = ""
    config_parameters = [
      {
        key   = "AP_NAME"
        value = "test-ap-01"
      },
      {
        key   = "AP_GROUP"
        value = "default-group"
      },
      {
        key   = "CONTROLLER_IP"
        value = "10.0.0.50"
      }
    ]
    rf_profile_name = "High-Density"
    skip_image      = true
    image_id        = ""
  }
}

# ================================================================================
# TEST SCENARIO 7: DEVICE RESET
# ================================================================================
variable "device_reset" {
  description = "Test Scenario 7: Device reset and error recovery"
  type = object({
    enabled           = bool
    create_test_device = bool
    test_device = object({
      serial_number = string
      hostname      = string
      pid           = string
      mac_address   = string
    })
    devices_to_reset = list(object({
      device_id                  = string
      license_level              = string
      license_type               = string
      top_of_stack_serial_number = string
      config_id                  = string
      config_parameters = list(object({
        key   = string
        value = string
      }))
    }))
    project_id         = string
    workflow_id        = string
    unclaim_devices    = bool
    unclaim_device_ids = list(string)
  })
  default = {
    enabled           = false
    create_test_device = true
    test_device = {
      serial_number = "TEST123456"
      hostname      = "error-device"
      pid           = "C9300-24T"
      mac_address   = "00:1B:44:11:3A:FF"
    }
    devices_to_reset = []
    project_id       = ""
    workflow_id      = ""
    unclaim_devices  = false
    unclaim_device_ids = []
  }
}

# ================================================================================
# TEST SCENARIO 8: GLOBAL SETTINGS
# ================================================================================
variable "global_settings" {
  description = "Test Scenario 8: PnP global settings configuration"
  type = object({
    enabled                   = bool
    aaa_username             = string
    aaa_password             = string
    accept_eula              = bool
    configure_default_profile = bool
    default_cert             = string
    fqdn_addresses           = list(string)
    ip_addresses             = list(string)
    port                     = number
    use_proxy                = bool
    configure_smart_account  = bool
    auto_sync_period         = number
    cco_user                 = string
    expiry                   = number
    last_sync                = number
    profile_address_fqdn     = string
    profile_address_ipv4     = string
    profile_cert             = string
    profile_make_default     = bool
    profile_name             = string
    profile_port             = number
    profile_id               = string
    profile_proxy            = bool
    smart_account_id         = string
    virtual_account_id       = string
    device_sn_list           = list(string)
    sync_type                = string
    sync_msg                 = string
    sync_result_str          = string
    sync_start_time          = number
    sync_status              = string
    tenant_id                = string
    token                    = string
    config_timeout           = number
    general_timeout          = number
    image_download_timeout   = number
    version                  = number
    sync_virtual_account     = bool
  })
  default = {
    enabled                  = false
    aaa_username            = "pnpadmin"
    aaa_password            = "PnPPassword123!"
    accept_eula             = true
    configure_default_profile = true
    default_cert            = ""
    fqdn_addresses          = ["pnp.example.com"]
    ip_addresses            = ["10.0.0.100"]
    port                    = 443
    use_proxy               = false
    configure_smart_account = false
    auto_sync_period        = 60
    cco_user                = ""
    expiry                  = 1735689600
    last_sync               = 0
    profile_address_fqdn    = ""
    profile_address_ipv4    = ""
    profile_cert            = ""
    profile_make_default    = false
    profile_name            = ""
    profile_port            = 443
    profile_id              = ""
    profile_proxy           = false
    smart_account_id        = ""
    virtual_account_id      = ""
    device_sn_list          = []
    sync_type               = "Add"
    sync_msg                = ""
    sync_result_str         = ""
    sync_start_time         = 0
    sync_status             = "NOT_SYNCED"
    tenant_id               = "default"
    token                   = ""
    config_timeout          = 600
    general_timeout         = 600
    image_download_timeout  = 3600
    version                 = 1
    sync_virtual_account    = false
  }
}

# ================================================================================
# ADDITIONAL SHARED RESOURCES
# ================================================================================

# Custom PnP Workflows
variable "pnp_workflow" {
  description = "Custom PnP workflows configuration"
  type = object({
    enabled = bool
    workflows = list(object({
      name             = string
      description      = string
      add_to_inventory = bool
      tasks = list(object({
        name        = string
        type        = string
        task_seq_no = number
        work_items = list(object({
          command    = string
          output_str = string
          state      = string
        }))
      }))
      tenant_id = string
      type      = string
      version   = number
    }))
  })
  default = {
    enabled   = false
    workflows = []
  }
}

# Configuration Preview
variable "config_preview" {
  description = "Configuration preview settings"
  type = object({
    enabled     = bool
    device_ids  = list(string)
    site_id     = string
    device_type = string
  })
  default = {
    enabled     = false
    device_ids  = []
    site_id     = ""
    device_type = "Default"
  }
}