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

# Alternative approach using the unified credential resource
# This creates all credential types in a single resource
resource "catalystcenter_global_credential_v2" "unified_credentials" {
  provider = catalystcenter
  
  parameters {
    cli_credential {
      description     = var.cli_credentials.cli_1.description
      enable_password = var.cli_credentials.cli_1.enable_password
      password        = var.cli_credentials.cli_1.password
      username        = var.cli_credentials.cli_1.username
    }
    
    https_read {
      description = var.https_credentials.read.description
      password    = var.https_credentials.read.password
      port        = var.https_credentials.read.port
      username    = var.https_credentials.read.username
    }
    
    https_write {
      description = var.https_credentials.write.description
      password    = var.https_credentials.write.password
      port        = var.https_credentials.write.port
      username    = var.https_credentials.write.username
    }
    
    snmp_v2c_read {
      description    = var.snmp_v2c_credentials.read.description
      read_community = var.snmp_v2c_credentials.read.community
    }
    
    snmp_v2c_write {
      description     = var.snmp_v2c_credentials.write.description
      write_community = var.snmp_v2c_credentials.write.community
    }
    
    snmp_v3 {
      auth_password    = var.snmp_v3_credentials.auth_password
      auth_type        = var.snmp_v3_credentials.auth_type
      description      = var.snmp_v3_credentials.description
      privacy_password = var.snmp_v3_credentials.privacy_password
      privacy_type     = var.snmp_v3_credentials.privacy_type
      snmp_mode        = var.snmp_v3_credentials.snmp_mode
      username         = var.snmp_v3_credentials.username
    }
  }
}

# Data source to retrieve credentials for site assignment
data "catalystcenter_global_credential_v2" "created_credentials" {
  provider = catalystcenter
  depends_on = [catalystcenter_global_credential_v2.unified_credentials]
}

# Site assignment using the unified approach
resource "catalystcenter_sites_device_credentials" "unified_site_assignment" {
  count    = length(var.site_ids_list)
  provider = catalystcenter
  
  parameters {
    id = var.site_ids_list[count.index]
    
    cli_credentials_id {
      credentials_id = catalystcenter_global_credential_v2.unified_credentials.item[0].cli_credential[0].id
    }
    
    snmpv3_credentials_id {
      credentials_id = catalystcenter_global_credential_v2.unified_credentials.item[0].snmp_v3[0].id
    }
    
    http_read_credentials_id {
      credentials_id = catalystcenter_global_credential_v2.unified_credentials.item[0].https_read[0].id
    }
    
    http_write_credentials_id {
      credentials_id = catalystcenter_global_credential_v2.unified_credentials.item[0].https_write[0].id
    }
    
    snmpv2c_read_credentials_id {
      credentials_id = catalystcenter_global_credential_v2.unified_credentials.item[0].snmp_v2c_read[0].id
    }
    
    snmpv2c_write_credentials_id {
      credentials_id = catalystcenter_global_credential_v2.unified_credentials.item[0].snmp_v2c_write[0].id
    }
  }
}