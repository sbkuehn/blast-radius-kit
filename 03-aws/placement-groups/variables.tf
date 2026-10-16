variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "prefix" {
  description = "Short prefix used in resource names."
  type        = string
  default     = "sbek"
}

variable "az_ids" {
  description = "AZ IDs (not names) to deploy into. AZ IDs point to the same physical zone in every account. List yours with 01-explore/aws-az-ids.sh."
  type        = list(string)
  default     = ["use1-az1", "use1-az2", "use1-az4"]
}

variable "partition_count" {
  description = "Partitions in the partition placement group. Max 7 per AZ."
  type        = number
  default     = 3

  validation {
    condition     = var.partition_count >= 1 && var.partition_count <= 7
    error_message = "partition_count must be between 1 and 7. AWS caps partitions at 7 per Availability Zone."
  }
}

variable "instances_per_partition" {
  description = "Instances to launch into each partition."
  type        = number
  default     = 2
}

variable "instance_size" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}
