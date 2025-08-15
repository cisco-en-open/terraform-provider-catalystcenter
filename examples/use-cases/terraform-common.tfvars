# Common Terraform Variables Example
# Copy this file to terraform.tfvars in your use case directory and update with your actual values
# You can also extend this with use-case specific variables as needed

# Cisco Catalyst Center credentials
catalyst_username = "admin"
catalyst_password = "Maglev1@3"

# Cisco Catalyst Center connection details
catalyst_base_url = "https://10.22.40.189"

# Optional: Enable debugging (useful for troubleshooting)
catalyst_debug = "false"

# Optional: Disable SSL verification (useful for lab environments)
catalyst_ssl_verify = "false"