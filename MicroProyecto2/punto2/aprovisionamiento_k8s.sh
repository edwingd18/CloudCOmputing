#!bin/bash

RESOURCE_GROUP="myResourceGroup"
CLUSTER_NAME="myfirstcluster"
LOCATION="southcentralus"


  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --node-count 2 \
  --node-vm-size Standard_B2ps_v2 \
  --enable-managed-identity \
  --generate-ssh-keys \
  --tier free \
  --location $LOCATION


az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME

