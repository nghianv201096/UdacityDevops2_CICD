# Provider
provider "azurerm" {
  features {}
}

locals {
  required_tags = {
	project = "Udacity Devops project 2"
	classification = "Learning"
  }
}

##################### Step1: create resource group.
###############################################################
resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-rg"
  location = var.location
  tags = local.required_tags
}

##################### Step2: create virtual network.
###############################################################
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.0.0.0/22"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags = local.required_tags
}

##################### Step3: create a subnet.
###############################################################
resource "azurerm_subnet" "internal" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

##################### Step4: create a NSG 
###############################################################
resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags = local.required_tags
}

resource "azurerm_network_security_rule" "ssh_allow_rule" {
  name                       = "SSH-InBound-Allow"
  priority                   = 3900
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "22"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.internal.id
  network_security_group_id = azurerm_network_security_group.main.id
}

##################### Step5: create a public ip.
###############################################################
resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-public-ip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  tags = local.required_tags
}

##################### Step6: create a network interface.
###############################################################
resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
  
  tags = local.required_tags
}

##################### Step7: create virual machines using packer images.
###############################################################
resource "azurerm_linux_virtual_machine" "main" {
  name                            = "${var.prefix}-agent-vm"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = "${var.agent_vm_size}"
  admin_username                  = "${var.username}"
  admin_password                  = "${var.password}"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  tags = local.required_tags
}

##################### Step8: Create appservice plan
###############################################################
resource "azurerm_service_plan" "main" {
  name                = "${var.prefix}-appservice-plan"
  location            = "Central US"
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  sku_name            = "${var.app_service_plan_sku}"
}


##################### step9: Create webapp 
###############################################################
resource "azurerm_linux_web_app" "main" {
  name                = "${var.prefix}app"
  location            = "Central US"
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.main.id

  site_config {
    application_stack {
      python_version = "${var.python_version}"
    }
  }
}