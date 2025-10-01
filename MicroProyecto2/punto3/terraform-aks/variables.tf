variable "resource_group_name" {
  description = "Nombre del grupo de recursos"
  type        = string
  default     = "myResourceGroup"
}

variable "location" {
  description = "Región de Azure"
  type        = string
  default     = "southcentralus"
}

variable "cluster_name" {
  description = "Nombre del cluster AKS"
  type        = string
  default     = "myfirstcluster"
}

variable "node_count" {
  description = "Número de nodos"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "Tamaño de la VM"
  type        = string
  default     = "Standard_B2ps_v2"
}
