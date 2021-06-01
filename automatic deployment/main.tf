terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.57.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "variables"{
  source = "./variables"
}

module "resource-group"{
  source = "./resource-group"
  random_string_result = module.variables.random_string_result
  location = module.variables.location
}

module "storage"{
  source = "./storage"
  location = module.variables.location
  resource-group-name = module.resource-group.resource-group-name
  random_string_result = module.variables.random_string_result
}

module "databricks"{
  source = "./databricks"
  location =  module.variables.location
  resource-group-name = module.resource-group.resource-group-name
  random_string_result = module.variables.random_string_result
}

module "synapse" {
  source = "./synapse"
  location = module.variables.location
  resource-group-name =  module.resource-group.resource-group-name
  random_string_result = module.variables.random_string_result
  filesystem-id = module.storage.filesystem-id
  filesystem-name = module.storage.filesystem-name
  storage-account-name = module.storage.storage-account-name
  function-name = module.functions.function-name
  function-url = module.functions.function-url
  databricksWorkspaceName = module.databricks.databricksWorkspaceName
  databricks_host = module.databricks.databricks_host
  depends_on = [module.databricks]
}

module "aml"{
  source = "./aml"
  location = module.variables.location
  resource-group-name =  module.resource-group.resource-group-name
  random_string_result = module.variables.random_string_result
  storage-account-id = module.storage.storage-account-id
}

module "functions"{
  source = "./functions"
  location = module.variables.location
  resource-group-name =  module.resource-group.resource-group-name
  random_string_result = module.variables.random_string_result
  storage-account-name =  module.storage.storage-account-name
  storage-account-primary-key = module.storage.storage-account-key
}