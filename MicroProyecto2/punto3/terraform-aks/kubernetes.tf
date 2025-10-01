# Provider de Kubernetes
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}

# Deployment de Home Assistant
resource "kubernetes_deployment" "home_assistant" {
  metadata {
    name = "home-assistant"
    labels = {
      app = "home-assistant"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "home-assistant"
      }
    }

    template {
      metadata {
        labels = {
          app = "home-assistant"
        }
      }

      spec {
        container {
          image = "homeassistant/home-assistant:latest"
          name  = "home-assistant"

          port {
            container_port = 8123
          }

          resources {
            requests = {
              memory = "256Mi"
              cpu    = "250m"
            }
            limits = {
              memory = "512Mi"
              cpu    = "500m"
            }
          }
        }
      }
    }
  }

  depends_on = [azurerm_kubernetes_cluster.aks]
}

# Service LoadBalancer
resource "kubernetes_service" "home_assistant" {
  metadata {
    name = "home-assistant"
  }

  spec {
    selector = {
      app = "home-assistant"
    }

    port {
      port        = 8123
      target_port = 8123
    }

    type = "LoadBalancer"
  }

  depends_on = [kubernetes_deployment.home_assistant]
}
