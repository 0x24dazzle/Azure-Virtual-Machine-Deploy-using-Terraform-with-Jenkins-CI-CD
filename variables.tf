variable "resource_group_name" {
  description = "Name of the resource group"
  default     = "test-jenkins2"
}

variable "location" {
  description = "Azure region for the resources"
  default     = "West Europe"
}

variable "admin_username" {
  description = "Admin username for the VM"
  default     = "azureuser"
}

variable "admin_password" {
  description = "Admin password for the VM"
  default     = "P@ssw0rd1234!"
}


