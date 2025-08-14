terraform {
  required_providers {
    catalystcenter = {
      version = "1.2.0-beta"
      source  = "hashicorp.com/edu/catalystcenter"
      # "hashicorp.com/edu/catalystcenter" is the local built source change to "cisco-en-programmability/catalystcenter" to use downloaded version from registry
    }
  }
}

provider "catalystcenter" {
  debug = "true"
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
    secure          = "Yes"
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
    secure          = "Yes"
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
    password        = var.netconf_credentials.password
    username        = var.netconf_credentials.username
  }
}

# Site assignment - Global/India site
resource "catalystcenter_sites_device_credentials" "india_site_credentials" {
  provider = catalystcenter
  
  parameters {
    id = var.site_ids.india
    
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

# Site assignment - Global/India/Bangalore site
resource "catalystcenter_sites_device_credentials" "bangalore_site_credentials" {
  provider = catalystcenter
  
  parameters {
    id = var.site_ids.bangalore
    
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