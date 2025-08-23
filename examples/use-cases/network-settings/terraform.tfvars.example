# Example terraform.tfvars file for Network Settings
# Copy this to terraform.tfvars and update with your actual values
# ================================================================

# INSTRUCTIONS FOR CUSTOMIZATION:
# 1. Replace all example IP addresses with your actual network values
# 2. Update site hierarchy to match your Catalyst Center configuration  
# 3. Configure AAA servers with your actual ISE/RADIUS server details
# 4. Adjust IP pools and subnets according to your network design
# 5. Set appropriate DHCP, DNS, NTP server addresses
# 6. Update shared secrets and credentials (keep them secure)

# -----------------------------------------------------------------------------
# Catalyst Center Connection Settings
# -----------------------------------------------------------------------------
catalyst_username   = "admin"
catalyst_password   = "YourCatalystCenterPassword!"
catalyst_base_url   = "https://your-catalyst-center.example.com"
catalyst_debug      = false
catalyst_ssl_verify = false

# -----------------------------------------------------------------------------
# Site Hierarchy Configuration
# -----------------------------------------------------------------------------
# Update these to match your site hierarchy in Catalyst Center
site_hierarchy = {
  global_site_name = "Global"
  target_site_name = "Global/USA/SAN JOSE"  # Replace with your actual site path
}

# -----------------------------------------------------------------------------
# Global IP Pools Configuration  
# -----------------------------------------------------------------------------
# Define your global IP address pools
ip_pools = {
  underlay = {
    name               = "underlay"
    gateway            = "10.1.1.1"              # Update with your gateway
    ip_address_space   = "IPv4"
    cidr               = "10.1.1.0/24"           # Update with your CIDR
    pool_type          = "Generic"
    dhcp_server_ips    = ["10.10.10.10"]         # Update with your DHCP server IPs
    dns_server_ips     = ["8.8.8.8", "8.8.4.4"] # Update with your DNS server IPs
  }
  sensor = {
    name               = "SENSORPool"
    gateway            = "10.1.48.1"             # Update with your gateway
    ip_address_space   = "IPv4"
    cidr               = "10.1.48.0/20"          # Update with your CIDR
    pool_type          = "Generic"
    dhcp_server_ips    = ["10.10.10.10"]         # Update with your DHCP server IPs
    dns_server_ips     = ["8.8.8.8", "8.8.4.4"] # Update with your DNS server IPs
  }
  sensor_v6 = {
    name               = "SENSORPool_V6"
    gateway            = "2001:db8:48::1"        # Update with your IPv6 gateway
    ip_address_space   = "IPv6"
    cidr               = "2001:db8:48::/64"      # Update with your IPv6 CIDR
    pool_type          = "Generic"
    dhcp_server_ips    = ["2001:db8:10::10"]     # Update with your IPv6 DHCP server IPs
    dns_server_ips     = ["2001:4860:4860::8888", "2001:4860:4860::8844"] # IPv6 DNS
  }
}

# -----------------------------------------------------------------------------
# Reserved IP Pools Configuration
# -----------------------------------------------------------------------------
# Configure subpools reserved for specific sites
reserved_pools = {
  underlay_sub = {
    name                = "underlay_sub"
    site_id             = ""  # Leave empty - will be populated from site data source
    type                = "LAN"
    ipv6_address_space  = false
    ipv4_global_pool    = "10.1.1.0/24"          # Must match underlay pool CIDR
    ipv4_prefix         = true
    ipv4_prefix_length  = 25
    ipv4_subnet         = "10.1.1.0"             # Update with your subnet
    ipv4_gateway        = "10.1.1.1"             # Update with your gateway
    slaac_support       = false
  }
  sensor_sub = {
    name                = "SENSORPool_sub"
    site_id             = ""  # Leave empty - will be populated from site data source
    type                = "Generic"
    ipv6_address_space  = true
    ipv4_global_pool    = "10.1.48.0/20"         # Must match sensor pool CIDR
    ipv4_prefix         = true
    ipv4_prefix_length  = 24
    ipv4_subnet         = "10.1.48.0/24"         # Update with your IPv4 subnet
    ipv4_gateway        = "10.1.48.1"            # Update with your IPv4 gateway
    ipv6_prefix         = true
    ipv6_prefix_length  = 112
    ipv6_global_pool    = "2001:db8:48::/64"     # Must match sensor_v6 pool CIDR
    ipv6_subnet         = "2001:db8:48::1:0"     # Update with your IPv6 subnet
    ipv6_gateway        = "2001:db8:48::1:1"     # Update with your IPv6 gateway
    ipv4_dhcp_servers   = ["10.10.10.10"]        # Update with your DHCP servers
    ipv4_dns_servers    = ["8.8.8.8"]            # Update with your DNS servers
    ipv6_dhcp_servers   = ["2001:db8:10::10"]    # Update with your IPv6 DHCP servers
    ipv6_dns_servers    = ["2001:4860:4860::8888"] # Update with your IPv6 DNS servers
    slaac_support       = false
  }
}

# -----------------------------------------------------------------------------
# Network Settings Configuration
# -----------------------------------------------------------------------------
# Configure network services (AAA, DHCP, DNS, NTP, SNMP, Syslog, etc.)
network_settings = {
  site_id = ""  # Leave empty - will be populated from site data source
  
  # Network AAA Configuration
  network_aaa = {
    ip_address    = "192.168.1.100"     # Update with your AAA server IP
    network       = "192.168.1.0/24"    # Update with your AAA network
    protocol      = "RADIUS"
    servers       = "AAA"
    shared_secret = "YourSharedSecret!"  # Update with your shared secret (keep secure)
  }
  
  # Client and Endpoint AAA Configuration
  client_and_endpoint_aaa = {
    ip_address    = "192.168.1.101"     # Update with your client AAA server IP
    network       = "192.168.1.0/24"    # Update with your client AAA network
    protocol      = "RADIUS"
    servers       = "AAA"
    shared_secret = "YourSharedSecret!"  # Update with your shared secret (keep secure)
  }
  
  # DHCP Server Configuration
  dhcp_server = [
    "10.10.10.10",              # Update with your DHCP server IPv4 addresses
    "2001:db8:10::10"           # Update with your DHCP server IPv6 addresses
  ]
  
  # DNS Server Configuration
  dns_server = {
    domain_name          = "your-company.local"  # Update with your domain
    primary_ip_address   = "8.8.8.8"            # Update with your primary DNS
    secondary_ip_address = "8.8.4.4"            # Update with your secondary DNS
  }
  
  # NTP Server Configuration
  ntp_server = [
    "time1.google.com",         # Update with your NTP servers
    "time2.google.com"
  ]
  
  # SNMP Server Configuration
  snmp_server = {
    configure_dnac_ip = "true"
    ip_addresses      = ["10.10.10.20"]  # Update with your SNMP server IPs
  }
  
  # Syslog Server Configuration
  syslog_server = {
    configure_dnac_ip = "true"
    ip_addresses      = ["10.10.10.21"]  # Update with your Syslog server IPs
  }
  
  # NetFlow Collector Configuration
  netflow_collector = {
    ip_address = "10.10.10.22"   # Update with your NetFlow collector IP
    port       = 9995            # Standard NetFlow port
  }
  
  # Message of the Day (Login Banner)
  message_of_theday = {
    banner_message         = "Welcome to Your Company Network - Authorized Access Only"
    retain_existing_banner = "false"
  }
  
  # Time Zone Configuration
  timezone = "America/Los_Angeles"  # Update with your time zone
}

# -----------------------------------------------------------------------------
# AAA Settings Configuration (ISE Integration)
# -----------------------------------------------------------------------------
# Configure ISE server integration for AAA services
aaa_settings = {
  site_id = ""  # Leave empty - will be populated from site data source
  
  # Network AAA Settings for ISE
  aaa_network = {
    pan                 = "192.168.1.200"        # Update with your ISE PAN IP
    primary_server_ip   = "192.168.1.201"        # Update with your primary ISE server IP
    protocol            = "RADIUS"
    secondary_server_ip = "192.168.1.202"        # Update with your secondary ISE server IP (optional)
    server_type         = "ISE"
    shared_secret       = "YourISESharedSecret!" # Update with your ISE shared secret
  }
  
  # Client AAA Settings for ISE
  aaa_client = {
    pan                 = "192.168.1.200"        # Update with your ISE PAN IP
    primary_server_ip   = "192.168.1.201"        # Update with your primary ISE server IP
    protocol            = "RADIUS"
    secondary_server_ip = "192.168.1.202"        # Update with your secondary ISE server IP (optional)
    server_type         = "ISE"
    shared_secret       = "YourISESharedSecret!" # Update with your ISE shared secret
  }
}

# -----------------------------------------------------------------------------
# Network Update Settings (For Testing Updates)
# -----------------------------------------------------------------------------
# Enable this to test network settings updates
enable_network_update = false

network_update_settings = {
  site_id = ""  # Leave empty - will be populated from site data source
  
  # Updated DHCP servers for testing
  dhcp_server = [
    "10.10.10.11",              # Updated DHCP server IPv4 addresses
    "2001:db8:10::11"           # Updated DHCP server IPv6 addresses
  ]
  
  # Updated NTP servers for testing
  ntp_server = [
    "time3.google.com",         # Updated NTP servers
    "time4.google.com"
  ]
  
  # Updated timezone for testing
  timezone = "America/New_York"
}

# -----------------------------------------------------------------------------
# Device Controllability Configuration
# -----------------------------------------------------------------------------
device_controllability = {
  enable_controllability = true  # Enable device controllability for better management
}

# -----------------------------------------------------------------------------
# Testing and Debug Configuration
# -----------------------------------------------------------------------------
enable_debug = false  # Set to true for detailed logging during testing

timeout_settings = {
  create_timeout = "20m"  # Increase if operations take longer in your environment
  update_timeout = "20m"
  delete_timeout = "20m"
}

# =============================================================================
# IMPORTANT SECURITY NOTES:
# =============================================================================
# 1. Never commit terraform.tfvars with real credentials to version control
# 2. Use environment variables for sensitive values in CI/CD pipelines:
#    export TF_VAR_catalyst_password="your_password"
#    export TF_VAR_aaa_settings='{"aaa_network":{"shared_secret":"secret"}}'
# 3. Consider using Terraform Cloud or other secure credential management
# 4. Regularly rotate passwords and shared secrets
# 5. Use strong, unique passwords for all services
# =============================================================================