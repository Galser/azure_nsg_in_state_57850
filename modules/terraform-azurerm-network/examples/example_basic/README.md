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