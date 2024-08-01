terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0, < 4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0, < 4.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}


## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/regions/azurerm"
  version = ">= 0.3.0"
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}
## End of section to provide a random Azure region for the resource group

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = module.regions.regions[random_integer.region_index.result].name
  name     = module.naming.resource_group.name_unique
}

module "avd" {
  source  = "Azure/avm-ptn-avd-lza-managementplane/azurerm"
  version = "0.1.4"
  enable_telemetry                                   = var.enable_telemetry
  location                                           = azurerm_resource_group.this.location
  resource_group_name                                = azurerm_resource_group.this.name
  description = "This is a test deployment of the Azure Virtual Desktop module."
  user_group_name                                    = var.user_group_name
  virtual_desktop_workspace_name                     = var.virtual_desktop_workspace_name
  virtual_desktop_scaling_plan_time_zone             = var.virtual_desktop_scaling_plan_time_zone
  virtual_desktop_scaling_plan_name                  = var.virtual_desktop_scaling_plan_name
  virtual_desktop_host_pool_type                     = var.virtual_desktop_host_pool_type
  virtual_desktop_host_pool_load_balancer_type       = var.virtual_desktop_host_pool_load_balancer_type
  virtual_desktop_host_pool_name                     = var.virtual_desktop_host_pool_name
  virtual_desktop_host_pool_maximum_sessions_allowed = var.virtual_desktop_host_pool_maximum_sessions_allowed
  virtual_desktop_host_pool_start_vm_on_connect      = var.virtual_desktop_host_pool_start_vm_on_connect
  virtual_desktop_application_group_type             = var.virtual_desktop_application_group_type
  virtual_desktop_application_group_name             = var.virtual_desktop_application_group_name
  virtual_desktop_host_pool_friendly_name            = var.virtual_desktop_host_pool_friendly_name
  log_analytics_workspace_name                       = module.naming.log_analytics_workspace.name_unique
}

module "sessionhost" {
  source = "../../"
  # source             = "Azure/avm-<res/ptn>-<name>/azurerm"
  enable_telemetry     = var.enable_telemetry # see variables.tf
  name                 = "sh-eus-001"         # TODO update with module.naming.<RESOURCE_TYPE>.name_unique
  resource_group_name  = azurerm_resource_group.this.name
  local_admin_password = "P@ssw0rd1234!"
  admin_username       = "admin"
  location             = module.regions.regions[random_integer.region_index.result].name
  vm_sku_size          = "Standard_D2s_v3"
  network_interfaces   = azurerm_network_interface.this.id
  virtual_machine_extension = {
    "extension1" = {
      name                        = "extension1"
      publisher                   = "Microsoft.Compute"
      type                        = "CustomScriptExtension"
      type_handler_version        = "1.10"
      virtual_machine_id          = azurerm_virtual_machine.this.id
      auto_upgrade_minor_version  = true
      automatic_upgrade_enabled   = true
      failure_suppression_enabled = false
      protected_settings = {
        commandToExecute = "echo 'Hello, World!' > /tmp/hello-world.txt"
      }
      provision_after_extensions        = []
      settings                          = null
      tags                              = null
      protected_settings_from_key_vault = null
      timeouts                          = null
    }
  }
}
