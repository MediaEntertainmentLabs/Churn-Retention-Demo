terraform {
   required_providers {
      databricks = {
        source = "databrickslabs/databricks"
        version = "0.3.3"
      }
  }
}


resource "azurerm_databricks_workspace" "databricks-ws" {
  name                        = "e2e-churn-demo-workspace-${var.random_string_result}"
  resource_group_name         = "${var.resource-group-name}"
  location                    = "${var.location}"
  sku                         = "standard"
  managed_resource_group_name = "e2e-demo-churn-workspace-${var.random_string_result}-managed"
}

variable "random_string_result"{}

variable "location"{}

variable "resource-group-name"{}

output "databricks_host" {
  value = "https://${azurerm_databricks_workspace.databricks-ws.workspace_url}/"
}

output "databricksWorkspaceName" {
  value = "${azurerm_databricks_workspace.databricks-ws.name}"
}

provider "databricks" {
  alias = "created_workspace" 

  host  = "https://${azurerm_databricks_workspace.databricks-ws.workspace_url}/"
}

resource "databricks_token" "pat" {
  provider = databricks.created_workspace
  comment  = "Terraform automatic"
  // 100 day token
  lifetime_seconds = 8640000
}



output "databricks_token" {
  value     = databricks_token.pat.token_value
  sensitive = true
}




resource "null_resource" "uploadNotebook" {
    provisioner "local-exec" {
    command = ".\\databricks\\uploadNotebooks.ps1 -apiUrl https://${azurerm_databricks_workspace.databricks-ws.workspace_url} -accessToken ${databricks_token.pat.token_value}"
    interpreter = ["PowerShell", "-Command"]
    }
}
