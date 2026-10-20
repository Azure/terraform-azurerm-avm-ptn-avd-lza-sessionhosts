output "name" {
  description = "The name of the virtual network."
  value       = azapi_resource.this.name
}

output "resource_id" {
  description = "The resource ID of the virtual network."
  value       = azapi_resource.this.id
}
