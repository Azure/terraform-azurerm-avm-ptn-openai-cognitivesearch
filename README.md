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

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.8.4)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (>= 1.13.1, < 2.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>= 3.106.1)

## Resources

The following resources are used by this module:

- [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_subnet.subnets](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: Azure Region

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: Resource Group name

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_address_space"></a> [address\_space](#input\_address\_space)

Description: The address spaces applied to the virtual network. You can supply more than one address space.

Type: `set(string)`

Default:

```json
[
  "10.0.0.0/23"
]
```

### <a name="input_network_security_group_app_name"></a> [network\_security\_group\_app\_name](#input\_network\_security\_group\_app\_name)

Description: Network Security Group for the application subnet

Type: `string`

Default: `"app-nsg"`

### <a name="input_network_security_group_app_security_rules"></a> [network\_security\_group\_app\_security\_rules](#input\_network\_security\_group\_app\_security\_rules)

Description: Network Security Group Rules for the application subnet

Type: `map`

Default:

```json
{
  "rule01": {
    "access": "Allow",
    "destination_address_prefix": "*",
    "destination_port_range": "22",
    "direction": "Inbound",
    "name": "Allow-SSH",
    "priority": 100,
    "protocol": "Tcp",
    "source_address_prefix": "*",
    "source_port_range": "*"
  }
}
```

### <a name="input_network_security_group_pe_name"></a> [network\_security\_group\_pe\_name](#input\_network\_security\_group\_pe\_name)

Description: Network Security Group for the private endpoint subnet

Type: `string`

Default: `"pe-nsg"`

### <a name="input_network_security_group_pe_security_rules"></a> [network\_security\_group\_pe\_security\_rules](#input\_network\_security\_group\_pe\_security\_rules)

Description: Network Security Group Rules for the private endpoint subnet

Type: `map`

Default:

```json
{
  "rule01": {
    "access": "Allow",
    "destination_address_prefix": "*",
    "destination_port_range": "22",
    "direction": "Inbound",
    "name": "Allow-SSH",
    "priority": 100,
    "protocol": "Tcp",
    "source_address_prefix": "*",
    "source_port_range": "*"
  }
}
```

### <a name="input_resource_group_tags"></a> [resource\_group\_tags](#input\_resource\_group\_tags)

Description: Resource Group tags

Type: `map(string)`

Default: `{}`

### <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name)

Description: The name of the resource.

Type: `string`

Default: `"openaiavmstorage"`

### <a name="input_storage_account_tier"></a> [storage\_account\_tier](#input\_storage\_account\_tier)

Description: Defines the Tier to use for this storage account. Valid options are `Standard` and `Premium`. For `BlockBlobStorage` and `FileStorage` accounts only `Premium` is valid. Changing this forces a new resource to be created.

Type: `string`

Default: `"Standard"`

### <a name="input_subnets"></a> [subnets](#input\_subnets)

Description: (Optional) A map of subnets to create

 - `address_prefixes` - (Required) The address prefixes to use for the subnet.
 - `enforce_private_link_endpoint_network_policies` -
 - `enforce_private_link_service_network_policies` -
 - `name` - (Required) The name of the subnet. Changing this forces a new resource to be created.
 - `default_outbound_access_enabled` - (Optional) Whether to allow internet access from the subnet. Defaults to `false`.
 - `private_endpoint_network_policies` - (Optional) Enable or Disable network policies for the private endpoint on the subnet. Possible values are `Disabled`, `Enabled`, `NetworkSecurityGroupEnabled` and `RouteTableEnabled`. Defaults to `Enabled`.
 - `private_link_service_network_policies_enabled` - (Optional) Enable or Disable network policies for the private link service on the subnet. Setting this to `true` will **Enable** the policy and setting this to `false` will **Disable** the policy. Defaults to `true`.
 - `service_endpoint_policies` - (Optional) The map of objects with IDs of Service Endpoint Policies to associate with the subnet.
 - `service_endpoints` - (Optional) The list of Service endpoints to associate with the subnet. Possible values include: `Microsoft.AzureActiveDirectory`, `Microsoft.AzureCosmosDB`, `Microsoft.ContainerRegistry`, `Microsoft.EventHub`, `Microsoft.KeyVault`, `Microsoft.ServiceBus`, `Microsoft.Sql`, `Microsoft.Storage`, `Microsoft.Storage.Global` and `Microsoft.Web`.

 ---
 `delegation` supports the following:
 - `name` - (Required) A name for this delegation.

 ---
 `nat_gateway` supports the following:
 - `id` - (Optional) The ID of the NAT Gateway which should be associated with the Subnet. Changing this forces a new resource to be created.

 ---
 `network_security_group` supports the following:
 - `id` - (Optional) The ID of the Network Security Group which should be associated with the Subnet. Changing this forces a new association to be created.

 ---
 `route_table` supports the following:
 - `id` - (Optional) The ID of the Route Table which should be associated with the Subnet. Changing this forces a new association to be created.

 ---
 `timeouts` supports the following:
 - `create` - (Defaults to 30 minutes) Used when creating the Subnet.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Subnet.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Subnet.
 - `update` - (Defaults to 30 minutes) Used when updating the Subnet.

 ---
 `role_assignments` supports the following:

 - `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
 - `principal_id` - The ID of the principal to assign the role to.
 - `description` - (Optional) The description of the role assignment.
 - `skip_service_principal_aad_check` - (Optional) If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
 - `condition` - (Optional) The condition which will be used to scope the role assignment.
 - `condition_version` - (Optional) The version of the condition syntax. Leave as `null` if you are not using a condition, if you are then valid values are '2.0'.
 - `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. This field is only used in cross-tenant scenario.
 - `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.

Type:

```hcl
map(object({
    address_prefixes = list(string)
    name             = string
    nat_gateway = optional(object({
      id = string
    }))
    network_security_group = optional(object({
      id = string
    }))
    private_endpoint_network_policies             = optional(string, "Enabled")
    private_link_service_network_policies_enabled = optional(bool, true)
    route_table = optional(object({
      id = string
    }))
    service_endpoint_policies = optional(map(object({
      id = string
    })))
    service_endpoints               = optional(set(string))
    default_outbound_access_enabled = optional(bool, false)
    delegation = optional(list(object({
      name = string
      service_delegation = object({
        name = string
      })
    })))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })))
  }))
```

Default:

```json
{
  "subnet1": {
    "address_prefixes": [
      "10.0.0.0/24"
    ],
    "name": "subnet1"
  }
}
```

### <a name="input_tags"></a> [tags](#input\_tags)

Description: (Optional) Tags of the resource.

Type: `map(string)`

Default: `null`

### <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name)

Description: Virtual Network name

Type: `string`

Default: `"openaiavm-vnet"`

## Outputs

No outputs.

## Modules

The following Modules are called:

### <a name="module_avm-res-network-networksecuritygroup-app"></a> [avm-res-network-networksecuritygroup-app](#module\_avm-res-network-networksecuritygroup-app)

Source: Azure/avm-res-network-networksecuritygroup/azurerm

Version: 0.2.0

### <a name="module_avm-res-network-networksecuritygroup-pe"></a> [avm-res-network-networksecuritygroup-pe](#module\_avm-res-network-networksecuritygroup-pe)

Source: Azure/avm-res-network-networksecuritygroup/azurerm

Version: 0.2.0

### <a name="module_avm-res-network-virtualnetwork"></a> [avm-res-network-virtualnetwork](#module\_avm-res-network-virtualnetwork)

Source: Azure/avm-res-network-virtualnetwork/azurerm

Version: 0.2.3

### <a name="module_avm-res-storage-storageaccount"></a> [avm-res-storage-storageaccount](#module\_avm-res-storage-storageaccount)

Source: Azure/avm-res-storage-storageaccount/azurerm

Version: 0.1.3

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->