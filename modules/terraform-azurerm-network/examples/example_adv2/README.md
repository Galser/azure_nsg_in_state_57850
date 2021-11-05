## Network Example Deployment - Basic
This example creates a virtual network with 1 subnet with NSG and NSG rule set, 1 subnet with no NSG and service delegation, & custom vnet diagnostic settings.

```hcl
# Create management plane resources using the mgmt-security module
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

  subnets = {
    // By default, an NSG will be created for this subnet
    snet_example1 = {
      subnet_name           = "snet-example1"
      subnet_address_prefix = ["10.0.2.0/25"]
      nsg_rule = [
        {
          name                         = "ALLOW-Rdp-In"
          description                  = "Allow RDP in for Jane Doe and John Doe from home"
          priority                     = "100"
          direction                    = "Inbound"
          access                       = "Allow"
          protocol                     = "Tcp"
          source_port_range            = "*"
          destination_port_range       = "3389"
          source_address_prefixes      = ["93.192.47.94/32","93.192.47.95/32"]
          destination_address_prefix   = "*"
        },
        {
          name                         = "ALLOW-TEMP-All-In-From-EHAD"
          description                  = "Allow all traffic inbound from EHAD for testing"
          priority                     = "110"
          direction                    = "Inbound"
          access                       = "Allow"
          protocol                     = "*"
          source_port_range            = "*"
          destination_port_range       = "*"
          source_address_prefix        = "212.98.85.164/32"
          destination_address_prefix   = "*"
        }
      ]
    }
    
    // This subnet will be created without an NSG
    snet_example2 = {
      subnet_name           = "snet-example2"
      subnet_address_prefix = ["10.0.2.128/25"]
      nsg                   = false
      delegation            = {
        name               = "example-delegation"
        service_delegation = {
          name    = "Microsoft.ContainerInstance/containerGroups"
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
        }
      }
    }
  }

  vnet_diag_object = {
    log = [
      # ["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period(# of days)]
      ["VMProtectionAlerts", true, true, 90],
    ]
    metric = [
      #["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period]
      ["AllMetrics", true, false, null],
    ]
  }

  diag_logs_la_workspace_resource_id = module.mgmt_security.ops_log_analytics_workspace_resource_id  // Required for diag logs and nsg flow log traffic analytics
  diag_logs_la_workspace_id          = module.mgmt_security.ops_log_analytics_workspace_id   // Required for nsg flow log traffic analytics
  diag_logs_la_workspace_location    = module.mgmt_security.ops_log_analytics_location   // Required for nsg flow log traffic analytics
}
```