terraform {
  required_providers {
    catalystcenter = {
      version = "1.2.0-beta"
      source  = "cisco-en-programmability/catalystcenter"
    }
  }
}

# Configure provider with your Cisco Catalyst Center SDK credentials
provider "catalystcenter" {

  username = var.catalyst_username

  password = var.catalyst_password

  base_url = var.catalyst_base_url

  debug = var.catalyst_debug

  ssl_verify = var.catalyst_ssl_verify
}

# CDP Discovery
# Discovers devices using Cisco Discovery Protocol with seed IP
resource "catalystcenter_discovery" "cdp_discovery" {
  provider = catalystcenter
  
  parameters {
    name                      = var.cdp_discovery.discovery_name
    discovery_type            = var.cdp_discovery.discovery_type
    ip_address_list           = join(",", var.cdp_discovery.ip_address_list)
    protocol_order            = var.cdp_discovery.protocol_order
    retry                     = var.cdp_discovery.retry
    cdp_level                 = var.cdp_discovery.cdp_level
    is_auto_cdp               = "true"
    netconf_port              = var.cdp_discovery.net_conf_port
    global_credential_id_list = var.global_credential_id_list
    discovery_condition       = "Complete"
    discovery_status          = "Active"
  }
}

# Single IP Discovery 1
# Discovers individual devices with comprehensive credentials
resource "catalystcenter_discovery" "single_ip_discovery_1" {
  provider = catalystcenter
  
  parameters {
    name                      = var.single_ip_discovery_1.discovery_name
    discovery_type            = var.single_ip_discovery_1.discovery_type
    ip_address_list           = join(",", var.single_ip_discovery_1.ip_address_list)
    protocol_order            = var.single_ip_discovery_1.protocol_order
    retry                     = var.single_ip_discovery_1.retry
    netconf_port              = var.single_ip_discovery_1.net_conf_port
    global_credential_id_list = var.global_credential_id_list
    discovery_condition       = "Complete"
    discovery_status          = "Active"
    
    # HTTP Read Credentials
    http_read_credential {
      username    = var.single_ip_discovery_1.http_read_credential.username
      password    = var.single_ip_discovery_1.http_read_credential.password
      port        = var.single_ip_discovery_1.http_read_credential.port
      secure      = tostring(var.single_ip_discovery_1.http_read_credential.secure)
      description = "HTTP Read credential for Single IP Discovery 1"
    }
    
    # HTTP Write Credentials
    http_write_credential {
      username    = var.single_ip_discovery_1.http_write_credential.username
      password    = var.single_ip_discovery_1.http_write_credential.password
      port        = var.single_ip_discovery_1.http_write_credential.port
      secure      = tostring(var.single_ip_discovery_1.http_write_credential.secure)
      description = "HTTP Write credential for Single IP Discovery 1"
    }
  }
}

# Single IP Discovery 2
# Second single IP discovery with SNMPv3 credentials
resource "catalystcenter_discovery" "single_ip_discovery_2" {
  provider = catalystcenter
  
  parameters {
    name                      = var.single_ip_discovery_2.discovery_name
    discovery_type            = var.single_ip_discovery_2.discovery_type
    ip_address_list           = join(",", var.single_ip_discovery_2.ip_address_list)
    protocol_order            = var.single_ip_discovery_2.protocol_order
    retry                     = var.single_ip_discovery_2.retry
    netconf_port              = var.single_ip_discovery_2.net_conf_port
    global_credential_id_list = var.global_credential_id_list
    discovery_condition       = "Complete"
    discovery_status          = "Active"
    
    # SNMPv3 Credentials
    snmp_version             = "v3"
    snmp_mode                = var.single_ip_discovery_2.snmp_v3_credential.snmp_mode
    snmp_user_name           = var.single_ip_discovery_2.snmp_v3_credential.username
    snmp_auth_protocol       = var.single_ip_discovery_2.snmp_v3_credential.auth_type
    snmp_auth_passphrase     = var.single_ip_discovery_2.snmp_v3_credential.auth_password
    snmp_priv_protocol       = var.single_ip_discovery_2.snmp_v3_credential.privacy_type
    snmp_priv_passphrase     = var.single_ip_discovery_2.snmp_v3_credential.privacy_password
    
    # HTTP Read Credentials
    http_read_credential {
      username    = var.single_ip_discovery_2.http_read_credential.username
      password    = var.single_ip_discovery_2.http_read_credential.password
      port        = var.single_ip_discovery_2.http_read_credential.port
      secure      = tostring(var.single_ip_discovery_2.http_read_credential.secure)
      description = "HTTP Read credential for Single IP Discovery 2"
    }
    
    # HTTP Write Credentials
    http_write_credential {
      username    = var.single_ip_discovery_2.http_write_credential.username
      password    = var.single_ip_discovery_2.http_write_credential.password
      port        = var.single_ip_discovery_2.http_write_credential.port
      secure      = tostring(var.single_ip_discovery_2.http_write_credential.secure)
      description = "HTTP Write credential for Single IP Discovery 2"
    }
  }
}

# Range IP Discovery
# Discovers devices within a specified IP address range
resource "catalystcenter_discovery" "range_ip_discovery" {
  provider = catalystcenter
  
  parameters {
    name                      = var.range_ip_discovery.discovery_name
    discovery_type            = var.range_ip_discovery.discovery_type
    ip_address_list           = join(",", var.range_ip_discovery.ip_address_list)
    protocol_order            = var.range_ip_discovery.protocol_order
    retry                     = var.range_ip_discovery.retry
    netconf_port              = var.range_ip_discovery.net_conf_port
    global_credential_id_list = var.global_credential_id_list
    discovery_condition       = "Complete"
    discovery_status          = "Active"
    
    # SNMPv3 Credentials
    snmp_version             = "v3"
    snmp_mode                = var.range_ip_discovery.snmp_v3_credential.snmp_mode
    snmp_user_name           = var.range_ip_discovery.snmp_v3_credential.username
    snmp_auth_protocol       = var.range_ip_discovery.snmp_v3_credential.auth_type
    snmp_auth_passphrase     = var.range_ip_discovery.snmp_v3_credential.auth_password
    snmp_priv_protocol       = var.range_ip_discovery.snmp_v3_credential.privacy_type
    snmp_priv_passphrase     = var.range_ip_discovery.snmp_v3_credential.privacy_password
    
    # HTTP Read Credentials
    http_read_credential {
      username    = var.range_ip_discovery.http_read_credential.username
      password    = var.range_ip_discovery.http_read_credential.password
      port        = var.range_ip_discovery.http_read_credential.port
      secure      = tostring(var.range_ip_discovery.http_read_credential.secure)
      description = "HTTP Read credential for Range IP Discovery"
    }
    
    # HTTP Write Credentials
    http_write_credential {
      username    = var.range_ip_discovery.http_write_credential.username
      password    = var.range_ip_discovery.http_write_credential.password
      port        = var.range_ip_discovery.http_write_credential.port
      secure      = tostring(var.range_ip_discovery.http_write_credential.secure)
      description = "HTTP Write credential for Range IP Discovery"
    }
  }
}

# Multi Range IP Discovery
# Discovers devices across multiple IP address ranges
resource "catalystcenter_discovery" "multi_range_ip_discovery" {
  provider = catalystcenter
  
  parameters {
    name                      = var.multi_range_ip_discovery.discovery_name
    discovery_type            = var.multi_range_ip_discovery.discovery_type
    ip_address_list           = join(",", var.multi_range_ip_discovery.ip_address_list)
    protocol_order            = var.multi_range_ip_discovery.protocol_order
    retry                     = var.multi_range_ip_discovery.retry
    time_out                  = var.multi_range_ip_discovery.timeout
    netconf_port              = var.multi_range_ip_discovery.net_conf_port
    global_credential_id_list = var.global_credential_id_list
    discovery_condition       = "Complete"
    discovery_status          = "Active"
    
    # SNMPv3 Credentials
    snmp_version             = "v3"
    snmp_mode                = var.multi_range_ip_discovery.snmp_v3_credential.snmp_mode
    snmp_user_name           = var.multi_range_ip_discovery.snmp_v3_credential.username
    snmp_auth_protocol       = var.multi_range_ip_discovery.snmp_v3_credential.auth_type
    snmp_auth_passphrase     = var.multi_range_ip_discovery.snmp_v3_credential.auth_password
    snmp_priv_protocol       = var.multi_range_ip_discovery.snmp_v3_credential.privacy_type
    snmp_priv_passphrase     = var.multi_range_ip_discovery.snmp_v3_credential.privacy_password
    
    # HTTP Read Credentials
    http_read_credential {
      username    = var.multi_range_ip_discovery.http_read_credential.username
      password    = var.multi_range_ip_discovery.http_read_credential.password
      port        = var.multi_range_ip_discovery.http_read_credential.port
      secure      = tostring(var.multi_range_ip_discovery.http_read_credential.secure)
      description = "HTTP Read credential for Multi Range IP Discovery"
    }
    
    # HTTP Write Credentials
    http_write_credential {
      username    = var.multi_range_ip_discovery.http_write_credential.username
      password    = var.multi_range_ip_discovery.http_write_credential.password
      port        = var.multi_range_ip_discovery.http_write_credential.port
      secure      = tostring(var.multi_range_ip_discovery.http_write_credential.secure)
      description = "HTTP Write credential for Multi Range IP Discovery"
    }
  }
}