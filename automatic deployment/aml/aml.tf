resource "azurerm_application_insights" "app-insight" {
  name                = "e2e-churn-demo-ai-${var.random_string_result}"
  location            = var.location
  resource_group_name = var.resource-group-name
  application_type    = "web"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "key-vault" {
  name                = "e2e-churm-demo-kv-${var.random_string_result}"
  location            = var.location
  resource_group_name = var.resource-group-name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  purge_protection_enabled    = false
}

resource "azurerm_machine_learning_workspace" "example" {
  name                    = "e2e-churn-demo-aml-ws-${var.random_string_result}"
  location                = var.location
  resource_group_name     = var.resource-group-name
  application_insights_id = azurerm_application_insights.app-insight.id
  key_vault_id            = azurerm_key_vault.key-vault.id
  storage_account_id      = var.storage-account-id
  identity {
    type = "SystemAssigned"
  }
}


variable "random_string_result"{}

variable "location"{}

variable "resource-group-name"{}

variable "storage-account-id"{}