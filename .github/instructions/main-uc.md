---
applyTo: 'examples/use-cases/*/main.tf'
---

# Copilot Instructions: main-uc.md

## Terraform Provider Block

Use the following provider block for all use cases. Always use the default version and source as specified below (do not use commented or alternative sources):

```hcl
terraform {
  required_providers {
    catalystcenter = {
      version = "1.2.0-beta"
      source  = "cisco-en-programmability/catalystcenter"
    }
  }
}
```

## Provider Configuration

When configuring the `catalystcenter` provider, always include all relevant fields for authentication and connection. Do not use only `debug` or partial configuration. The recommended provider block is:

```hcl
provider "catalystcenter" {
  username   = var.catalyst_username   # Catalyst Center user name
  password   = var.catalyst_password   # Catalyst Center password
  base_url   = var.catalyst_base_url   # Catalyst Center base URL, FQDN or IP
  debug      = var.catalyst_debug      # Boolean to enable debugging (optional)
  ssl_verify = var.catalyst_ssl_verify # Boolean to enable/disable SSL verification (optional)
}
```

- Always provide `username`, `password`, and `base_url`.
- Use variables for sensitive or environment-specific values.
- Set `debug` and `ssl_verify` as needed for your environment.

## Example Usage

```hcl
terraform {
  required_providers {
    catalystcenter = {
      version = "1.2.0-beta"
      source  = "cisco-en-programmability/catalystcenter"
    }
  }
}

provider "catalystcenter" {
  username   = var.catalyst_username
  password   = var.catalyst_password
  base_url   = var.catalyst_base_url
  debug      = var.catalyst_debug
  ssl_verify = var.catalyst_ssl_verify
}
```

## Notes
- Do not use commented-out or alternative provider sources/versions.
- Do not omit required provider fields; always include all connection and authentication details.
- Reference variables for all provider fields for flexibility and security.
