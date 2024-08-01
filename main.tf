
# required AVM resources interfaces
resource "azurerm_management_lock" "this" {
  count = var.lock.kind != "None" ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.name}")
  scope      = azurerm_TODO_resource.this.id
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azurerm_TODO_resource.this.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}

resource "random_string" "avd_local_admin_password" {
  for_each = var.local_admin_password

  length           = each.value.length
  special          = each.value.special
  override_special = each.value.override_special
  min_special      = each.value.min_special
}

module "vm" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "0.15.0"
  # insert the 5 required variables here
  admin_password      = random_string.avd_local_admin_password[0].result
  admin_username      = var.admin_username
  location            = var.location
  name                = var.name
  resource_group_name = var.resource_group_name
  network_interfaces  = azurerm_network_interface.this.id
  sku_size            = var.vm_sku_size
  zone                = [1, 2, 3]
  extensions = {
    azure_monitor_agent = {
      name                       = "AzureMonitorWindowsAgent"
      publisher                  = "Microsoft.Azure.Monitor"
      type                       = "AzureMonitorWindowsAgent"
      type_handler_version       = "1.2"
      auto_upgrade_minor_version = true
      automatic_upgrade_enabled  = true
      settings                   = null
    }
    avd_agent = {
      name                       = "AVD-Agent"
      publisher                  = "Microsoft.Powershell"
      type                       = "DSC"
      type_handler_version       = "2.73"
      virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
      auto_upgrade_minor_version = true
      protected_settings         = <<PROTECTED_SETTINGS
  {
    "properties": {
      "registrationInfoToken": "${local.registration_token}"
    }
  }
PROTECTED_SETTINGS
      settings                   = <<-SETTINGS
    {
      "modulesUrl": "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_1.0.02714.342.zip",
      "configurationFunction": "Configuration.ps1\\AddSessionHost",
      "properties": {
        "HostPoolName":"${module.avm_res_desktopvirtualization_hostpool.resource.name}"
      }
    }
SETTINGS
    }
    mal = {
      name                       = "IaaSAntimalware"
      publisher                  = "Microsoft.Azure.Security"
      type                       = "IaaSAntimalware"
      type_handler_version       = "1.3"
      virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
      auto_upgrade_minor_version = "true"
    }
  }
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "registrationinfo" {
  expiration_date = timeadd(timestamp(), var.registration_expiration_period)
  hostpool_id     = module.avm_res_desktopvirtualization_hostpool.resource.id
}

resource "azurerm_network_interface" "virtualmachine_network_interfaces" {
  for_each = var.network_interfaces

  location                       = var.location
  name                           = each.value.name
  resource_group_name            = coalesce(each.value.resource_group_name, var.resource_group_name)
  accelerated_networking_enabled = each.value.accelerated_networking_enabled
  dns_servers                    = each.value.dns_servers
  edge_zone                      = each.value.edge_zone
  internal_dns_name_label        = each.value.internal_dns_name_label
  ip_forwarding_enabled          = each.value.ip_forwarding_enabled
  tags                           = each.value.tags

  dynamic "ip_configuration" {
    for_each = each.value.ip_configurations
    content {
      name                                               = ip_configuration.value.name
      private_ip_address_allocation                      = ip_configuration.value.private_ip_address_allocation
      gateway_load_balancer_frontend_ip_configuration_id = ip_configuration.value.gateway_load_balancer_frontend_ip_configuration_resource_id
      primary                                            = ip_configuration.value.is_primary_ipconfiguration
      private_ip_address                                 = ip_configuration.value.private_ip_address
      private_ip_address_version                         = ip_configuration.value.private_ip_address_version
      public_ip_address_id                               = ip_configuration.value.create_public_ip_address ? azurerm_public_ip.virtualmachine_public_ips["${each.key}-${ip_configuration.key}"].id : ip_configuration.value.public_ip_address_resource_id
      subnet_id                                          = ip_configuration.value.private_ip_subnet_resource_id
    }
  }
}
