resource "azurerm_synapse_workspace" "synapse-ws" {
  name                                 = "e2e-churn-demo-${var.random_string_result}"
  resource_group_name                  = "${var.resource-group-name}"
  location                             = "${var.location}"
  storage_data_lake_gen2_filesystem_id = "${var.filesystem-id}"
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = "H@Sh1CoR3!"

}

resource "azurerm_synapse_firewall_rule" "synapse-firewall-ws" {
  name                 = "AllowAll"
  synapse_workspace_id = azurerm_synapse_workspace.synapse-ws.id
  start_ip_address     = "0.0.0.0"
  end_ip_address       = "255.255.255.255"
}

variable "location"{}

variable "resource-group-name"{}

variable "filesystem-id"{}

variable "random_string_result"{}

variable "filesystem-name"{}

variable "storage-account-name"{}

variable "function-name"{}

variable "function-url"{}

variable "databricksWorkspaceName"{}

variable "databricks_host"{}


resource "null_resource" "uploadSqlScripts" {
    provisioner "local-exec" {
    command = ".\\synapse\\uploadSqlScripts.ps1 -filesystem ${var.filesystem-name} -storage ${var.storage-account-name} -synapseWorkspaceName ${azurerm_synapse_workspace.synapse-ws.name}"
    interpreter = ["PowerShell", "-Command"]
    }
    depends_on = [azurerm_synapse_firewall_rule.synapse-firewall-ws]
}

resource "null_resource" "createSynapseArtifacts" {
    provisioner "local-exec" {
    command = ".\\synapse\\synapse-artifacts-deployment.ps1 -resourceGroupName ${var.resource-group-name} -workspaceName ${azurerm_synapse_workspace.synapse-ws.name} -dataricksworkspaceName ${var.databricksWorkspaceName} -databricksHost ${var.databricks_host} -functionName ${var.function-name} -functionUrl https://${var.function-url} -LinkedStorageServiceName ${azurerm_synapse_workspace.synapse-ws.name}-WorkspaceDefaultStorage -filesystem ${var.filesystem-name}"
    interpreter = ["PowerShell", "-Command"]
    }
    depends_on = [null_resource.uploadSqlScripts]
}
