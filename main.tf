resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = var.resource_group_name
  tags     = try(merge(var.resource_group_tags, var.tags), {})
}

module "avm-res-network-virtualnetwork" {
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  version             = "0.2.3"
  location            = resource.azurerm_resource_group.rg.location
  address_space       = var.address_space
  resource_group_name = resource.azurerm_resource_group.rg.name
  # subnets             = var.subnets
  name = var.virtual_network_name

  tags = try(merge(var.resource_group_tags, var.tags), {})
}

resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  address_prefixes     = each.value.address_prefixes
  name                 = each.value.name
  resource_group_name  = resource.azurerm_resource_group.rg.name
  virtual_network_name = module.avm-res-network-virtualnetwork.name
}

## probably need to do resource blocks for subnets so we can associate nsgs at the same time
## there is no nsg association module either so this will do both

## resource block for azurerm_route_table

## resource block for azurerm_route

module "avm-res-network-networksecuritygroup-app" {
  source              = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version             = "0.2.0"
  location            = var.location
  resource_group_name = var.resource_group_name
  name                = var.network_security_group_app_name
  security_rules      = var.network_security_group_app_security_rules
}

module "avm-res-network-networksecuritygroup-pe" {
  source              = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version             = "0.2.0"
  location            = var.location
  resource_group_name = var.resource_group_name
  name                = var.network_security_group_pe_name
  security_rules      = var.network_security_group_pe_security_rules
}

module "avm-res-storage-storageaccount" {
  source              = "Azure/avm-res-storage-storageaccount/azurerm"
  version             = "0.1.3"
  location            = resource.azurerm_resource_group.rg.location
  resource_group_name = resource.azurerm_resource_group.rg.name
  account_tier        = var.storage_account_tier
  name                = var.storage_account_name

  tags = try(merge(var.resource_group_tags, var.tags), {})

}

## resource block for azurerm_sql_server

## resource block for azurerm_sql_database

## resource block for azurerm_redis_cache

## resource block for azurerm_application_insights

# module "avm-res-cognitiveservices-account" {
#   source  = "Azure/avm-res-cognitiveservices-account/azurerm"
#   version = "0.1.1"
#   # insert the 5 required variables here
# }

## resource block for azurerm_app_service_plan

## resource block for azurerm_linux_web_app

## resource block for azurerm_private_endpoint

## resource block for azurerm_public_ip

## resource block for azurerm_application_gateway
