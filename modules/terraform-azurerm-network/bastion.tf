// Azure Bastion Host

resource "azurerm_subnet" "bastion_subnet" {
  count                = var.create_bastion_host ? 1 : 0
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.network_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.bas_subnet_address_prefix
}

resource "azurerm_public_ip" "bastion_pip" {
  count               = var.create_bastion_host ? 1 : 0
  name                = coalesce(lower(var.bas_pip_name), lower("pip-${local.bas_name}"))
  resource_group_name = azurerm_resource_group.network_rg.name
  location            = var.location
  allocation_method   = "Static"   // Bastion only supports Static allocation method
  sku                 = "Standard" // Bastion only supports Standard sku

  tags = merge(local.default_tags, var.tags)

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}

resource "azurerm_bastion_host" "bastion" {
  count               = var.create_bastion_host ? 1 : 0
  name                = local.bas_name
  location            = var.location
  resource_group_name = azurerm_resource_group.network_rg.name

  ip_configuration {
    name                 = lower("ipcon-${local.bas_name}")
    subnet_id            = azurerm_subnet.bastion_subnet[0].id
    public_ip_address_id = azurerm_public_ip.bastion_pip[0].id
  }

  tags = merge(local.default_tags, var.tags)

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}

resource "azurerm_network_security_group" "bastion_nsg" {
  count               = var.create_bastion_host ? 1 : 0
  name                = "nsg-${azurerm_subnet.bastion_subnet[0].name}"
  location            = var.location
  resource_group_name = azurerm_resource_group.network_rg.name

  security_rule {
    priority                   = 120
    name                       = "AllowHttpsInbound"
    direction                  = "Inbound"
    destination_port_range     = "443"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
    access                     = "Allow"
  }

  security_rule {
    priority                   = 130
    name                       = "AllowGatewayManagerInbound"
    direction                  = "Inbound"
    destination_port_range     = "443"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
    access                     = "Allow"
  }

  security_rule {
    priority                   = 140
    name                       = "AllowAzureLoadBalancerInbound"
    direction                  = "Inbound"
    destination_port_range     = "443"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
    access                     = "Allow"
  }

  security_rule {
    priority                   = 150
    name                       = "AllowBastionHostCommunication"
    direction                  = "Inbound"
    destination_port_ranges    = ["8080", "5701"]
    protocol                   = "*"
    source_port_range          = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
    access                     = "Allow"
  }

  security_rule {
    priority                   = 100
    name                       = "AllowSshRdpOutbound"
    direction                  = "Outbound"
    destination_port_ranges    = ["22", "3389"]
    protocol                   = "*"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
    access                     = "Allow"
  }

  security_rule {
    priority                   = 110
    name                       = "AllowAzureCloudOutbound"
    direction                  = "Outbound"
    destination_port_range     = "443"
    protocol                   = "TCP"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureCloud"
    access                     = "Allow"
  }

  security_rule {
    priority                   = 120
    name                       = "AllowBastionCommunication"
    direction                  = "Outbound"
    destination_port_ranges    = ["8080", "5701"]
    protocol                   = "*"
    source_port_range          = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
    access                     = "Allow"
  }

  security_rule {
    priority                   = 130
    name                       = "AllowGetSessionInformation"
    direction                  = "Outbound"
    destination_port_range     = "80"
    protocol                   = "*"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
    access                     = "Allow"
  }

  tags = merge(local.default_tags, var.tags)

  lifecycle {
    ignore_changes = [
      tags["CreationDate"]
    ]
  }
}

resource "azurerm_subnet_network_security_group_association" "bastion_nsg_assoc" {
  count                     = var.create_bastion_host ? 1 : 0
  subnet_id                 = azurerm_subnet.bastion_subnet[0].id
  network_security_group_id = azurerm_network_security_group.bastion_nsg[0].id
}