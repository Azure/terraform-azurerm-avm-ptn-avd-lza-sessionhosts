resource "azapi_resource" "this" {
  location  = var.location
  name      = var.name
  parent_id = var.parent_id
  type      = var.resource_types.network_virtual_networks
  body = {
    properties = {
      addressSpace = {
        addressPrefixes = var.address_space
      }
    }
  }
  ignore_body_changes    = length(var.ignore_body_changes.network_virtual_networks) > 0 ? var.ignore_body_changes.network_virtual_networks : null
  response_export_values = []
  retry                  = var.retry
  tags                   = var.tags

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}
