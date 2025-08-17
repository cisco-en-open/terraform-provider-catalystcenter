package catalystcenter

import (
	"context"

	"log"

	catalystcentersdkgo "github.com/cisco-en-programmability/catalystcenter-go-sdk/v3/sdk"

	"github.com/hashicorp/terraform-plugin-sdk/v2/diag"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
)

func dataSourceGlobalCredential() *schema.Resource {
	return &schema.Resource{
		Description: `It performs read operation on Discovery.

- Returns global credential for the given credential sub type

- Returns the credential sub type for the given Id
`,

		ReadContext: dataSourceGlobalCredentialRead,
		Schema: map[string]*schema.Schema{
			"credential_sub_type": &schema.Schema{
				Description: `credentialSubType query parameter. Credential type as CLI / SNMPV2_READ_COMMUNITY / SNMPV2_WRITE_COMMUNITY / SNMPV3 / HTTP_WRITE / HTTP_READ / NETCONF
`,
				Type:     schema.TypeString,
				Optional: true,
			},
			"id": &schema.Schema{
				Description: `id path parameter. Global Credential ID
`,
				Type:     schema.TypeString,
				Optional: true,
			},
			"order": &schema.Schema{
				Description: `order query parameter. Order of sorting. 'asc' or 'des'
`,
				Type:     schema.TypeString,
				Optional: true,
			},
			"sort_by": &schema.Schema{
				Description: `sortBy query parameter. Field to sort the results by. Sorts by 'instanceId' if no value is provided
`,
				Type:     schema.TypeString,
				Optional: true,
			},

			"item": &schema.Schema{
				Type:     schema.TypeList,
				Computed: true,
				Elem: &schema.Resource{
					Schema: map[string]*schema.Schema{

						"response": &schema.Schema{
							Description: `Credential type as 'CLICredential', 'HTTPReadCredential', 'HTTPWriteCredential', 'NetconfCredential', 'SNMPv2ReadCommunity', 'SNMPv2WriteCommunity', 'SNMPv3Credential'
`,
							Type:     schema.TypeString,
							Computed: true,
						},

						"version": &schema.Schema{
							Type:     schema.TypeString,
							Computed: true,
						},
					},
				},
			},

			"items": &schema.Schema{
				Type:     schema.TypeList,
				Computed: true,
				Elem: &schema.Resource{
					Schema: map[string]*schema.Schema{

						"auth_password": &schema.Schema{
							Description: `SNMPV3 Auth Password
`,
							Type:     schema.TypeString,
							Computed: true,
						},

						"auth_type": &schema.Schema{
							Description: `SNMPV3 Auth Type
`,
							Type:     schema.TypeString,
							Computed: true,
						},

						"comments": &schema.Schema{
							Description: `Comments to identify the Global Credential
`,
							Type:     schema.TypeString,
							Computed: true,
						},

						"credential_type": &schema.Schema{
							Description: `Credential type to identify the application that uses the Global credential
`,
							Type:     schema.TypeString,
							Computed: true,
						},

						"description": &schema.Schema{
							Description: `Description for Global Credential
`,
							Type:     schema.TypeString,
							Computed: true,
						},

						"enable_password": &schema.Schema{
							Description: `CLI Enable Password
`,
							Type:     schema.TypeString,
							Computed: true,
						},

						"id": &schema.Schema{
							Description: `Id of the Global Credential
`,
							Type:     schema.TypeString,
							Computed: true,
						},

						"instance_tenant_id": &schema.Schema{
							Description: `Instance Tenant Id of the Global Credential
`,
							Type:     schema.TypeString,
							Computed: true,
						},

						"instance_uuid": &schema.Schema{
							Description: `Instance Uuid of the Global Credential
`,
							Type:     schema.TypeString,
							Computed: true,
						},

						"netconf_port": &schema.Schema{
							Description: `Netconf Port
`,
							Type:     schema.TypeString,
							Computed: true,
						},

						"password": &schema.Schema{
							Description: `CLI Password
`,
							Type:      schema.TypeString,
							Sensitive: true,
							Computed:  true,
						},

						"port": &schema.Schema{
							Description: `HTTP(S) port
`,
							Type:     schema.TypeInt,
							Computed: true,
						},

						"privacy_password": &schema.Schema{
							Description: `SNMPV3 Privacy Password
`,
							Type:     schema.TypeString,
							Computed: true,
						},

						"privacy_type": &schema.Schema{
							Description: `SNMPV3 Privacy Type
`,
							Type:     schema.TypeString,
							Computed: true,
						},

						"read_community": &schema.Schema{
							Description: `SNMP Read Community
`,
							Type:     schema.TypeString,
							Computed: true,
						},

						"secure": &schema.Schema{
							Description: `Flag for HTTP(S)
`,
							Type:     schema.TypeString,
							Computed: true,
						},

						"snmp_mode": &schema.Schema{
							Description: `SNMP Mode
`,
							Type:     schema.TypeString,
							Computed: true,
						},

						"username": &schema.Schema{
							Description: `CLI Username
`,
							Type:     schema.TypeString,
							Computed: true,
						},

						"write_community": &schema.Schema{
							Description: `SNMP Write Community
`,
							Type:     schema.TypeString,
							Computed: true,
						},
					},
				},
			},
		},
	}
}

func dataSourceGlobalCredentialRead(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	client := m.(*catalystcentersdkgo.Client)

	var diags diag.Diagnostics
	vCredentialSubType, okCredentialSubType := d.GetOk("credential_sub_type")
	vSortBy, okSortBy := d.GetOk("sort_by")
	vOrder, okOrder := d.GetOk("order")
	vID, okID := d.GetOk("id")

	method1 := []bool{okCredentialSubType, okSortBy, okOrder}
	log.Printf("[DEBUG] Selecting method. Method 1 %v", method1)
	method2 := []bool{okID}
	log.Printf("[DEBUG] Selecting method. Method 2 %v", method2)

	selectedMethod := pickMethod([][]bool{method1, method2})
	if selectedMethod == 1 {
		log.Printf("[DEBUG] Selected method: GetGlobalCredentials")
		queryParams1 := catalystcentersdkgo.GetGlobalCredentialsQueryParams{}

		if okCredentialSubType {
			queryParams1.CredentialSubType = vCredentialSubType.(string)
		}
		if okSortBy {
			queryParams1.SortBy = vSortBy.(string)
		}
		if okOrder {
			queryParams1.Order = vOrder.(string)
		}

		// has_unknown_response: None

		response1, restyResp1, err := client.Discovery.GetGlobalCredentials(&queryParams1)

		if err != nil || response1 == nil {
			if restyResp1 != nil {
				log.Printf("[DEBUG] Retrieved error response %s", restyResp1.String())
			}
			diags = append(diags, diagErrorWithAlt(
				"Failure when executing 2 GetGlobalCredentials", err,
				"Failure at GetGlobalCredentials, unexpected response", ""))
			return diags
		}

		log.Printf("[DEBUG] Retrieved response %+v", responseInterfaceToString(*response1))

		if err != nil || response1 == nil {
			if restyResp1 != nil {
				log.Printf("[DEBUG] Retrieved error response %s", restyResp1.String())
			}
			diags = append(diags, diagErrorWithAlt(
				"Failure when executing 2 GetGlobalCredentials", err,
				"Failure at GetGlobalCredentials, unexpected response", ""))
			return diags
		}

		log.Printf("[DEBUG] Retrieved response %+v", responseInterfaceToString(*response1))

		vItems1 := flattenDiscoveryGetGlobalCredentialsItems(response1.Response)
		if err := d.Set("items", vItems1); err != nil {
			diags = append(diags, diagError(
				"Failure when setting GetGlobalCredentials response",
				err))
			return diags
		}

		d.SetId(getUnixTimeString())
		return diags

	}
	if selectedMethod == 2 {
		log.Printf("[DEBUG] Selected method: GetCredentialSubTypeByCredentialID")
		vvID := vID.(string)

		// has_unknown_response: None

		response2, restyResp2, err := client.Discovery.GetCredentialSubTypeByCredentialID(vvID)

		if err != nil || response2 == nil {
			if restyResp2 != nil {
				log.Printf("[DEBUG] Retrieved error response %s", restyResp2.String())
			}
			diags = append(diags, diagErrorWithAlt(
				"Failure when executing 2 GetCredentialSubTypeByCredentialID", err,
				"Failure at GetCredentialSubTypeByCredentialID, unexpected response", ""))
			return diags
		}

		log.Printf("[DEBUG] Retrieved response %+v", responseInterfaceToString(*response2))

		if err != nil || response2 == nil {
			if restyResp2 != nil {
				log.Printf("[DEBUG] Retrieved error response %s", restyResp2.String())
			}
			diags = append(diags, diagErrorWithAlt(
				"Failure when executing 2 GetCredentialSubTypeByCredentialID", err,
				"Failure at GetCredentialSubTypeByCredentialID, unexpected response", ""))
			return diags
		}

		log.Printf("[DEBUG] Retrieved response %+v", responseInterfaceToString(*response2))

		vItem2 := flattenDiscoveryGetCredentialSubTypeByCredentialIDItem(response2)
		if err := d.Set("item", vItem2); err != nil {
			diags = append(diags, diagError(
				"Failure when setting GetCredentialSubTypeByCredentialID response",
				err))
			return diags
		}

		d.SetId(getUnixTimeString())
		return diags

	}
	return diags
}

func flattenDiscoveryGetGlobalCredentialsItems(items *[]catalystcentersdkgo.ResponseDiscoveryGetGlobalCredentialsResponse) []map[string]interface{} {
	if items == nil {
		return nil
	}
	var respItems []map[string]interface{}
	for _, item := range *items {
		respItem := make(map[string]interface{})

		// Common fields for all credential types
		respItem["comments"] = item.Comments
		respItem["credential_type"] = item.CredentialType
		respItem["description"] = item.Description
		respItem["id"] = item.ID
		respItem["instance_tenant_id"] = item.InstanceTenantID
		respItem["instance_uuid"] = item.InstanceUUID

		// Determine credential type and set type-specific fields
		credType := item.CredentialType

		switch credType {
		case "CLI":
			// CLI-specific fields
			if item.Username != "" {
				respItem["username"] = item.Username
			}
			if item.Password != "" {
				respItem["password"] = item.Password
			}
			if item.EnablePassword != "" {
				respItem["enable_password"] = item.EnablePassword
			}

		case "SNMPV3":
			// SNMPv3-specific fields
			if item.Username != "" {
				respItem["username"] = item.Username
			}
			if item.AuthPassword != "" {
				respItem["auth_password"] = item.AuthPassword
			}
			if item.AuthType != "" {
				respItem["auth_type"] = item.AuthType
			}
			if item.PrivacyPassword != "" {
				respItem["privacy_password"] = item.PrivacyPassword
			}
			if item.PrivacyType != "" {
				respItem["privacy_type"] = item.PrivacyType
			}
			if item.SNMPMode != "" {
				respItem["snmp_mode"] = item.SNMPMode
			}

		case "SNMPV2_READ_COMMUNITY":
			// SNMPv2 read community specific fields
			if item.ReadCommunity != "" {
				respItem["read_community"] = item.ReadCommunity
			}

		case "SNMPV2_WRITE_COMMUNITY":
			// SNMPv2 write community specific fields
			if item.WriteCommunity != "" {
				respItem["write_community"] = item.WriteCommunity
			}

		case "HTTP_READ", "HTTP_WRITE":
			// HTTP-specific fields
			if item.Username != "" {
				respItem["username"] = item.Username
			}
			if item.Password != "" {
				respItem["password"] = item.Password
			}
			if item.Port != nil && *item.Port != 0 {
				respItem["port"] = item.Port
			}
			// Handle secure field conversion
			if item.Secure != "" {
				respItem["secure"] = item.Secure
			}

		case "NETCONF":
			// Netconf-specific fields
			if item.NetconfPort != "" {
				respItem["netconf_port"] = item.NetconfPort
			}

		default:
			// For unknown types, include all non-empty fields safely
			if item.Username != "" {
				respItem["username"] = item.Username
			}
			if item.Password != "" {
				respItem["password"] = item.Password
			}
			if item.EnablePassword != "" {
				respItem["enable_password"] = item.EnablePassword
			}
			if item.NetconfPort != "" {
				respItem["netconf_port"] = item.NetconfPort
			}
			if item.ReadCommunity != "" {
				respItem["read_community"] = item.ReadCommunity
			}
			if item.WriteCommunity != "" {
				respItem["write_community"] = item.WriteCommunity
			}
			if item.AuthPassword != "" {
				respItem["auth_password"] = item.AuthPassword
			}
			if item.AuthType != "" {
				respItem["auth_type"] = item.AuthType
			}
			if item.PrivacyPassword != "" {
				respItem["privacy_password"] = item.PrivacyPassword
			}
			if item.PrivacyType != "" {
				respItem["privacy_type"] = item.PrivacyType
			}
			if item.SNMPMode != "" {
				respItem["snmp_mode"] = item.SNMPMode
			}
			if item.Secure != "" {
				respItem["secure"] = item.Secure
			}
			if item.Port != nil && *item.Port != 0 {
				respItem["port"] = item.Port
			}
		}

		respItems = append(respItems, respItem)
	}
	return respItems
}

func flattenDiscoveryGetCredentialSubTypeByCredentialIDItem(item *catalystcentersdkgo.ResponseDiscoveryGetCredentialSubTypeByCredentialID) []map[string]interface{} {
	if item == nil {
		return nil
	}
	respItem := make(map[string]interface{})
	respItem["response"] = item.Response
	respItem["version"] = item.Version
	return []map[string]interface{}{
		respItem,
	}
}
