variable "location" {
  type        = string
  description = "Azure region where the resource should be deployed."
  nullable    = false
}

variable "subscription_id" {
  type        = string
  description = "The Azure subscription ID."
}

variable "api_management" {
  type = object({
    publisher_email = string
    publisher_name  = string
    sku_name        = string
    zones           = list(string)
  })
  default = {
    publisher_email = "na@na.na"
    publisher_name  = "na"
    sku_name        = "Premium_2"
    zones           = ["1", "2"]
  }
  description = "Attributes for the API Management resource"
}

variable "apiapp_settings" {
  type = object({
    ftp_publish_basic_authentication_enabled       = bool
    https_only                                     = bool
    public_network_access_enabled                  = bool
    webdeploy_publish_basic_authentication_enabled = bool

    site_config = object({
      ftps_state                        = string
      ip_restriction_default_action     = string
      scm_ip_restriction_default_action = string
      vnet_route_all_enabled            = bool
    })
  })
  default = {
    ftp_publish_basic_authentication_enabled       = false
    https_only                                     = true
    public_network_access_enabled                  = false
    webdeploy_publish_basic_authentication_enabled = false

    site_config = {
      ftps_state                        = "FtpsOnly"
      ip_restriction_default_action     = "Deny"
      scm_ip_restriction_default_action = "Deny"
      vnet_route_all_enabled            = true
    }
  }
  description = "Configuration settings for the api app including authentication, network access, and site configuration options"
}

variable "app_service_inbound_security_rules" {
  type = map(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = {
    allow_inbound_from_apim = {
      name                       = "AllowInboundFromApimToAppServiceInbound"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "10.0.0.0/24"
      destination_address_prefix = "10.0.1.0/24"
    },
    allow_outbound_to_apim = {
      name                       = "AllowOutboundFromAppServiceInboundToApim"
      priority                   = 100
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "10.0.1.0/24"
      destination_address_prefix = "10.0.0.0/24"
    }
  }
  description = "Security rules for the App Service inbound NSG"
}

variable "app_service_outbound_security_rules" {
  type = map(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = {
    allow_inbound_from_private_endpoint = {
      name                       = "AllowInboundFromPrivateEndpointToAppServiceOutbound"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "10.0.3.0/24"
      destination_address_prefix = "10.0.2.0/24"
    },
    allow_outbound_to_private_endpoint = {
      name                       = "AllowOutboundFromAppServiceOutboundToPrivateEndpoint"
      priority                   = 100
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "10.0.2.0/24"
      destination_address_prefix = "10.0.3.0/24"
    }
  }
  description = "Security rules for the App Service outbound NSG"
}

variable "app_service_sku" {
  type        = string
  default     = "P0v3"
  description = "SKU for App Service Plan"
}

variable "cognitive_services_sku" {
  type        = string
  default     = "S0"
  description = "SKU for Cognitive Services"
}

variable "create_resource_group" {
  type        = bool
  default     = false
  description = "Confirmation if Resource Group should be created by the root module or if it already exists"
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment name for resource naming"
}

variable "name" {
  type        = string
  default     = "oaiavmptn"
  description = "The name string to be applied to all resource names"
}

variable "private_endpoint_security_rules" {
  type = map(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = {
    allow_inbound_from_app_service_outbound = {
      name                       = "AllowInboundFromAppServiceOutboundToPrivateEndpoint"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "10.0.2.0/24"
      destination_address_prefix = "10.0.3.0/24"
    },
    allow_outbound_to_app_service_outbound = {
      name                       = "AllowOutboundFromPrivateEndpointToAppServiceOutbound"
      priority                   = 100
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "10.0.3.0/24"
      destination_address_prefix = "10.0.2.0/24"
    }
  }
  description = "Security rules for the Private Endpoint NSG"
}

variable "resource_group_name" {
  type        = string
  default     = "avm-ptn-openai-cognitivesearch-rg"
  description = "The resource group where the resources will be deployed."
}

variable "search_sku" {
  type        = string
  default     = "standard"
  description = "SKU for Azure Search Service"
}

variable "subnet_prefixes" {
  type = map(string)
  default = {
    apim                 = "10.0.0.0/24"
    app_service_inbound  = "10.0.1.0/24"
    app_service_outbound = "10.0.2.0/24"
    private_endpoint     = "10.0.3.0/24"
    reserved             = "10.0.4.0/24"
  }
  description = "Address prefixes for subnets"
}

variable "tags" {
  type = map(string)
  default = {
    Environment = "dev"
  }
  description = "Tags to be applied to all resources"
}

variable "vnet_address_space" {
  type        = list(string)
  default     = ["10.0.0.0/16"]
  description = "Address space for the virtual network"
}

variable "webapp_settings" {
  type = object({
    ftp_publish_basic_authentication_enabled       = bool
    https_only                                     = bool
    public_network_access_enabled                  = bool
    webdeploy_publish_basic_authentication_enabled = bool

    site_config = object({
      ftps_state                        = string
      ip_restriction_default_action     = string
      scm_ip_restriction_default_action = string
      vnet_route_all_enabled            = bool
    })
  })
  default = {
    ftp_publish_basic_authentication_enabled       = false
    https_only                                     = true
    public_network_access_enabled                  = false
    webdeploy_publish_basic_authentication_enabled = false

    site_config = {
      ftps_state                        = "FtpsOnly"
      ip_restriction_default_action     = "Deny"
      scm_ip_restriction_default_action = "Deny"
      vnet_route_all_enabled            = true
    }
  }
  description = "Configuration settings for the web app including authentication, network access, and site configuration options"
}
