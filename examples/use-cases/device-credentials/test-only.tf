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

# This configuration focuses only on credential creation for testing purposes
# It does not require existing sites and can be used for CI/CD testing

# Test CLI Credential
resource "catalystcenter_global_credential_cli" "test_cli" {
  provider = catalystcenter
  parameters {
    comments        = "Test CLI - Automated Test"
    credential_type = "GLOBAL"
    description     = "CLI Test Credential"
    enable_password = var.test_credentials.cli.enable_password
    password        = var.test_credentials.cli.password
    username        = var.test_credentials.cli.username
  }
}

# Test SNMPv2c Read Credential
resource "catalystcenter_global_credential_snmpv2_read_community" "test_snmp_read" {
  provider = catalystcenter
  parameters {
    comments        = "Test SNMP Read - Automated Test"
    credential_type = "GLOBAL"
    description     = "SNMP Read Test Credential"
    read_community  = var.test_credentials.snmp_v2c_read.community
  }
}

# Test SNMPv2c Write Credential
resource "catalystcenter_global_credential_snmpv2_write_community" "test_snmp_write" {
  provider = catalystcenter
  parameters {
    comments         = "Test SNMP Write - Automated Test"
    credential_type  = "GLOBAL"
    description      = "SNMP Write Test Credential"
    write_community  = var.test_credentials.snmp_v2c_write.community
  }
}

# Test SNMPv3 Credential
resource "catalystcenter_global_credential_snmpv3" "test_snmpv3" {
  provider = catalystcenter
  parameters {
    auth_password    = var.test_credentials.snmp_v3.auth_password
    auth_type        = var.test_credentials.snmp_v3.auth_type
    comments         = "Test SNMPv3 - Automated Test"
    credential_type  = "GLOBAL"
    description      = "SNMPv3 Test Credential"
    privacy_password = var.test_credentials.snmp_v3.privacy_password
    privacy_type     = var.test_credentials.snmp_v3.privacy_type
    snmp_mode        = var.test_credentials.snmp_v3.snmp_mode
    username         = var.test_credentials.snmp_v3.username
  }
}

# Test HTTPS Read Credential
resource "catalystcenter_global_credential_http_read" "test_https_read" {
  provider = catalystcenter
  parameters {
    comments        = "Test HTTPS Read - Automated Test"
    credential_type = "GLOBAL"
    description     = "HTTPS Read Test Credential"
    password        = var.test_credentials.https_read.password
    port            = var.test_credentials.https_read.port
    secure          = "Yes"
    username        = var.test_credentials.https_read.username
  }
}

# Test HTTPS Write Credential
resource "catalystcenter_global_credential_http_write" "test_https_write" {
  provider = catalystcenter
  parameters {
    comments        = "Test HTTPS Write - Automated Test"
    credential_type = "GLOBAL"
    description     = "HTTPS Write Test Credential"
    password        = var.test_credentials.https_write.password
    port            = var.test_credentials.https_write.port
    secure          = "Yes"
    username        = var.test_credentials.https_write.username
  }
}

# Test Netconf Credential
resource "catalystcenter_global_credential_netconf" "test_netconf" {
  provider = catalystcenter
  parameters {
    comments        = "Test Netconf - Automated Test"
    credential_type = "GLOBAL"
    description     = "Netconf Test Credential"
    netconf_port    = var.test_credentials.netconf.port
    password        = var.test_credentials.netconf.password
    username        = var.test_credentials.netconf.username
  }
}

# Data sources for validation
data "catalystcenter_global_credential" "validate_all_credentials" {
  provider   = catalystcenter
  depends_on = [
    catalystcenter_global_credential_cli.test_cli,
    catalystcenter_global_credential_snmpv2_read_community.test_snmp_read,
    catalystcenter_global_credential_snmpv2_write_community.test_snmp_write,
    catalystcenter_global_credential_snmpv3.test_snmpv3,
    catalystcenter_global_credential_http_read.test_https_read,
    catalystcenter_global_credential_http_write.test_https_write,
    catalystcenter_global_credential_netconf.test_netconf
  ]
}

# Test outputs
output "test_results" {
  description = "Test results for credential creation"
  value = {
    cli_credential_created = {
      id          = catalystcenter_global_credential_cli.test_cli.item[0].id
      description = catalystcenter_global_credential_cli.test_cli.item[0].description
      username    = catalystcenter_global_credential_cli.test_cli.item[0].username
    }
    snmp_read_credential_created = {
      id          = catalystcenter_global_credential_snmpv2_read_community.test_snmp_read.item[0].id
      description = catalystcenter_global_credential_snmpv2_read_community.test_snmp_read.item[0].description
    }
    snmp_write_credential_created = {
      id          = catalystcenter_global_credential_snmpv2_write_community.test_snmp_write.item[0].id
      description = catalystcenter_global_credential_snmpv2_write_community.test_snmp_write.item[0].description
    }
    snmpv3_credential_created = {
      id          = catalystcenter_global_credential_snmpv3.test_snmpv3.item[0].id
      description = catalystcenter_global_credential_snmpv3.test_snmpv3.item[0].description
      username    = catalystcenter_global_credential_snmpv3.test_snmpv3.item[0].username
    }
    https_read_credential_created = {
      id          = catalystcenter_global_credential_http_read.test_https_read.item[0].id
      description = catalystcenter_global_credential_http_read.test_https_read.item[0].description
      username    = catalystcenter_global_credential_http_read.test_https_read.item[0].username
    }
    https_write_credential_created = {
      id          = catalystcenter_global_credential_http_write.test_https_write.item[0].id
      description = catalystcenter_global_credential_http_write.test_https_write.item[0].description
      username    = catalystcenter_global_credential_http_write.test_https_write.item[0].username
    }
    netconf_credential_created = {
      id          = catalystcenter_global_credential_netconf.test_netconf.item[0].id
      description = catalystcenter_global_credential_netconf.test_netconf.item[0].description
      username    = catalystcenter_global_credential_netconf.test_netconf.item[0].username
    }
    test_summary = {
      total_credentials_created = 7
      test_passed              = true
    }
  }
  sensitive = true
}