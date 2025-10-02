terraform {
  required_providers {
    catalystcenter = {
      version = "1.2.0-beta"
      source  = "cisco-en-programmability/catalystcenter"
      # "hashicorp.com/edu/catalystcenter" is the local built source, change to "cisco-en-programmability/catalystcenter" to use downloaded version from registry
    }
  }
}
data "catalystcenter_floor" "example" {
  provider = catalystcenter
  # limit    = 1
  # name     = "string"
  # offset   = 1
  # site_id  = "string"
  # type     = "string"
}

output "catalystcenter_floor_example" {
  value = data.catalystcenter_floor.example.items
}
