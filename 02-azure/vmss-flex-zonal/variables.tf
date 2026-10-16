variable "subscription_id" {
  description = "Azure subscription to deploy into."
  type        = string
}

variable "region" {
  description = "Azure region. Must support availability zones."
  type        = string
  default     = "eastus2"
}

variable "prefix" {
  description = "Short prefix used in resource names."
  type        = string
  default     = "sbek"
}

variable "zones" {
  description = "Logical zones to spread across. Confirm your VM size is offered in each with 01-explore/az-sku-zones.sh."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "instance_count" {
  description = "Instances in the scale set. Use a multiple of the zone count for an even spread."
  type        = number
  default     = 3
}

variable "instance_size" {
  description = "VM size."
  type        = string
  default     = "Standard_D2s_v5"
}

variable "admin_username" {
  description = "Admin username for the instances."
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key for the admin user."
  type        = string
  sensitive   = true
}
