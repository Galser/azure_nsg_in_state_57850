// Common

output "rg_id" {
  value       = azurerm_resource_group.network_rg.id
  description = "The ID of the Resource Group."
}

output "rg_name" {
  value       = azurerm_resource_group.network_rg.name
  description = "The name of the Resource Group."
}

output "rg_location" {
  value       = azurerm_resource_group.network_rg.location
  description = "The location of the Resource Group."
}


// Virtual Network

output "vnet_id" {
  value       = azurerm_virtual_network.vnet.id
  description = "The ID of the vnet."
}

output "vnet_name" {
  value       = azurerm_virtual_network.vnet.name
  description = "The name of the vnet."
}

output "vnet_address_space" {
  value       = azurerm_virtual_network.vnet.address_space
  description = "The address space of the vnet."
}

output "ddos_plan_id" {
  value       = azurerm_network_ddos_protection_plan.ddos.*.id
  description = "The ID of the DDoS Protection Plan."
}

output "ddos_plan_name" {
  value       = azurerm_network_ddos_protection_plan.ddos.*.name
  description = "The name of the DDoS Protection Plan."
}

output "subnet_ids" {
  value = tomap({
    for s, subnet in azurerm_subnet.subnet : s => subnet.id
  })
  description = "The IDs of the subnets in the vnet."
}

output "subnet_names" {
  value = tomap({
    for s, subnet in azurerm_subnet.subnet : s => subnet.name
  })
  description = "The names of the subnets in the vnet."
}

output "subnet_address_prefixes" {
  value = tomap({
    for s, subnet in azurerm_subnet.subnet : s => subnet.address_prefixes
  })
  description = "The address prefixes of the subnets in the vnet."
}

output "nsg_ids" {
  value = tomap({
    for n, nsg in azurerm_network_security_group.nsg : n => nsg.id
  })
  description = "The IDs of the NSGs."
}

output "nsg_names" {
  value = tomap({
    for n, nsg in azurerm_network_security_group.nsg : n => nsg.name
  })
  description = "The names of the NSGs."
}

#output "nsg_flow_logs_storage_account_id" {
#  value       = var.create_nsg_flow_logs_storage_account ? azurerm_storage_account.nsg_flow_logs_sa[0].id : null
#  description = "The ID of the Storage Account created by this module used for sending NSG flow logs to."
#}


// Bastion

output "bas_subnet_id" {
  value       = var.create_bastion_host ? azurerm_subnet.bastion_subnet[0].id : null
  description = "The ID of the Azure Bastion subnet."
}

output "bas_subnet_name" {
  value       = var.create_bastion_host ? azurerm_subnet.bastion_subnet[0].name : null
  description = "The name of the Azure Bastion subnet."
}

output "bas_subnet_address_prefix" {
  value       = var.create_bastion_host ? azurerm_subnet.bastion_subnet[0].address_prefixes : null
  description = "The subnet address prefix of the Azure Bastion subnet."
}

output "bas_public_ip_address" {
  value       = var.create_bastion_host ? azurerm_public_ip.bastion_pip[0].ip_address : null
  description = "The public IP address of the Azure Bastion host."
}

output "bas_host_id" {
  value       = var.create_bastion_host ? azurerm_bastion_host.bastion[0].id : null
  description = "The ID of the Azure Bastion host."
}

output "bas_host_fqdn" {
  value       = var.create_bastion_host ? azurerm_bastion_host.bastion[0].dns_name : null
  description = "The FQDN of the Azure Bastion host."
}

output "bas_nsg_id" {
  value       = var.create_bastion_host ? azurerm_network_security_group.bastion_nsg[0].id : null
  description = "The ID of the Azure Bastion NSG."
}

output "bas_nsg_name" {
  value       = var.create_bastion_host ? azurerm_network_security_group.bastion_nsg[0].name : null
  description = "The name of the Azure Bastion NSG."
}


// Firewall

output "fw_name" {
  value       = var.create_azure_firewall ? azurerm_firewall.fw[0].name : null
  description = "The name of the Azure Firewall."
}

output "fw_id" {
  value       = var.create_azure_firewall ? azurerm_firewall.fw[0].id : null
  description = "The ID of the Azure Firewall."
}

output "fw_subnet_id" {
  value       = var.create_azure_firewall ? azurerm_subnet.fw_subnet[0].id : null
  description = "The ID of the Azure Firewall subnet."
}

output "fw_subnet_name" {
  value       = var.create_azure_firewall ? azurerm_subnet.fw_subnet[0].name : null
  description = "The name of the Azure Firewall subnet."
}

output "fw_subnet_address_prefix" {
  value       = var.create_azure_firewall ? azurerm_subnet.fw_subnet[0].address_prefixes : null
  description = "The subnet address prefix of the Azure Firewall subnet."
}

output "fw_private_ip_address" {
  value       = var.create_azure_firewall ? azurerm_firewall.fw[0].ip_configuration[0].private_ip_address : null
  description = "The private IP Address of the Azure Firewall."
}

output "fw_public_ip_address" {
  value       = var.create_azure_firewall ? azurerm_public_ip.fw_pip[0].ip_address : null
  description = "The public IP Address of the Azure Firewall."
}

output "fw_policy_name" {
  value       = var.create_fw_policy ? azurerm_firewall_policy.fw_policy[0].name : null
  description = "The name of the Azure Firewall Policy."
}

output "fw_policy_id" {
  value       = var.create_fw_policy ? azurerm_firewall_policy.fw_policy[0].id : null
  description = "The ID of the Azure Firewall Policy."
}

output "fw_route_table_name" {
  value       = var.configure_fw_aks_egress ? azurerm_route_table.rt[0].name : null
  description = "The name of the firewall Route Table."
}

output "fw_route_table_id" {
  value       = var.configure_fw_aks_egress ? azurerm_route_table.rt[0].id : null
  description = "The ID of the firewall Route Table."
}

output "fw_aks_policy_rule_coll_group_id" {
  value       = var.configure_fw_aks_egress ? azurerm_firewall_policy_rule_collection_group.aks_fwp_rule_coll_group[0].id : null
  description = "The ID of the Azure Firewall Policy Rule Collection Group for AKS egress."
}
