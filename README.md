<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-avm-template

This is a template repo for Terraform Azure Verified Modules.

Things to do:

1. Set up a GitHub repo environment called `test`.
1. Configure environment protection rule to ensure that approval is required before deploying to this environment.
1. Create a user-assigned managed identity in your test subscription.
1. Create a role assignment for the managed identity on your test subscription, use the minimum required role.
1. Configure federated identity credentials on the user assigned managed identity. Use the GitHub environment.
1. Search and update TODOs within the code and remove the TODO comments once complete.

> [!IMPORTANT]
> As the overall AVM framework is not GA (generally available) yet - the CI framework and test automation is not fully functional and implemented across all supported languages yet - breaking changes are expected, and additional customer feedback is yet to be gathered and incorporated. Hence, modules **MUST NOT** be published at version `1.0.0` or higher at this time.
>
> All module **MUST** be published as a pre-release version (e.g., `0.1.0`, `0.1.1`, `0.2.0`, etc.) until the AVM framework becomes GA.
>
> However, it is important to note that this **DOES NOT** mean that the modules cannot be consumed and utilized. They **CAN** be leveraged in all types of environments (dev, test, prod etc.). Consumers can treat them just like any other IaC module and raise issues or feature requests against them as they learn from the usage of the module. Consumers should also read the release notes for each version, if considering updating to a more recent version of a module to see if there are any considerations or breaking changes etc.

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.5)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.71)

- <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) (~> 0.3)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.5)

## Resources

The following resources are used by this module:

- [azurerm_application_insights.appinsights](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) (resource)
- [azurerm_cognitive_account.document_intelligence](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_account) (resource)
- [azurerm_cognitive_account.openai](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_account) (resource)
- [azurerm_linux_web_app.webapp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app) (resource)
- [azurerm_monitor_action_group.smart_detection](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_action_group) (resource)
- [azurerm_search_service.search](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/search_service) (resource)
- [azurerm_service_plan.plan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) (resource)
- [modtm_telemetry.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/resources/telemetry) (resource)
- [random_uuid.telemetry](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) (resource)
- [azurerm_client_config.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [modtm_module_source.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/data-sources/module_source) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: Azure region where the resource should be deployed.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the this resource.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The resource group where the resources will be deployed.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_app_service_sku"></a> [app\_service\_sku](#input\_app\_service\_sku)

Description: SKU for App Service Plan

Type: `string`

Default: `"P0v3"`

### <a name="input_cognitive_services_sku"></a> [cognitive\_services\_sku](#input\_cognitive\_services\_sku)

Description: SKU for Cognitive Services

Type: `string`

Default: `"S0"`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_environment"></a> [environment](#input\_environment)

Description: Environment name for resource naming

Type: `string`

Default: `"oaiavm"`

### <a name="input_lock"></a> [lock](#input\_lock)

Description: Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.

Type:

```hcl
object({
    kind = string
    name = optional(string, null)
  })
```

Default: `null`

### <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id)

Description: Resource ID of Log Analytics Workspace

Type: `string`

Default: `"/subscriptions/08b6b8ba-e32d-484d-9052-d4e88f050899/resourceGroups/DefaultResourceGroup-CCAN/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-08b6b8ba-e32d-484d-9052-d4e88f050899-CCAN"`

### <a name="input_search_sku"></a> [search\_sku](#input\_search\_sku)

Description: SKU for Azure Search Service

Type: `string`

Default: `"standard"`

### <a name="input_subnet_prefixes"></a> [subnet\_prefixes](#input\_subnet\_prefixes)

Description: Address prefixes for subnets

Type: `map(string)`

Default:

```json
{
  "apim": "10.0.0.0/24",
  "app_service_inbound": "10.0.1.0/24",
  "app_service_outbound": "10.0.2.0/24",
  "private_endpoint": "10.0.3.0/24",
  "reserved": "10.0.4.0/24"
}
```

### <a name="input_vnet_address_space"></a> [vnet\_address\_space](#input\_vnet\_address\_space)

Description: Address space for the virtual network

Type: `list(string)`

Default:

```json
[
  "10.0.0.0/16"
]
```

## Outputs

No outputs.

## Modules

The following Modules are called:

### <a name="module_aisearch_private_endpoint"></a> [aisearch\_private\_endpoint](#module\_aisearch\_private\_endpoint)

Source: Azure/avm-res-network-privateendpoint/azurerm

Version: 0.2.0

### <a name="module_apim_nsg"></a> [apim\_nsg](#module\_apim\_nsg)

Source: Azure/avm-res-network-networksecuritygroup/azurerm

Version: 0.3.0

### <a name="module_app_service_inbound_nsg"></a> [app\_service\_inbound\_nsg](#module\_app\_service\_inbound\_nsg)

Source: Azure/avm-res-network-networksecuritygroup/azurerm

Version: 0.3.0

### <a name="module_app_service_outbound_nsg"></a> [app\_service\_outbound\_nsg](#module\_app\_service\_outbound\_nsg)

Source: Azure/avm-res-network-networksecuritygroup/azurerm

Version: 0.3.0

### <a name="module_app_service_private_endpoint"></a> [app\_service\_private\_endpoint](#module\_app\_service\_private\_endpoint)

Source: Azure/avm-res-network-privateendpoint/azurerm

Version: 0.2.0

### <a name="module_document_intelligence_private_endpoint"></a> [document\_intelligence\_private\_endpoint](#module\_document\_intelligence\_private\_endpoint)

Source: Azure/avm-res-network-privateendpoint/azurerm

Version: 0.2.0

### <a name="module_openai_private_endpoint"></a> [openai\_private\_endpoint](#module\_openai\_private\_endpoint)

Source: Azure/avm-res-network-privateendpoint/azurerm

Version: 0.2.0

### <a name="module_private_endpoint_nsg"></a> [private\_endpoint\_nsg](#module\_private\_endpoint\_nsg)

Source: Azure/avm-res-network-networksecuritygroup/azurerm

Version: 0.3.0

### <a name="module_reserved_nsg"></a> [reserved\_nsg](#module\_reserved\_nsg)

Source: Azure/avm-res-network-networksecuritygroup/azurerm

Version: 0.3.0

### <a name="module_vnet"></a> [vnet](#module\_vnet)

Source: Azure/avm-res-network-virtualnetwork/azurerm

Version: 0.8.1

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->