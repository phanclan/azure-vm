terraform {
  required_version = ">= 0.12.1"
}

variable "location" {
  description = "Azure location in which to create resources"
  default = "West US"
}

variable "windows_dns_prefix" {
  description = "DNS prefix to add to to public IP address for Windows VM"
  default     = "pphan-win"
}

variable "admin_password" {
  description = "admin password for Windows VM"
  default = "pTFE1234!"
}

module "windowsserver" {
  source              = "Azure/compute/azurerm"
  version             = "1.3.0"
  location            = var.location
  resource_group_name = "${var.windows_dns_prefix}-rc"
  vm_os_simple        = "WindowsServer"
  is_windows_image    = "true"
  vm_hostname         = "pwc-ptfe"
  admin_password      = var.admin_password
  public_ip_dns       = ["${var.windows_dns_prefix}"]
  vnet_subnet_id      = module.network.vnet_subnets[0]
}

module "network" {
  source              = "Azure/network/azurerm"
  version             = "2.0.0"
  location            = var.location
  resource_group_name = "${var.windows_dns_prefix}-rc"
  # allow_ssh_traffic   = "true"
}

output "windows_vm_public_name"{
  value = module.windowsserver.public_ip_dns_name
}
