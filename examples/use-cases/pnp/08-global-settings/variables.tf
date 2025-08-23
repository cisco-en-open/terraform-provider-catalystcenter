# Include common variables
variable "catalyst_center_host" {
  description = "Cisco Catalyst Center FQDN or IP address"
  type        = string
}

variable "catalyst_center_username" {
  description = "Cisco Catalyst Center username"
  type        = string
}

variable "catalyst_center_password" {
  description = "Cisco Catalyst Center password"
  type        = string
  sensitive   = true
}

variable "catalyst_center_port" {
  description = "Cisco Catalyst Center port"
  type        = number
  default     = 443
}

variable "catalyst_center_debug" {
  description = "Enable debugging"
  type        = string
  default     = "false"
}

variable "catalyst_center_ssl_verify" {
  description = "Enable SSL certificate verification"
  type        = string
  default     = "false"
}

# PnP Global Settings
variable "global_settings" {
  description = "PnP global settings configuration"
  type = object({
    tenant_id   = string
    version     = number
    accept_eula = string
    
    default_profile = object({
      cert           = string
      fqdn_addresses = list(string)
      ip_addresses   = list(string)
      port           = number
      proxy          = string
    })
    
    task_time_outs = object({
      config_time_out         = number
      general_time_out        = number
      image_download_time_out = number
    })
    
    sava_mapping_enabled = bool
    
    sava_mapping = object({
      auto_sync_period = number
      cco_user         = string
      expiry           = number
      last_sync        = number
      profile = object({
        address_fqdn  = string
        address_ip_v4 = string
        cert          = string
        make_default  = string
        name          = string
        port          = number
        profile_id    = string
        proxy         = string
      })
      smart_account_id   = string
      sync_result_str    = string
      sync_start_time    = number
      sync_status        = string
      token              = string
      virtual_account_id = string
    })
  })
  
  default = {
    tenant_id   = "1"
    version     = 1
    accept_eula = "true"
    
    default_profile = {
      cert           = "default_cert"
      fqdn_addresses = ["pnpserver.cisco.com"]
      ip_addresses   = ["172.16.1.1"]
      port           = 443
      proxy          = "false"
    }
    
    task_time_outs = {
      config_time_out         = 3600
      general_time_out        = 1800
      image_download_time_out = 7200
    }
    
    sava_mapping_enabled = false
    
    sava_mapping = {
      auto_sync_period = 86400
      cco_user         = "default_user"
      expiry           = 1735689600
      last_sync        = 1672156800
      profile = {
        address_fqdn  = "pnpserver.cisco.com"
        address_ip_v4 = "172.16.1.1"
        cert          = "default_cert"
        make_default  = "true"
        name          = "default_profile"
        port          = 443
        profile_id    = "default_profile_id"
        proxy         = "false"
      }
      smart_account_id   = "default_smart_account"
      sync_result_str    = "SUCCESS"
      sync_start_time    = 1672156800
      sync_status        = "COMPLETED"
      token              = "default_token"
      virtual_account_id = "default_virtual_account"
    }
  }
}

# Optional server profile update
variable "update_server_profile" {
  description = "Whether to update server profile"
  type        = bool
  default     = false
}

variable "server_profile" {
  description = "Server profile configuration for update"
  type = object({
    auto_sync_period   = number
    cco_user          = string
    expiry            = number
    last_sync         = number
    profile_id        = string
    smart_account_id  = string
    sync_result_str   = string
    sync_start_time   = number
    sync_status       = string
    tenant_id         = string
    token             = string
    virtual_account_id = string
  })
  default = {
    auto_sync_period   = 86400
    cco_user          = "default_user"
    expiry            = 1735689600
    last_sync         = 1672156800
    profile_id        = "default_profile_id"
    smart_account_id  = "default_smart_account"
    sync_result_str   = "SUCCESS"
    sync_start_time   = 1672156800
    sync_status       = "COMPLETED"
    tenant_id         = "1"
    token             = "default_token"
    virtual_account_id = "default_virtual_account"
  }
}

# Optional virtual account addition
variable "add_virtual_account" {
  description = "Whether to add virtual account"
  type        = bool
  default     = false
}

variable "virtual_account" {
  description = "Virtual account configuration"
  type = object({
    auto_sync_period   = number
    cco_user          = string
    expiry            = number
    last_sync         = number
    profile_id        = string
    smart_account_id  = string
    sync_result_str   = string
    sync_start_time   = number
    sync_status       = string
    tenant_id         = string
    token             = string
    virtual_account_id = string
  })
  default = {
    auto_sync_period   = 86400
    cco_user          = "virtual_user"
    expiry            = 1735689600
    last_sync         = 1672156800
    profile_id        = "virtual_profile_id"
    smart_account_id  = "virtual_smart_account"
    sync_result_str   = "SUCCESS"
    sync_start_time   = 1672156800
    sync_status       = "COMPLETED"
    tenant_id         = "1"
    token             = "virtual_token"
    virtual_account_id = "virtual_account_id"
  }
}

# Optional device sync
variable "sync_virtual_account_devices" {
  description = "Whether to sync virtual account devices"
  type        = bool
  default     = false
}

variable "device_sync" {
  description = "Device sync configuration"
  type = object({
    auto_sync_period   = number
    cco_user          = string
    expiry            = number
    last_sync         = number
    profile_id        = string
    smart_account_id  = string
    sync_result_str   = string
    sync_start_time   = number
    sync_status       = string
    tenant_id         = string
    token             = string
    virtual_account_id = string
  })
  default = {
    auto_sync_period   = 86400
    cco_user          = "sync_user"
    expiry            = 1735689600
    last_sync         = 1672156800
    profile_id        = "sync_profile_id"
    smart_account_id  = "sync_smart_account"
    sync_result_str   = "SUCCESS"
    sync_start_time   = 1672156800
    sync_status       = "COMPLETED"
    tenant_id         = "1"
    token             = "sync_token"
    virtual_account_id = "sync_virtual_account"
  }
}