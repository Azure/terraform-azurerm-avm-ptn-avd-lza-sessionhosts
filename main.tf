
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

module "vm" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "~> 0.15.0"
  # insert the 5 required variables here
  admin_password      = var.admin_password
  admin_username      = var.admin_username
  location            = var.location
  name                = var.name
  resource_group_name = var.resource_group_name
  network_interfaces  = azurerm_network_interface.this.id
  sku_size            = var.vm_sku_size
  zone                = [1, 2, 3]
}

resource "azurerm_virtual_machine_extension" "this" {
  for_each = var.virtual_machine_extension

  name                        = each.value.name
  publisher                   = each.value.publisher
  type                        = each.value.type
  type_handler_version        = each.value.type_handler_version
  virtual_machine_id          = each.value.virtual_machine_id
  auto_upgrade_minor_version  = each.value.auto_upgrade_minor_version
  automatic_upgrade_enabled   = each.value.automatic_upgrade_enabled
  failure_suppression_enabled = each.value.failure_suppression_enabled
  protected_settings          = each.value.protected_settings
  provision_after_extensions  = each.value.provision_after_extensions
  settings                    = each.value.settings
  tags                        = each.value.tags

  dynamic "protected_settings_from_key_vault" {
    for_each = var.virtual_machine_extension.protected_settings_from_key_vault == null ? [] : [var.virtual_machine_extension.protected_settings_from_key_vault]
    content {
      secret_url      = protected_settings_from_key_vault.value.secret_url
      source_vault_id = protected_settings_from_key_vault.value.source_vault_id
    }
  }
  dynamic "timeouts" {
    for_each = var.virtual_machine_extension.timeouts == null ? [] : [var.virtual_machine_extension.timeouts]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
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
