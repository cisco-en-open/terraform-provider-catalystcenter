# Inventory Workflow Variables
# Variables for device onboarding, site assignment, provisioning, operations, and maintenance

# Site hierarchy for device assignment and provisioning
variable "site_name_hierarchy" {
  description = "Site hierarchy path for device assignment and provisioning"
  type        = string
  default     = "Global/USA/SAN JOSE/SJ_BLD23"
}

# Device Onboarding Configuration
variable "device_onboarding" {
  description = "Configuration for device onboarding workflow"
  type = object({
    enabled = bool
    devices = list(object({
      description   = string
      hostname      = string
      mac_address   = string
      pid           = string
      serial_number = string
    }))
  })
  default = {
    enabled = true
    devices = [
      {
        description   = "Switch for Access Layer"
        hostname      = "SW-ACCESS-01"
        mac_address   = "00:1A:2B:3C:4D:5E"
        pid           = "C9300-24T"
        serial_number = "FDO12345678"
      },
      {
        description   = "Switch for Distribution Layer" 
        hostname      = "SW-DIST-01"
        mac_address   = "00:1A:2B:3C:4D:5F"
        pid           = "C9300-48T"
        serial_number = "FDO12345679"
      }
    ]
  }
}

# Site Assignment and Provisioning Configuration
variable "site_assignment_provision" {
  description = "Configuration for site assignment and provisioning workflow"
  type = object({
    enabled    = bool
    device_ips = list(string)
  })
  default = {
    enabled = true
    device_ips = [
      "204.1.2.10",
      "204.1.2.11",
      "204.1.2.12"
    ]
  }
}

# Device Operations Configuration
variable "device_operations" {
  description = "Configuration for device operations (resync, reboot)"
  type = object({
    resync_enabled    = bool
    reboot_enabled    = bool
    force_sync        = bool
    device_ids        = list(string)
    ap_mac_addresses  = list(string)
  })
  default = {
    resync_enabled = true
    reboot_enabled = false
    force_sync     = false
    device_ids = [
      "device-uuid-1",
      "device-uuid-2"
    ]
    ap_mac_addresses = [
      "00:2A:3B:4C:5D:6E",
      "00:2A:3B:4C:5D:6F"
    ]
  }
}

# Device Deletion Configuration
variable "device_deletion" {
  description = "Configuration for device deletion workflow"
  type = object({
    enabled      = bool
    clean_config = bool
    device_ids   = list(string)
  })
  default = {
    enabled      = false
    clean_config = true
    device_ids = [
      "device-uuid-to-delete-1",
      "device-uuid-to-delete-2"
    ]
  }
}

# Maintenance Scheduling Configuration
variable "maintenance_scheduling" {
  description = "Configuration for maintenance scheduling workflow"
  type = object({
    enabled = bool
    schedules = list(object({
      description          = string
      device_ids          = list(string)
      start_time          = number
      end_time            = number
      recurrence_interval = optional(number)
      recurrence_end_time = optional(number)
    }))
  })
  default = {
    enabled = true
    schedules = [
      {
        description          = "Monthly maintenance for access switches"
        device_ids          = ["device-uuid-1", "device-uuid-2"]
        start_time          = 1735689000000  # 2025-01-01 00:30:00 UTC (Unix epoch in milliseconds)
        end_time            = 1735692600000  # 2025-01-01 01:30:00 UTC (Unix epoch in milliseconds)
        recurrence_interval = 30             # 30 days
        recurrence_end_time = 1767225000000  # 2026-01-01 00:30:00 UTC (Unix epoch in milliseconds)
      },
      {
        description = "One-time maintenance for border devices"
        device_ids  = ["device-uuid-3"]
        start_time  = 1735689000000  # 2025-01-01 00:30:00 UTC
        end_time    = 1735692600000  # 2025-01-01 01:30:00 UTC
      }
    ]
  }
}

# Global settings
variable "enable_debug" {
  description = "Enable debug mode for troubleshooting"
  type        = bool
  default     = true
}

variable "timeout_settings" {
  description = "Timeout settings for inventory operations"
  type = object({
    onboarding_timeout  = number
    provision_timeout   = number
    operation_timeout   = number
    deletion_timeout    = number
  })
  default = {
    onboarding_timeout = 300   # 5 minutes
    provision_timeout  = 600   # 10 minutes
    operation_timeout  = 180   # 3 minutes
    deletion_timeout   = 240   # 4 minutes
  }
}