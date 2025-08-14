# CLI Credentials Outputs
output "cli_credential_1_id" {
  description = "ID of the first CLI credential"
  value       = catalystcenter_global_credential_cli.cli_sample_1.item[0].id
}

output "cli_credential_2_id" {
  description = "ID of the second CLI credential"
  value       = catalystcenter_global_credential_cli.cli_sample_2.item[0].id
}

# SNMPv2c Credentials Outputs
output "snmp_read_credential_id" {
  description = "ID of the SNMPv2c Read credential"
  value       = catalystcenter_global_credential_snmpv2_read_community.snmp_read_1.item[0].id
}

output "snmp_write_credential_id" {
  description = "ID of the SNMPv2c Write credential"
  value       = catalystcenter_global_credential_snmpv2_write_community.snmp_write_1.item[0].id
}

# SNMPv3 Credential Output
output "snmpv3_credential_id" {
  description = "ID of the SNMPv3 credential"
  value       = catalystcenter_global_credential_snmpv3.snmpv3_sample_1.item[0].id
}

# HTTPS Credentials Outputs
output "https_read_credential_id" {
  description = "ID of the HTTPS Read credential"
  value       = catalystcenter_global_credential_http_read.https_read_sample_1.item[0].id
}

output "https_write_credential_id" {
  description = "ID of the HTTPS Write credential"
  value       = catalystcenter_global_credential_http_write.https_write_sample_1.item[0].id
}

# Netconf Credential Output
output "netconf_credential_id" {
  description = "ID of the Netconf credential"
  value       = catalystcenter_global_credential_netconf.netconf_sample_1.item[0].id
}

# Site Assignment Outputs
output "india_site_credentials_status" {
  description = "Status of credential assignment to India site"
  value       = catalystcenter_sites_device_credentials.india_site_credentials.item
}

output "bangalore_site_credentials_status" {
  description = "Status of credential assignment to Bangalore site"
  value       = catalystcenter_sites_device_credentials.bangalore_site_credentials.item
}

# Summary of all credentials created
output "credentials_summary" {
  description = "Summary of all credentials created"
  value = {
    cli_credentials = {
      cli_1 = catalystcenter_global_credential_cli.cli_sample_1.item[0].id
      cli_2 = catalystcenter_global_credential_cli.cli_sample_2.item[0].id
    }
    snmp_credentials = {
      v2c_read  = catalystcenter_global_credential_snmpv2_read_community.snmp_read_1.item[0].id
      v2c_write = catalystcenter_global_credential_snmpv2_write_community.snmp_write_1.item[0].id
      v3        = catalystcenter_global_credential_snmpv3.snmpv3_sample_1.item[0].id
    }
    https_credentials = {
      read  = catalystcenter_global_credential_http_read.https_read_sample_1.item[0].id
      write = catalystcenter_global_credential_http_write.https_write_sample_1.item[0].id
    }
    netconf_credential = catalystcenter_global_credential_netconf.netconf_sample_1.item[0].id
  }
}