resource  "azurerm_resource_group" "rg" {
  name     = "e2e-churn-demo-${var.random_string_result}"
  location = var.location
}

variable "random_string_result"{}

variable "location"{}

output "resource-group-name"{
  value = azurerm_resource_group.rg.name
}

output "resource-group-id"{
  value = azurerm_resource_group.rg.id
}