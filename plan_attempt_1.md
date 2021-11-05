## Attempt to plan

```
 terraform plan
module.network.azurerm_resource_group.network_rg: Refreshing state... [id=/subscriptions/02d0e06b-ed9d-4ca5-bb9f-0a0243a9c9f2/resourceGroups/rg-vnet-testapp-test-weu-001]
module.network.azurerm_network_security_group.nsg["subnet_1"]: Refreshing state... [id=/subscriptions/02d0e06b-ed9d-4ca5-bb9f-0a0243a9c9f2/resourceGroups/rg-vnet-testapp-test-weu-001/providers/Microsoft.Network/networkSecurityGroups/nsg-snet-test-001]
module.network.azurerm_virtual_network.vnet: Refreshing state... [id=/subscriptions/02d0e06b-ed9d-4ca5-bb9f-0a0243a9c9f2/resourceGroups/rg-vnet-testapp-test-weu-001/providers/Microsoft.Network/virtualNetworks/vnet-testapp-test-weu-001]
module.network.azurerm_subnet.subnet["subnet_1"]: Refreshing state... [id=/subscriptions/02d0e06b-ed9d-4ca5-bb9f-0a0243a9c9f2/resourceGroups/rg-vnet-testapp-test-weu-001/providers/Microsoft.Network/virtualNetworks/vnet-testapp-test-weu-001/subnets/snet-test-001]
module.network.azurerm_subnet_network_security_group_association.nsg_assoc["subnet_1"]: Refreshing state... [id=/subscriptions/02d0e06b-ed9d-4ca5-bb9f-0a0243a9c9f2/resourceGroups/rg-vnet-testapp-test-weu-001/providers/Microsoft.Network/virtualNetworks/vnet-testapp-test-weu-001/subnets/snet-test-001]

Note: Objects have changed outside of Terraform

Terraform detected the following changes made outside of Terraform since the last "terraform apply":

  # module.network.azurerm_virtual_network.vnet has been changed
  ~ resource "azurerm_virtual_network" "vnet" {
        id                    = "/subscriptions/02d0e06b-ed9d-4ca5-bb9f-0a0243a9c9f2/resourceGroups/rg-vnet-testapp-test-weu-001/providers/Microsoft.Network/virtualNetworks/vnet-testapp-test-weu-001"
        name                  = "vnet-testapp-test-weu-001"
      ~ subnet                = [
          + {
              + address_prefix = "10.73.1.0/24"
              + id             = "/subscriptions/02d0e06b-ed9d-4ca5-bb9f-0a0243a9c9f2/resourceGroups/rg-vnet-testapp-test-weu-001/providers/Microsoft.Network/virtualNetworks/vnet-testapp-test-weu-001/subnets/snet-test-001"
              + name           = "snet-test-001"
              + security_group = "/subscriptions/02d0e06b-ed9d-4ca5-bb9f-0a0243a9c9f2/resourceGroups/rg-vnet-testapp-test-weu-001/providers/Microsoft.Network/networkSecurityGroups/nsg-snet-test-001"
            },
        ]
        tags                  = {
            "CreationDate" = "2021-11-05T13:16:36Z"
        }
        # (6 unchanged attributes hidden)
    }
  # module.network.azurerm_subnet.subnet["subnet_1"] has been changed
  ~ resource "azurerm_subnet" "subnet" {
        id                                             = "/subscriptions/02d0e06b-ed9d-4ca5-bb9f-0a0243a9c9f2/resourceGroups/rg-vnet-testapp-test-weu-001/providers/Microsoft.Network/virtualNetworks/vnet-testapp-test-weu-001/subnets/snet-test-001"
        name                                           = "snet-test-001"
      + service_endpoint_policy_ids                    = []
        # (7 unchanged attributes hidden)
    }

Unless you have made equivalent changes to your configuration, or ignored the relevant attributes using
ignore_changes, the following plan may include actions to undo or respond to these changes.

─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
```