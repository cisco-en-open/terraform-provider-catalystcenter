# Software Image Management (SWIM) Workflow Use Case

## Overview

This use case demonstrates Software Image Management (SWIM) operations using the Terraform provider for Cisco Catalyst Center. The configuration implements image import workflows based on the [SWIM Ansible workflow guidelines](https://github.com/DNACENSolutions/dnac_ansible_workflows/tree/main/workflows/swim).

The following SWIM operations are covered:

1. **Query Existing Images** - Retrieve information about existing software images in Catalyst Center
2. **Import Images from URL** - Import software images from remote HTTP/FTP servers
3. **Import Images from Local Files** - Import software images from local file system
4. **Verify Imports** - Validate that images were successfully imported

## Features

### Current Implementation

- **Image Import from URLs**: Import software images from remote servers using HTTP/FTP
- **Local File Import**: Import images from local file system  
- **Image Query**: Query existing images with filtering capabilities
- **Import Verification**: Verify successful import operations
- **Flexible Configuration**: Enable/disable individual workflows via variables
- **Multiple Image Support**: Import multiple images in parallel
- **Third-party Support**: Handle third-party images and vendors

### Future Enhancements

The following SWIM operations are defined in the Ansible workflow but not yet available as Terraform resources:

- **Golden Tagging**: Mark images as golden for specific device families
- **Image Distribution**: Distribute images to devices at sites
- **Image Activation**: Activate images on target devices
- **Full Workflow**: Complete import-tag-distribute-activate workflow

## Prerequisites

1. **Cisco Catalyst Center**: Access to Catalyst Center with SWIM permissions
2. **Terraform**: Terraform v1.0+ installed
3. **Provider**: terraform-provider-catalystcenter configured
4. **Images**: Access to software images via URL or local file system
5. **Network Connectivity**: HTTP/FTP access for URL-based imports

## Quick Start

### 1. Clone and Setup

```bash
cd examples/use-cases/swim/
cp terraform.tfvars.example terraform.tfvars
```

### 2. Configure Variables

Edit `terraform.tfvars` and customize:

```hcl
# Update with your image server URLs
swim_operations = {
  import_from_url = {
    enabled = true
    images = [
      {
        source_url    = "http://your-server.com/images/cat9k_lite_iosxe.17.12.01.SPA.bin"
        schedule_desc = "Import Catalyst 9300 IOS XE image"
      }
    ]
  }
}

# Update with your site hierarchy
site_name_hierarchy = "Global/USA/SAN JOSE/BLD23"
```

### 3. Initialize and Plan

```bash
terraform init
terraform plan
```

### 4. Execute SWIM Workflows

```bash
terraform apply
```

### 5. Monitor Results

Check outputs for import status:

```bash
terraform output swim_workflow_summary
terraform output url_import_results
```

## Workflow Details

### 1. Query Existing Images

**Purpose**: Retrieve information about software images already in Catalyst Center

**Resources Used**:
- `data.catalystcenter_swim_image_details.existing_images`

**Configuration**:
```hcl
query_existing_images = {
  enabled            = true
  family             = "Cisco Catalyst 9300 Switch"
  is_cco_recommended = true
}
```

### 2. Import Images from URL

**Purpose**: Import software images from remote HTTP/FTP servers

**Resources Used**:
- `catalystcenter_swim_image_url.import_from_url`

**Process**:
1. Configure source URL and image details
2. Optionally schedule import operation
3. Monitor import task via outputs
4. Supported formats: bin, img, tar, smu, pie, aes, iso, ova, tar_gz, qcow2

**Configuration**:
```hcl
import_from_url = {
  enabled = true
  images = [
    {
      source_url       = "http://server.com/image.bin"
      third_party      = false
      schedule_desc    = "Import description"
    }
  ]
}
```

### 3. Import Images from Local Files

**Purpose**: Import software images from local file system

**Resources Used**:
- `catalystcenter_swim_image_file.import_from_file`

**Process**:
1. Specify local file path and name
2. Configure third-party settings if needed
3. Monitor import task via outputs
4. Supported formats: bin, img, tar, smu, pie, aes, iso, ova, tar_gz, qcow2

**Configuration**:
```hcl
import_from_file = {
  enabled = true
  images = [
    {
      file_name = "cat9k_lite_iosxe.17.12.01.SPA.bin"
      file_path = "/path/to/image.bin"
    }
  ]
}
```

### 4. Verify Imports

**Purpose**: Validate that images were successfully imported

**Resources Used**:
- `data.catalystcenter_swim_image_details.verify_imported_images`

**Process**:
1. Query images after import operations complete
2. Filter by family or name
3. Compare results with expected imports

## Variable Reference

### Core SWIM Operations

| Variable | Type | Description | Default |
|----------|------|-------------|---------|
| `swim_operations.query_existing_images.enabled` | bool | Enable existing image query | `true` |
| `swim_operations.import_from_url.enabled` | bool | Enable URL-based import | `true` |
| `swim_operations.import_from_file.enabled` | bool | Enable file-based import | `false` |
| `swim_operations.verify_imports.enabled` | bool | Enable import verification | `true` |

### Image Configuration

| Variable | Type | Description |
|----------|------|-------------|
| `source_url` | string | HTTP/FTP URL for image download |
| `file_path` | string | Local file system path to image |
| `file_name` | string | Name of the image file |
| `third_party` | bool | Whether image is from third-party vendor |
| `schedule_desc` | string | Description for import operation |

### Filtering Options

| Variable | Type | Description |
|----------|------|-------------|
| `family` | string | Device family filter (e.g., "Cisco Catalyst 9300 Switch") |
| `image_name` | string | Specific image name filter |
| `image_series` | string | Image series filter |
| `is_cco_recommended` | bool | Filter for CCO recommended images |
| `is_tagged_golden` | bool | Filter for golden tagged images |

## Output Reference

### Image Information

- `existing_images`: Details about existing images in Catalyst Center
- `url_import_results`: Results from URL-based imports including task IDs
- `file_import_results`: Results from file-based imports including task IDs
- `import_verification`: Verification results for imported images

### Workflow Summary

- `swim_workflow_summary`: Complete summary of all SWIM operations
- `debug_info`: Debugging information and configuration details

## Supported Image Formats

The SWIM workflow supports the following image file extensions:

- **bin**: Binary image files
- **img**: Image files
- **tar**: Tar archives
- **smu**: Software Maintenance Updates
- **pie**: Packaged IOS images
- **aes**: Encrypted images
- **iso**: ISO images
- **ova**: Open Virtual Appliance
- **tar_gz**: Compressed tar archives
- **qcow2**: QEMU disk images

## Troubleshooting

### Common Issues

1. **Import Failures**: Verify URL accessibility and file permissions
2. **Third-party Images**: Ensure proper vendor and family configuration
3. **Network Issues**: Check HTTP/FTP connectivity to image servers
4. **File Paths**: Verify local file paths are accessible to Terraform

### Debug Information

Use the debug output for troubleshooting:

```bash
terraform output debug_info
```

### Validation

Run the test script to validate configuration:

```bash
./test.sh
```

## Migration from Ansible

If migrating from the Ansible SWIM workflow, map these operations:

| Ansible Task | Terraform Resource | Status |
|--------------|-------------------|--------|
| `import_images` | `catalystcenter_swim_image_url` / `catalystcenter_swim_image_file` | ✅ Available |
| `golden_tag_images` | N/A | ⏳ Future enhancement |
| `distribute_images` | N/A | ⏳ Future enhancement |  
| `activate_images` | N/A | ⏳ Future enhancement |
| `upload_tag_dis_activate_images` | N/A | ⏳ Future enhancement |

## Security Considerations

- Store image server credentials securely
- Use HTTPS URLs when possible for image downloads
- Validate image integrity before import
- Follow organizational change management processes
- Test imports in non-production environments first

## Related Use Cases

- [Device Discovery](../device-discovery/) - Discover devices before SWIM operations
- [Inventory Management](../inventory/) - Manage device inventory
- [Provisioning](../provision/) - Provision devices after image updates

## References

- [SWIM Ansible Workflow](https://github.com/DNACENSolutions/dnac_ansible_workflows/tree/main/workflows/swim)
- [Catalyst Center SWIM Documentation](https://www.cisco.com/c/en/us/support/cloud-systems-management/dna-center/series.html)
- [Terraform Provider Documentation](../../../docs/)