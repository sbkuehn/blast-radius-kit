output "group_id" {
  description = "IDs of the spread placement policy and the regional managed instance group."
  value = {
    spread = google_compute_resource_policy.spread.id
    mig    = google_compute_region_instance_group_manager.mig.id
  }
}

output "zones" {
  description = "Zones the regional managed instance group spreads across."
  value       = google_compute_region_instance_group_manager.mig.distribution_policy_zones
}

output "check_placement" {
  description = "Command that shows which zone each managed instance landed in."
  value       = "gcloud compute instance-groups managed list-instances ${google_compute_region_instance_group_manager.mig.name} --region ${var.region}"
}
