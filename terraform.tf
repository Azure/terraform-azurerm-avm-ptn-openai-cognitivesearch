terraform {
  required_version = ">= 1.8.4"
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = ">= 1.13.1, < 2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.106.1"
    }
    # local = {
    #   source  = "hashicorp/local"
    #   version = "2.4.1"
    # }
    # null = {
    #   source  = "hashicorp/null"
    #   version = ">= 3.0"
    # }
    # random = {
    #   source  = "hashicorp/random"
    #   version = ">= 3.5.0"
    # }
  }
}
