// Firewall Resources

resource "azurerm_subnet" "fw_subnet" {
  count                = var.create_azure_firewall ? 1 : 0
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.network_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.fw_subnet_address_prefix
  service_endpoints    = var.fw_service_endpoints
}


resource "azurerm_public_ip" "fw_pip" {
  count               = var.create_azure_firewall ? 1 : 0
  name                = coalesce(lower(var.fw_pip_name), lower("pip-fw-${var.app_name}-${var.environment}-${var.location_short}-001"))
  location            = var.location
  resource_group_name = azurerm_resource_group.network_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  sku_tier            = "Regional"

  tags = merge(local.default_tags, var.tags)

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}


// Firewall

resource "azurerm_firewall" "fw" {
  count               = var.create_azure_firewall ? 1 : 0
  name                = coalesce(lower(var.fw_name), lower("fw-${var.app_name}-${var.environment}-${var.location_short}-001"))
  location            = var.location
  resource_group_name = azurerm_resource_group.network_rg.name
  sku_name            = var.fw_sku_name
  sku_tier            = "Premium"
  firewall_policy_id  = var.create_fw_policy ? azurerm_firewall_policy.fw_policy[0].id : var.fw_policy_id
  dns_servers         = var.fw_dns_servers
  threat_intel_mode   = var.fw_threat_intel_mode
  zones               = var.fw_availability_zones != [] ? var.fw_availability_zones : null

  ip_configuration {
    name                 = var.fw_name != "" ? lower("ipcon-${var.fw_name}") : lower("ipcon-fw-${var.app_name}-${var.environment}-${var.location_short}-001")
    subnet_id            = azurerm_subnet.fw_subnet[0].id
    public_ip_address_id = azurerm_public_ip.fw_pip[0].id
  }

  dynamic "ip_configuration" {
    for_each = toset(var.fw_additional_public_ips)

    content {
      name                 = lookup(ip_configuration.value, "name")
      public_ip_address_id = lookup(ip_configuration.value, "public_ip_address_id")
    }
  }

  tags = merge(local.default_tags, var.tags)

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}


// Firewall Policy

resource "azurerm_firewall_policy" "fw_policy" {
  count                    = var.create_fw_policy ? 1 : 0
  name                     = coalesce(lower(var.fw_policy_name), lower("fwp-${var.app_name}-${var.environment}-${var.location_short}-001"))
  resource_group_name      = azurerm_resource_group.network_rg.name
  location                 = var.location
  sku                      = "Premium"
  base_policy_id           = var.fw_parent_policy_id != "" ? var.fw_parent_policy_id : null
  threat_intelligence_mode = var.fw_policy_threat_intel_mode

  dns {
    servers       = var.fw_dns_servers
    proxy_enabled = var.configure_fw_aks_egress ? true : var.fw_dns_proxy_enabled
  }

  dynamic "threat_intelligence_allowlist" {
    for_each = local.configure_fw_threat_intel_allowlist == true ? [1] : []

    content {
      ip_addresses = var.fw_threat_intel_allowlist_ip_addresses
      fqdns        = var.fw_threat_intel_allowlist_fqdns
    }
  }

  // There's a bug in the Azure API that doesn't allow uppercase tag keys on AFW Policy: https://github.com/terraform-providers/terraform-provider-azurerm/pull/9624
  // Removed Tags on this resource until the issue is resolved.
  tags = merge(local.policy_tags, var.policy_tags)

  lifecycle {
    ignore_changes = [
      tags["creationdate"]
    ]
  }
}


// AKS Egress. Default egress configuration reference documentation: https://docs.microsoft.com/en-us/azure/aks/limit-egress-traffic

resource "azurerm_firewall_policy_rule_collection_group" "aks_fwp_rule_coll_group" {
  count              = var.configure_fw_aks_egress ? 1 : 0
  name               = coalesce(lower(var.fw_aks_rule_coll_group_name), lower("fwrcg-aks-${var.app_name}-${var.environment}-${var.location_short}-001"))
  firewall_policy_id = var.create_fw_policy ? azurerm_firewall.fw[0].firewall_policy_id : var.fw_policy_id
  priority           = var.fw_aks_rule_coll_group_priority

  application_rule_collection {
    name     = coalesce(lower(var.fw_aks_app_rule_coll_name), lower("fwarc-aks-${var.app_name}-${var.environment}-${var.location_short}-001"))
    action   = "Allow"
    priority = var.fw_aks_app_rule_priority
    rule {
      name = coalesce(lower(var.fw_aks_app_rule_name), "fwar-allow-aks-fqdn-tag")

      dynamic "protocols" {
        for_each = var.fw_aks_app_rule_protocols

        content {
          type = protocols.value.type
          port = protocols.value.port
        }
      }
      source_addresses      = ["*"]
      destination_fqdn_tags = ["AzureKubernetesService"]
    }
  }

  network_rule_collection {
    name     = coalesce(lower(var.fw_aks_net_rule_coll_name), lower("fwnrc-aks-${var.app_name}-${var.environment}-${var.location_short}-001"))
    priority = var.fw_aks_net_rule_priority
    action   = "Allow"
    dynamic "rule" {
      for_each = var.fw_aks_net_rule
      content {
        name                  = lookup(rule.value, "name", null)
        protocols             = lookup(rule.value, "protocols", null)
        source_addresses      = lookup(rule.value, "source_addresses", ["*"])
        destination_addresses = lookup(rule.value, "destination_addresses", ["AzureCloud.${var.location}"])
        destination_fqdns     = lookup(rule.value, "destination_fqdns", null)
        destination_ports     = lookup(rule.value, "destination_ports", null)
      }
    }
  }
}


// Routing

resource "azurerm_route_table" "rt" {
  count                         = var.configure_fw_aks_egress || var.create_fw_routing ? 1 : 0
  name                          = coalesce(lower(var.fw_route_table_name), lower("rt-fw-${var.app_name}-${var.environment}-${var.location_short}-001"))
  location                      = var.location
  resource_group_name           = azurerm_resource_group.network_rg.name
  disable_bgp_route_propagation = false

  tags = merge(local.default_tags, var.tags)

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}

resource "azurerm_route" "route_fw" {
  count                  = var.configure_fw_aks_egress || var.create_fw_routing ? 1 : 0
  name                   = "route-firewall"
  resource_group_name    = azurerm_resource_group.network_rg.name
  route_table_name       = azurerm_route_table.rt[0].name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.fw[0].ip_configuration[0].private_ip_address
}

resource "azurerm_route" "route_internet" {
  count               = var.configure_fw_aks_egress || var.create_fw_routing ? 1 : 0
  name                = "route-internet"
  resource_group_name = azurerm_resource_group.network_rg.name
  route_table_name    = azurerm_route_table.rt[0].name
  address_prefix      = "${azurerm_public_ip.fw_pip[0].ip_address}/32"
  next_hop_type       = "Internet"
}

resource "azurerm_subnet_route_table_association" "snet_rt_assoc" {
  for_each = {
    for k, v in var.subnets : k => v
    if lookup(v, "fw_route", false)
  }

  subnet_id      = azurerm_subnet.subnet[each.key].id
  route_table_id = azurerm_route_table.rt[0].id

  depends_on = [azurerm_route_table.rt]
}


// Firewall Logging

resource "azurerm_monitor_diagnostic_setting" "fw_diag_logs" {
  count              = var.enable_fw_logging == true && var.create_azure_firewall == true ? 1 : 0
  name               = "log-diag-${azurerm_firewall.fw[0].name}"
  target_resource_id = azurerm_firewall.fw[0].id

  storage_account_id             = var.diag_logs_storage_account_id != "" ? var.diag_logs_storage_account_id : null
	# log_analytics_workspace_id     = var.diag_logs_la_workspace_resource_id
  eventhub_authorization_rule_id = var.eventhub_auth_rule_id != "" ? var.eventhub_auth_rule_id : null
  eventhub_name                  = var.eventhub_name != "" ? var.eventhub_name : null

  dynamic "log" {
    for_each = var.fw_diag_object.log

    content {
      category = log.value[0]
      enabled  = log.value[1]

      retention_policy {
        enabled = log.value[2] != null ? true : false
        days    = log.value[2]
      }
    }
  }

  dynamic "metric" {
    for_each = var.fw_diag_object.metric

    content {
      category = metric.value[0]
      enabled  = metric.value[1]

      retention_policy {
        enabled = metric.value[2] != null ? true : false
        days    = metric.value[2]
      }
    }
  }
}
