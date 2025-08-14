terraform {
  required_providers {
    catalystcenter = {
      version = "1.2.0-beta"
      source  = "hashicorp.com/edu/catalystcenter"
      # "hashicorp.com/edu/catalystcenter" is the local built source, change to "cisco-en-programmability/catalystcenter" to use downloaded version from registry
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

# Area Resources
resource "catalystcenter_area" "usa" {
  provider = catalystcenter
  parameters {
    site {
      area {
        name        = "USA"
        parent_name = "Global"
      }
    }
    type = "area"
  }
}

resource "catalystcenter_area" "san_jose" {
  provider   = catalystcenter
  depends_on = [catalystcenter_area.usa]
  parameters {
    site {
      area {
        name        = "SAN JOSE"
        parent_name = "Global/USA"
      }
    }
    type = "area"
  }
}

resource "catalystcenter_area" "san_francisco" {
  provider   = catalystcenter
  depends_on = [catalystcenter_area.usa]
  parameters {
    site {
      area {
        name        = "SAN-FRANCISCO"
        parent_name = "Global/USA"
      }
    }
    type = "area"
  }
}

resource "catalystcenter_area" "new_york" {
  provider   = catalystcenter
  depends_on = [catalystcenter_area.usa]
  parameters {
    site {
      area {
        name        = "New York"
        parent_name = "Global/USA"
      }
    }
    type = "area"
  }
}

resource "catalystcenter_area" "berkeley" {
  provider   = catalystcenter
  depends_on = [catalystcenter_area.usa]
  parameters {
    site {
      area {
        name        = "BERKELEY"
        parent_name = "Global/USA"
      }
    }
    type = "area"
  }
}

resource "catalystcenter_area" "rtp" {
  provider   = catalystcenter
  depends_on = [catalystcenter_area.usa]
  parameters {
    site {
      area {
        name        = "RTP"
        parent_name = "Global/USA"
      }
    }
    type = "area"
  }
}

resource "catalystcenter_area" "bay_area_guest" {
  provider   = catalystcenter
  depends_on = [catalystcenter_area.usa]
  parameters {
    site {
      area {
        name        = "BayAreaGuest"
        parent_name = "Global/USA"
      }
    }
    type = "area"
  }
}

# Building Resources
resource "catalystcenter_building" "bld23" {
  provider   = catalystcenter
  depends_on = [catalystcenter_area.san_jose]
  parameters {
    site {
      building {
        name        = "BLD23"
        parent_name = "Global/USA/SAN JOSE"
        address     = "McCarthy Blvd, San Jose, California 95131, United States"
        latitude    = 37.398188
        longitude   = -121.912974
        country     = "United States"
      }
    }
    type = "building"
  }
}

resource "catalystcenter_building" "bld20" {
  provider   = catalystcenter
  depends_on = [catalystcenter_area.san_jose]
  parameters {
    site {
      building {
        name        = "BLD20"
        parent_name = "Global/USA/SAN JOSE"
        address     = "725 Alder Drive, Milpitas, California 95035, United States"
        latitude    = 37.415947
        longitude   = -121.916327
        country     = "United States"
      }
    }
    type = "building"
  }
}

resource "catalystcenter_building" "bld_gb" {
  provider   = catalystcenter
  depends_on = [catalystcenter_area.bay_area_guest]
  parameters {
    site {
      building {
        name        = "BLD_GB"
        parent_name = "Global/USA/BayAreaGuest"
        address     = "725 Alder Drive, Milpitas, California 95035, United States"
        latitude    = 37.415947
        longitude   = -121.916327
        country     = "United States"
      }
    }
    type = "building"
  }
}

resource "catalystcenter_building" "bldnyc" {
  provider   = catalystcenter
  depends_on = [catalystcenter_area.new_york]
  parameters {
    site {
      building {
        name        = "BLDNYC"
        parent_name = "Global/USA/New York"
        address     = "McCarthy Blvd, San Jose, California 95131, United States"
        latitude    = 37.398188
        longitude   = -121.912974
        country     = "United States"
      }
    }
    type = "building"
  }
}

resource "catalystcenter_building" "bld_sf" {
  provider   = catalystcenter
  depends_on = [catalystcenter_area.san_francisco]
  parameters {
    site {
      building {
        name        = "BLD_SF"
        parent_name = "Global/USA/SAN-FRANCISCO"
        address     = "McCarthy Blvd, San Jose, California 95131, United States"
        latitude    = 37.398188
        longitude   = -121.912974
        country     = "United States"
      }
    }
    type = "building"
  }
}

resource "catalystcenter_building" "bld_sf1" {
  provider   = catalystcenter
  depends_on = [catalystcenter_area.san_francisco]
  parameters {
    site {
      building {
        name        = "BLD_SF1"
        parent_name = "Global/USA/SAN-FRANCISCO"
        address     = "McCarthy Blvd, San Jose, California 95131, United States"
        latitude    = 37.398188
        longitude   = -121.912974
        country     = "United States"
      }
    }
    type = "building"
  }
}

resource "catalystcenter_building" "bldberk" {
  provider   = catalystcenter
  depends_on = [catalystcenter_area.berkeley]
  parameters {
    site {
      building {
        name        = "BLDBERK"
        parent_name = "Global/USA/BERKELEY"
        address     = "725 Alder Drive, Milpitas, California 95035, United States"
        latitude    = 37.415947
        longitude   = -121.916327
        country     = "United States"
      }
    }
    type = "building"
  }
}

resource "catalystcenter_building" "bld10" {
  provider   = catalystcenter
  depends_on = [catalystcenter_area.rtp]
  parameters {
    site {
      building {
        name        = "BLD10"
        parent_name = "Global/USA/RTP"
        address     = "725 Alder Drive, Milpitas, California 95035, United States"
        latitude    = 37.415947
        longitude   = -121.916327
        country     = "United States"
      }
    }
    type = "building"
  }
}

resource "catalystcenter_building" "bld11" {
  provider   = catalystcenter
  depends_on = [catalystcenter_area.rtp]
  parameters {
    site {
      building {
        name        = "BLD11"
        parent_name = "Global/USA/RTP"
        address     = "725 Alder Drive, Milpitas, California 95035, United States"
        latitude    = 37.415947
        longitude   = -121.916327
        country     = "United States"
      }
    }
    type = "building"
  }
}

# Floor Resources
resource "catalystcenter_floor" "bld10_floor1" {
  provider   = catalystcenter
  depends_on = [catalystcenter_building.bld10]
  parameters {
    site {
      floor {
        name         = "BLD10_FLOOR1"
        parent_name  = "Global/USA/RTP/BLD10"
        rf_model     = "Cubes And Walled Offices"
        width        = 100.00
        length       = 100.00
        height       = 10.00
        floor_number = 1
      }
    }
    type = "floor"
  }
}

resource "catalystcenter_floor" "bld10_floor2" {
  provider   = catalystcenter
  depends_on = [catalystcenter_building.bld10]
  parameters {
    site {
      floor {
        name         = "BLD10_FLOOR2"
        parent_name  = "Global/USA/RTP/BLD10"
        rf_model     = "Cubes And Walled Offices"
        width        = 100.00
        length       = 100.00
        height       = 10.00
        floor_number = 2
      }
    }
    type = "floor"
  }
}

resource "catalystcenter_floor" "bld10_floor3" {
  provider   = catalystcenter
  depends_on = [catalystcenter_building.bld10]
  parameters {
    site {
      floor {
        name         = "BLD10_FLOOR3"
        parent_name  = "Global/USA/RTP/BLD10"
        rf_model     = "Cubes And Walled Offices"
        width        = 100.00
        length       = 100.00
        height       = 10.00
        floor_number = 3
      }
    }
    type = "floor"
  }
}

resource "catalystcenter_floor" "bld11_floor1" {
  provider   = catalystcenter
  depends_on = [catalystcenter_building.bld11]
  parameters {
    site {
      floor {
        name         = "BLD11_FLOOR1"
        parent_name  = "Global/USA/RTP/BLD11"
        rf_model     = "Cubes And Walled Offices"
        width        = 100.00
        length       = 100.00
        height       = 10.00
        floor_number = 1
      }
    }
    type = "floor"
  }
}

resource "catalystcenter_floor" "bld11_floor2" {
  provider   = catalystcenter
  depends_on = [catalystcenter_building.bld11]
  parameters {
    site {
      floor {
        name         = "BLD11_FLOOR2"
        parent_name  = "Global/USA/RTP/BLD11"
        rf_model     = "Cubes And Walled Offices"
        width        = 100.00
        length       = 100.00
        height       = 10.00
        floor_number = 2
      }
    }
    type = "floor"
  }
}

resource "catalystcenter_floor" "bld20_floor1" {
  provider   = catalystcenter
  depends_on = [catalystcenter_building.bld20]
  parameters {
    site {
      floor {
        name         = "FLOOR1"
        parent_name  = "Global/USA/SAN JOSE/BLD20"
        rf_model     = "Cubes And Walled Offices"
        width        = 100.00
        length       = 100.00
        height       = 10.00
        floor_number = 1
      }
    }
    type = "floor"
  }
}

resource "catalystcenter_floor" "bld20_floor2" {
  provider   = catalystcenter
  depends_on = [catalystcenter_building.bld20]
  parameters {
    site {
      floor {
        name         = "FLOOR2"
        parent_name  = "Global/USA/SAN JOSE/BLD20"
        rf_model     = "Cubes And Walled Offices"
        width        = 100.00
        length       = 100.00
        height       = 10.00
        floor_number = 2
      }
    }
    type = "floor"
  }
}

resource "catalystcenter_floor" "bld23_floor1" {
  provider   = catalystcenter
  depends_on = [catalystcenter_building.bld23]
  parameters {
    site {
      floor {
        name         = "FLOOR1"
        parent_name  = "Global/USA/SAN JOSE/BLD23"
        rf_model     = "Cubes And Walled Offices"
        width        = 100.00
        length       = 100.00
        height       = 10.00
        floor_number = 1
      }
    }
    type = "floor"
  }
}

resource "catalystcenter_floor" "bld23_floor2" {
  provider   = catalystcenter
  depends_on = [catalystcenter_building.bld23]
  parameters {
    site {
      floor {
        name         = "FLOOR2"
        parent_name  = "Global/USA/SAN JOSE/BLD23"
        rf_model     = "Cubes And Walled Offices"
        width        = 100.00
        length       = 100.00
        height       = 10.00
        floor_number = 2
      }
    }
    type = "floor"
  }
}

resource "catalystcenter_floor" "bld23_floor3" {
  provider   = catalystcenter
  depends_on = [catalystcenter_building.bld23]
  parameters {
    site {
      floor {
        name         = "FLOOR3"
        parent_name  = "Global/USA/SAN JOSE/BLD23"
        rf_model     = "Cubes And Walled Offices"
        width        = 100.00
        length       = 100.00
        height       = 10.00
        floor_number = 3
      }
    }
    type = "floor"
  }
}

resource "catalystcenter_floor" "bld23_floor4" {
  provider   = catalystcenter
  depends_on = [catalystcenter_building.bld23]
  parameters {
    site {
      floor {
        name         = "FLOOR4"
        parent_name  = "Global/USA/SAN JOSE/BLD23"
        rf_model     = "Cubes And Walled Offices"
        width        = 100.00
        length       = 100.00
        height       = 10.00
        floor_number = 4
      }
    }
    type = "floor"
  }
}

resource "catalystcenter_floor" "bldnyc_floor1" {
  provider   = catalystcenter
  depends_on = [catalystcenter_building.bldnyc]
  parameters {
    site {
      floor {
        name         = "FLOOR1"
        parent_name  = "Global/USA/New York/BLDNYC"
        rf_model     = "Cubes And Walled Offices"
        width        = 100.00
        length       = 100.00
        height       = 10.00
        floor_number = 1
      }
    }
    type = "floor"
  }
}

resource "catalystcenter_floor" "bldnyc_floor2" {
  provider   = catalystcenter
  depends_on = [catalystcenter_building.bldnyc]
  parameters {
    site {
      floor {
        name         = "FLOOR2"
        parent_name  = "Global/USA/New York/BLDNYC"
        rf_model     = "Cubes And Walled Offices"
        width        = 100.00
        length       = 100.00
        height       = 10.00
        floor_number = 2
      }
    }
    type = "floor"
  }
}

resource "catalystcenter_floor" "bld_sf_floor1" {
  provider   = catalystcenter
  depends_on = [catalystcenter_building.bld_sf]
  parameters {
    site {
      floor {
        name         = "FLOOR1"
        parent_name  = "Global/USA/SAN-FRANCISCO/BLD_SF"
        rf_model     = "Cubes And Walled Offices"
        width        = 100.00
        length       = 100.00
        height       = 10.00
        floor_number = 1
      }
    }
    type = "floor"
  }
}

resource "catalystcenter_floor" "bld_sf_floor2" {
  provider   = catalystcenter
  depends_on = [catalystcenter_building.bld_sf]
  parameters {
    site {
      floor {
        name         = "FLOOR2"
        parent_name  = "Global/USA/SAN-FRANCISCO/BLD_SF"
        rf_model     = "Cubes And Walled Offices"
        width        = 100.00
        length       = 100.00
        height       = 10.00
        floor_number = 2
      }
    }
    type = "floor"
  }
}

resource "catalystcenter_floor" "bld_sf1_floor1" {
  provider   = catalystcenter
  depends_on = [catalystcenter_building.bld_sf1]
  parameters {
    site {
      floor {
        name         = "FLOOR1"
        parent_name  = "Global/USA/SAN-FRANCISCO/BLD_SF1"
        rf_model     = "Cubes And Walled Offices"
        width        = 100.00
        length       = 100.00
        height       = 10.00
        floor_number = 1
      }
    }
    type = "floor"
  }
}

resource "catalystcenter_floor" "bld_sf1_floor2" {
  provider   = catalystcenter
  depends_on = [catalystcenter_building.bld_sf1]
  parameters {
    site {
      floor {
        name         = "FLOOR2"
        parent_name  = "Global/USA/SAN-FRANCISCO/BLD_SF1"
        rf_model     = "Cubes And Walled Offices"
        width        = 100.00
        length       = 100.00
        height       = 10.00
        floor_number = 2
      }
    }
    type = "floor"
  }
}

resource "catalystcenter_floor" "bld11_floor3" {
  provider   = catalystcenter
  depends_on = [catalystcenter_building.bld11]
  parameters {
    site {
      floor {
        name         = "BLD12_FLOOR3"
        parent_name  = "Global/USA/RTP/BLD11"
        rf_model     = "Cubes And Walled Offices"
        width        = 100.00
        length       = 100.00
        height       = 10.00
        floor_number = 3
      }
    }
    type = "floor"
  }
}

resource "catalystcenter_floor" "bldberk_floor1" {
  provider   = catalystcenter
  depends_on = [catalystcenter_building.bldberk]
  parameters {
    site {
      floor {
        name         = "FLOOR1_LEVEL1"
        parent_name  = "Global/USA/BERKELEY/BLDBERK"
        rf_model     = "Cubes And Walled Offices"
        width        = 100.00
        length       = 100.00
        height       = 10.00
        floor_number = 1
      }
    }
    type = "floor"
  }
}