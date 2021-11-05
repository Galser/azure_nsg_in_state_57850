## Network Example Deployment - Advanced 1
This example creates a virtual network with a subnet with an NSG, an Azure Bastion host, an Azure Firewall Premium instance with a Firewall Policy and AKS egress configuration, and custom tagging. Additionally, it demonstrates how to make subsequent module calls when multiple vnets are being deployed to the same region.

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

  create_bastion_host       = true
  bas_subnet_address_prefix = ["10.0.1.32/27"]
  create_azure_firewall     = true
  fw_subnet_address_prefix  = ["10.0.1.64/26"]
  create_fw_policy          = true
  configure_fw_aks_egress   = true

  // Unless otherwise specified, NSGs will be created and associated for all subnets configured here
  subnets = {
    snet-example = {
      subnet_name           = "snet-example"
      subnet_address_prefix = ["10.0.1.128/25"]
    }
    aks_subnet = {
      subnet_name           = "snet-aks-dev-weu-001"
      subnet_address_prefix = ["10.0.2.0/24"]
      fw_route              = true
      nsg                   = false
    }
  }

  tags = {
    BusinessUnit = "it"
    CostCenter   = "example"
    Environment  = "dev"
    DeployedBy   = "terraform"
  }

  // Tag keys assigned to the Firewall Policy must be in all lowercase due to Azure API bug.
  policy_tags = {
    businessunit = "it"
    costcenter   = "example"
    environment  = "dev"
    deployedby   = "terraform"
  }

  diag_logs_la_workspace_resource_id = module.mgmt_security.ops_log_analytics_workspace_resource_id  // Required for diag logs and nsg flow log traffic analytics
  diag_logs_la_workspace_id          = module.mgmt_security.ops_log_analytics_workspace_id   // Required for nsg flow log traffic analytics
  diag_logs_la_workspace_location    = module.mgmt_security.ops_log_analytics_location   // Required for nsg flow log traffic analytics
}

module "network_2" {
  source  = "app.terraform.io/ef-cloudops/network/azurerm"
  version = "x.x.x"

  environment    = "test"
  location       = "westeurope"
  location_short = "weu"   // for resource naming conventions when custom names are not defined with variables
  app_name       = "example"
  address_space  = ["10.1.1.0/23"]

  // Network Watcher resources are per region. If deploying multiple vnets to the same region, pass these values from the first Network module call into any subsequent call
  create_network_watcher               = false
  existing_network_watcher_rg_name     = module.network.network_watcher_rg_name
  existing_network_watcher_name        = module.network.network_watcher_name

  // This module creates a Storage Account per vnet to send NSG Flow Logs to by default. To use the same Storage Account, pass these values from the first module call
  create_nsg_flow_logs_storage_account = false
  nsg_flow_logs_storage_account_id     = module.network.nsg_flow_logs_storage_account_id

  tags = {
    BusinessUnit = "it"
    CostCenter   = "example"
    Environment  = "dev"
    DeployedBy   = "terraform"
  }

  diag_logs_la_workspace_id          = module.mgmt_security.ops_log_analytics_workspace_id   // workspace ID needed for nsg flow log traffic analytics
  diag_logs_la_workspace_location    = module.mgmt_security.ops_log_analytics_location   // location value needed for nsg flow log traffic analytics
  diag_logs_la_workspace_resource_id = module.mgmt_security.ops_log_analytics_workspace_resource_id
}
```
