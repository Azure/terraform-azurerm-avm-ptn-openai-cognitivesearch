# OpenAI Cognitive Services Account
resource "azurerm_cognitive_account" "openai" {
  location            = var.location
  name                = var.openai_name
  resource_group_name = var.resource_group_name
  kind                = "OpenAI"
  sku_name            = var.openai_sku_name
  tags                = var.tags

  dynamic "identity" {
    for_each = local.managed_identities.system_assigned_user_assigned
    content {
      type         = identity.value.type
      identity_ids = identity.value.user_assigned_resource_ids
    }
  }

  dynamic "customer_managed_key" {
    for_each = var.customer_managed_key != null ? ["customer_managed_key"] : []
    content {
      key_vault_key_id   = var.customer_managed_key.key_vault_resource_id
      identity_client_id = var.customer_managed_key.user_assigned_identity != null ? var.customer_managed_key.user_assigned_identity.resource_id : null
    }
  }
}

# Cognitive Search Service
resource "azurerm_search_service" "this" {
  location                      = var.location
  name                          = var.search_service_name
  resource_group_name           = var.resource_group_name
  sku                           = var.search_service_sku
  replica_count                 = var.search_service_replica_count
  partition_count               = var.search_service_partition_count
  public_network_access_enabled = var.search_service_public_network_access_enabled
  tags                          = var.tags
}

# required AVM resources interfaces
resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.lock.kind}")
  scope      = azurerm_cognitive_account.openai.id
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azurerm_cognitive_account.openai.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}
