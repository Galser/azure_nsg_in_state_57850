// Common

resource "azurerm_resource_group" "network_rg" {
  name     = coalesce(lower(var.resource_group_name), lower("rg-vnet-${var.app_name}-${var.environment}-${var.location_short}-001"))
  location = var.location

  tags = merge(local.default_tags, var.tags)

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}


// Virtual Network

resource "azurerm_virtual_network" "vnet" {
  name                = coalesce(lower(var.vnet_name), lower("vnet-${var.app_name}-${var.environment}-${var.location_short}-001"))
  resource_group_name = azurerm_resource_group.network_rg.name
  location            = azurerm_resource_group.network_rg.location
  address_space       = var.address_space
  dns_servers         = var.dns_servers

  dynamic "ddos_protection_plan" {
    for_each = var.create_ddos_plan ? [{}] : []

    content {
      id     = azurerm_network_ddos_protection_plan.ddos[0].id
      enable = true
    }
  }

  tags = merge(local.default_tags, var.tags)

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}

resource "azurerm_network_ddos_protection_plan" "ddos" {
  count               = var.create_ddos_plan ? 1 : 0
  name                = coalesce(lower(var.ddos_plan_name), lower("ddos-vnet-${var.app_name}-${var.environment}-${var.location_short}-001"))
  resource_group_name = azurerm_resource_group.network_rg.name
  location            = azurerm_resource_group.network_rg.location

  tags = merge(local.default_tags, var.tags)

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}


// Network Watcher

/* data "azurerm_resource_group" "existing_nw_rg" {
  count = var.create_network_watcher ? 0 : 1
  name  = var.existing_network_watcher_rg_name
}

data "azurerm_network_watcher" "existing_network_watcher" {
  count               = var.create_network_watcher ? 0 : 1
  name                = var.existing_network_watcher_name
  resource_group_name = var.existing_network_watcher_rg_name
}

resource "azurerm_resource_group" "nw_rg" {
  count    = var.create_network_watcher ? 1 : 0
  name     = "NetworkWatcherRG"
  location = var.location

  tags = merge(local.default_tags, var.tags)

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}

resource "azurerm_network_watcher" "network_watcher" {
  count               = var.create_network_watcher ? 1 : 0
  name                = coalesce(lower(var.network_watcher_name), "NetworkWatcher_${var.location}")
  location            = var.location
  resource_group_name = azurerm_resource_group.nw_rg[0].name

  tags = merge(local.default_tags, var.tags)

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}
*/

// Subnets

resource "azurerm_subnet" "subnet" {
  for_each = var.subnets

  name                                           = lower(each.value.subnet_name)
  resource_group_name                            = azurerm_resource_group.network_rg.name
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  address_prefixes                               = each.value.subnet_address_prefix
  service_endpoints                              = lookup(each.value, "service_endpoints", [])
  enforce_private_link_endpoint_network_policies = lookup(each.value, "enforce_private_link_endpoint_network_policies", null)
  enforce_private_link_service_network_policies  = lookup(each.value, "enforce_private_link_service_network_policies", null)

  dynamic "delegation" {
    for_each = lookup(each.value, "delegation", {}) != {} ? [1] : []
    content {
      name = lookup(each.value.delegation, "name", null)
      service_delegation {
        name    = lookup(each.value.delegation.service_delegation, "name", null)
        actions = lookup(each.value.delegation.service_delegation, "actions", null)
      }
    }
  }
}


// NSGs

resource "azurerm_network_security_group" "nsg" {
  for_each = {
    for k, v in var.subnets : k => v
    if lookup(v, "nsg", true)
  }

  name                = lower("nsg-${each.value.subnet_name}")
  location            = var.location
  resource_group_name = azurerm_resource_group.network_rg.name

  dynamic "security_rule" {
    for_each = lookup(each.value, "nsg_rule", [])
    content {
      name                                       = lookup(security_rule.value, "name", null)
      description                                = lookup(security_rule.value, "description", null)
      priority                                   = lookup(security_rule.value, "priority", null)
      direction                                  = lookup(security_rule.value, "direction", null)
      access                                     = lookup(security_rule.value, "access", null)
      protocol                                   = lookup(security_rule.value, "protocol", null)
      source_port_range                          = lookup(security_rule.value, "source_port_range", null)
      source_port_ranges                         = lookup(security_rule.value, "source_port_rangees", null)
      destination_port_range                     = lookup(security_rule.value, "destination_port_range", null)
      destination_port_ranges                    = lookup(security_rule.value, "destination_port_ranges", null)
      source_address_prefix                      = lookup(security_rule.value, "source_address_prefix", null)
      source_address_prefixes                    = lookup(security_rule.value, "source_address_prefixes", null)
      destination_address_prefix                 = lookup(security_rule.value, "destination_address_prefix", null)
      destination_address_prefixes               = lookup(security_rule.value, "destination_address_prefixes", null)
      source_application_security_group_ids      = lookup(security_rule.value, "source_application_security_group_ids", null)
      destination_application_security_group_ids = lookup(security_rule.value, "destination_application_security_group_ids", null)
    }
  }

  tags = merge(local.default_tags, var.tags)

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  for_each = {
    for k, v in var.subnets : k => v
    if lookup(v, "nsg", true)
  }

  subnet_id                 = azurerm_subnet.subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}
