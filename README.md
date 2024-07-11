<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-avm-template

This is a template repo for Terraform Azure Verified Modules.

Things to do:

1. Set up a GitHub repo environment called `test`.
1. Configure environment protection rule to ensure that approval is required before deploying to this environment.
1. Create a user-assigned managed identity in your test subscription.
1. Create a role assignment for the managed identity on your test subscription, use the minimum required role.
1. Configure federated identity credentials on the user assigned managed identity. Use the GitHub environment.
1. Create the following environment secrets on the `test` environment:
   1. AZURE\_CLIENT\_ID
   1. AZURE\_TENANT\_ID
   1. AZURE\_SUBSCRIPTION\_ID
1. Search and update TODOs within the code and remove the TODO comments once complete.

Major version Zero (0.y.z) is for initial development. Anything MAY change at any time. A module SHOULD NOT be considered stable till at least it is major version one (1.0.0) or greater. Changes will always be via new versions being published and no changes will be made to existing published versions. For more details please go to <https://semver.org/>

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.5)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.71)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.5)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 3.71)

- <a name="provider_random"></a> [random](#provider\_random) (~> 3.5)

## Resources

The following resources are used by this module:

- [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) (resource)
- [azurerm_network_interface.virtualmachine_network_interfaces](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) (resource)
- [azurerm_resource_group_template_deployment.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_template_deployment) (resource)
- [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_virtual_machine_extension.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) (resource)
- [random_id.telem](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password)

Description: The password of the local administrator on the Virtual Machine.

Type: `string`

### <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username)

Description: The username of the local administrator on the Virtual Machine.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the this resource.

Type: `string`

### <a name="input_network_interfaces"></a> [network\_interfaces](#input\_network\_interfaces)

Description: A map of objects representing each network virtual machine network interface

- `<map key>` - Use a custom map key to define each network interface
  - `name` = (Required) The name of the Network Interface. Changing this forces a new resource to be created.
  - `ip_configurations` - A required map of objects defining each interfaces IP configurations
    - `<map key>` - Use a custom map key to define each ip configuration
      - `name`                                                        = (Required) - A name used for this IP Configuration.
      - `app_gateway_backend_pools`                                   = (Optional) - A map defining app gateway backend pool(s) this IP configuration should be associated to.
        - `<map key>` - Use a custom map key to define each app gateway backend pool association.  This is done to handle issues with certain details not being known until after apply.
          - `app_gateway_backend_pool_resource_id`                    = (Required) - An application gateway backend pool Azure Resource ID can be entered to join this ip configuration to the backend pool of an Application Gateway.    
      - `create_public_ip_address`                                    = (Optional) - Select true here to have the module create the public IP address for this IP Configuration
      - `gateway_load_balancer_frontend_ip_configuration_resource_id` = (Optional) - The Frontend IP Configuration Azure Resource ID of a Gateway SKU Load Balancer.)
      - `is_primary_ipconfiguration`                                  = (Optional) - Is this the Primary IP Configuration? Must be true for the first ip\_configuration when multiple are specified.
      - `load_balancer_backend_pools`                                 = (Optional) - A map defining load balancer backend pool(s) this IP configuration should be associated to.
        - `<map key>` - Use a custom map key to define each load balancer backend pool association.  This is done to handle issues with certain details not being known until after apply.
          - `load_balancer_backend_pool_resource_id`                  = (Required) - A Load Balancer backend pool Azure Resource ID can be entered to join this ip configuration to a load balancer backend pool.
      - `load_balancer_nat_rules`                                     = (Optional) - A map defining load balancer NAT rule(s) that this IP Configuration should be associated to.
        - `<map key>` - Use a custom map key to define each load balancer NAT Rule association.  This is done to handle issues with certain details not being known until after apply.  
          - `load_balancer_nat_rule_resource_id`                        = (Optional) - A Load Balancer Nat Rule Azure Resource ID can be entered to associate this ip configuration to a load balancer NAT rule.
      - `private_ip_address`                                          = (Optional) - The Static IP Address which should be used. Configured when private\_ip\_address\_allocation is set to Static
      - `private_ip_address_allocation`                               = (Optional) - The allocation method used for the Private IP Address. Possible values are Dynamic and Static. Dynamic means "An IP is automatically assigned during creation of this Network Interface" and is the default; Static means "User supplied IP address will be used"
      - `private_ip_address_version`                                  = (Optional) - The IP Version to use. Possible values are IPv4 or IPv6. Defaults to IPv4.  
      - `private_ip_subnet_resource_id`                               = (Optional) - The Azure Resource ID of the Subnet where this Network Interface should be located in.
      - `public_ip_address_resource_id`                               = (Optional) - Reference to a Public IP Address resource ID to associate with this NIC  
  - `accelerated_networking_enabled`                                  = (Optional) - Should Accelerated Networking be enabled? Defaults to false. Only certain Virtual Machine sizes are supported for Accelerated Networking. To use Accelerated Networking in an Availability Set, the Availability Set must be deployed onto an Accelerated Networking enabled cluster.  
  - `application_security_groups`                                     = (Optional) - A map defining the Application Security Group(s) that this network interface should be a part of.
    - `<map key>` - Use a custom map key to define each Application Security Group association.  This is done to handle issues with certain details not being known until after apply.   
      - `application_security_group_resource_ids`                     = (Required) - The Application Security Group (ASG) Azure Resource ID for this Network Interface to be associated to.
  - `diagnostic_settings`                                             = (Optional) - A map of objects defining the network interface resource diagnostic settings
    - `<map key>` - Use a custom map key to define each diagnostic setting configuration
      - `name`                                     = (required) - Name to use for the Diagnostic setting configuration.  Changing this creates a new resource
      - `event_hub_authorization_rule_resource_id` = (Optional) - The Event Hub Namespace Authorization Rule Resource ID when sending logs or metrics to an Event Hub Namespace
      - `event_hub_name`                           = (Optional) - The Event Hub name when sending logs or metrics to an Event Hub  
      - `log_analytics_destination_type`           = (Optional) - Valid values are null, AzureDiagnostics, and Dedicated.  Defaults to null
      - `log_categories_and_groups`                = (Optional) - List of strings used to define log categories and groups. Currently not valid for the VM resource
      - `marketplace_partner_resource_id`          = (Optional) - The marketplace partner solution Azure Resource ID when sending logs or metrics to a partner integration
      - `metric_categories`                        = (Optional) - List of strings used to define metric categories. Currently only AllMetrics is valid
      - `storage_account_resource_id`              = (Optional) - The Storage Account Azure Resource ID when sending logs or metrics to a Storage Account
      - `workspace_resource_id`                    = (Optional) - The Log Analytics Workspace Azure Resource ID when sending logs or metrics to a Log Analytics Workspace
  - `dns_servers`                                                     = (Optional) - A list of IP Addresses defining the DNS Servers which should be used for this Network Interface.
  - `inherit_tags`                                                    = (Optional) - Defaults to true.  Set this to false if only the tags defined on this resource should be applied. This is potential future functionality and is currently ignored.
  - `internal_dns_name_label`                                         = (Optional) - The (relative) DNS Name used for internal communications between Virtual Machines in the same Virtual Network.
  - `ip_forwarding_enabled`                                           = (Optional) - Should IP Forwarding be enabled? Defaults to false
  - `lock_level`                                                      = (Optional) - Set this value to override the resource level lock value.  Possible values are `None`, `CanNotDelete`, and `ReadOnly`.
  - `lock_name`                                                       = (Optional) - The name for the lock on this nic
  - `network_security_groups`                                         = (Optional) - A map describing Network Security Group(s) that this Network Interface should be associated to.
    - `<map key>` - Use a custom map key to define each network security group association.  This is done to handle issues with certain details not being known until after apply.
      - `network_security_group_resource_id` = (Optional) - The Network Security Group (NSG) Azure Resource ID used to associate this Network Interface to the NSG.
  - `resource_group_name` (Optional) - Specify a resource group name if the network interface should be created in a separate resource group from the virtual machine
  - `role_assignments` = An optional map of objects defining role assignments on the individual network configuration resource
    - `<map key>` - Use a custom map key to define each role assignment configuration  
      - `assign_to_child_public_ip_addresses`        = (Optional) - Set this to true if the assignment should also apply to any children public IP addresses.
      - `condition`                                  = (Optional) - The condition that limits the resources that the role can be assigned to. Changing this forces a new resource to be created.
      - `condition_version`                          = (Optional) - The version of the condition. Possible values are 1.0 or 2.0. Changing this forces a new resource to be created.
      - `delegated_managed_identity_resource_id`     = (Optional) - The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created.
      - `description`                                = (Optional) - The description for this Role Assignment. Changing this forces a new resource to be created.  
      - `principal_id`                               = (optional) - The ID of the Principal (User, Group or Service Principal) to assign the Role Definition to. Changing this forces a new resource to be created.
      - `role_definition_id_or_name`                 = (Optional) - The Scoped-ID of the Role Definition or the built-in role name. Changing this forces a new resource to be created. Conflicts with role\_definition\_name   
      - `skip_service_principal_aad_check`           = (Optional) - If the principal\_id is a newly provisioned Service Principal set this value to true to skip the Azure Active Directory check which may fail due to replication lag. This argument is only valid if the principal\_id is a Service Principal identity. Defaults to true.
      - `principal_type`                             = (Optional) - The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.
  - `tags`                           = (Optional) - A mapping of tags to assign to the resource.

Example Inputs:

```hcl
#Simple private IP single NIC with IPV4 private address
network_interfaces = {
  network_interface_1 = {
    name = "testnic1"
    ip_configurations = {
      ip_configuration_1 = {
        name                          = "testnic1-ipconfig1"
        private_ip_subnet_resource_id = azurerm_subnet.this_subnet_1.id
      }
    }
  }
}

#Simple NIC with private and public IP address
network_interfaces = {
  network_interface_1 = {
    name = "testnic1"
    ip_configurations = {
      ip_configuration_1 = {
        name                          = "testnic1-ipconfig1"
        private_ip_subnet_resource_id = azurerm_subnet.this_subnet_1.id
        create_public_ip_address      = true
        public_ip_address_name        = "vm1-testnic1-publicip1"
      }
    }
  }
}
```

Type:

```hcl
map(object({
    name = string
    ip_configurations = map(object({
      name = string
      app_gateway_backend_pools = optional(map(object({
        app_gateway_backend_pool_resource_id = string
      })), {})
      create_public_ip_address                                    = optional(bool, false)
      gateway_load_balancer_frontend_ip_configuration_resource_id = optional(string)
      is_primary_ipconfiguration                                  = optional(bool, true)
      load_balancer_backend_pools = optional(map(object({
        load_balancer_backend_pool_resource_id = string
      })), {})
      load_balancer_nat_rules = optional(map(object({
        load_balancer_nat_rule_resource_id = string
      })), {})
      private_ip_address            = optional(string)
      private_ip_address_allocation = optional(string, "Dynamic")
      private_ip_address_version    = optional(string, "IPv4")
      private_ip_subnet_resource_id = optional(string)
      public_ip_address_lock_name   = optional(string)
      public_ip_address_name        = optional(string)
      public_ip_address_resource_id = optional(string)
    }))
    accelerated_networking_enabled = optional(bool, false)
    application_security_groups = optional(map(object({
      application_security_group_resource_id = string
    })), {})
    diagnostic_settings = optional(map(object({
      name                                     = optional(string, null)
      log_categories                           = optional(set(string), [])
      log_groups                               = optional(set(string), [])
      metric_categories                        = optional(set(string), ["AllMetrics"])
      log_analytics_destination_type           = optional(string, null)
      workspace_resource_id                    = optional(string, null)
      storage_account_resource_id              = optional(string, null)
      event_hub_authorization_rule_resource_id = optional(string, null)
      event_hub_name                           = optional(string, null)
      marketplace_partner_resource_id          = optional(string, null)
    })), {})
    dns_servers             = optional(list(string))
    inherit_tags            = optional(bool, true)
    internal_dns_name_label = optional(string)
    ip_forwarding_enabled   = optional(bool, false)
    lock_level              = optional(string)
    lock_name               = optional(string)
    network_security_groups = optional(map(object({
      network_security_group_resource_id = string
    })), {})
    resource_group_name = optional(string)
    role_assignments = optional(map(object({
      principal_id                           = string
      role_definition_id_or_name             = string
      assign_to_child_public_ip_addresses    = optional(bool, true)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      principal_type                         = optional(string, null)
    })), {})
    tags = optional(map(string), null)
  }))
```

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The resource group where the resources will be deployed.

Type: `string`

### <a name="input_virtual_machine_extension"></a> [virtual\_machine\_extension](#input\_virtual\_machine\_extension)

Description: All attributes related to configuring a Virtual Machine Extension.

Type:

```hcl
object({
    name                        = string
    publisher                   = string
    type                        = string
    type_handler_version        = string
    virtual_machine_id          = string
    auto_upgrade_minor_version  = bool
    automatic_upgrade_enabled   = bool
    failure_suppression_enabled = bool
    protected_settings          = string
    protected_settings_from_key_vault = object({
      secret_url      = string
      source_vault_id = string
    })
    provision_after_extensions = list(string)
    settings                   = string
    tags                       = map(string)
    timeouts = object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    })
  })
```

### <a name="input_virtual_machine_extension_name"></a> [virtual\_machine\_extension\_name](#input\_virtual\_machine\_extension\_name)

Description: (Required) The name of the virtual machine extension peering. Changing this forces a new resource to be created.

Type: `string`

### <a name="input_virtual_machine_extension_publisher"></a> [virtual\_machine\_extension\_publisher](#input\_virtual\_machine\_extension\_publisher)

Description: (Required) The publisher of the extension, available publishers can be found by using the Azure CLI. Changing this forces a new resource to be created.

Type: `string`

### <a name="input_virtual_machine_extension_type"></a> [virtual\_machine\_extension\_type](#input\_virtual\_machine\_extension\_type)

Description: (Required) The type of extension, available types for a publisher can be found using the Azure CLI.

Type: `string`

### <a name="input_virtual_machine_extension_type_handler_version"></a> [virtual\_machine\_extension\_type\_handler\_version](#input\_virtual\_machine\_extension\_type\_handler\_version)

Description: (Required) Specifies the version of the extension to use, available versions can be found using the Azure CLI.

Type: `string`

### <a name="input_virtual_machine_extension_virtual_machine_id"></a> [virtual\_machine\_extension\_virtual\_machine\_id](#input\_virtual\_machine\_extension\_virtual\_machine\_id)

Description: (Required) The ID of the Virtual Machine. Changing this forces a new resource to be created

Type: `string`

### <a name="input_vm_sku_size"></a> [vm\_sku\_size](#input\_vm\_sku\_size)

Description: The SKU size of the Virtual Machine.

Type: `string`

### <a name="input_windows_virtual_machine_admin_password"></a> [windows\_virtual\_machine\_admin\_password](#input\_windows\_virtual\_machine\_admin\_password)

Description: (Required) The Password which should be used for the local-administrator on this Virtual Machine. Changing this forces a new resource to be created.

Type: `string`

### <a name="input_windows_virtual_machine_admin_username"></a> [windows\_virtual\_machine\_admin\_username](#input\_windows\_virtual\_machine\_admin\_username)

Description: (Required) The username of the local administrator used for the Virtual Machine. Changing this forces a new resource to be created.

Type: `string`

### <a name="input_windows_virtual_machine_location"></a> [windows\_virtual\_machine\_location](#input\_windows\_virtual\_machine\_location)

Description: (Required) The Azure location where the Windows Virtual Machine should exist. Changing this forces a new resource to be created.

Type: `string`

### <a name="input_windows_virtual_machine_name"></a> [windows\_virtual\_machine\_name](#input\_windows\_virtual\_machine\_name)

Description: (Required) The name of the Windows Virtual Machine. Changing this forces a new resource to be created.

Type: `string`

### <a name="input_windows_virtual_machine_network_interface_ids"></a> [windows\_virtual\_machine\_network\_interface\_ids](#input\_windows\_virtual\_machine\_network\_interface\_ids)

Description: (Required). A list of Network Interface IDs which should be attached to this Virtual Machine. The first Network Interface ID in this list will be the Primary Network Interface on the Virtual Machine.

Type: `list(string)`

### <a name="input_windows_virtual_machine_os_disk"></a> [windows\_virtual\_machine\_os\_disk](#input\_windows\_virtual\_machine\_os\_disk)

Description: - `caching` - (Required) The Type of Caching which should be used for the Internal OS Disk. Possible values are `None`, `ReadOnly` and `ReadWrite`.
- `disk_encryption_set_id` - (Optional) The ID of the Disk Encryption Set which should be used to Encrypt this OS Disk. Conflicts with `secure_vm_disk_encryption_set_id`.
- `disk_size_gb` - (Optional) The Size of the Internal OS Disk in GB, if you wish to vary from the size used in the image this Virtual Machine is sourced from.
- `name` - (Optional) The name which should be used for the Internal OS Disk. Changing this forces a new resource to be created.
- `secure_vm_disk_encryption_set_id` - (Optional) The ID of the Disk Encryption Set which should be used to Encrypt this OS Disk when the Virtual Machine is a Confidential VM. Conflicts with `disk_encryption_set_id`. Changing this forces a new resource to be created.
- `security_encryption_type` - (Optional) Encryption Type when the Virtual Machine is a Confidential VM. Possible values are `VMGuestStateOnly` and `DiskWithVMGuestState`. Changing this forces a new resource to be created.
- `storage_account_type` - (Required) The Type of Storage Account which should back this the Internal OS Disk. Possible values are `Standard_LRS`, `StandardSSD_LRS`, `Premium_LRS`, `StandardSSD_ZRS` and `Premium_ZRS`. Changing this forces a new resource to be created.
- `write_accelerator_enabled` - (Optional) Should Write Accelerator be Enabled for this OS Disk? Defaults to `false`.

---
`diff_disk_settings` block supports the following:
- `option` - (Required) Specifies the Ephemeral Disk Settings for the OS Disk. At this time the only possible value is `Local`. Changing this forces a new resource to be created.
- `placement` - (Optional) Specifies where to store the Ephemeral Disk. Possible values are `CacheDisk` and `ResourceDisk`. Defaults to `CacheDisk`. Changing this forces a new resource to be created.

Type:

```hcl
object({
    caching                          = string
    disk_encryption_set_id           = optional(string)
    disk_size_gb                     = optional(number)
    name                             = optional(string)
    secure_vm_disk_encryption_set_id = optional(string)
    security_encryption_type         = optional(string)
    storage_account_type             = string
    write_accelerator_enabled        = optional(bool)
    diff_disk_settings = optional(object({
      option    = string
      placement = optional(string)
    }))
  })
```

### <a name="input_windows_virtual_machine_resource_group_name"></a> [windows\_virtual\_machine\_resource\_group\_name](#input\_windows\_virtual\_machine\_resource\_group\_name)

Description: (Required) The name of the Resource Group in which the Windows Virtual Machine should be exist. Changing this forces a new resource to be created.

Type: `string`

### <a name="input_windows_virtual_machine_size"></a> [windows\_virtual\_machine\_size](#input\_windows\_virtual\_machine\_size)

Description: (Required) The SKU which should be used for this Virtual Machine, such as `Standard_F2`.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_customer_managed_key"></a> [customer\_managed\_key](#input\_customer\_managed\_key)

Description: Customer managed keys that should be associated with the resource.

Type:

```hcl
object({
    key_vault_resource_id              = optional(string)
    key_name                           = optional(string)
    key_version                        = optional(string, null)
    user_assigned_identity_resource_id = optional(string, null)
  })
```

Default: `{}`

### <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings)

Description:   A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

  - `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.
  - `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.
  - `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`.
  - `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.
  - `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
  - `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
  - `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
  - `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
  - `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
  - `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic LogsLogs.

Type:

```hcl
map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), ["allLogs"])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_location"></a> [location](#input\_location)

Description: Azure region where the resource should be deployed.  If null, the location will be inferred from the resource group location.

Type: `string`

Default: `null`

### <a name="input_lock"></a> [lock](#input\_lock)

Description:   Controls the Resource Lock configuration for this resource. The following properties can be specified:

  - `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
  - `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.

Type:

```hcl
object({
    kind = string
    name = optional(string, null)
  })
```

Default: `null`

### <a name="input_managed_identities"></a> [managed\_identities](#input\_managed\_identities)

Description:   Controls the Managed Identity configuration on this resource. The following properties can be specified:

  - `system_assigned` - (Optional) Specifies if the System Assigned Managed Identity should be enabled.
  - `user_assigned_resource_ids` - (Optional) Specifies a list of User Assigned Managed Identity resource IDs to be assigned to this resource.

Type:

```hcl
object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
```

Default: `{}`

### <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments)

Description:   A map of role assignments to create on the <RESOURCE>. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

  - `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
  - `principal_id` - The ID of the principal to assign the role to.
  - `description` - (Optional) The description of the role assignment.
  - `skip_service_principal_aad_check` - (Optional) If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
  - `condition` - (Optional) The condition which will be used to scope the role assignment.
  - `condition_version` - (Optional) The version of the condition syntax. Leave as `null` if you are not using a condition, if you are then valid values are '2.0'.
  - `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. This field is only used in cross-tenant scenario.
  - `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.

  > Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.

Type:

```hcl
map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: (Optional) Tags of the resource.

Type: `map(string)`

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_private_endpoints"></a> [private\_endpoints](#output\_private\_endpoints)

Description: A map of private endpoints. The map key is the supplied input to var.private\_endpoints. The map value is the entire azurerm\_private\_endpoint resource.

### <a name="output_resource"></a> [resource](#output\_resource)

Description: This is the full output for the resource.

## Modules

The following Modules are called:

### <a name="module_vm"></a> [vm](#module\_vm)

Source: Azure/avm-res-compute-virtualmachine/azurerm

Version: ~> 0.15.0

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->