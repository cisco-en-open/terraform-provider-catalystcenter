output "areas_created" {
  description = "List of created areas"
  value = {
    usa            = catalystcenter_area.usa.item
    san_jose       = catalystcenter_area.san_jose.item
    san_francisco  = catalystcenter_area.san_francisco.item
    new_york       = catalystcenter_area.new_york.item
    berkeley       = catalystcenter_area.berkeley.item
    rtp            = catalystcenter_area.rtp.item
    bay_area_guest = catalystcenter_area.bay_area_guest.item
  }
}

output "buildings_created" {
  description = "List of created buildings"
  value = {
    bld23   = catalystcenter_building.bld23.item
    bld20   = catalystcenter_building.bld20.item
    bld_gb  = catalystcenter_building.bld_gb.item
    bldnyc  = catalystcenter_building.bldnyc.item
    bld_sf  = catalystcenter_building.bld_sf.item
    bld_sf1 = catalystcenter_building.bld_sf1.item
    bldberk = catalystcenter_building.bldberk.item
    bld10   = catalystcenter_building.bld10.item
    bld11   = catalystcenter_building.bld11.item
  }
}

output "floors_created" {
  description = "List of created floors by building"
  value = {
    bld10 = {
      floor1 = catalystcenter_floor.bld10_floor1.item
      floor2 = catalystcenter_floor.bld10_floor2.item
      floor3 = catalystcenter_floor.bld10_floor3.item
    }
    bld11 = {
      floor1 = catalystcenter_floor.bld11_floor1.item
      floor2 = catalystcenter_floor.bld11_floor2.item
      floor3 = catalystcenter_floor.bld11_floor3.item
    }
    bld20 = {
      floor1 = catalystcenter_floor.bld20_floor1.item
      floor2 = catalystcenter_floor.bld20_floor2.item
    }
    bld23 = {
      floor1 = catalystcenter_floor.bld23_floor1.item
      floor2 = catalystcenter_floor.bld23_floor2.item
      floor3 = catalystcenter_floor.bld23_floor3.item
      floor4 = catalystcenter_floor.bld23_floor4.item
    }
    bldnyc = {
      floor1 = catalystcenter_floor.bldnyc_floor1.item
      floor2 = catalystcenter_floor.bldnyc_floor2.item
    }
    bld_sf = {
      floor1 = catalystcenter_floor.bld_sf_floor1.item
      floor2 = catalystcenter_floor.bld_sf_floor2.item
    }
    bld_sf1 = {
      floor1 = catalystcenter_floor.bld_sf1_floor1.item
      floor2 = catalystcenter_floor.bld_sf1_floor2.item
    }
    bldberk = {
      floor1 = catalystcenter_floor.bldberk_floor1.item
    }
  }
}

output "site_hierarchy_summary" {
  description = "Summary of the complete site hierarchy created"
  value = {
    total_areas         = 7
    total_buildings     = 9
    total_floors        = 19
    hierarchy_structure = "Global -> USA -> Areas (SAN JOSE, SAN-FRANCISCO, New York, BERKELEY, RTP, BayAreaGuest) -> Buildings -> Floors"
  }
}