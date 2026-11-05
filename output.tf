output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "hub_vnet_id" {
  value = azurerm_virtual_network.hub.id
}

output "spoke_vnet_id" {
  value = azurerm_virtual_network.spoke.id
}

output "storage_account_name" {
  value = azurerm_storage_account.storage.name
}

output "private_endpoint_id" {
  value = azurerm_private_endpoint.storage_pe.id
}

output "private_endpoint_ip" {
  value = azurerm_private_endpoint.storage_pe.private_service_connection[0].private_ip_address
}

output "private_dns_zone" {
  value = azurerm_private_dns_zone.storage_dns.name
}