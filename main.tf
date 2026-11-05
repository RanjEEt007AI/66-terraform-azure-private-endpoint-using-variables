locals {
  prefix = "${var.project_name}-${var.environment}"
}

# Resource Group

resource "azurerm_resource_group" "rg" {
  name     = "${local.prefix}-rg"
  location = var.location
  tags     = var.common_tags
}

# Hub Virtual Network

resource "azurerm_virtual_network" "hub" {
  name                = "${local.prefix}-hub-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.hub_address_space

  tags = var.common_tags
}

# Hub Subnet

resource "azurerm_subnet" "hub" {
  name                 = "Hub-Subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = var.hub_subnet_prefix
}

# Spoke Virtual Network

resource "azurerm_virtual_network" "spoke" {
  name                = "${local.prefix}-spoke-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.spoke_address_space

  tags = var.common_tags
}

# Private Endpoint Subnet

resource "azurerm_subnet" "spoke_pe" {
  name                 = "Private-Endpoint-Subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = var.spoke_pe_subnet_prefix

  private_endpoint_network_policies = "Disabled"
}

# Hub to Spoke Peering

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "hub-to-spoke"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke.id
}

# Spoke to Hub Peering

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "spoke-to-hub"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.spoke.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
}

# Storage Account

resource "azurerm_storage_account" "storage" {
  name                     = "st${var.name_suffix}data"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  public_network_access_enabled   = true
  allow_nested_items_to_be_public = false

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }

  tags = var.common_tags
}

# Private DNS Zone

resource "azurerm_private_dns_zone" "storage_dns" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name

  tags = var.common_tags
}

# Hub DNS Link

resource "azurerm_private_dns_zone_virtual_network_link" "hub_dns" {
  name                  = "hub-dns-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_dns.name
  virtual_network_id    = azurerm_virtual_network.hub.id
}

# Spoke DNS Link

resource "azurerm_private_dns_zone_virtual_network_link" "spoke_dns" {
  name                  = "spoke-dns-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_dns.name
  virtual_network_id    = azurerm_virtual_network.spoke.id
}

# Private Endpoint

resource "azurerm_private_endpoint" "storage_pe" {
  name                = "${local.prefix}-storage-pe"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.spoke_pe.id

  private_service_connection {
    name                           = "storage-private-connection"
    private_connection_resource_id = azurerm_storage_account.storage.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "storage-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.storage_dns.id]
  }

  tags = var.common_tags
}