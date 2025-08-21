terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.4"
    }
    # TODO: Ensure all required providers are listed here.
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.71.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0"
    }
  }
}
