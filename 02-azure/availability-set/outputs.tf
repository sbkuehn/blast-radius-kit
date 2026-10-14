output "group_id" {
  description = "Resource ID of the availability set."
  value       = azurerm_availability_set.this.id
}

output "instance_names" {
  description = "VM names."
  value       = azurerm_linux_virtual_machine.this[*].name
}

output "check_placement" {
  description = "Command that shows which fault and update domain each VM landed in."
  value       = "az vm list -g ${azurerm_resource_group.this.name} --query \"[].name\" -o tsv | xargs -I{} az vm get-instance-view -g ${azurerm_resource_group.this.name} -n {} --query \"{vm:name, faultDomain:instanceView.platformFaultDomain, updateDomain:instanceView.platformUpdateDomain}\" -o tsv"
}
