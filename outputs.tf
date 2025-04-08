output "application_insights_resource_id" {
  description = "The resource ID of the Application Insights."
  value       = azurerm_application_insights.appinsights.id
}

output "cognitive_account_resource_id" {
  description = "The resource ID of the OpenAI cognitive account."
  value       = azurerm_cognitive_account.openai.id
}

output "document_intelligence_resource_id" {
  description = "The resource ID of the Document Intelligence cognitive account."
  value       = azurerm_cognitive_account.document_intelligence.id
}

output "linux_web_app_resource_id" {
  description = "The resource ID of the Linux Web App."
  value       = azurerm_linux_web_app.webapp.id
}

output "monitor_action_group_resource_id" {
  description = "The resource ID of the Monitor Action Group."
  value       = azurerm_monitor_action_group.smart_detection.id
}

output "resource_id" {
  description = "The resource ID of the OpenAI service"
  value       = azurerm_cognitive_account.openai.id
}

output "search_service_resource_id" {
  description = "The resource ID of the Azure Search Service."
  value       = azurerm_search_service.search.id
}

output "service_plan_resource_id" {
  description = "The resource ID of the App Service Plan."
  value       = azurerm_service_plan.plan.id
}
