
/*// VNET Diagnostic Logging

resource "azurerm_monitor_diagnostic_setting" "vnet_diag_logs" {
  name               = "log-diag-${azurerm_virtual_network.vnet.name}"
  target_resource_id = azurerm_virtual_network.vnet.id

  storage_account_id             = var.diag_logs_storage_account_id != "" ? var.diag_logs_storage_account_id : null
  log_analytics_workspace_id     = var.diag_logs_la_workspace_resource_id
  eventhub_authorization_rule_id = var.eventhub_auth_rule_id != "" ? var.eventhub_auth_rule_id : null
  eventhub_name                  = var.eventhub_name != "" ? var.eventhub_name : null

  dynamic "log" {
    for_each = var.vnet_diag_object.log

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
    for_each = var.vnet_diag_object.metric

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


// NSG Diagnostic Logging

resource "azurerm_monitor_diagnostic_setting" "nsg_diag_logs" {
  for_each = {
    for k, v in var.subnets : k => v
    if lookup(v, "nsg", true)
  }

  name               = "log-diag-nsg-${replace(each.key, "_", "-")}-${var.location_short}-001"
  target_resource_id = azurerm_network_security_group.nsg[each.key].id

  storage_account_id             = var.diag_logs_storage_account_id != "" ? var.diag_logs_storage_account_id : null
  log_analytics_workspace_id     = var.diag_logs_la_workspace_resource_id
  eventhub_authorization_rule_id = var.eventhub_auth_rule_id != "" ? var.eventhub_auth_rule_id : null
  eventhub_name                  = var.eventhub_name != "" ? var.eventhub_name : null

  dynamic "log" {
    for_each = var.nsg_diag_log.log

    content {
      category = log.value[0]
      enabled  = log.value[1]

      retention_policy {
        enabled = log.value[2] != null ? true : false
        days    = log.value[2]
      }
    }
  }
}


// NSG Flow Logging

resource "random_string" "str" {
  length  = 4
  special = false
  upper   = false
  keepers = {
    app_name = var.app_name
  }
}

resource "azurerm_storage_account" "nsg_flow_logs_sa" {
  count                     = var.create_nsg_flow_logs_storage_account ? 1 : 0
  name                      = coalesce(var.nsg_flow_logs_storage_account_name, lower("stnetflowlogs${var.location_short}${random_string.str.result}"))
  resource_group_name       = var.create_network_watcher ? azurerm_resource_group.nw_rg[0].name : data.azurerm_resource_group.existing_nw_rg[0].name
  location                  = var.location
  account_tier              = "Standard"
  account_kind              = "StorageV2"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"

  tags = merge(local.default_tags, var.tags)

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}

resource "azurerm_network_watcher_flow_log" "nw_flow_log" {
  for_each = {
    for k, v in var.subnets : k => v
    if lookup(v, "nsg", true)
  }

  network_watcher_name      = var.create_network_watcher ? azurerm_network_watcher.network_watcher[0].name : data.azurerm_network_watcher.existing_network_watcher[0].name
  resource_group_name       = var.create_network_watcher ? azurerm_resource_group.nw_rg[0].name : data.azurerm_resource_group.existing_nw_rg[0].name
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
  storage_account_id        = var.nsg_flow_logs_storage_account_id != "" ? var.nsg_flow_logs_storage_account_id : azurerm_storage_account.nsg_flow_logs_sa[0].id
  enabled                   = true
  version                   = 2
  retention_policy {
    enabled = true
    days    = 30
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = var.diag_logs_la_workspace_id
    workspace_region      = var.diag_logs_la_workspace_location
    workspace_resource_id = var.diag_logs_la_workspace_resource_id
    interval_in_minutes   = 10
  }

  tags = merge(local.default_tags, var.tags)

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}*/