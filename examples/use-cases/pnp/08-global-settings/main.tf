# PnP Global Settings Management Test

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

# Configure PnP Global Settings
# This includes default profiles, SAVA mapping, and other global configurations
resource "catalystcenter_pnp_global_settings" "pnp_global_config" {
  parameters {
    tenant_id = var.global_settings.tenant_id
    version   = var.global_settings.version

    # Accept EULA
    accept_eula = var.global_settings.accept_eula

    # Default profile configuration
    default_profile {
      cert           = var.global_settings.default_profile.cert
      fqdn_addresses = var.global_settings.default_profile.fqdn_addresses
      ip_addresses   = var.global_settings.default_profile.ip_addresses
      port           = var.global_settings.default_profile.port
      proxy          = var.global_settings.default_profile.proxy
    }

    # Task timeout configurations
    task_time_outs {
      config_time_out         = var.global_settings.task_time_outs.config_time_out
      general_time_out        = var.global_settings.task_time_outs.general_time_out
      image_download_time_out = var.global_settings.task_time_outs.image_download_time_out
    }

    # SAVA mapping configuration (if enabled)
    dynamic "sava_mapping_list" {
      for_each = var.global_settings.sava_mapping_enabled ? [1] : []
      content {
        auto_sync_period = var.global_settings.sava_mapping.auto_sync_period
        cco_user         = var.global_settings.sava_mapping.cco_user
        expiry           = var.global_settings.sava_mapping.expiry
        last_sync        = var.global_settings.sava_mapping.last_sync

        profile {
          address_fqdn  = var.global_settings.sava_mapping.profile.address_fqdn
          address_ip_v4 = var.global_settings.sava_mapping.profile.address_ip_v4
          cert          = var.global_settings.sava_mapping.profile.cert
          make_default  = var.global_settings.sava_mapping.profile.make_default
          name          = var.global_settings.sava_mapping.profile.name
          port          = var.global_settings.sava_mapping.profile.port
          profile_id    = var.global_settings.sava_mapping.profile.profile_id
          proxy         = var.global_settings.sava_mapping.profile.proxy
        }

        smart_account_id   = var.global_settings.sava_mapping.smart_account_id
        sync_result_str    = var.global_settings.sava_mapping.sync_result_str
        sync_start_time    = var.global_settings.sava_mapping.sync_start_time
        sync_status        = var.global_settings.sava_mapping.sync_status
        token              = var.global_settings.sava_mapping.token
        virtual_account_id = var.global_settings.sava_mapping.virtual_account_id
      }
    }
  }
}

# Update PnP server profile (if needed)
resource "catalystcenter_pnp_server_profile_update" "server_profile_update" {
  count = var.update_server_profile ? 1 : 0

  parameters {
    auto_sync_period   = var.server_profile.auto_sync_period
    cco_user          = var.server_profile.cco_user
    expiry            = var.server_profile.expiry
    last_sync         = var.server_profile.last_sync
    profile_id        = var.server_profile.profile_id
    smart_account_id  = var.server_profile.smart_account_id
    sync_result_str   = var.server_profile.sync_result_str
    sync_start_time   = var.server_profile.sync_start_time
    sync_status       = var.server_profile.sync_status
    tenant_id         = var.server_profile.tenant_id
    token             = var.server_profile.token
    virtual_account_id = var.server_profile.virtual_account_id
  }

  depends_on = [catalystcenter_pnp_global_settings.pnp_global_config]
}

# Add virtual account (if needed)
resource "catalystcenter_pnp_virtual_account_add" "virtual_account" {
  count = var.add_virtual_account ? 1 : 0

  parameters {
    auto_sync_period   = var.virtual_account.auto_sync_period
    cco_user          = var.virtual_account.cco_user
    expiry            = var.virtual_account.expiry
    last_sync         = var.virtual_account.last_sync
    profile_id        = var.virtual_account.profile_id
    smart_account_id  = var.virtual_account.smart_account_id
    sync_result_str   = var.virtual_account.sync_result_str
    sync_start_time   = var.virtual_account.sync_start_time
    sync_status       = var.virtual_account.sync_status
    tenant_id         = var.virtual_account.tenant_id
    token             = var.virtual_account.token
    virtual_account_id = var.virtual_account.virtual_account_id
  }

  depends_on = [catalystcenter_pnp_global_settings.pnp_global_config]
}

# Sync virtual account devices (if needed)
resource "catalystcenter_pnp_virtual_account_devices_sync" "devices_sync" {
  count = var.sync_virtual_account_devices ? 1 : 0

  parameters {
    auto_sync_period   = var.device_sync.auto_sync_period
    cco_user          = var.device_sync.cco_user
    expiry            = var.device_sync.expiry
    last_sync         = var.device_sync.last_sync
    profile_id        = var.device_sync.profile_id
    smart_account_id  = var.device_sync.smart_account_id
    sync_result_str   = var.device_sync.sync_result_str
    sync_start_time   = var.device_sync.sync_start_time
    sync_status       = var.device_sync.sync_status
    tenant_id         = var.device_sync.tenant_id
    token             = var.device_sync.token
    virtual_account_id = var.device_sync.virtual_account_id
  }

  depends_on = [
    catalystcenter_pnp_global_settings.pnp_global_config,
    catalystcenter_pnp_virtual_account_add.virtual_account
  ]
}

# Output global settings information
output "global_settings_info" {
  description = "PnP global settings information"
  value = {
    id          = catalystcenter_pnp_global_settings.pnp_global_config.id
    tenant_id   = var.global_settings.tenant_id
    version     = var.global_settings.version
    accept_eula = var.global_settings.accept_eula
  }
  sensitive = true
}

output "default_profile_info" {
  description = "Default profile configuration"
  value = {
    port           = var.global_settings.default_profile.port
    fqdn_addresses = var.global_settings.default_profile.fqdn_addresses
    ip_addresses   = var.global_settings.default_profile.ip_addresses
    proxy          = var.global_settings.default_profile.proxy
  }
}

output "task_timeouts_info" {
  description = "Task timeout configuration"
  value = {
    config_time_out         = var.global_settings.task_time_outs.config_time_out
    general_time_out        = var.global_settings.task_time_outs.general_time_out
    image_download_time_out = var.global_settings.task_time_outs.image_download_time_out
  }
}

output "optional_components_status" {
  description = "Status of optional components"
  value = {
    server_profile_updated         = var.update_server_profile
    virtual_account_added          = var.add_virtual_account
    virtual_account_devices_synced = var.sync_virtual_account_devices
  }
}

output "test_status" {
  description = "Test completion status"
  value = "PnP global settings configured successfully with all required components"
}