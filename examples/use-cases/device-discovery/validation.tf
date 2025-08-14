# Optional validation configuration to verify created discoveries
# This file can be used alongside main.tf to validate discovery creation

# Data source to get discovery details by ID
data "catalystcenter_discovery" "cdp_discovery_validation" {
  depends_on = [catalystcenter_discovery.cdp_discovery]
  id = catalystcenter_discovery.cdp_discovery.item[0].id
}

data "catalystcenter_discovery" "single_ip_discovery_1_validation" {
  depends_on = [catalystcenter_discovery.single_ip_discovery_1]
  id = catalystcenter_discovery.single_ip_discovery_1.item[0].id
}

data "catalystcenter_discovery" "single_ip_discovery_2_validation" {
  depends_on = [catalystcenter_discovery.single_ip_discovery_2]
  id = catalystcenter_discovery.single_ip_discovery_2.item[0].id
}

data "catalystcenter_discovery" "range_ip_discovery_validation" {
  depends_on = [catalystcenter_discovery.range_ip_discovery]
  id = catalystcenter_discovery.range_ip_discovery.item[0].id
}

data "catalystcenter_discovery" "multi_range_ip_discovery_validation" {
  depends_on = [catalystcenter_discovery.multi_range_ip_discovery]
  id = catalystcenter_discovery.multi_range_ip_discovery.item[0].id
}

# Data source to get discovery summary
data "catalystcenter_discovery_summary" "all_discoveries" {
  depends_on = [
    catalystcenter_discovery.cdp_discovery,
    catalystcenter_discovery.single_ip_discovery_1,
    catalystcenter_discovery.single_ip_discovery_2,
    catalystcenter_discovery.range_ip_discovery,
    catalystcenter_discovery.multi_range_ip_discovery
  ]
}

# Validation outputs
output "validation_results" {
  description = "Validation results for all created discoveries"
  value = {
    cdp_discovery_validated = {
      id = data.catalystcenter_discovery.cdp_discovery_validation.item[0].id
      name = data.catalystcenter_discovery.cdp_discovery_validation.item[0].name
      type = data.catalystcenter_discovery.cdp_discovery_validation.item[0].discovery_type
      status = data.catalystcenter_discovery.cdp_discovery_validation.item[0].discovery_status
    }
    single_ip_discovery_1_validated = {
      id = data.catalystcenter_discovery.single_ip_discovery_1_validation.item[0].id
      name = data.catalystcenter_discovery.single_ip_discovery_1_validation.item[0].name
      type = data.catalystcenter_discovery.single_ip_discovery_1_validation.item[0].discovery_type
      status = data.catalystcenter_discovery.single_ip_discovery_1_validation.item[0].discovery_status
    }
    single_ip_discovery_2_validated = {
      id = data.catalystcenter_discovery.single_ip_discovery_2_validation.item[0].id
      name = data.catalystcenter_discovery.single_ip_discovery_2_validation.item[0].name
      type = data.catalystcenter_discovery.single_ip_discovery_2_validation.item[0].discovery_type
      status = data.catalystcenter_discovery.single_ip_discovery_2_validation.item[0].discovery_status
    }
    range_ip_discovery_validated = {
      id = data.catalystcenter_discovery.range_ip_discovery_validation.item[0].id
      name = data.catalystcenter_discovery.range_ip_discovery_validation.item[0].name
      type = data.catalystcenter_discovery.range_ip_discovery_validation.item[0].discovery_type
      status = data.catalystcenter_discovery.range_ip_discovery_validation.item[0].discovery_status
    }
    multi_range_ip_discovery_validated = {
      id = data.catalystcenter_discovery.multi_range_ip_discovery_validation.item[0].id
      name = data.catalystcenter_discovery.multi_range_ip_discovery_validation.item[0].name
      type = data.catalystcenter_discovery.multi_range_ip_discovery_validation.item[0].discovery_type
      status = data.catalystcenter_discovery.multi_range_ip_discovery_validation.item[0].discovery_status
    }
  }
}

output "discovery_summary_validation" {
  description = "Summary of all discoveries from data source"
  value = data.catalystcenter_discovery_summary.all_discoveries
}