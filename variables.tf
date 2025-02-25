variable "location" {
  type        = string
  description = "Azure region where the resource should be deployed."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the this resource."

  validation {
    condition     = can(regex("TODO", var.name))
    error_message = "The name must be TODO." # TODO remove the example below once complete:
    #condition     = can(regex("^[a-z0-9]{5,50}$", var.name))
    #error_message = "The name must be between 5 and 50 characters long and can only contain lowercase letters and numbers."
  }
}

# This is required for most resource modules
variable "resource_group_name" {
  type        = string
  description = "The resource group where the resources will be deployed."
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

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "The lock level must be one of: 'None', 'CanNotDelete', or 'ReadOnly'."
  }
}

variable "environment" {
  type        = string
  description = "Environment name for resource naming"
  default     = "oaiavm"
}

variable "vnet_address_space" {
  type        = list(string)
  description = "Address space for the virtual network"
  default     = ["10.0.0.0/16"]
}

variable "subnet_prefixes" {
  type = map(string)
  description = "Address prefixes for subnets"
  default = {
    apim                = "10.0.0.0/24"
    app_service_inbound = "10.0.1.0/24"
    app_service_outbound = "10.0.2.0/24"
    private_endpoint    = "10.0.3.0/24"
    reserved           = "10.0.4.0/24"
  }
}

variable "app_service_sku" {
  type        = string
  description = "SKU for App Service Plan"
  default     = "P0v3"
}

variable "search_sku" {
  type        = string
  description = "SKU for Azure Search Service"
  default     = "standard"
}

variable "cognitive_services_sku" {
  type        = string
  description = "SKU for Cognitive Services"
  default     = "S0"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Resource ID of Log Analytics Workspace"
  default     = "/subscriptions/08b6b8ba-e32d-484d-9052-d4e88f050899/resourceGroups/DefaultResourceGroup-CCAN/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-08b6b8ba-e32d-484d-9052-d4e88f050899-CCAN"
} 
