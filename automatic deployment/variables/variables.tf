resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}

output "random_string_result"{
  value = random_string.naming.result
}

variable "location"{
  type = string
  default = "eastus2"
}

output "location"{
  value = var.location
}