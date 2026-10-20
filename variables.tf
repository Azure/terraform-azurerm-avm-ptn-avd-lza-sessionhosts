variable "address_space" {
  type        = list(string)
  description = "The address prefixes of the virtual network, in CIDR notation."
  nullable    = false

  validation {
    condition     = length(var.address_space) > 0 && alltrue([for prefix in var.address_space : can(cidrhost(prefix, 0))])
    error_message = "Provide at least one address prefix in CIDR notation."
  }
}

variable "location" {
  type        = string
  description = "The Azure region where the virtual network will be created."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the virtual network."
  nullable    = false

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9._-]{0,62}[a-zA-Z0-9_]$", var.name))
    error_message = "The name must be 2 to 64 characters, start with a letter or number, end with a letter, number, or underscore, and contain only letters, numbers, underscores, periods, or hyphens."
  }
}

variable "parent_id" {
  type        = string
  description = "The resource ID of the resource group where the virtual network will be created."
  nullable    = false

  validation {
    condition     = can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+$", var.parent_id))
    error_message = "The parent_id must be a resource group resource ID."
  }
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "ignore_body_changes" {
  type = object({
    network_virtual_networks = optional(list(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Body paths, in dot notation, whose changes made outside Terraform are ignored for each AzAPI resource. Changes to this value take effect after the next apply.

- `network_virtual_networks` - (Optional) Paths to ignore on the virtual network, for example `properties.dhcpOptions`.
DESCRIPTION
  nullable    = false
}

variable "resource_types" {
  type = object({
    network_virtual_networks = optional(string, "Microsoft.Network/virtualNetworks@2024-07-01")
  })
  default     = {}
  description = <<DESCRIPTION
The AzAPI resource type and API version used for each resource.

- `network_virtual_networks` - (Optional) The virtual network type. Defaults to `Microsoft.Network/virtualNetworks@2024-07-01`.
DESCRIPTION
  nullable    = false
}

variable "retry" {
  type = object({
    error_message_regex  = optional(list(string))
    interval_seconds     = optional(number)
    max_interval_seconds = optional(number)
  })
  default     = null
  description = <<DESCRIPTION
Retry configuration applied to every AzAPI resource in the module. Defaults to `null` (no custom retry).

- `error_message_regex` - (Optional) Regular expressions matching error messages that trigger a retry.
- `interval_seconds` - (Optional) Initial interval between retries, in seconds.
- `max_interval_seconds` - (Optional) Maximum interval between retries, in seconds.
DESCRIPTION
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "A map of tags to assign to the virtual network."
}

variable "timeouts" {
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
Operation timeouts applied to every AzAPI resource in the module, as duration strings such as `30m`. Defaults to `null` (provider defaults).

- `create` - (Optional) Timeout for create operations.
- `read` - (Optional) Timeout for read operations.
- `update` - (Optional) Timeout for update operations.
- `delete` - (Optional) Timeout for delete operations.
DESCRIPTION
}
