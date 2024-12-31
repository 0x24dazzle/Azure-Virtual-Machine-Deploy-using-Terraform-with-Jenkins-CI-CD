variable "resource_group_name" {
  description = "Name of the resource group"
  default     = "test-jenkins"
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
variable "azure_subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}

variable "azure_client_id" {
  description = "The client ID of the Azure service principal"
  type        = string
}

variable "azure_client_secret" {
  description = "The client secret of the Azure service principal"
  type        = string
  sensitive   = true
}

variable "azure_tenant_id" {
  description = "The Azure tenant ID"
  type        = string
}


