<!-- BEGIN_TF_DOCS -->
# Default example

This deploys the module in its simplest form.

```hcl
terraform {
  required_version = ">= 1.8.4"
  required_providers {
    # azapi = {
    #   source  = "Azure/azapi"
    #   version = ">= 1.13.1, < 2.0"
    # }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.90.0, < 4.0.0"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true
  storage_use_azuread        = true
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.0"
  prefix  = ["aap"]
}

# This is the module call
module "avm_ptn_aap_openai_cognitivesearch" {
  source                          = "../../"
  resource_group_name             = module.naming.resource_group.name_unique
  location                        = "westus2"
  virtual_network_name            = module.naming.virtual_network.name_unique
  network_security_group_app_name = "${module.naming.network_security_group.name}-app"
  network_security_group_pe_name  = "${module.naming.network_security_group.name}-pe"
  storage_account_name            = module.naming.storage_account.name_unique
  # address_space        = ["10.0.0.0/23"]
  # subnets = {
  #   subnet1 = {
  #     address_prefixes = ["10.0.0.0/24"]
  #     name             = "subnet1"
  #   }
  # }

  tags = {
    test_example = "default"
  }
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.8.4)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>= 3.90.0, < 4.0.0)

## Resources

No resources.

<!-- markdownlint-disable MD013 -->
## Required Inputs

No required inputs.

## Optional Inputs

No optional inputs.

## Outputs

No outputs.

## Modules

The following Modules are called:

### <a name="module_avm_ptn_aap_openai_cognitivesearch"></a> [avm\_ptn\_aap\_openai\_cognitivesearch](#module\_avm\_ptn\_aap\_openai\_cognitivesearch)

Source: ../../

Version:

### <a name="module_naming"></a> [naming](#module\_naming)

Source: Azure/naming/azurerm

Version: 0.4.0

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->