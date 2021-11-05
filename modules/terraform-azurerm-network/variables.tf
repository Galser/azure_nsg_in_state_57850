// Common

variable "environment" {
  type        = string
  description = "The stage of the development lifecycle for the workload that the resource supports. Examples: dev, test, uat, prod."
}

variable "location" {
  type        = string
  description = "The Azure Region where the Resource Group should exist in full format. Examples: eastus2, westeurope, southeastasia. Changing this forces a new Resource Group to be created."
}

variable "location_short" {
  type        = string
  description = "The Azure Region where the Resource Group should exist, abbreviated. Examples: eus2, weu, sea. For standard abbreviations, see <insert link>. Changing this forces a new Resource Group to be created."
}

variable "resource_group_name" {
  type        = string
  default     = ""
  description = "The name of the Resource Group resources will be deployed into. If no value is specified, one will be provided."
}

variable "app_name" {
  type        = string
  description = "The name of the application, workload, or service that the resource is a part of. Examples: navigator, emissions, sharepoint, hadoop."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags which should be assigned to all resources (except the Firewall Policy. See `policy_tags`.)."
}

variable "policy_tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags which should be assigned to the Firewall Policy. The key of policy tags must be lowercase due to a bug in the Azure API: https://github.com/terraform-providers/terraform-provider-azurerm/issues/9620"
}

/*variable "diag_logs_la_workspace_id" {
  type        = string
  description = "The Workspace ID of the Log Analytics Workspace where diagnostics logs and NSG flow logs should be sent."
}

variable "diag_logs_la_workspace_location" {
  type        = string
  description = "The Azure region of the Log Analytics Workspace where diagnostics logs and NSG flow logs should be sent."
}

variable "diag_logs_la_workspace_resource_id" {
  type        = string
  description = "The ID of the Log Analytics Workspace where diagnostics logs and NSG flow logs should be sent."
}
*/

// Virtual Network

variable "vnet_name" {
  type        = string
  default     = ""
  description = "The name of the Virtual Network. If no value is specified, one will be provided."
}

variable "create_network_watcher" {
  type        = bool
  default     = true
  description = "Wether to create a Network Watcher and Resource Group. For scenarios where multiple Virtual Networks are deployed to both the same region and subscription, set this value to false on all subsequent module calls except the first one that initially creates the Network Watcher. See README for more info. Defaults to true."
}

variable "network_watcher_name" {
  type        = string
  default     = ""
  description = "The name of the Network Watcher. If no value is specified, one will be provided using the Azure default naming convention: `NetworkWatcher_<region>`."
}

variable "existing_network_watcher_rg_name" {
  type        = string
  default     = ""
  description = "The name of the Resource Group containing the existing Network Watcher. For scenarios where multiple Virtual Networks are deployed to the same region, specify this variable with the name from the first module call that initially creates the Network Watcher for the region and set variable `create_network_watcher` to false."
}

variable "existing_network_watcher_name" {
  type        = string
  default     = ""
  description = "The name of the existing Network Watcher. For scenarios where multiple Virtual Networks are deployed to the same region, specify this variable with the name from the first module call that initially creates the Network Watcher for the region and set variable `create_network_watcher` to false."
}

variable "address_space" {
  type        = list(string)
  default     = ["10.0.0.0/16"]
  description = "Address space of the Virtual Network. Defaults to 10.0.0.0/16."
}

variable "dns_servers" {
  type        = list(string)
  default     = []
  description = "DNS servers to be used with Virtual Network. If none specified, defaults to Azure DNS."
}

variable "create_ddos_plan" {
  type        = bool
  default     = false
  description = "Whether or not create a DDOS Protection Plan. Defaults to false."
}

variable "ddos_plan_name" {
  type        = string
  default     = ""
  description = "The name of the DDOS Protection Plan. If no value is specified, one will be provided."
}

variable "subnets" {
  default     = {}
  description = "A mapping of subnet names in the Virtual Network. By default, subnets will be associated with a Network Security Group (NSG). To create a subnet without an NSG, specify `nsg = false`. Any rules specified for the NSG will be in addition to the default rules."
}

variable "subnet_service_endpoints" {
  type        = map(any)
  default     = {}
  description = "A mapping of subnet name to service endpoints to add to the subnet."
}

variable "subnet_enforce_private_link_endpoint_network_policies" {
  type        = map(bool)
  default     = {}
  description = "A mapping of subnet name to enable/disable private link endpoint network policies on the subnet."
}

variable "subnet_enforce_private_link_service_network_policies" {
  type        = map(bool)
  default     = {}
  description = "A mapping of subnet name to enable/disable private link service network policies on the subnet."
}


// Bastion

variable "create_bastion_host" {
  type        = bool
  default     = false
  description = "Whether or not to create an Azure Bastion Host instance with all prerequisite network resources. If set to true, the `bas_subnet_address_prefix` attribute must be specified. Defaults to false."
}

variable "bas_name" {
  type        = string
  default     = ""
  description = "The name of the Azure Bastion Host. If no value is specified, one will be provided."
}

variable "bas_pip_name" {
  type        = string
  default     = ""
  description = "The name of the Public IP resource of the Azure Bastion Host. If no value is specified, one will be provided."
}

variable "bas_subnet_address_prefix" {
  type        = list(string)
  default     = []
  description = "The address prefix to use for the Bastion Host subnet. Must be at least /27 or larger."
}


// Azure Firewall

variable "create_azure_firewall" {
  type        = bool
  default     = false
  description = "Whether or not to create an Azure Firewall Premium instance. Defaults to false."
}

variable "fw_name" {
  type        = string
  default     = ""
  description = "The name of the Azure Firewall. If no value is specified, one will be provided."
}

variable "fw_service_endpoints" {
  type        = list(string)
  default     = []
  description = "The list of service endpoints to associate with the Azure Firewall subnet. Possible values include: Microsoft.AzureActiveDirectory, Microsoft.AzureCosmosDB, Microsoft.ContainerRegistry, Microsoft.EventHub, Microsoft.KeyVault, Microsoft.ServiceBus, Microsoft.Sql, Microsoft.Storage and Microsoft.Web."
}

variable "fw_subnet_address_prefix" {
  type        = list(string)
  default     = []
  description = "The address prefix to use for the Azure Firewall subnet. Should be a /26 subnet."
}

variable "fw_sku_name" {
  type        = string
  default     = "AZFW_VNet"
  description = "The sku name of the Firewall. Possible values are AZFW_Hub and AZFW_VNet. Defaults to AZFW_VNet."
}

variable "fw_dns_servers" {
  type        = list(string)
  default     = null
  description = "A list of DNS servers that the Azure Firewall will direct DNS traffic to for name resolution. If no value is specified, uses Azure DNS."
}

variable "fw_threat_intel_mode" {
  type        = string
  default     = "Alert"
  description = "The operation mode for threat intelligence-based filtering. Possible values are: Off, Alert, and Deny. Defaults to Alert."
}

variable "fw_availability_zones" {
  default     = []
  description = "Specifies the availability zones in which the Azure Firewall should be created. Changing this forces a new resource to be created."
}

variable "fw_pip_name" {
  type        = string
  default     = ""
  description = "The name of the mandatory Azure Firewall Public IP. If no value is specified, one will be provided."
}

variable "fw_additional_public_ips" {
  type = list(object({
    name                 = string,
    public_ip_address_id = string
  }))
  default     = []
  description = "A list of additional Public IPs to attach to the firewall."
}

variable "fw_ip_config_name" {
  type        = string
  default     = ""
  description = "The name of the of firewall IP configuration. If no value is specified, one will be provided."
}


// Firewall Policy

variable "create_fw_policy" {
  type        = bool
  default     = false
  description = "Whether or not to create an Azure Firewall Policy instance for Firewall Manager. Defaults to false."
}

variable "fw_policy_id" {
  type        = string
  default     = null
  description = "The ID of an existing Firewall Policy created outside this module to be assigned to the Firewall and/or the AKS Rule Collection Group if enabled. Only one of `fw_policy_id` or `create_fw_policy` can be specified, not both."
}

variable "fw_policy_name" {
  type        = string
  default     = ""
  description = "The name of the Azure Firewall Policy. If no value is specified, one will be provided."
}

variable "fw_parent_policy_id" {
  type        = string
  default     = ""
  description = "The ID of the base Firewall Policy."
}

variable "fw_dns_proxy_enabled" {
  type        = bool
  default     = false
  description = "Whether or not to enable DNS proxy on Firewalls attached to this Firewall Policy. If `configure_aks_egress` is set to true, this will also be set to true. Defaults to false."
}

variable "fw_policy_threat_intel_mode" {
  type        = string
  default     = "Alert"
  description = "The operation mode for threat intelligence-based filtering. Possible values are: Off, Alert, and Deny. Defaults to Alert."
}

variable "fw_threat_intel_allowlist_ip_addresses" {
  type        = list(any)
  default     = []
  description = "A list of IP addresses or IP address ranges that will be skipped for threat detection."
}

variable "fw_threat_intel_allowlist_fqdns" {
  type        = list(any)
  default     = []
  description = "A list of FQDNs that will be skipped for threat detection."
}


// Firewall AKS Egress

variable "configure_fw_aks_egress" {
  type        = bool
  default     = false
  description = "Whether or not to configure AKS egress resources. Resources created automatically include a Route Table with routes to the firewall & Internet, and default application and network rules as stated here: https://docs.microsoft.com/en-us/azure/aks/limit-egress-traffic. Defaults to false."
}

variable "fw_aks_rule_coll_group_name" {
  type        = string
  default     = ""
  description = "The name of the AKS egress Firewall Rule Collection Group. If no value is specified, one will be provided."
}

variable "fw_aks_rule_coll_group_priority" {
  type        = number
  default     = 100
  description = "The priority number for the AKS egress Rule Collection Group. Defaults to 100."
}

variable "fw_aks_app_rule_coll_name" {
  type        = string
  default     = ""
  description = "The name of the AKS egress firewall Application Rule Collection. If no value is specified, one will be provided."
}

variable "fw_aks_app_rule_name" {
  type        = string
  default     = ""
  description = "The name of the AKS egress firewall Application Rule. If no value is specified, one will be provided."
}

variable "fw_aks_app_rule_protocols" {
  type = list(object({
    type = string,
    port = number
  }))
  default = [
    {
      type = "Http"
      port = 80
    },
    {
      type = "Https"
      port = 443
    }
  ]
  description = "List of protocols for the AKS app rule collection. Defaults to the protocols listed here: https://docs.microsoft.com/en-us/azure/aks/limit-egress-traffic."
}

variable "fw_aks_net_rule" {
  type = any
  default = [
    {
      name              = "fwnr-allow-apiudp"
      protocols         = ["UDP"]
      destination_ports = ["1194"]
    },
    {
      name              = "fwnr-allow-apitcp"
      protocols         = ["TCP"]
      destination_ports = ["9000"]
    },
    {
      name                  = "fwnr-allow-time"
      protocols             = ["UDP"]
      destination_addresses = null
      destination_fqdns     = ["ntp.ubuntu.com"]
      destination_ports     = ["123"]
    }
  ]
  description = "List of Network Rules for the AKS Network Rule Collection. `destination_addresses` defaults to [`AzureCloud.<var.location>`], to override this, enter a new value such as null. Defaults to the rules listed here: https://docs.microsoft.com/en-us/azure/aks/limit-egress-traffic."
}

variable "fw_aks_app_rule_fqdn_tag_name" {
  type        = string
  default     = ""
  description = "The name of the AKS egress firewall Application Rule with `AzureKubernetesService` tag. If no value is specified, one will be provided."
}

variable "fw_aks_app_rule_priority" {
  type        = number
  default     = 300
  description = "The priority number of the AKS egress firewall Application Rule. Defaults to 300."
}

variable "fw_aks_net_rule_coll_name" {
  type        = string
  default     = ""
  description = "The name of the AKS egress firewall Network Rule Collection. If no value is specified, one will be provided."
}

variable "fw_aks_net_rule_priority" {
  type        = number
  default     = 200
  description = "The priority number of the AKS egress firewall Network Rule. Defaults to 200."
}


// Firewall Routing

variable "create_fw_routing" {
  type        = bool
  default     = false
  description = "Whether or not to create routing resources to route traffic from a subnet to the firewall and Internet. Defaults to false."
}

variable "fw_route_table_name" {
  type        = string
  default     = ""
  description = "The name of the firewall Route Table. If no value is specified, one will be provided."
}


// Vnet Logging

variable "create_nsg_flow_logs_storage_account" {
  type        = bool
  default     = true
  description = "Whether to create a Storage Account to send NSG Flow Logs to. If false, you must specify the ID of an existing account using the `nsg_flow_logs_storage_account_id` argument. Defaults to true."
}

variable "nsg_flow_logs_storage_account_name" {
  type        = string
  default     = ""
  description = "The name of the Storage Account created by this module that will be used for the NSG Flow Logs. If no value is specified, one will be provided."
}

variable "nsg_flow_logs_storage_account_id" {
  type        = string
  default     = ""
  description = "The ID of an existing Storage Account used for the NSG flow logs. If no value is specified, a new Storage Account will be created."
}

variable "vnet_diag_object" {
  default = {
    log = [
      # ["Category name",  "Diagnostics Enabled(true/false)", Retention_period(# of days)]
      ["VMProtectionAlerts", true, 30],
    ]
    metric = [
      #["Category name",  "Diagnostics Enabled(true/false)", Retention_period(# of days)]
      ["AllMetrics", true, 30],
    ]
  }
  description = <<EOD
  Contains the diagnostics setting object. Defaults to all logs and metrics enabled with 30 days retention. Example:
  diag_object = {
    log = [
      # ["Category name",  "Diagnostics Enabled(true/false)", Retention_period(# of days)]
      ["VMProtectionAlerts", true, 30],
    ]
    metric = [
      #["Category name",  "Diagnostics Enabled(true/false)", Retention_period(# of days)]
      ["AllMetrics", true, 30]
    ]
  }
  EOD
}

variable "diag_logs_storage_account_id" {
  type        = string
  default     = ""
  description = "Specifies the ID of the Storage Account where Diagnostics Logs should be sent. By default, Diagnostics Logs are only sent to Azure Monitor via Log Analystics Workspace."
}

variable "eventhub_auth_rule_id" {
  type        = string
  default     = ""
  description = "The authorization rule ID of the Eventhub to send diagnostic logs to. By default, Diagnostics Logs are only sent to Azure Monitor via Log Analystics Workspace."
}

variable "eventhub_name" {
  type        = string
  default     = ""
  description = "The name of the Eventhub to send diagnostic logs to. By default, Diagnostics Logs are only sent to Azure Monitor via Log Analystics Workspace."
}

variable "nsg_diag_log" {
  default = {
    log = [
      # ["Category name",  "Diagnostics Enabled(true/false)", Retention_period(# of days)]
      ["NetworkSecurityGroupEvent", true, 30],
      ["NetworkSecurityGroupRuleCounter", true, 30]
    ]
  }
  description = <<EOD
  Contains the diagnostics setting object. Defaults to all logs enabled with 30 days retention. Example:
  diag_object = {
    log = [
      # ["Category name",  "Diagnostics Enabled(true/false)", Retention_period(# of days)]
      ["NetworkSecurityGroupEvent", true, 30],
      ["NetworkSecurityGroupRuleCounter", true, 30]
    ]
  }
  EOD
}


// Firewall Logging

variable "enable_fw_logging" {
  type        = bool
  default     = true
  description = "Whether or not to enable diagnostic logging on Azure Firewall. Defaults to true."
}

variable "fw_diag_logs_name" {
  type        = string
  default     = ""
  description = "The name of the firewall diagnostic logs. If no value is specified, one will be provided."
}

variable "fw_diag_object" {
  default = {
    log = [
      # ["Category name",  "Diagnostics Enabled(true/false)", Retention_period(# of days)]
      ["AzureFirewallApplicationRule", true, 30],
      ["AzureFirewallNetworkRule", true, 30],
      ["AzureFirewallDnsProxy", true, 30]
    ]
    metric = [
      #["Category name",  "Diagnostics Enabled(true/false)", Retention_period(# of days)]
      ["AllMetrics", true, 30]
    ]
  }
  description = <<EOD
  Contains the diagnostics setting object. Defaults to all logs and metrics enabled with 30 days retention. Example:
  diag_object = {
    log = [
      # ["Category name",  "Diagnostics Enabled(true/false)", Retention_period(# of days)]
      ["AzureFirewallApplicationRule", true, 30],
      ["AzureFirewallNetworkRule", true, 30],
      ["AzureFirewallDnsProxy", true, 30]
    ]
    metric = [
      #["Category name",  "Diagnostics Enabled(true/false)", Retention_period(# of days)]
      ["AllMetrics", true, 30]
    ]
  }
  EOD
}