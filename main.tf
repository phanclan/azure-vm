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
  resource_group_name = "${var.windows_dns_prefix}-rc"
  location            = var.location
  vm_os_simple        = "WindowsServer"
  is_windows_image    = "true"
  vm_hostname         = "phan-pwc-ptfe"
  admin_password      = var.admin_password
  public_ip_dns       = ["${var.windows_dns_prefix}"]
  vnet_subnet_id      = module.network.vnet_subnets[0]
}

module "linuxservers" {
  source              = "Azure/compute/azurerm"
  resource_group_name = "${var.windows_dns_prefix}-rc"
  location            = var.location
  vm_hostname         = "phan-linux-ptfe"
  vm_os_simple        = "UbuntuServer"
  ssh_key             = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjOXiqjoBMlfCBvmG6BcUGPv1q+YqNYLHlm6X18Frue+Yf2zG/56pMWtSoPbHKB+Nul0VNpANuOyt3qsEU+HtZz9MMTBiWL6kGH6S0saLMp7EpcZaib/Qxfkl1By6JnOwr6w7eW+XE4TXHRdBKaRWW4J52KdhlPXAeMFeSDL3qnZWaP7tIyKTQzdDXu0rSJIBpcYCVCQ5BkshWNvoVpDH0dH9r4ayLrzgnNzQHyqVFASU3DxqIAqrC3JflAz1aUWiwXhDJeZU3w6eDWvYxOAm+Z2vP5oiX/pqbYMlCUlPrsU5+6828kDQ5uQaZiCnSi2Bj3BDqpJngiVvyicJgvhW9 pephan@Mac-mini.local"
  public_ip_dns       = ["phan-linsimplevmips"] // change to a unique name per datacenter region
  vnet_subnet_id      = "${module.network.vnet_subnets[0]}"
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
