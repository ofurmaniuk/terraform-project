#!/bin/bash

# login to EKS cluster 
aws eks update-kubeconfig --name production-cluster --region us-east-2

echo "Installing NGINX Ingress Controller..."

# Apply the NGINX Ingress Controller manifest
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.5/deploy/static/provider/cloud/deploy.yaml

# Wait for the pods to be ready
echo "Waiting for NGINX Ingress Controller pods to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s


echo "NGINX Ingress Controller installation complete!"


# Create namespace 
kubectl create namespace production

# Deploy ConfigMaps
kubectl apply -f ../k8s/api/api-cm.yaml
kubectl apply -f ../k8s/web/web-cm.yaml 

# Deploy Services 
kubectl apply -f ../k8s/api/api-svc.yaml
kubectl apply -f ../k8s/web/web-svc.yaml 

# Deploy aplications API and WEB 
kubectl apply -f ../k8s/api/api-deploy.yaml 
kubectl apply -f ../k8s/web/web-deploy.yaml 

# bash post-install.sh  - command to run script 
# ./post-install.sh
