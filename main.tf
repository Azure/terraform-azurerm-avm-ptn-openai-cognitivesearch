data "azurerm_resource_group" "existing" {
  count = var.create_resource_group ? 0 : 1

  name = var.resource_group_name
}

resource "azurerm_resource_group" "openai_rg" {
  count = var.create_resource_group ? 1 : 0

  location = var.location
  name     = var.resource_group_name
  tags     = var.tags
}
module "apim_nsg" {
  source              = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version             = "0.3.0"
  name                = "${var.name}-vnet-ApimSubnet-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}
module "app_service_inbound_nsg" {
  source              = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version             = "0.3.0"
  name                = "${var.name}-vnet-AppServiceInboundSubnet-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  security_rules      = var.app_service_inbound_security_rules
  tags                = var.tags
}
module "app_service_outbound_nsg" {
  source              = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version             = "0.3.0"
  name                = "${var.name}-vnet-AppServiceOutboundSubnet-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  security_rules      = var.app_service_outbound_security_rules
  tags                = var.tags
}
module "private_endpoint_nsg" {
  source              = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version             = "0.3.0"
  name                = "${var.name}-vnet-PrivateEndpointSubnet-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  security_rules      = var.private_endpoint_security_rules
  tags                = var.tags
}
module "reserved_nsg" {
  source              = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version             = "0.3.0"
  name                = "${var.name}-vnet-ReservedSubnet-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}
module "vnet" {
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  version             = "0.8.1"
  name                = "${var.name}-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space

  subnets = {
    apim = {
      name                            = "ApimSubnet"
      address_prefixes                = [var.subnet_prefixes.apim]
      default_outbound_access_enabled = false
      network_security_group = {
        id = module.apim_nsg.resource_id
      }
    }
    app_service_inbound = {
      name                            = "AppServiceInboundSubnet"
      address_prefixes                = [var.subnet_prefixes.app_service_inbound]
      default_outbound_access_enabled = false
      network_security_group = {
        id = module.app_service_inbound_nsg.resource_id
      }
    }
    app_service_outbound = {
      name                            = "AppServiceOutboundSubnet"
      address_prefixes                = [var.subnet_prefixes.app_service_outbound]
      default_outbound_access_enabled = false
      service_endpoints               = ["Microsoft.Storage"]
      network_security_group = {
        id = module.app_service_outbound_nsg.resource_id
      }
      delegation = [{
        name = "delegation"
        service_delegation = {
          name = "Microsoft.Web/serverFarms"
        }
      }]
    }
    private_endpoint = {
      name                            = "PrivateEndpointSubnet"
      address_prefixes                = [var.subnet_prefixes.private_endpoint]
      default_outbound_access_enabled = false
      network_security_group = {
        id = module.private_endpoint_nsg.resource_id
      }
    }
    reserved = {
      name                            = "ReservedSubnet"
      address_prefixes                = [var.subnet_prefixes.reserved]
      default_outbound_access_enabled = false
      network_security_group = {
        id = module.reserved_nsg.resource_id
      }
    }
  }
}
resource "azurerm_api_management" "this" {
  location            = var.location
  name                = "${var.name}-apim"
  publisher_email     = var.api_management.publisher_email
  publisher_name      = var.api_management.publisher_name
  resource_group_name = var.resource_group_name
  sku_name            = var.api_management.sku_name
  tags                = var.tags
  zones               = var.api_management.zones
}
resource "azurerm_cognitive_account" "openai" {
  kind                          = "OpenAI"
  location                      = var.location
  name                          = "${var.name}-azureopenai"
  resource_group_name           = var.resource_group_name
  sku_name                      = var.cognitive_services_sku
  custom_subdomain_name         = "${var.name}-azureopenai"
  public_network_access_enabled = false
  tags                          = var.tags

  network_acls {
    default_action = "Deny"
  }
}
resource "azurerm_cognitive_account" "document_intelligence" {
  kind                          = "FormRecognizer"
  location                      = var.location
  name                          = "${var.name}-documentintelligence"
  resource_group_name           = var.resource_group_name
  sku_name                      = var.cognitive_services_sku
  custom_subdomain_name         = "${var.name}-documentintelligence"
  public_network_access_enabled = false
  tags                          = var.tags

  identity {
    type = "SystemAssigned"
  }
  network_acls {
    default_action = "Deny"
  }
}
resource "azurerm_search_service" "search" {
  location                      = var.location
  name                          = "${var.name}-aisearch"
  resource_group_name           = var.resource_group_name
  sku                           = var.search_sku
  public_network_access_enabled = false
  semantic_search_sku           = "free"
  tags                          = var.tags
}
resource "azurerm_service_plan" "plan" {
  location            = var.location
  name                = "${var.name}-appserviceplan"
  os_type             = "Linux"
  resource_group_name = var.resource_group_name
  sku_name            = var.app_service_sku
  tags                = var.tags
}
resource "azurerm_linux_web_app" "webapp" {
  location            = var.location
  name                = "${var.name}-webapp"
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.plan.id
  app_settings = {
    APPLICATIONINSIGHTS_CONNECTION_STRING      = azurerm_application_insights.appinsights.connection_string
    ApplicationInsightsAgent_EXTENSION_VERSION = "~3"
    XDT_MicrosoftApplicationInsights_Mode      = "default"
  }
  ftp_publish_basic_authentication_enabled       = var.webapp_settings.ftp_publish_basic_authentication_enabled
  https_only                                     = var.webapp_settings.https_only
  public_network_access_enabled                  = var.webapp_settings.public_network_access_enabled
  tags                                           = var.tags
  virtual_network_subnet_id                      = module.vnet.subnets["app_service_outbound"].resource_id
  webdeploy_publish_basic_authentication_enabled = var.webapp_settings.webdeploy_publish_basic_authentication_enabled

  site_config {
    ftps_state                        = var.webapp_settings.site_config.ftps_state
    ip_restriction_default_action     = var.webapp_settings.site_config.ip_restriction_default_action
    scm_ip_restriction_default_action = var.webapp_settings.site_config.scm_ip_restriction_default_action
    vnet_route_all_enabled            = var.webapp_settings.site_config.vnet_route_all_enabled
  }
}
resource "azurerm_linux_web_app" "apiapp" {
  location            = var.location
  name                = "${var.name}-apiapp"
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.plan.id
  app_settings = {
    APPLICATIONINSIGHTS_CONNECTION_STRING      = azurerm_application_insights.appinsights.connection_string
    ApplicationInsightsAgent_EXTENSION_VERSION = "~3"
    XDT_MicrosoftApplicationInsights_Mode      = "default"
  }
  ftp_publish_basic_authentication_enabled       = var.apiapp_settings.ftp_publish_basic_authentication_enabled
  https_only                                     = var.apiapp_settings.https_only
  public_network_access_enabled                  = var.apiapp_settings.public_network_access_enabled
  tags                                           = var.tags
  virtual_network_subnet_id                      = module.vnet.subnets["app_service_outbound"].resource_id
  webdeploy_publish_basic_authentication_enabled = var.apiapp_settings.webdeploy_publish_basic_authentication_enabled

  site_config {
    ftps_state                        = var.apiapp_settings.site_config.ftps_state
    ip_restriction_default_action     = var.apiapp_settings.site_config.ip_restriction_default_action
    scm_ip_restriction_default_action = var.apiapp_settings.site_config.scm_ip_restriction_default_action
    vnet_route_all_enabled            = var.apiapp_settings.site_config.vnet_route_all_enabled
  }
}
module "aisearch_private_endpoint" {
  source                         = "Azure/avm-res-network-privateendpoint/azurerm"
  version                        = "0.2.0"
  name                           = "${var.name}-aisearch-pe"
  location                       = var.location
  resource_group_name            = var.resource_group_name
  subnet_resource_id             = module.vnet.subnets["private_endpoint"].resource_id
  private_connection_resource_id = azurerm_search_service.search.id
  subresource_names              = ["searchService"]
  network_interface_name         = "${var.name}-aisearch-pe-nic"
  tags                           = var.tags
}
module "app_service_private_endpoint" {
  source                         = "Azure/avm-res-network-privateendpoint/azurerm"
  version                        = "0.2.0"
  name                           = "${var.name}-appservice-pe"
  location                       = var.location
  resource_group_name            = var.resource_group_name
  subnet_resource_id             = module.vnet.subnets["private_endpoint"].resource_id
  private_connection_resource_id = azurerm_linux_web_app.webapp.id
  subresource_names              = ["sites"]
  network_interface_name         = "${var.name}-appservice-pe-nic"
  tags                           = var.tags
}
module "openai_private_endpoint" {
  source                         = "Azure/avm-res-network-privateendpoint/azurerm"
  version                        = "0.2.0"
  name                           = "${var.name}-openai-pe"
  location                       = var.location
  resource_group_name            = var.resource_group_name
  subnet_resource_id             = module.vnet.subnets["private_endpoint"].resource_id
  private_connection_resource_id = azurerm_cognitive_account.openai.id
  subresource_names              = ["account"]
  network_interface_name         = "${var.name}-openai-pe-nic"
  tags                           = var.tags
}
module "document_intelligence_private_endpoint" {
  source                         = "Azure/avm-res-network-privateendpoint/azurerm"
  version                        = "0.2.0"
  name                           = "${var.name}-docint-pe"
  location                       = var.location
  resource_group_name            = var.resource_group_name
  subnet_resource_id             = module.vnet.subnets["private_endpoint"].resource_id
  private_connection_resource_id = azurerm_cognitive_account.document_intelligence.id
  subresource_names              = ["account"]
  network_interface_name         = "${var.name}-docint-pe-nic"
  tags                           = var.tags
}
resource "azurerm_monitor_action_group" "smart_detection" {
  name                = "${var.name}-smartdetection-mag"
  resource_group_name = var.resource_group_name
  short_name          = "SmartDetect"
  tags                = var.tags

  arm_role_receiver {
    name                    = "Monitoring Contributor"
    role_id                 = "749f88d5-cbae-40b8-bcfc-e573ddc772fa"
    use_common_alert_schema = true
  }
  arm_role_receiver {
    name                    = "Monitoring Reader"
    role_id                 = "43d0d8ad-25c7-4714-9337-8ba259a9fe05"
    use_common_alert_schema = true
  }
}
resource "azurerm_application_insights" "appinsights" {
  application_type    = "web"
  location            = var.location
  name                = "${var.name}-webapp"
  resource_group_name = var.resource_group_name
  sampling_percentage = 0
  tags                = var.tags
}
