variable "subscription_id" {
  description = "Azure subscription to deploy into."
  type        = string
}

variable "region" {
  description = "Azure region. Availability sets are the best in-region option where zones aren't available."
  type        = string
  default     = "westus"
}

variable "prefix" {
  description = "Short prefix used in resource names."
  type        = string
  default     = "sbek"
}

variable "fault_domain_count" {
  description = "Fault domains (racks). Max 3; some regions only support 2. Check with 01-explore/az-fault-domains.sh. Locked after creation."
  type        = number
  default     = 2

  validation {
    condition     = var.fault_domain_count >= 1 && var.fault_domain_count <= 3
    error_message = "fault_domain_count must be 1, 2, or 3. Azure availability sets cap fault domains at 3."
  }
}

variable "update_domain_count" {
  description = "Update domains (maintenance waves). Max 20. Locked after creation."
  type        = number
  default     = 5

  validation {
    condition     = var.update_domain_count >= 1 && var.update_domain_count <= 20
    error_message = "update_domain_count must be between 1 and 20."
  }
}

variable "instance_count" {
  description = "VMs in the availability set. You need at least 2 for the 99.95% SLA."
  type        = number
  default     = 3

  validation {
    condition     = var.instance_count >= 2 && var.instance_count <= 10
    error_message = "instance_count must be between 2 and 10."
  }
}

variable "instance_size" {
  description = "VM size."
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Admin username for the VMs."
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key for the admin user."
  type        = string
  sensitive   = true
}
