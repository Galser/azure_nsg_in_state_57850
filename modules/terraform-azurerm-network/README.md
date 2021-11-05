# Network Module
This Terraform module deploys a virtual network with a subnet or set of subnets and network security groups (optional).

This module can also deploy the following optional features:
* Azure Bastion Host
* Azure Firewall Premium instance
* Azure Firewall Policy
* Azure Firewall AKS default egress resources and configuration, documented here: [Control egress traffic for cluster nodes in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/limit-egress-traffic)

## Prerequisite Resources
This module requires the following resources:
* Log Analytics Workspace (see [mgmt_security](https://app.terraform.io/app/ef-cloudops/registry/modules/private/ef-cloudops/mgmt-security/azurerm) module) - to send diagnostic logs for Azure Monitor and NSG flow logs for Network Watcher

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 2.71.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 2.71.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_bastion_host.bastion](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/bastion_host) | resource |
| [azurerm_firewall.fw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall) | resource |
| [azurerm_firewall_policy.fw_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall_policy) | resource |
| [azurerm_firewall_policy_rule_collection_group.aks_fwp_rule_coll_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall_policy_rule_collection_group) | resource |
| [azurerm_monitor_diagnostic_setting.fw_diag_logs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.nsg_diag_logs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.vnet_diag_logs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_network_ddos_protection_plan.ddos](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_ddos_protection_plan) | resource |
| [azurerm_network_security_group.bastion_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_watcher.network_watcher](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_watcher) | resource |
| [azurerm_network_watcher_flow_log.nw_flow_log](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_watcher_flow_log) | resource |
| [azurerm_public_ip.bastion_pip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_public_ip.fw_pip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_resource_group.network_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.nw_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_route.route_fw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route) | resource |
| [azurerm_route.route_internet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route) | resource |
| [azurerm_route_table.rt](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource |
| [azurerm_storage_account.nsg_flow_logs_sa](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_subnet.bastion_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.fw_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.bastion_nsg_assoc](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_network_security_group_association.nsg_assoc](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_route_table_association.snet_rt_assoc](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [random_string.str](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

# Example usage with Terraform 0.13+
## Network Example Deployment - Basic
This example creates a basic virtual network with no subnets using the minimum required parameters.

```hcl
# Create management plane resources using the mgmt-security module, truncated for brevity
module "mgmt_security" {
  source  = "app.terraform.io/ef-cloudops/mgmt-security/azurerm"
  version = "x.x.x" 
  ...
}

module "network" {
  source  = "app.terraform.io/ef-cloudops/network/azurerm"
  version = "x.x.x"

  environment    = "test"
  location       = "westeurope"
  location_short = "weu"   // for resource naming conventions when custom names are not defined with variables
  app_name       = "example"
  address_space  = ["10.0.1.0/23"]

  diag_logs_la_workspace_resource_id = module.mgmt_security.ops_log_analytics_workspace_resource_id  // Required for diag logs and nsg flow log traffic analytics
  diag_logs_la_workspace_id          = module.mgmt_security.ops_log_analytics_workspace_id   // Required for nsg flow log traffic analytics
  diag_logs_la_workspace_location    = module.mgmt_security.ops_log_analytics_location   // Required for nsg flow log traffic analytics
}
```

## Tags
This module deploys a default set of tags assigned to all resources formatted with "Camel Case" *keys* and all lowercase *values*:
* `CreationDate : timestamp()` (timestamp will not be modified with subsequent applies)

In addition, you can create your own custom tags using the **tags** variable. See *example_adv2* for example usage. Note: Azure limits the number of tags per resource to 15.

## Network Security Group Info
* By default, each subnet will be deployed with an NSG (with flow logging enabled with a 30 day retention period and traffic analytics enabled). Any custom rules added will be in addition to the default rules. For example usage of custom NSG rules, see *example_adv2*. To deploy a subnet without an NSG, specify `nsg = false` in the *subnets* variable map.

## Network Watcher Info
* The Network Watcher Resource Group name is hard-coded to the Azure default "NetworkWatcherRG". The reason for this is that if Terraform creates this RG with another name the default RG will be still created by Azure and not managed by Terraform, and this is an undesirable outcome.
* Network Watcher is a per-region resource within a subscription. Only deploy 1 Network Watcher per-region in a subscription. If deploying multiple vnets to the same region in the same subscription, ensure the following: the first Network module call creates the Network Watcher resources (default), and with subsequent module calls specify `create_network_watcher = false` and pass in the values `existing_network_watcher_rg_name` and `existing_network_watcher_name` from the first module.
  * In addition to the above, if you would like multiple vnets to send NSG Flow Logs to the same Storage Account rather than create a new storage account for each vnet, you can specify `create_nsg_flow_logs_storage_account = false` and pass the value `nsg_flow_logs_storage_account_id`. See *example_adv1* for example usage.

## Azure Bastion Host (Optional)
* To deploy an Azure Bastion Host, simply specify `create_bastion_host = true` and provide the subnet address space with `bas_subnet_address_prefix = ["x.x.x.x/27"]`. This will create the Bastion subnet, the NSG with required rule set, the Bastion host and Public IP for connecting.
* All attributes used to customize the Bastion Host are prefixed with *bas_*.

## Azure Firewall Premium (Optional)
* This module only supports the Firewall Premium sku.
* To deploy an Azure Firewall instance, specify `create_azure_firewall = true` and provide the subnet address space with `fw_subnet_address_prefix = ["x.x.x.x/26"]`. There are no other additional required variables. Refer to the **Input** table for default values of additional *Optional* arguments.
* All attributes used to customize the Firewall and optional Policy are prefixed with *fw_*.
* To route traffic to the Firewall, assign the Route Table to the subnet by specifying `fw_route = true` in the subnet attribute mapping.

### Firewall Policy (Optional)
* To create a Firewall Policy assigned to the created Firewall, specify `create_fw_policy = true`.
* You can use the [Azure Firewall Policy](https://app.terraform.io/app/ef-cloudops/registry/modules/private/ef-cloudops/azure-firewall-policy/azurerm) module to manage the Policy rules.
* To assign an existing Policy, such as one created by the [Azure Firewall Policy](https://app.terraform.io/app/ef-cloudops/registry/modules/private/ef-cloudops/azure-firewall-policy/azurerm) module, specify the existing Firewall Policy ID using the *fw_policy_id* attribute, for example: `fw_policy_id = module.azure_firewall_policy.policy_id`.
* Similar to the Firewall, all attributes used to customize the optional Policy are prefixed with *fw_*.

### AKS Egress Configuration (Optional)
This module can create a default AKS egress configuration to protect your AKS clusters, as documented here: [Control egress traffic for cluster nodes in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/limit-egress-traffic). Specifically, it uses the [AKS FQDN Tag](https://docs.microsoft.com/en-us/azure/aks/limit-egress-traffic#restrict-egress-traffic-using-azure-firewall), which contains all the required FQDNs and automatically keeps them up to date, in order to simplify the configuration.
* To deploy this AKS default configuration, specify `configure_fw_aks_egress = true`.
* Ensure you have a subnet created for AKS.
* You can assign the Firewall Route Table to the subnet by specifying `fw_route = true` in the subnet attribute mapping.
* This can be further customized using the attributes prefixed with *fw_aks_*.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | Address space of the Virtual Network. Defaults to 10.0.0.0/16. | `list(string)` | <pre>[<br>  "10.0.0.0/16"<br>]</pre> | no |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | The name of the application, workload, or service that the resource is a part of. Examples: navigator, emissions, sharepoint, hadoop. | `string` | n/a | yes |
| <a name="input_bas_name"></a> [bas\_name](#input\_bas\_name) | The name of the Azure Bastion Host. If no value is specified, one will be provided. | `string` | `""` | no |
| <a name="input_bas_pip_name"></a> [bas\_pip\_name](#input\_bas\_pip\_name) | The name of the Public IP resource of the Azure Bastion Host. If no value is specified, one will be provided. | `string` | `""` | no |
| <a name="input_bas_subnet_address_prefix"></a> [bas\_subnet\_address\_prefix](#input\_bas\_subnet\_address\_prefix) | The address prefix to use for the Bastion Host subnet. Must be at least /27 or larger. | `list(string)` | `[]` | no |
| <a name="input_configure_fw_aks_egress"></a> [configure\_fw\_aks\_egress](#input\_configure\_fw\_aks\_egress) | Whether or not to configure AKS egress resources. Resources created automatically include a Route Table with routes to the firewall & Internet, and default application and network rules as stated here: https://docs.microsoft.com/en-us/azure/aks/limit-egress-traffic. Defaults to false. | `bool` | `false` | no |
| <a name="input_create_azure_firewall"></a> [create\_azure\_firewall](#input\_create\_azure\_firewall) | Whether or not to create an Azure Firewall Premium instance. Defaults to false. | `bool` | `false` | no |
| <a name="input_create_bastion_host"></a> [create\_bastion\_host](#input\_create\_bastion\_host) | Whether or not to create an Azure Bastion Host instance with all prerequisite network resources. If set to true, the `bas_subnet_address_prefix` attribute must be specified. Defaults to false. | `bool` | `false` | no |
| <a name="input_create_ddos_plan"></a> [create\_ddos\_plan](#input\_create\_ddos\_plan) | Whether or not create a DDOS Protection Plan. Defaults to false. | `bool` | `false` | no |
| <a name="input_create_fw_policy"></a> [create\_fw\_policy](#input\_create\_fw\_policy) | Whether or not to create an Azure Firewall Policy instance for Firewall Manager. Defaults to false. | `bool` | `false` | no |
| <a name="input_create_fw_routing"></a> [create\_fw\_routing](#input\_create\_fw\_routing) | Whether or not to create routing resources to route traffic from a subnet to the firewall and Internet. Defaults to false. | `bool` | `false` | no |
| <a name="input_create_network_watcher"></a> [create\_network\_watcher](#input\_create\_network\_watcher) | Wether to create a Network Watcher and Resource Group. For scenarios where multiple Virtual Networks are deployed to both the same region and subscription, set this value to false on all subsequent module calls except the first one that initially creates the Network Watcher. See README for more info. Defaults to true. | `bool` | `true` | no |
| <a name="input_create_nsg_flow_logs_storage_account"></a> [create\_nsg\_flow\_logs\_storage\_account](#input\_create\_nsg\_flow\_logs\_storage\_account) | Whether to create a Storage Account to send NSG Flow Logs to. If false, you must specify the ID of an existing account using the `nsg_flow_logs_storage_account_id` argument. Defaults to true. | `bool` | `true` | no |
| <a name="input_ddos_plan_name"></a> [ddos\_plan\_name](#input\_ddos\_plan\_name) | The name of the DDOS Protection Plan. If no value is specified, one will be provided. | `string` | `""` | no |
| <a name="input_diag_logs_la_workspace_id"></a> [diag\_logs\_la\_workspace\_id](#input\_diag\_logs\_la\_workspace\_id) | The Workspace ID of the Log Analytics Workspace where diagnostics logs and NSG flow logs should be sent. | `string` | n/a | yes |
| <a name="input_diag_logs_la_workspace_location"></a> [diag\_logs\_la\_workspace\_location](#input\_diag\_logs\_la\_workspace\_location) | The Azure region of the Log Analytics Workspace where diagnostics logs and NSG flow logs should be sent. | `string` | n/a | yes |
| <a name="input_diag_logs_la_workspace_resource_id"></a> [diag\_logs\_la\_workspace\_resource\_id](#input\_diag\_logs\_la\_workspace\_resource\_id) | The ID of the Log Analytics Workspace where diagnostics logs and NSG flow logs should be sent. | `string` | n/a | yes |
| <a name="input_diag_logs_storage_account_id"></a> [diag\_logs\_storage\_account\_id](#input\_diag\_logs\_storage\_account\_id) | Specifies the ID of the Storage Account where Diagnostics Logs should be sent. By default, Diagnostics Logs are only sent to Azure Monitor via Log Analystics Workspace. | `string` | `""` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | DNS servers to be used with Virtual Network. If none specified, defaults to Azure DNS. | `list(string)` | `[]` | no |
| <a name="input_enable_fw_logging"></a> [enable\_fw\_logging](#input\_enable\_fw\_logging) | Whether or not to enable diagnostic logging on Azure Firewall. Defaults to true. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The stage of the development lifecycle for the workload that the resource supports. Examples: dev, test, uat, prod. | `string` | n/a | yes |
| <a name="input_eventhub_auth_rule_id"></a> [eventhub\_auth\_rule\_id](#input\_eventhub\_auth\_rule\_id) | The authorization rule ID of the Eventhub to send diagnostic logs to. By default, Diagnostics Logs are only sent to Azure Monitor via Log Analystics Workspace. | `string` | `""` | no |
| <a name="input_eventhub_name"></a> [eventhub\_name](#input\_eventhub\_name) | The name of the Eventhub to send diagnostic logs to. By default, Diagnostics Logs are only sent to Azure Monitor via Log Analystics Workspace. | `string` | `""` | no |
| <a name="input_existing_network_watcher_name"></a> [existing\_network\_watcher\_name](#input\_existing\_network\_watcher\_name) | The name of the existing Network Watcher. For scenarios where multiple Virtual Networks are deployed to the same region, specify this variable with the name from the first module call that initially creates the Network Watcher for the region and set variable `create_network_watcher` to false. | `string` | `""` | no |
| <a name="input_existing_network_watcher_rg_name"></a> [existing\_network\_watcher\_rg\_name](#input\_existing\_network\_watcher\_rg\_name) | The name of the Resource Group containing the existing Network Watcher. For scenarios where multiple Virtual Networks are deployed to the same region, specify this variable with the name from the first module call that initially creates the Network Watcher for the region and set variable `create_network_watcher` to false. | `string` | `""` | no |
| <a name="input_fw_additional_public_ips"></a> [fw\_additional\_public\_ips](#input\_fw\_additional\_public\_ips) | A list of additional Public IPs to attach to the firewall. | <pre>list(object({<br>    name                 = string,<br>    public_ip_address_id = string<br>  }))</pre> | `[]` | no |
| <a name="input_fw_aks_app_rule_coll_name"></a> [fw\_aks\_app\_rule\_coll\_name](#input\_fw\_aks\_app\_rule\_coll\_name) | The name of the AKS egress firewall Application Rule Collection. If no value is specified, one will be provided. | `string` | `""` | no |
| <a name="input_fw_aks_app_rule_fqdn_tag_name"></a> [fw\_aks\_app\_rule\_fqdn\_tag\_name](#input\_fw\_aks\_app\_rule\_fqdn\_tag\_name) | The name of the AKS egress firewall Application Rule with `AzureKubernetesService` tag. If no value is specified, one will be provided. | `string` | `""` | no |
| <a name="input_fw_aks_app_rule_name"></a> [fw\_aks\_app\_rule\_name](#input\_fw\_aks\_app\_rule\_name) | The name of the AKS egress firewall Application Rule. If no value is specified, one will be provided. | `string` | `""` | no |
| <a name="input_fw_aks_app_rule_priority"></a> [fw\_aks\_app\_rule\_priority](#input\_fw\_aks\_app\_rule\_priority) | The priority number of the AKS egress firewall Application Rule. Defaults to 300. | `number` | `300` | no |
| <a name="input_fw_aks_app_rule_protocols"></a> [fw\_aks\_app\_rule\_protocols](#input\_fw\_aks\_app\_rule\_protocols) | List of protocols for the AKS app rule collection. Defaults to the protocols listed here: https://docs.microsoft.com/en-us/azure/aks/limit-egress-traffic. | <pre>list(object({<br>    type = string,<br>    port = number<br>  }))</pre> | <pre>[<br>  {<br>    "port": 80,<br>    "type": "Http"<br>  },<br>  {<br>    "port": 443,<br>    "type": "Https"<br>  }<br>]</pre> | no |
| <a name="input_fw_aks_net_rule"></a> [fw\_aks\_net\_rule](#input\_fw\_aks\_net\_rule) | List of Network Rules for the AKS Network Rule Collection. `destination_addresses` defaults to [`AzureCloud.<var.location>`], to override this, enter a new value such as null. Defaults to the rules listed here: https://docs.microsoft.com/en-us/azure/aks/limit-egress-traffic. | `any` | <pre>[<br>  {<br>    "destination_ports": [<br>      "1194"<br>    ],<br>    "name": "fwnr-allow-apiudp",<br>    "protocols": [<br>      "UDP"<br>    ]<br>  },<br>  {<br>    "destination_ports": [<br>      "9000"<br>    ],<br>    "name": "fwnr-allow-apitcp",<br>    "protocols": [<br>      "TCP"<br>    ]<br>  },<br>  {<br>    "destination_addresses": null,<br>    "destination_fqdns": [<br>      "ntp.ubuntu.com"<br>    ],<br>    "destination_ports": [<br>      "123"<br>    ],<br>    "name": "fwnr-allow-time",<br>    "protocols": [<br>      "UDP"<br>    ]<br>  }<br>]</pre> | no |
| <a name="input_fw_aks_net_rule_coll_name"></a> [fw\_aks\_net\_rule\_coll\_name](#input\_fw\_aks\_net\_rule\_coll\_name) | The name of the AKS egress firewall Network Rule Collection. If no value is specified, one will be provided. | `string` | `""` | no |
| <a name="input_fw_aks_net_rule_priority"></a> [fw\_aks\_net\_rule\_priority](#input\_fw\_aks\_net\_rule\_priority) | The priority number of the AKS egress firewall Network Rule. Defaults to 200. | `number` | `200` | no |
| <a name="input_fw_aks_rule_coll_group_name"></a> [fw\_aks\_rule\_coll\_group\_name](#input\_fw\_aks\_rule\_coll\_group\_name) | The name of the AKS egress Firewall Rule Collection Group. If no value is specified, one will be provided. | `string` | `""` | no |
| <a name="input_fw_aks_rule_coll_group_priority"></a> [fw\_aks\_rule\_coll\_group\_priority](#input\_fw\_aks\_rule\_coll\_group\_priority) | The priority number for the AKS egress Rule Collection Group. Defaults to 100. | `number` | `100` | no |
| <a name="input_fw_availability_zones"></a> [fw\_availability\_zones](#input\_fw\_availability\_zones) | Specifies the availability zones in which the Azure Firewall should be created. Changing this forces a new resource to be created. | `list` | `[]` | no |
| <a name="input_fw_diag_logs_name"></a> [fw\_diag\_logs\_name](#input\_fw\_diag\_logs\_name) | The name of the firewall diagnostic logs. If no value is specified, one will be provided. | `string` | `""` | no |
| <a name="input_fw_diag_object"></a> [fw\_diag\_object](#input\_fw\_diag\_object) | Contains the diagnostics setting object. Defaults to all logs and metrics enabled with 30 days retention. Example:<br>  diag\_object = {<br>    log = [<br>      # ["Category name",  "Diagnostics Enabled(true/false)", Retention\_period(# of days)]<br>      ["AzureFirewallApplicationRule", true, 30],<br>      ["AzureFirewallNetworkRule", true, 30],<br>      ["AzureFirewallDnsProxy", true, 30]<br>    ]<br>    metric = [<br>      #["Category name",  "Diagnostics Enabled(true/false)", Retention\_period(# of days)]<br>      ["AllMetrics", true, 30]<br>    ]<br>  } | `map` | <pre>{<br>  "log": [<br>    [<br>      "AzureFirewallApplicationRule",<br>      true,<br>      30<br>    ],<br>    [<br>      "AzureFirewallNetworkRule",<br>      true,<br>      30<br>    ],<br>    [<br>      "AzureFirewallDnsProxy",<br>      true,<br>      30<br>    ]<br>  ],<br>  "metric": [<br>    [<br>      "AllMetrics",<br>      true,<br>      30<br>    ]<br>  ]<br>}</pre> | no |
| <a name="input_fw_dns_proxy_enabled"></a> [fw\_dns\_proxy\_enabled](#input\_fw\_dns\_proxy\_enabled) | Whether or not to enable DNS proxy on Firewalls attached to this Firewall Policy. If `configure_aks_egress` is set to true, this will also be set to true. Defaults to false. | `bool` | `false` | no |
| <a name="input_fw_dns_servers"></a> [fw\_dns\_servers](#input\_fw\_dns\_servers) | A list of DNS servers that the Azure Firewall will direct DNS traffic to for name resolution. If no value is specified, uses Azure DNS. | `list(string)` | `null` | no |
| <a name="input_fw_ip_config_name"></a> [fw\_ip\_config\_name](#input\_fw\_ip\_config\_name) | The name of the of firewall IP configuration. If no value is specified, one will be provided. | `string` | `""` | no |
| <a name="input_fw_name"></a> [fw\_name](#input\_fw\_name) | The name of the Azure Firewall. If no value is specified, one will be provided. | `string` | `""` | no |
| <a name="input_fw_parent_policy_id"></a> [fw\_parent\_policy\_id](#input\_fw\_parent\_policy\_id) | The ID of the base Firewall Policy. | `string` | `""` | no |
| <a name="input_fw_pip_name"></a> [fw\_pip\_name](#input\_fw\_pip\_name) | The name of the mandatory Azure Firewall Public IP. If no value is specified, one will be provided. | `string` | `""` | no |
| <a name="input_fw_policy_id"></a> [fw\_policy\_id](#input\_fw\_policy\_id) | The ID of an existing Firewall Policy created outside this module to be assigned to the Firewall and/or the AKS Rule Collection Group if enabled. Only one of `fw_policy_id` or `create_fw_policy` can be specified, not both. | `string` | `null` | no |
| <a name="input_fw_policy_name"></a> [fw\_policy\_name](#input\_fw\_policy\_name) | The name of the Azure Firewall Policy. If no value is specified, one will be provided. | `string` | `""` | no |
| <a name="input_fw_policy_threat_intel_mode"></a> [fw\_policy\_threat\_intel\_mode](#input\_fw\_policy\_threat\_intel\_mode) | The operation mode for threat intelligence-based filtering. Possible values are: Off, Alert, and Deny. Defaults to Alert. | `string` | `"Alert"` | no |
| <a name="input_fw_route_table_name"></a> [fw\_route\_table\_name](#input\_fw\_route\_table\_name) | The name of the firewall Route Table. If no value is specified, one will be provided. | `string` | `""` | no |
| <a name="input_fw_service_endpoints"></a> [fw\_service\_endpoints](#input\_fw\_service\_endpoints) | The list of service endpoints to associate with the Azure Firewall subnet. Possible values include: Microsoft.AzureActiveDirectory, Microsoft.AzureCosmosDB, Microsoft.ContainerRegistry, Microsoft.EventHub, Microsoft.KeyVault, Microsoft.ServiceBus, Microsoft.Sql, Microsoft.Storage and Microsoft.Web. | `list(string)` | `[]` | no |
| <a name="input_fw_sku_name"></a> [fw\_sku\_name](#input\_fw\_sku\_name) | The sku name of the Firewall. Possible values are AZFW\_Hub and AZFW\_VNet. Defaults to AZFW\_VNet. | `string` | `"AZFW_VNet"` | no |
| <a name="input_fw_subnet_address_prefix"></a> [fw\_subnet\_address\_prefix](#input\_fw\_subnet\_address\_prefix) | The address prefix to use for the Azure Firewall subnet. Should be a /26 subnet. | `list(string)` | `[]` | no |
| <a name="input_fw_threat_intel_allowlist_fqdns"></a> [fw\_threat\_intel\_allowlist\_fqdns](#input\_fw\_threat\_intel\_allowlist\_fqdns) | A list of FQDNs that will be skipped for threat detection. | `list` | `[]` | no |
| <a name="input_fw_threat_intel_allowlist_ip_addresses"></a> [fw\_threat\_intel\_allowlist\_ip\_addresses](#input\_fw\_threat\_intel\_allowlist\_ip\_addresses) | A list of IP addresses or IP address ranges that will be skipped for threat detection. | `list` | `[]` | no |
| <a name="input_fw_threat_intel_mode"></a> [fw\_threat\_intel\_mode](#input\_fw\_threat\_intel\_mode) | The operation mode for threat intelligence-based filtering. Possible values are: Off, Alert, and Deny. Defaults to Alert. | `string` | `"Alert"` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure Region where the Resource Group should exist in full format. Examples: eastus2, westeurope, southeastasia. Changing this forces a new Resource Group to be created. | `string` | n/a | yes |
| <a name="input_location_short"></a> [location\_short](#input\_location\_short) | The Azure Region where the Resource Group should exist, abbreviated. Examples: eus2, weu, sea. For standard abbreviations, see <insert link>. Changing this forces a new Resource Group to be created. | `string` | n/a | yes |
| <a name="input_network_watcher_name"></a> [network\_watcher\_name](#input\_network\_watcher\_name) | The name of the Network Watcher. If no value is specified, one will be provided using the Azure default naming convention: `NetworkWatcher_<region>`. | `string` | `""` | no |
| <a name="input_nsg_diag_log"></a> [nsg\_diag\_log](#input\_nsg\_diag\_log) | Contains the diagnostics setting object. Defaults to all logs enabled with 30 days retention. Example:<br>  diag\_object = {<br>    log = [<br>      # ["Category name",  "Diagnostics Enabled(true/false)", Retention\_period(# of days)]<br>      ["NetworkSecurityGroupEvent", true, 30],<br>      ["NetworkSecurityGroupRuleCounter", true, 30]<br>    ]<br>  } | `map` | <pre>{<br>  "log": [<br>    [<br>      "NetworkSecurityGroupEvent",<br>      true,<br>      30<br>    ],<br>    [<br>      "NetworkSecurityGroupRuleCounter",<br>      true,<br>      30<br>    ]<br>  ]<br>}</pre> | no |
| <a name="input_nsg_flow_logs_storage_account_id"></a> [nsg\_flow\_logs\_storage\_account\_id](#input\_nsg\_flow\_logs\_storage\_account\_id) | The ID of an existing Storage Account used for the NSG flow logs. If no value is specified, a new Storage Account will be created. | `string` | `""` | no |
| <a name="input_nsg_flow_logs_storage_account_name"></a> [nsg\_flow\_logs\_storage\_account\_name](#input\_nsg\_flow\_logs\_storage\_account\_name) | The name of the Storage Account created by this module that will be used for the NSG Flow Logs. If no value is specified, one will be provided. | `string` | `""` | no |
| <a name="input_policy_tags"></a> [policy\_tags](#input\_policy\_tags) | A mapping of tags which should be assigned to the Firewall Policy. The key of policy tags must be lowercase due to a bug in the Azure API: https://github.com/terraform-providers/terraform-provider-azurerm/issues/9620 | `map(string)` | `{}` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the Resource Group resources will be deployed into. If no value is specified, one will be provided. | `string` | `""` | no |
| <a name="input_subnet_enforce_private_link_endpoint_network_policies"></a> [subnet\_enforce\_private\_link\_endpoint\_network\_policies](#input\_subnet\_enforce\_private\_link\_endpoint\_network\_policies) | A mapping of subnet name to enable/disable private link endpoint network policies on the subnet. | `map(bool)` | `{}` | no |
| <a name="input_subnet_enforce_private_link_service_network_policies"></a> [subnet\_enforce\_private\_link\_service\_network\_policies](#input\_subnet\_enforce\_private\_link\_service\_network\_policies) | A mapping of subnet name to enable/disable private link service network policies on the subnet. | `map(bool)` | `{}` | no |
| <a name="input_subnet_service_endpoints"></a> [subnet\_service\_endpoints](#input\_subnet\_service\_endpoints) | A mapping of subnet name to service endpoints to add to the subnet. | `map(any)` | `{}` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | A mapping of subnet names in the Virtual Network. By default, subnets will be associated with a Network Security Group (NSG). To create a subnet without an NSG, specify `nsg = false`. Any rules specified for the NSG will be in addition to the default rules. | `map` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags which should be assigned to all resources (except the Firewall Policy. See `policy_tags`.). | `map(string)` | `{}` | no |
| <a name="input_vnet_diag_object"></a> [vnet\_diag\_object](#input\_vnet\_diag\_object) | Contains the diagnostics setting object. Defaults to all logs and metrics enabled with 30 days retention. Example:<br>  diag\_object = {<br>    log = [<br>      # ["Category name",  "Diagnostics Enabled(true/false)", Retention\_period(# of days)]<br>      ["VMProtectionAlerts", true, 30],<br>    ]<br>    metric = [<br>      #["Category name",  "Diagnostics Enabled(true/false)", Retention\_period(# of days)]<br>      ["AllMetrics", true, 30]<br>    ]<br>  } | `map` | <pre>{<br>  "log": [<br>    [<br>      "VMProtectionAlerts",<br>      true,<br>      30<br>    ]<br>  ],<br>  "metric": [<br>    [<br>      "AllMetrics",<br>      true,<br>      30<br>    ]<br>  ]<br>}</pre> | no |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | The name of the Virtual Network. If no value is specified, one will be provided. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bas_host_fqdn"></a> [bas\_host\_fqdn](#output\_bas\_host\_fqdn) | The FQDN of the Azure Bastion host. |
| <a name="output_bas_host_id"></a> [bas\_host\_id](#output\_bas\_host\_id) | The ID of the Azure Bastion host. |
| <a name="output_bas_nsg_id"></a> [bas\_nsg\_id](#output\_bas\_nsg\_id) | The ID of the Azure Bastion NSG. |
| <a name="output_bas_nsg_name"></a> [bas\_nsg\_name](#output\_bas\_nsg\_name) | The name of the Azure Bastion NSG. |
| <a name="output_bas_public_ip_address"></a> [bas\_public\_ip\_address](#output\_bas\_public\_ip\_address) | The public IP address of the Azure Bastion host. |
| <a name="output_bas_subnet_address_prefix"></a> [bas\_subnet\_address\_prefix](#output\_bas\_subnet\_address\_prefix) | The subnet address prefix of the Azure Bastion subnet. |
| <a name="output_bas_subnet_id"></a> [bas\_subnet\_id](#output\_bas\_subnet\_id) | The ID of the Azure Bastion subnet. |
| <a name="output_bas_subnet_name"></a> [bas\_subnet\_name](#output\_bas\_subnet\_name) | The name of the Azure Bastion subnet. |
| <a name="output_ddos_plan_id"></a> [ddos\_plan\_id](#output\_ddos\_plan\_id) | The ID of the DDoS Protection Plan. |
| <a name="output_ddos_plan_name"></a> [ddos\_plan\_name](#output\_ddos\_plan\_name) | The name of the DDoS Protection Plan. |
| <a name="output_fw_aks_policy_rule_coll_group_id"></a> [fw\_aks\_policy\_rule\_coll\_group\_id](#output\_fw\_aks\_policy\_rule\_coll\_group\_id) | The ID of the Azure Firewall Policy Rule Collection Group for AKS egress. |
| <a name="output_fw_id"></a> [fw\_id](#output\_fw\_id) | The ID of the Azure Firewall. |
| <a name="output_fw_name"></a> [fw\_name](#output\_fw\_name) | The name of the Azure Firewall. |
| <a name="output_fw_policy_id"></a> [fw\_policy\_id](#output\_fw\_policy\_id) | The ID of the Azure Firewall Policy. |
| <a name="output_fw_policy_name"></a> [fw\_policy\_name](#output\_fw\_policy\_name) | The name of the Azure Firewall Policy. |
| <a name="output_fw_private_ip_address"></a> [fw\_private\_ip\_address](#output\_fw\_private\_ip\_address) | The private IP Address of the Azure Firewall. |
| <a name="output_fw_public_ip_address"></a> [fw\_public\_ip\_address](#output\_fw\_public\_ip\_address) | The public IP Address of the Azure Firewall. |
| <a name="output_fw_route_table_id"></a> [fw\_route\_table\_id](#output\_fw\_route\_table\_id) | The ID of the firewall Route Table. |
| <a name="output_fw_route_table_name"></a> [fw\_route\_table\_name](#output\_fw\_route\_table\_name) | The name of the firewall Route Table. |
| <a name="output_fw_subnet_address_prefix"></a> [fw\_subnet\_address\_prefix](#output\_fw\_subnet\_address\_prefix) | The subnet address prefix of the Azure Firewall subnet. |
| <a name="output_fw_subnet_id"></a> [fw\_subnet\_id](#output\_fw\_subnet\_id) | The ID of the Azure Firewall subnet. |
| <a name="output_fw_subnet_name"></a> [fw\_subnet\_name](#output\_fw\_subnet\_name) | The name of the Azure Firewall subnet. |
| <a name="output_network_watcher_id"></a> [network\_watcher\_id](#output\_network\_watcher\_id) | The ID of the Network Watcher. |
| <a name="output_network_watcher_name"></a> [network\_watcher\_name](#output\_network\_watcher\_name) | The name of the Network Watcher. |
| <a name="output_network_watcher_rg_id"></a> [network\_watcher\_rg\_id](#output\_network\_watcher\_rg\_id) | The ID of the Resource Group containing the Network Watcher. |
| <a name="output_network_watcher_rg_name"></a> [network\_watcher\_rg\_name](#output\_network\_watcher\_rg\_name) | The name of the Resource Group containing the Network Watcher. |
| <a name="output_nsg_flow_logs_storage_account_id"></a> [nsg\_flow\_logs\_storage\_account\_id](#output\_nsg\_flow\_logs\_storage\_account\_id) | The ID of the Storage Account created by this module used for sending NSG flow logs to. |
| <a name="output_nsg_ids"></a> [nsg\_ids](#output\_nsg\_ids) | The IDs of the NSGs. |
| <a name="output_nsg_names"></a> [nsg\_names](#output\_nsg\_names) | The names of the NSGs. |
| <a name="output_rg_id"></a> [rg\_id](#output\_rg\_id) | The ID of the Resource Group. |
| <a name="output_rg_location"></a> [rg\_location](#output\_rg\_location) | The location of the Resource Group. |
| <a name="output_rg_name"></a> [rg\_name](#output\_rg\_name) | The name of the Resource Group. |
| <a name="output_subnet_address_prefixes"></a> [subnet\_address\_prefixes](#output\_subnet\_address\_prefixes) | The address prefixes of the subnets in the vnet. |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | The IDs of the subnets in the vnet. |
| <a name="output_subnet_names"></a> [subnet\_names](#output\_subnet\_names) | The names of the subnets in the vnet. |
| <a name="output_vnet_address_space"></a> [vnet\_address\_space](#output\_vnet\_address\_space) | The address space of the vnet. |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | The ID of the vnet. |
| <a name="output_vnet_name"></a> [vnet\_name](#output\_vnet\_name) | The name of the vnet. |
<!-- END_TF_DOCS -->