output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "resource_group" {
  value = azurerm_resource_group.rg.name
}

output "load_balancer_ip" {
  value = kubernetes_service.home_assistant.status.0.load_balancer.0.ingress.0.ip
}
