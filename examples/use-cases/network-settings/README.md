# Network Settings Terraform Configuration

This Terraform configuration provides comprehensive network settings management for Cisco Catalyst Center, implementing the functionality described in the [Ansible Network Settings Workflow](https://github.com/DNACENSolutions/dnac_ansible_workflows/blob/main/workflows/network_settings/README.md).

## Overview

This configuration automates the deployment and management of network settings including:

- **Global IP Pools**: Creation of IPv4 and IPv6 address pools
- **Reserved IP Pools**: Site-specific IP address allocation
- **Network Services**: AAA, DHCP, DNS, NTP, SNMP, Syslog, and NetFlow configuration
- **AAA Integration**: ISE/RADIUS server configuration for authentication
- **Device Controllability**: Network device management settings
- **Banner Configuration**: Message of the day and login banners

## Features

### 🌐 **IP Pool Management**
- Create global IPv4 and IPv6 address pools
- Reserve subnets for specific sites
- Automatic DHCP and DNS server assignment
- Support for both Generic and LAN pool types

### 🔐 **AAA Services**
- Network AAA configuration with ISE integration
- Client and Endpoint AAA settings
- RADIUS protocol support
- Shared secret management

### ⚙️ **Network Services**
- DHCP server configuration (IPv4/IPv6)
- DNS server settings with domain configuration
- NTP server configuration
- SNMP server setup
- Syslog server configuration
- NetFlow collector settings

### 🛡️ **Security & Management**
- Device controllability settings
- Login banner configuration
- Secure credential handling
- SSL verification options

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Cisco Catalyst Center                        │
└─────────────────────┬───────────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────────┐
│                Network Settings Configuration                   │
├─────────────────────────────────────────────────────────────────┤
│  Global IP Pools    │  Reserved Pools  │  Network Services      │
│  ┌─────────────┐   │  ┌─────────────┐  │  ┌─────────────────┐   │
│  │ Underlay    │   │  │ Underlay    │  │  │ AAA (ISE)       │   │
│  │ 204.1.1/24  │   │  │ Sub         │  │  │ DHCP Servers    │   │
│  └─────────────┘   │  └─────────────┘  │  │ DNS Servers     │   │
│  ┌─────────────┐   │  ┌─────────────┐  │  │ NTP Servers     │   │
│  │ Sensor      │   │  │ Sensor      │  │  │ SNMP Servers    │   │
│  │ 204.1.48/20 │   │  │ Sub         │  │  │ Syslog Servers  │   │
│  └─────────────┘   │  └─────────────┘  │  │ NetFlow         │   │
│  ┌─────────────┐   │                   │  │ Banner/Timezone │   │
│  │ Sensor V6   │   │                   │  └─────────────────┘   │
│  │ 2004:1:48/64│   │                   │                        │
│  └─────────────┘   │                   │                        │
└─────────────────────────────────────────────────────────────────┘
```

## Prerequisites

- Cisco Catalyst Center 2.3.7.6 or later
- Terraform >= 1.0
- Access to Catalyst Center with appropriate permissions
- Network connectivity to Catalyst Center

## Quick Start

### 1. Clone and Setup

```bash
# Navigate to the network-settings directory
cd examples/use-cases/network-settings

# Copy the example variables file
cp terraform.tfvars.example terraform.tfvars
```

### 2. Configure Variables

Edit `terraform.tfvars` with your environment-specific values:

```hcl
# Catalyst Center connection
catalyst_username = "admin"
catalyst_password = "your-password"
catalyst_base_url = "https://your-catalyst-center.example.com"

# Site hierarchy
site_hierarchy = {
  global_site_name = "Global"
  target_site_name = "Global/USA/San Jose"  # Update to your site
}

# IP pools configuration
ip_pools = {
  underlay = {
    name               = "underlay"
    gateway            = "10.1.1.1"        # Update with your network
    cidr               = "10.1.1.0/24"     # Update with your CIDR
    dhcp_server_ips    = ["10.10.10.10"]   # Your DHCP servers
    dns_server_ips     = ["8.8.8.8"]       # Your DNS servers
  }
  # ... configure other pools
}

# AAA settings for ISE integration
aaa_settings = {
  aaa_network = {
    pan               = "192.168.1.200"     # ISE PAN IP
    primary_server_ip = "192.168.1.201"     # Primary ISE server
    protocol          = "RADIUS"
    server_type       = "ISE"
    shared_secret     = "your-shared-secret"
  }
  # ... configure client AAA
}
```

### 3. Deploy Configuration

```bash
# Initialize Terraform
terraform init

# Review the planned changes
terraform plan

# Apply the configuration
terraform apply
```

### 4. Validate Deployment

```bash
# Run the validation test
chmod +x test.sh
./test.sh

# Check outputs
terraform output
```

## Configuration Files

| File | Description |
|------|-------------|
| `main.tf` | Main Terraform configuration with resources |
| `variables.tf` | Variable definitions and defaults |
| `outputs.tf` | Output definitions for created resources |
| `terraform.tfvars.example` | Example variable values |
| `test.sh` | Configuration validation script |
| `README.md` | This documentation |

## Resource Types

### Global IP Pools
```hcl
resource "catalystcenter_global_pool" "underlay_pool" {
  # Creates global IPv4/IPv6 address pools
}
```

### Reserved IP Pools
```hcl
resource "catalystcenter_reserve_ip_subpool" "underlay_sub" {
  # Reserves portions of global pools for specific sites
}
```

### Network Settings
```hcl
resource "catalystcenter_network_create" "site_network_settings" {
  # Configures DHCP, DNS, NTP, SNMP, Syslog, NetFlow, AAA
}
```

### AAA Settings
```hcl
resource "catalystcenter_sites_aaa_settings" "site_aaa" {
  # Dedicated AAA configuration for ISE integration
}
```

### Device Controllability
```hcl
resource "catalystcenter_network_devices_device_controllability_settings" "controllability" {
  # Device management settings
}
```

## Workflow Scenarios

### Scenario 1: Initial Network Setup
1. Create global IP pools
2. Reserve IP subnets for sites
3. Configure basic network services (DHCP, DNS, NTP)
4. Set up device controllability

### Scenario 2: AAA Integration
1. Configure ISE server settings
2. Set up Network AAA for device authentication
3. Configure Client AAA for user authentication
4. Apply shared secrets and protocols

### Scenario 3: Network Services Expansion
1. Add SNMP monitoring servers
2. Configure Syslog for centralized logging
3. Set up NetFlow collection
4. Configure login banners

### Scenario 4: Updates and Maintenance
1. Enable `enable_network_update = true`
2. Update network service configurations
3. Modify IP pool allocations
4. Change timezone and banner settings

## Testing

### Automated Testing

The included `test.sh` script validates:
- ✅ Terraform file structure
- ✅ Resource configurations
- ✅ Variable definitions
- ✅ Ansible workflow compatibility
- ✅ Network service configurations
- ✅ IP pool setups
- ✅ AAA configurations

```bash
chmod +x test.sh
./test.sh
```

### Manual Validation

1. **Check Global Pools**: Verify IP pools in Catalyst Center GUI
2. **Validate Reserved Pools**: Confirm site-specific allocations
3. **Test Network Services**: Verify DHCP, DNS, NTP functionality
4. **Validate AAA**: Test device and user authentication
5. **Check Device Controllability**: Ensure device management is active

## Troubleshooting

### Common Issues

**Issue**: Site not found error
```
Solution: Verify site hierarchy names match Catalyst Center exactly
Check: terraform output troubleshooting_info
```

**Issue**: IP pool creation fails
```
Solution: Ensure CIDR ranges don't overlap
Check: Review IP pool configurations in variables
```

**Issue**: AAA configuration fails
```
Solution: Verify ISE server connectivity and shared secrets
Check: Test RADIUS connectivity from Catalyst Center
```

**Issue**: Resource dependencies
```
Solution: Let Terraform handle dependencies automatically
Check: Review depends_on relationships in main.tf
```

### Debug Mode

Enable debug mode for detailed logging:

```hcl
catalyst_debug = true
enable_debug = true
```

### Useful Outputs

Check these outputs for troubleshooting:
- `terraform output validation_checks`
- `terraform output troubleshooting_info`
- `terraform output network_settings_workflow_summary`

## Security Best Practices

### 🔒 **Credential Management**
- Never commit `terraform.tfvars` with real credentials
- Use environment variables for sensitive values:
  ```bash
  export TF_VAR_catalyst_password="your_password"
  export TF_VAR_aaa_settings='{"aaa_network":{"shared_secret":"secret"}}'
  ```

### 🛡️ **Network Security**
- Use strong, unique passwords
- Regularly rotate shared secrets
- Enable SSL verification in production
- Implement proper firewall rules

### 📝 **Access Control**
- Use minimum required permissions
- Implement role-based access control
- Audit configuration changes
- Monitor network access patterns

## Integration with Ansible

This Terraform configuration implements the same workflows as the Ansible version:

| Ansible Playbook | Terraform Resource | Purpose |
|------------------|-------------------|---------|
| `network_settings_playbook.yml` | `catalystcenter_network_create` | Network services configuration |
| Global pool creation | `catalystcenter_global_pool` | IP address pool management |
| Reserved pool creation | `catalystcenter_reserve_ip_subpool` | Site-specific IP allocation |
| AAA configuration | `catalystcenter_sites_aaa_settings` | Authentication services |

### Migration from Ansible

1. Export existing configurations from Catalyst Center
2. Map Ansible variables to Terraform variables
3. Import existing resources: `terraform import`
4. Validate configuration with test script

## Support

### Resources
- [Catalyst Center Terraform Provider Documentation](https://registry.terraform.io/providers/cisco-en-programmability/catalystcenter/latest/docs)
- [Cisco Catalyst Center API Reference](https://developer.cisco.com/docs/dna-center/)
- [Ansible Network Settings Workflow](https://github.com/DNACENSolutions/dnac_ansible_workflows/tree/main/workflows/network_settings)

### Community
- File issues for bugs or feature requests
- Contribute improvements via pull requests
- Share configuration examples and best practices

## License

This configuration is provided as-is for educational and operational use with Cisco Catalyst Center.

---

**Note**: This configuration is based on the Ansible workflow requirements from `workflows/network_settings/` and implements comprehensive network settings management for Cisco Catalyst Center environments.