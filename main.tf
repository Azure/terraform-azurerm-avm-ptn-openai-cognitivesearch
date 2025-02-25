# resource "azurerm_resource_group" "openai_rg" {
#   location = var.location
#   name     = var.resource_group_name
# }
resource "azurerm_cognitive_account" "openai" {
  custom_subdomain_name         = "${var.environment}-azuroepenai"
  kind                          = "OpenAI"
  location                      = var.location
  name                          = "${var.environment}-azuroepenai"
  public_network_access_enabled = false
  resource_group_name           = var.resource_group_name
  sku_name                      = var.cognitive_services_sku
  network_acls {
    default_action = "Allow"
  }
}
resource "azurerm_cognitive_account" "document_intelligence" {
  custom_subdomain_name         = "${var.environment}-documentintelligenc"
  kind                          = "FormRecognizer"
  location                      = var.location
  name                          = "${var.environment}-documentintelligenc"
  public_network_access_enabled = false
  resource_group_name           = var.resource_group_name
  sku_name                      = var.cognitive_services_sku
  identity {
    type = "SystemAssigned"
  }
  network_acls {
    default_action = "Allow"
  }
}
module "apim_nsg" {
  source              = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version             = "0.3.0"
  name                = "${var.environment}-vnet-ApimNetworkSecurityGroup-nsg-${var.location}"
  location            = var.location
  resource_group_name = var.resource_group_name
}
module "app_service_inbound_nsg" {
  source              = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version             = "0.3.0"
  name                = "${var.environment}-vnet-AppServiceInboundSubnet-nsg-${var.location}"
  location            = var.location
  resource_group_name = var.resource_group_name
}
module "app_service_outbound_nsg" {
  source              = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version             = "0.3.0"
  name                = "${var.environment}-vnet-AppServiceOutboundSubnet-nsg-${var.location}"
  location            = var.location
  resource_group_name = var.resource_group_name
}
module "private_endpoint_nsg" {
  source              = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version             = "0.3.0"
  name                = "${var.environment}-vnet-PrivateEndpointSubnet-nsg-${var.location}"
  location            = var.location
  resource_group_name = var.resource_group_name
}
module "reserved_nsg" {
  source              = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version             = "0.3.0"
  name                = "${var.environment}-vnet-ReservedSubnet-nsg-${var.location}"
  location            = var.location
  resource_group_name = var.resource_group_name
}
module "vnet" {
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  version             = "0.8.1"
  name                = "${var.environment}-vnet"
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
module "aisearch_private_endpoint" {
  source                         = "Azure/avm-res-network-privateendpoint/azurerm"
  version                        = "0.2.0"
  name                          = "AiSearchPrivateEndpoint"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  subnet_resource_id            = module.vnet.subnets["private_endpoint"].resource_id
  private_connection_resource_id = azurerm_search_service.search.id
  subresource_names             = ["searchService"]
  network_interface_name        = "aisearch-pe-nic"
}
module "app_service_private_endpoint" {
  source                         = "Azure/avm-res-network-privateendpoint/azurerm"
  version                        = "0.2.0"
  name                          = "AppServicePrivateEndpoint"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  subnet_resource_id            = module.vnet.subnets["app_service_inbound"].resource_id
  private_connection_resource_id = azurerm_linux_web_app.webapp.id
  subresource_names             = ["sites"]
  network_interface_name        = "appservice-pe-nic"
}
module "openai_private_endpoint" {
  source                         = "Azure/avm-res-network-privateendpoint/azurerm"
  version                        = "0.2.0"
  name                          = "AzureOpenAiPrivateEndpoint"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  subnet_resource_id            = module.vnet.subnets["private_endpoint"].resource_id
  private_connection_resource_id = azurerm_cognitive_account.openai.id
  subresource_names             = ["account"]
  network_interface_name        = "AzureOpenAiPrivateEndpoint-nic"
}
module "document_intelligence_private_endpoint" {
  source                         = "Azure/avm-res-network-privateendpoint/azurerm"
  version                        = "0.2.0"
  name                          = "DocumentIntelligencePrivateEndpoint"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  subnet_resource_id            = module.vnet.subnets["private_endpoint"].resource_id
  private_connection_resource_id = azurerm_cognitive_account.document_intelligence.id
  subresource_names             = ["account"]
  network_interface_name        = "DocumentIntelligencePrivateEndpoint-nic"
}
resource "azurerm_search_service" "search" {
  location                      = var.location
  name                          = "${var.environment}-aisearch"
  public_network_access_enabled = false
  resource_group_name           = var.resource_group_name
  semantic_search_sku           = "free"
  sku                           = var.search_sku
}
resource "azurerm_service_plan" "plan" {
  location            = var.location
  name                = "${var.environment}-appserviceplan"
  os_type             = "Linux"
  resource_group_name = var.resource_group_name
  sku_name            = var.app_service_sku
}
resource "azurerm_linux_web_app" "webapp" {
  app_settings = {
    APPLICATIONINSIGHTS_CONNECTION_STRING      = azurerm_application_insights.appinsights.connection_string
    ApplicationInsightsAgent_EXTENSION_VERSION = "~3"
    XDT_MicrosoftApplicationInsights_Mode     = "default"
  }
  ftp_publish_basic_authentication_enabled       = false
  https_only                                     = true
  location                                       = var.location
  name                                           = "${var.environment}-webapp"
  public_network_access_enabled                  = false
  resource_group_name                            = var.resource_group_name
  service_plan_id                                = azurerm_service_plan.plan.id
  virtual_network_subnet_id                      = module.vnet.subnets["app_service_outbound"].resource_id
  webdeploy_publish_basic_authentication_enabled = false
  
  site_config {
    ftps_state                        = "FtpsOnly"
    ip_restriction_default_action     = "Deny"
    scm_ip_restriction_default_action = "Deny"
    vnet_route_all_enabled            = true
  }
}
resource "azurerm_monitor_action_group" "smart_detection" {
  name                = "Application Insights Smart Detection"
  resource_group_name = var.resource_group_name
  short_name          = "SmartDetect"
  
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
  name                = "${var.environment}-webapp"
  resource_group_name = var.resource_group_name
  sampling_percentage = 0
  workspace_id        = var.log_analytics_workspace_id
}
