# Example terraform.tfvars for Consolidated PnP Test Suite
# Copy this file to terraform.tfvars and update with your values
# Enable only the test scenarios you want to run

# ================================================================================
# TEST SCENARIO 1: SINGLE DEVICE ONBOARDING
# Basic test to add a single device to PnP without claiming
# ================================================================================
device_onboarding = {
  enabled = true  # Set to true to enable this test
  device = {
    serial_number = "FJC2721271T"
    hostname      = "single-test-switch"
    pid           = "C9300-48T"
    mac_address   = "00:1B:44:11:3A:B7"
  }
  day_zero_config = ""  # Optional: Add day-zero configuration
}

# ================================================================================
# TEST SCENARIO 2: BULK DEVICE ONBOARDING
# Test bulk import of multiple devices including stacks
# ================================================================================
bulk_onboarding = {
  enabled = false  # Set to true to enable this test
  devices = [
    {
      serial_number            = "FJC2721271U"
      hostname                = "bulk-switch-01"
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
      hostname                = "bulk-switch-02"
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

# ================================================================================
# TEST SCENARIO 3: ROUTER CLAIMING
# Test claiming and provisioning an ASR router
# ================================================================================
router_claiming = {
  enabled             = false  # Set to true to enable this test
  site_name_hierarchy = "Global/USA/San Francisco/Building1"
  device = {
    serial_number = "FGL222290LB"
    hostname      = "asr-router-01"
    pid           = "ASR1001-X"
    mac_address   = "00:C8:8B:80:BB:00"
    sudi_required = true
  }
  config_id = ""  # Add template ID if using configuration template
  config_parameters = [
    {
      key   = "HOSTNAME"
      value = "asr-router-01"
    },
    {
      key   = "LOOPBACK0"
      value = "192.168.1.1"
    },
    {
      key   = "BGP_AS"
      value = "65001"
    }
  ]
  skip_image = true
  image_id   = ""  # Add image ID if upgrading during claim
}

# ================================================================================
# TEST SCENARIO 4: SWITCH CLAIMING (INCLUDING STACKS)
# Test claiming and provisioning switches and stack switches
# ================================================================================
switch_claiming = {
  enabled             = false  # Set to true to enable this test
  site_name_hierarchy = "Global/USA/San Francisco/Floor1"
  device = {
    serial_number            = "FCW2225C0WK"
    hostname                = "access-switch-01"
    pid                     = "C9300-48UXM"
    mac_address             = "D4:AD:BD:C1:67:00"
    is_stack                = false  # Set to true for stack switch
    sudi_required           = false
    stack_is_full_ring      = false
    stack_ring_protocol     = ""
    supports_stack_workflows = false
    total_member_count      = 1
    valid_license_levels    = ["essentials", "advantage"]
  }
  config_id = ""  # Add template ID if using configuration template
  config_parameters = [
    {
      key   = "HOSTNAME"
      value = "access-switch-01"
    },
    {
      key   = "MANAGEMENT_VLAN"
      value = "100"
    },
    {
      key   = "MANAGEMENT_IP"
      value = "10.100.1.10"
    }
  ]
  skip_image        = true
  image_id          = ""
  use_static_ip     = false
  static_ip_address = "10.100.1.10"
  subnet_mask       = "255.255.255.0"
  gateway           = "10.100.1.1"
  dns_server        = "8.8.8.8"
  domain            = "example.local"
}

# ================================================================================
# TEST SCENARIO 5: WIRELESS CONTROLLER CLAIMING
# Test claiming and provisioning Catalyst 9800 wireless controllers
# ================================================================================
wlc_claiming = {
  enabled             = false  # Set to true to enable this test
  site_name_hierarchy = "Global/USA/San Francisco/DataCenter"
  device = {
    serial_number = "FCW2242M0EP"
    hostname      = "wlc-primary"
    pid           = "C9800-40-K9"
    mac_address   = "F8:7B:20:67:62:80"
    sudi_required = true
  }
  config_id = ""  # Add template ID if using configuration template
  config_parameters = [
    {
      key   = "HOSTNAME"
      value = "wlc-primary"
    },
    {
      key   = "MANAGEMENT_IP"
      value = "10.0.0.50"
    },
    {
      key   = "HA_MODE"
      value = "primary"
    },
    {
      key   = "PEER_IP"
      value = "10.0.0.51"
    }
  ]
  skip_image = true
  image_id   = ""
}

# ================================================================================
# TEST SCENARIO 6: ACCESS POINT CLAIMING
# Test claiming and provisioning access points
# ================================================================================
ap_claiming = {
  enabled             = false  # Set to true to enable this test
  site_name_hierarchy = "Global/USA/San Francisco/Floor1"
  device = {
    serial_number = "KWC23400E7K"
    hostname      = "ap-floor1-01"
    pid           = "C9120AXE-E"
    mac_address   = "90:E9:5E:03:F3:40"
  }
  config_id = ""  # Add template ID if using configuration template
  config_parameters = [
    {
      key   = "AP_NAME"
      value = "ap-floor1-01"
    },
    {
      key   = "AP_GROUP"
      value = "Floor1-APs"
    },
    {
      key   = "CONTROLLER_IP"
      value = "10.0.0.50"
    },
    {
      key   = "AP_MODE"
      value = "local"
    }
  ]
  rf_profile_name = "High-Density"  # RF profile for high-density deployments
  skip_image      = true
  image_id        = ""
}

# ================================================================================
# TEST SCENARIO 7: DEVICE RESET
# Test resetting devices in error state and unclaiming
# ================================================================================
device_reset = {
  enabled           = false  # Set to true to enable this test
  create_test_device = true  # Create a test device in error state
  test_device = {
    serial_number = "TEST123456"
    hostname      = "error-device"
    pid           = "C9300-24T"
    mac_address   = "00:1B:44:11:3A:FF"
  }
  devices_to_reset = [
    # Add devices to reset
    # {
    #   device_id                  = "device-uuid-here"
    #   license_level              = "essentials"
    #   license_type               = "Permanent"
    #   top_of_stack_serial_number = ""
    #   config_id                  = ""
    #   config_parameters = []
    # }
  ]
  project_id         = ""
  workflow_id        = ""
  unclaim_devices    = false
  unclaim_device_ids = []  # Add device IDs to unclaim
}

# ================================================================================
# TEST SCENARIO 8: GLOBAL SETTINGS
# Test configuring PnP global settings and Smart Account integration
# ================================================================================
global_settings = {
  enabled                  = false  # Set to true to enable this test
  aaa_username            = "pnpadmin"
  aaa_password            = "PnPPassword123!"
  accept_eula             = true
  configure_default_profile = true
  default_cert            = ""
  fqdn_addresses          = ["pnp.example.com"]
  ip_addresses            = ["10.0.0.100"]
  port                    = 443
  use_proxy               = false
  configure_smart_account = false  # Set to true if using Smart Account
  auto_sync_period        = 60
  cco_user                = "smartaccount@example.com"
  expiry                  = 1735689600
  last_sync               = 0
  profile_address_fqdn    = "pnp-profile.example.com"
  profile_address_ipv4    = "10.0.0.101"
  profile_cert            = ""
  profile_make_default    = true
  profile_name            = "Default PnP Profile"
  profile_port            = 443
  profile_id              = ""
  profile_proxy           = false
  smart_account_id        = "SA-12345678"  # Your Smart Account ID
  virtual_account_id      = "VA-87654321"  # Your Virtual Account ID
  device_sn_list          = []  # Devices to sync
  sync_type               = "Add"
  sync_msg                = "Initial sync"
  sync_result_str         = ""
  sync_start_time         = 0
  sync_status             = "NOT_SYNCED"
  tenant_id               = "default"
  token                   = ""  # Will be populated during runtime
  config_timeout          = 600
  general_timeout         = 600
  image_download_timeout  = 3600
  version                 = 1
  sync_virtual_account    = false  # Set to true to sync virtual account
}

# ================================================================================
# CUSTOM PNP WORKFLOWS (SHARED ACROSS TESTS)
# ================================================================================
pnp_workflow = {
  enabled = false  # Set to true to create custom workflows
  workflows = [
    {
      name             = "Switch-Onboarding-Workflow"
      description      = "Standard workflow for switch onboarding"
      add_to_inventory = true
      tasks = [
        {
          name        = "Configure Management"
          type        = "Config"
          task_seq_no = 1
          work_items = [
            {
              command    = "interface vlan 100"
              output_str = ""
              state      = "PENDING"
            },
            {
              command    = "ip address dhcp"
              output_str = ""
              state      = "PENDING"
            }
          ]
        },
        {
          name        = "Configure NTP"
          type        = "Config"
          task_seq_no = 2
          work_items = [
            {
              command    = "ntp server 10.0.0.1"
              output_str = ""
              state      = "PENDING"
            }
          ]
        }
      ]
      tenant_id = "default"
      type      = "Standard"
      version   = 1
    }
  ]
}

# ================================================================================
# CONFIGURATION PREVIEW (OPTIONAL)
# ================================================================================
config_preview = {
  enabled     = false  # Set to true to preview configurations
  device_ids  = []     # Add device IDs to preview
  site_id     = ""     # Site ID for preview
  device_type = "Default"
}