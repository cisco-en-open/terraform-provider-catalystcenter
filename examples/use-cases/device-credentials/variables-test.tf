# Test-only variables for credential testing without site dependencies
variable "test_credentials" {
  description = "Test credentials for automated testing"
  type = object({
    cli = object({
      username        = string
      password        = string
      enable_password = string
    })
    snmp_v2c_read = object({
      community = string
    })
    snmp_v2c_write = object({
      community = string
    })
    snmp_v3 = object({
      auth_password    = string
      auth_type        = string
      snmp_mode        = string
      privacy_password = string
      privacy_type     = string
      username         = string
    })
    https_read = object({
      username = string
      password = string
      port     = number
    })
    https_write = object({
      username = string
      password = string
      port     = number
    })
    netconf = object({
      username = string
      password = string
      port     = number
    })
  })
  default = {
    cli = {
      username        = "test-cli-user"
      password        = "TestCLIPass123!"
      enable_password = "TestEnablePass123!"
    }
    snmp_v2c_read = {
      community = "test-read-comm"
    }
    snmp_v2c_write = {
      community = "test-write-comm"
    }
    snmp_v3 = {
      auth_password    = "TestAuthPass123!"
      auth_type        = "SHA"
      snmp_mode        = "AUTHPRIV"
      privacy_password = "TestPrivPass123!"
      privacy_type     = "AES128"
      username         = "test-snmpv3-user"
    }
    https_read = {
      username = "test-https-read"
      password = "TestHTTPSRead123!"
      port     = 443
    }
    https_write = {
      username = "test-https-write"
      password = "TestHTTPSWrite123!"
      port     = 443
    }
    netconf = {
      username = "test-netconf-user"
      password = "TestNetconf123!"
      port     = 830
    }
  }
  sensitive = true
}