resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "e2e-churn-demo-function-app${var.random_string_result}"
  location            = var.location
  resource_group_name = var.resource-group-name
  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "function" {
  name                       = "e2e-churn-demo-function-${var.random_string_result}"
  location                   = var.location
  resource_group_name        = var.resource-group-name
  app_service_plan_id        = azurerm_app_service_plan.app_service_plan.id
  storage_account_name       = var.storage-account-name
  storage_account_access_key = var.storage-account-primary-key
}


variable "random_string_result"{}

variable "location"{}

variable "resource-group-name"{}

variable "storage-account-name"{}

variable "storage-account-primary-key"{}

output "function-name"{
    value = azurerm_function_app.function.name
}

output "function-url"{
    value = azurerm_function_app.function.default_hostname
}