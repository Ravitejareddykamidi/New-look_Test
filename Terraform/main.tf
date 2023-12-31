# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "NewLook-Test"
  location = "UK South"
}

resource "azurerm_container_registry" "test" {
  name                = "NewlookApi"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
  admin_enabled       = true
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "Newlook-aks"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "newlookaks1"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

resource "azurerm_role_assignment" "test" {
  principal_id                     = azurerm_kubernetes_cluster.test.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.test.id
  skip_service_principal_aad_check = true
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.test.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.test.kube_config_raw

  sensitive = true
}

output "admin_username" {
  value       = azurerm_container_registry.test.admin_username
  description = "The Username associated with the Container Registry Admin account"
  sensitive   = true
}



output "admin_password" {
  value       = azurerm_container_registry.test.admin_password
  description = "The Password associated with the Container Registry Admin account "
  sensitive   = true
}
testing
