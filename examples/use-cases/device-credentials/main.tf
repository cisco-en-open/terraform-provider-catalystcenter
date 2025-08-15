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
  # Cisco Catalyst Center user name
  username = var.catalyst_username
  # Cisco Catalyst Center password
  password = var.catalyst_password
  # Cisco Catalyst Center base URL, FQDN or IP
  base_url = var.catalyst_base_url
  # Boolean to enable debugging
  debug = var.catalyst_debug
  # Boolean to enable or disable SSL certificate verification
  ssl_verify = var.catalyst_ssl_verify
}

# CLI Credential 1
resource "catalystcenter_global_credential_cli" "cli_sample_1" {
  provider = catalystcenter
  parameters {
    comments        = "CLI Sample 1 - Test credential"
    credential_type = "GLOBAL"
    description     = "CLI Sample 1"
    enable_password = var.cli_credentials.cli_1.enable_password
    password        = var.cli_credentials.cli_1.password
    username        = var.cli_credentials.cli_1.username
  }
}

# CLI Credential 2
resource "catalystcenter_global_credential_cli" "cli_sample_2" {
  provider = catalystcenter
  parameters {
    comments        = "CLI Sample 2 - Test credential"
    credential_type = "GLOBAL"
    description     = "CLI2"
    enable_password = var.cli_credentials.cli_2.enable_password
    password        = var.cli_credentials.cli_2.password
    username        = var.cli_credentials.cli_2.username
  }
}

# SNMPv2c Read Credential
resource "catalystcenter_global_credential_snmpv2_read_community" "snmp_read_1" {
  provider = catalystcenter
  parameters {
    comments        = "SNMP Read Community - Test credential"
    credential_type = "GLOBAL"
    description     = "snmpRead-1"
    read_community  = var.snmp_v2c_credentials.read.community
  }
}

# SNMPv2c Write Credential  
resource "catalystcenter_global_credential_snmpv2_write_community" "snmp_write_1" {
  provider = catalystcenter
  parameters {
    comments         = "SNMP Write Community - Test credential"
    credential_type  = "GLOBAL"
    description      = "snmpWrite-1"
    write_community  = var.snmp_v2c_credentials.write.community
  }
}

# SNMPv3 Credential
resource "catalystcenter_global_credential_snmpv3" "snmpv3_sample_1" {
  provider = catalystcenter
  parameters {
    auth_password    = var.snmp_v3_credentials.auth_password
    auth_type        = var.snmp_v3_credentials.auth_type
    comments         = "SNMPv3 Sample 1 - Test credential"
    credential_type  = "GLOBAL"
    description      = var.snmp_v3_credentials.description
    privacy_password = var.snmp_v3_credentials.privacy_password
    privacy_type     = var.snmp_v3_credentials.privacy_type
    snmp_mode        = var.snmp_v3_credentials.snmp_mode
    username         = var.snmp_v3_credentials.username
  }
}

# HTTPS Read Credential
resource "catalystcenter_global_credential_http_read" "https_read_sample_1" {
  provider = catalystcenter
  parameters {
    comments        = "HTTPS Read Sample 1 - Test credential"
    credential_type = "GLOBAL"
    description     = var.https_credentials.read.description
    password        = var.https_credentials.read.password
    port            = var.https_credentials.read.port
    secure          = "true"
    username        = var.https_credentials.read.username
  }
}

# HTTPS Write Credential
resource "catalystcenter_global_credential_http_write" "https_write_sample_1" {
  provider = catalystcenter
  parameters {
    comments        = "HTTPS Write Sample 1 - Test credential"
    credential_type = "GLOBAL"
    description     = var.https_credentials.write.description
    password        = var.https_credentials.write.password
    port            = var.https_credentials.write.port
    secure          = "true"
    username        = var.https_credentials.write.username
  }
}

# Netconf Credential
resource "catalystcenter_global_credential_netconf" "netconf_sample_1" {
  provider = catalystcenter
  parameters {
    comments        = "Netconf Sample 1 - Test credential"
    credential_type = "GLOBAL"
    description     = var.netconf_credentials.description
    netconf_port    = var.netconf_credentials.port
  }
}

# Site assignment - Global/USA site
resource "catalystcenter_sites_device_credentials" "usa_site_credentials" {
  provider = catalystcenter
  
  parameters {
    id = var.site_ids.usa
    
    cli_credentials_id {
      credentials_id = catalystcenter_global_credential_cli.cli_sample_1.item[0].id
    }
    
    snmpv3_credentials_id {
      credentials_id = catalystcenter_global_credential_snmpv3.snmpv3_sample_1.item[0].id
    }
    
    http_read_credentials_id {
      credentials_id = catalystcenter_global_credential_http_read.https_read_sample_1.item[0].id
    }
    
    http_write_credentials_id {
      credentials_id = catalystcenter_global_credential_http_write.https_write_sample_1.item[0].id
    }
  }
}

# Site assignment - Global/USA/SAN JOSE site
resource "catalystcenter_sites_device_credentials" "san_jose_site_credentials" {
  provider = catalystcenter
  
  parameters {
    id = var.site_ids.san_jose
    
    cli_credentials_id {
      credentials_id = catalystcenter_global_credential_cli.cli_sample_1.item[0].id
    }
    
    snmpv3_credentials_id {
      credentials_id = catalystcenter_global_credential_snmpv3.snmpv3_sample_1.item[0].id
    }
    
    http_read_credentials_id {
      credentials_id = catalystcenter_global_credential_http_read.https_read_sample_1.item[0].id
    }
    
    http_write_credentials_id {
      credentials_id = catalystcenter_global_credential_http_write.https_write_sample_1.item[0].id
    }
  }
}