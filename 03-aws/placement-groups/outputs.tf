output "group_id" {
  description = "IDs of the partition and spread placement groups."
  value = {
    partition = aws_placement_group.partition.id
    spread    = aws_placement_group.spread.id
  }
}

output "zones" {
  description = "Each subnet's AZ ID next to the zone name it maps to in this account."
  value       = { for s in aws_subnet.this : s.availability_zone_id => s.availability_zone }
}

output "check_placement" {
  description = "Command that shows which partition and AZ each instance landed in."
  value       = "aws ec2 describe-instances --region ${var.region} --filters Name=tag:project,Values=blast-radius-kit Name=instance-state-name,Values=running --query \"Reservations[].Instances[].{Name:Tags[?Key=='Name']|[0].Value, AZ:Placement.AvailabilityZone, Partition:Placement.PartitionNumber}\" --output table"
}
