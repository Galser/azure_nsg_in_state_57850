provider "azurerm" {
  subscription_id = var.azure_subscription_id
  features {}
}


module "network" {
  source = "./modules/terraform-azurerm-network"
  # version = "0.16.13"  # -> version constrain removed to woek with local module

  location       = "westeurope"
  location_short = "weu"
  environment    = "test"
  app_name       = "testapp"
  address_space  = ["10.73.0.0/16"]

  subnets = {
    subnet_1 = {
      subnet_name                                    = "snet-test-001"
      subnet_address_prefix                          = ["10.73.1.0/24"]
      enforce_private_link_endpoint_network_policies = true
      nsg                                            = true
      nsg_rule = [
/*        {
          name                       = "ALLOW-Rdp-In"
          description                = "Allow RDP in for John Doe from home"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "3389"
          source_address_prefixes    = ["93.192.47.94/32"]
          destination_address_prefix = "*"
        } */
      ]
    }
  }

}

