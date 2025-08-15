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

# Data source to validate CLI credentials exist
data "catalystcenter_global_credential" "cli_credentials" {
  provider            = catalystcenter
  credential_sub_type = "CLI"
  depends_on          = [
    catalystcenter_global_credential_cli.cli_sample_1,
    catalystcenter_global_credential_cli.cli_sample_2
  ]
}

# Data source to validate SNMPv2c Read credentials exist
data "catalystcenter_global_credential" "snmpv2c_read_credentials" {
  provider            = catalystcenter
  credential_sub_type = "SNMPV2_READ_COMMUNITY"
  depends_on          = [catalystcenter_global_credential_snmpv2_read_community.snmp_read_1]
}

# Data source to validate SNMPv2c Write credentials exist
data "catalystcenter_global_credential" "snmpv2c_write_credentials" {
  provider            = catalystcenter
  credential_sub_type = "SNMPV2_WRITE_COMMUNITY"
  depends_on          = [catalystcenter_global_credential_snmpv2_write_community.snmp_write_1]
}

# Data source to validate SNMPv3 credentials exist
data "catalystcenter_global_credential" "snmpv3_credentials" {
  provider            = catalystcenter
  credential_sub_type = "SNMPV3"
  depends_on          = [catalystcenter_global_credential_snmpv3.snmpv3_sample_1]
}

# Data source to validate HTTP Read credentials exist
data "catalystcenter_global_credential" "http_read_credentials" {
  provider            = catalystcenter
  credential_sub_type = "HTTP_READ"
  depends_on          = [catalystcenter_global_credential_http_read.https_read_sample_1]
}

# Data source to validate HTTP Write credentials exist
data "catalystcenter_global_credential" "http_write_credentials" {
  provider            = catalystcenter
  credential_sub_type = "HTTP_WRITE"
  depends_on          = [catalystcenter_global_credential_http_write.https_write_sample_1]
}

# Data source to validate Netconf credentials exist
data "catalystcenter_global_credential" "netconf_credentials" {
  provider            = catalystcenter
  credential_sub_type = "NETCONF"
  depends_on          = [catalystcenter_global_credential_netconf.netconf_sample_1]
}

# Data source to validate site credential assignments
data "catalystcenter_sites_device_credentials" "usa_site_validation" {
  provider = catalystcenter
  id  = var.site_ids.usa
  depends_on = [catalystcenter_sites_device_credentials.usa_site_credentials]
}

data "catalystcenter_sites_device_credentials" "san_jose_site_validation" {
  provider = catalystcenter
  id  = var.site_ids.san_jose
  depends_on = [catalystcenter_sites_device_credentials.san_jose_site_credentials]
}

# Validation outputs - these will show if the credentials were created successfully
output "validation_cli_credentials_count" {
  description = "Number of CLI credentials found"
  value       = length(data.catalystcenter_global_credential.cli_credentials.items)
}

output "validation_snmpv2c_read_credentials_count" {
  description = "Number of SNMPv2c Read credentials found"
  value       = length(data.catalystcenter_global_credential.snmpv2c_read_credentials.items)
}

output "validation_snmpv2c_write_credentials_count" {
  description = "Number of SNMPv2c Write credentials found"
  value       = length(data.catalystcenter_global_credential.snmpv2c_write_credentials.items)
}

output "validation_snmpv3_credentials_count" {
  description = "Number of SNMPv3 credentials found"
  value       = length(data.catalystcenter_global_credential.snmpv3_credentials.items)
}

output "validation_http_read_credentials_count" {
  description = "Number of HTTP Read credentials found"
  value       = length(data.catalystcenter_global_credential.http_read_credentials.items)
}

output "validation_http_write_credentials_count" {
  description = "Number of HTTP Write credentials found"
  value       = length(data.catalystcenter_global_credential.http_write_credentials.items)
}

output "validation_netconf_credentials_count" {
  description = "Number of Netconf credentials found"
  value       = length(data.catalystcenter_global_credential.netconf_credentials.items)
}

# Site assignment validation outputs
output "validation_usa_site_has_credentials" {
  description = "Whether USA site has credential assignments"
  value = {
    has_cli_credentials     = length(data.catalystcenter_sites_device_credentials.usa_site_validation.item[0].cli_credentials_id) > 0
    has_snmpv3_credentials  = length(data.catalystcenter_sites_device_credentials.usa_site_validation.item[0].snmpv3_credentials_id) > 0
    has_http_read_credentials = length(data.catalystcenter_sites_device_credentials.usa_site_validation.item[0].http_read_credentials_id) > 0
    has_http_write_credentials = length(data.catalystcenter_sites_device_credentials.usa_site_validation.item[0].http_write_credentials_id) > 0
  }
}

output "validation_san_jose_site_has_credentials" {
  description = "Whether San Jose site has credential assignments"
  value = {
    has_cli_credentials     = length(data.catalystcenter_sites_device_credentials.san_jose_site_validation.item[0].cli_credentials_id) > 0
    has_snmpv3_credentials  = length(data.catalystcenter_sites_device_credentials.san_jose_site_validation.item[0].snmpv3_credentials_id) > 0
    has_http_read_credentials = length(data.catalystcenter_sites_device_credentials.san_jose_site_validation.item[0].http_read_credentials_id) > 0
    has_http_write_credentials = length(data.catalystcenter_sites_device_credentials.san_jose_site_validation.item[0].http_write_credentials_id) > 0
  }
}

# Summary validation output
output "validation_summary" {
  description = "Summary of credential creation and assignment validation"
  value = {
    global_credentials_created = {
      cli_count           = length(data.catalystcenter_global_credential.cli_credentials.items)
      snmpv2c_read_count  = length(data.catalystcenter_global_credential.snmpv2c_read_credentials.items)
      snmpv2c_write_count = length(data.catalystcenter_global_credential.snmpv2c_write_credentials.items)
      snmpv3_count        = length(data.catalystcenter_global_credential.snmpv3_credentials.items)
      http_read_count     = length(data.catalystcenter_global_credential.http_read_credentials.items)
      http_write_count    = length(data.catalystcenter_global_credential.http_write_credentials.items)
      netconf_count       = length(data.catalystcenter_global_credential.netconf_credentials.items)
    }
    total_credentials_created = (
      length(data.catalystcenter_global_credential.cli_credentials.items) +
      length(data.catalystcenter_global_credential.snmpv2c_read_credentials.items) +
      length(data.catalystcenter_global_credential.snmpv2c_write_credentials.items) +
      length(data.catalystcenter_global_credential.snmpv3_credentials.items) +
      length(data.catalystcenter_global_credential.http_read_credentials.items) +
      length(data.catalystcenter_global_credential.http_write_credentials.items) +
      length(data.catalystcenter_global_credential.netconf_credentials.items)
    )
    site_assignments_configured = 2
    test_passed = (
      length(data.catalystcenter_global_credential.cli_credentials.items) >= 2 &&
      length(data.catalystcenter_global_credential.snmpv2c_read_credentials.items) >= 1 &&
      length(data.catalystcenter_global_credential.snmpv2c_write_credentials.items) >= 1 &&
      length(data.catalystcenter_global_credential.snmpv3_credentials.items) >= 1 &&
      length(data.catalystcenter_global_credential.http_read_credentials.items) >= 1 &&
      length(data.catalystcenter_global_credential.http_write_credentials.items) >= 1 &&
      length(data.catalystcenter_global_credential.netconf_credentials.items) >= 1
    )
  }
}