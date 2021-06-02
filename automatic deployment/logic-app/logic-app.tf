resource "azurerm_logic_app_workflow" "logic" {
  name                = "e2e-churn-demo-logic-app-${var.random_string_result}"
  location                   = var.location
  resource_group_name        = var.resource-group-name
}


variable "location"{}

variable "resource-group-name"{}

variable "random_string_result"{}