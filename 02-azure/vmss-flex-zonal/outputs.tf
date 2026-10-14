output "group_id" {
  description = "Resource ID of the scale set."
  value       = azurerm_orchestrated_virtual_machine_scale_set.this.id
}

output "zones" {
  description = "Logical zones the scale set spans."
  value       = var.zones
}

output "check_placement" {
  description = "Command that shows which zone each instance landed in."
  value       = "az vm list -g ${azurerm_resource_group.this.name} --query \"[].{vm:name, zone:zones[0]}\" -o table"
}
