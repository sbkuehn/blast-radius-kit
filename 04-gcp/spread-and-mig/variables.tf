variable "project_id" {
  description = "Google Cloud project to deploy into."
  type        = string
}

variable "region" {
  description = "Google Cloud region."
  type        = string
  default     = "us-central1"
}

variable "prefix" {
  description = "Short prefix used in resource names."
  type        = string
  default     = "br"
}

variable "spread_zone" {
  description = "Zone for the spread-placement instances. Placement policies work inside a single zone."
  type        = string
  default     = "us-central1-a"
}

variable "availability_domain_count" {
  description = "Availability domains (isolated hardware) to spread across. Max 8."
  type        = number
  default     = 3

  validation {
    condition     = var.availability_domain_count >= 1 && var.availability_domain_count <= 8
    error_message = "availability_domain_count must be between 1 and 8."
  }
}

variable "spread_instance_count" {
  description = "Instances attached to the spread placement policy."
  type        = number
  default     = 3
}

variable "zones" {
  description = "Zones for the regional managed instance group. List yours with 01-explore/gcp-zones.sh."
  type        = list(string)
  default     = ["us-central1-a", "us-central1-b", "us-central1-c"]
}

variable "instance_count" {
  description = "Instances in the regional managed instance group. Use a multiple of the zone count for an even spread."
  type        = number
  default     = 3
}

variable "instance_size" {
  description = "Machine type."
  type        = string
  default     = "e2-small"
}
