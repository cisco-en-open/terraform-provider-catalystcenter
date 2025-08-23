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

# Wireless Controller 1 device information
variable "wlc_device_1" {
  description = "Wireless controller 1 device information"
  type = object({
    serial_number = string
    hostname      = string
    pid           = string
  })
  default = {
    serial_number = "TTM2737020R"
    hostname      = "NY-EWLC-1"
    pid           = "C9800-40-K9"
  }
}

# Wireless Controller 1 configuration
variable "wlc_config_1" {
  description = "Wireless controller 1 configuration parameters"
  type = object({
    site_name         = string
    project_name      = string
    template_name     = string
    image_name        = string
    pnp_type          = string
    static_ip         = string
    subnet_mask       = string
    gateway           = string
    ip_interface_name = string
    vlan_id           = number
    template_params   = object({
      MGMT_IP        = string
      MGMT_SUBNET    = string
      NTP_SERVER_IP  = string
    })
  })
  default = {
    site_name         = "Global/USA/New York/NY_BLD2"
    project_name      = "Onboarding Configuration"
    template_name     = "PnP-Devices_NY-EWLC_No-Vars"
    image_name        = "C9800-40-universalk9_wlc.17.13.01.SPA.bin"
    pnp_type          = "CatalystWLC"
    static_ip         = "10.4.218.230"
    subnet_mask       = "255.255.255.240"
    gateway           = "10.4.218.225"
    ip_interface_name = "TenGigabitEthernet0/0/1"
    vlan_id           = 2014
    template_params = {
      MGMT_IP       = "10.4.218.230"
      MGMT_SUBNET   = "255.255.255.240"
      NTP_SERVER_IP = "171.68.38.66"
    }
  }
}

# Wireless Controller 2 device information (HA setup)
variable "wlc_device_2" {
  description = "Wireless controller 2 device information"
  type = object({
    serial_number = string
    hostname      = string
    pid           = string
  })
  default = {
    serial_number = "TTM2737021L"
    hostname      = "NY-EWLC-2"
    pid           = "C9800-40-K9"
  }
}

# Wireless Controller 2 configuration (HA setup)
variable "wlc_config_2" {
  description = "Wireless controller 2 configuration parameters"
  type = object({
    site_name         = string
    project_name      = string
    template_name     = string
    image_name        = string
    pnp_type          = string
    static_ip         = string
    subnet_mask       = string
    gateway           = string
    ip_interface_name = string
    vlan_id           = number
  })
  default = {
    site_name         = "Global/USA/New York/NY_BLD2"
    project_name      = "Onboarding Configuration"
    template_name     = "PnP-Devices_NY-EWLC_No-Vars"
    image_name        = "C9800-40-universalk9_wlc.17.13.01.SPA.bin"
    pnp_type          = "CatalystWLC"
    static_ip         = "10.4.218.232"
    subnet_mask       = "255.255.255.240"
    gateway           = "10.4.218.225"
    ip_interface_name = "TenGigabitEthernet0/0/1"
    vlan_id           = 2014
  }
}

# Alternative WLC configuration for different site (San Jose)
variable "wlc_device_sj" {
  description = "San Jose wireless controller device information"
  type = object({
    serial_number = string
    hostname      = string
    pid           = string
  })
  default = {
    serial_number = "FOX2639PAYD"
    hostname      = "SJ-EWLC-1"
    pid           = "C9800-40-K9"
  }
}

variable "wlc_config_sj" {
  description = "San Jose wireless controller configuration parameters"
  type = object({
    site_name         = string
    project_name      = string
    template_name     = string
    image_name        = string
    pnp_type          = string
    static_ip         = string
    subnet_mask       = string
    gateway           = string
    ip_interface_name = string
    vlan_id           = number
    template_params   = object({
      MGMT_IP        = string
      MGMT_SUBNET    = string
      NTP_SERVER_IP  = string
    })
  })
  default = {
    site_name         = "Global/USA/SAN JOSE/SJ_BLD23"
    project_name      = "Onboarding Configuration"
    template_name     = "PnP-Devices_SJ-EWLC"
    image_name        = "C9800-40-universalk9_wlc.17.12.02.SPA.bin"
    pnp_type          = "CatalystWLC"
    static_ip         = "204.192.50.200"
    subnet_mask       = "255.255.255.0"
    gateway           = "204.192.50.1"
    ip_interface_name = "TenGigabitEthernet0/0/2"
    vlan_id           = 2050
    template_params = {
      MGMT_IP       = "10.22.40.244"
      MGMT_SUBNET   = "255.255.255.0"
      NTP_SERVER_IP = "171.68.38.66"
    }
  }
}