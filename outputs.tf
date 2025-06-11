output "openai_account" {
  description = "The OpenAI cognitive account resource."
  value       = azurerm_cognitive_account.openai
}

output "search_service" {
  description = "The Azure Cognitive Search service resource."
  value       = azurerm_search_service.this
}

output "private_endpoints" {
  description = <<DESCRIPTION
  A map of the private endpoints created.
  DESCRIPTION
  value       = var.private_endpoints_manage_dns_zone_group ? azurerm_private_endpoint.this_managed_dns_zone_groups : azurerm_private_endpoint.this_unmanaged_dns_zone_groups
}

# https://azure.github.io/Azure-Verified-Modules/specs/terraform/#id-tffr2---category-outputs---additional-terraform-outputs
