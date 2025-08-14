# Site Hierarchy Test Case

This test case validates the Network Design Site Hierarchy functionality of the terraform-provider-catalystcenter by creating a comprehensive site hierarchy based on the design sites data from the [DNACENSolutions ansible workflows repository](https://github.com/DNACENSolutions/dnac_ansible_workflows/blob/main/workflows/sites/vars/site_hierarchy_design_vars.yml).

## Overview

This Terraform configuration creates a complete site hierarchy that includes:

- **7 Areas**: USA, SAN JOSE, SAN-FRANCISCO, New York, BERKELEY, RTP, BayAreaGuest
- **9 Buildings**: Distributed across different areas with realistic addresses and coordinates  
- **19 Floors**: Multiple floors in each building with proper RF models and dimensions

## Hierarchy Structure

```
Global
└── USA
    ├── SAN JOSE
    │   ├── BLD23 (4 floors)
    │   └── BLD20 (2 floors)
    ├── SAN-FRANCISCO
    │   ├── BLD_SF (2 floors)
    │   └── BLD_SF1 (2 floors)
    ├── New York
    │   └── BLDNYC (2 floors)
    ├── BERKELEY
    │   └── BLDBERK (1 floor)
    ├── RTP
    │   ├── BLD10 (3 floors)
    │   └── BLD11 (2 floors)
    └── BayAreaGuest
        └── BLD_GB (1 floor)
```

## Files

- `main.tf` - Main Terraform configuration with all resources
- `variables.tf` - Variable definitions for flexible configuration
- `outputs.tf` - Output definitions to display created resources
- `README.md` - This documentation file

## Usage

### Prerequisites

1. Cisco Catalyst Center instance running and accessible
2. Terraform installed
3. terraform-provider-catalystcenter provider available

### Configuration

1. Update the variables in `variables.tf` or create a `terraform.tfvars` file with your Catalyst Center credentials:

```hcl
catalyst_username   = "your-username"
catalyst_password   = "your-password"
catalyst_base_url   = "https://your-catalyst-center.domain.com"
catalyst_debug      = "true"  # Optional: enable for debugging
catalyst_ssl_verify = "false" # Optional: disable SSL verification for lab environments
```

### Deployment

1. Initialize Terraform:
```bash
terraform init
```

2. Review the planned changes:
```bash
terraform plan
```

3. Apply the configuration:
```bash
terraform apply
```

4. View the outputs:
```bash
terraform output
```

### Cleanup

To destroy all created resources:
```bash
terraform destroy
```

## Validation

After successful deployment, the following resources will be created in Catalyst Center:

1. **Areas**: All 7 areas will appear in the site hierarchy
2. **Buildings**: All 9 buildings will be created with proper addresses and GPS coordinates
3. **Floors**: All 19 floors will be created with appropriate RF models and dimensions

You can verify the creation by:

1. Logging into Catalyst Center web interface
2. Navigating to Design > Network Hierarchy  
3. Expanding the hierarchy to see all created sites
4. Checking the terraform outputs for resource details

## Resource Details

### Areas
- All areas are created under Global/USA
- Each area has proper parent-child relationships
- Dependencies are managed with Terraform `depends_on` attributes

### Buildings
- Buildings include realistic addresses in California and New York
- GPS coordinates are provided for proper location mapping
- Each building is associated with its correct parent area

### Floors
- Floors use "Cubes And Walled Offices" RF model
- Standard dimensions: 100x100 feet with 10-foot height
- Floor numbers are properly assigned
- Each floor references its correct parent building

## Notes

- This test case is designed to validate the provider's ability to create complex site hierarchies
- Resource dependencies ensure proper creation order
- All resource names match the original YAML specification
- The configuration follows Terraform best practices with proper variable usage and outputs