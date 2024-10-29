terraform {
  required_version = ">= 1.8.4"
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = ">= 1.13.1, < 2.0"
    }
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
