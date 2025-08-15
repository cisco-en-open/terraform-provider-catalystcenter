# CLI Credentials Outputs
output "cli_credential_1_id" {
  description = "ID of the first CLI credential"
  value       = try(catalystcenter_global_credential.credentials_v2.item[0].cli_credential[0].id, null)
}

output "cli_credential_2_id" {
  description = "ID of the second CLI credential (note: v2 resource only creates one CLI credential)"
  value       = try(catalystcenter_global_credential.credentials_v2.item[0].cli_credential[0].id, null)
}

# SNMPv2c Credentials Outputs
output "snmp_read_credential_id" {
  description = "ID of the SNMPv2c Read credential"
  value       = try(catalystcenter_global_credential.credentials_v2.item[0].snmp_v2c_read[0].id, null)
}

output "snmp_write_credential_id" {
  description = "ID of the SNMPv2c Write credential"
  value       = try(catalystcenter_global_credential.credentials_v2.item[0].snmp_v2c_write[0].id, null)
}

# SNMPv3 Credential Output
output "snmpv3_credential_id" {
  description = "ID of the SNMPv3 credential"
  value       = try(catalystcenter_global_credential.credentials_v2.item[0].snmp_v3[0].id, null)
}

# HTTPS Credentials Outputs
output "https_read_credential_id" {
  description = "ID of the HTTPS Read credential"
  value       = try(catalystcenter_global_credential.credentials_v2.item[0].https_read[0].id, null)
}

output "https_write_credential_id" {
  description = "ID of the HTTPS Write credential"
  value       = try(catalystcenter_global_credential.credentials_v2.item[0].https_write[0].id, null)
}

# Netconf Credential Output (Note: Not supported in v2 resource)
output "netconf_credential_id" {
  description = "ID of the Netconf credential (not supported in v2 resource)"
  value       = null
}

# Site Assignment Outputs
output "usa_site_credentials_status" {
  description = "Status of credential assignment to USA site"
  value       = try(catalystcenter_sites_device_credentials.site_assignment_v2[0].item, null)
}

output "san_jose_site_credentials_status" {
  description = "Status of credential assignment to San Jose site"
  value       = try(catalystcenter_sites_device_credentials.site_assignment_v2[1].item, null)
}

# Summary of all credentials created
output "credentials_summary" {
  description = "Summary of all credentials created"
  value = {
    cli_credentials = {
      cli_1 = try(catalystcenter_global_credential.credentials_v2.item[0].cli_credential[0].id, null)
      cli_2 = try(catalystcenter_global_credential.credentials_v2.item[0].cli_credential[0].id, null)
    }
    snmp_credentials = {
      v2c_read  = try(catalystcenter_global_credential.credentials_v2.item[0].snmp_v2c_read[0].id, null)
      v2c_write = try(catalystcenter_global_credential.credentials_v2.item[0].snmp_v2c_write[0].id, null)
      v3        = try(catalystcenter_global_credential.credentials_v2.item[0].snmp_v3[0].id, null)
    }
    https_credentials = {
      read  = try(catalystcenter_global_credential.credentials_v2.item[0].https_read[0].id, null)
      write = try(catalystcenter_global_credential.credentials_v2.item[0].https_write[0].id, null)
    }
    netconf_credential = null  # Not supported in v2 resource
    site_assignments = [for i, assignment in catalystcenter_sites_device_credentials.site_assignment_v2 : {
      site_id = var.site_ids_list[i]
      status = try(assignment.item, null)
    }]
  }
}