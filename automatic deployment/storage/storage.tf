resource "azurerm_storage_account" "storage" {
  name                     = "e2echurndemostor${var.random_string_result}"
  resource_group_name      = var.resource-group-name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = "true"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "filesystem" {
  name               = "e2edemo"
  storage_account_id = azurerm_storage_account.storage.id
}


resource "null_resource" "createDirectories-adls-gen2" {
    provisioner "local-exec" {
    command = ".\\storage\\create_directory_adls_gen2.ps1 -storageAccountName ${azurerm_storage_account.storage.name} -filesystemName ${azurerm_storage_data_lake_gen2_filesystem.filesystem.name}"
    interpreter = ["PowerShell", "-Command"]
    }
    depends_on = [azurerm_storage_data_lake_gen2_filesystem.filesystem]
}
 
output "filesystem-id"{
    value = azurerm_storage_data_lake_gen2_filesystem.filesystem.id
}

output "filesystem-name"{
    value = azurerm_storage_data_lake_gen2_filesystem.filesystem.name
}


output "storage-account-id"{
    value = azurerm_storage_account.storage.id
}

output "storage-account-key"{
    value = azurerm_storage_account.storage.primary_access_key
    sensitive = true

}

output "storage-account-name"{
    value = azurerm_storage_account.storage.name
}


variable "location"{}

variable "resource-group-name"{}

variable "random_string_result"{}