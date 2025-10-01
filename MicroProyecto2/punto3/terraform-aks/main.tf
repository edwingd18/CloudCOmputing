# Grupo de recursos
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Cluster AKS
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.cluster_name
  sku_tier            = "Free"

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Development"
    Project     = "AKS-Demo"
  }


}
