#!/bin/bash

# Todo App - Kubernetes Deployment Script for AKS
# This script deploys the complete 3-tier application to Azure Kubernetes Service

set -e

echo "========================================="
echo "Todo App - AKS Deployment Script"
echo "========================================="

# Variables - UPDATE THESE
RESOURCE_GROUP="todo-app-rg"
AKS_CLUSTER_NAME="todo-aks-cluster"
LOCATION="eastus"
NAMESPACE="todo-app"
DOCKERHUB_USERNAME="YOUR_DOCKERHUB_USERNAME"

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    print_error "Azure CLI is not installed. Please install it first."
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed. Please install it first."
    exit 1
fi

# Step 1: Azure Login
print_message "Logging in to Azure..."
az login

# Step 2: Create Resource Group
print_message "Creating resource group: $RESOURCE_GROUP"
az group create --name $RESOURCE_GROUP --location $LOCATION

# Step 3: Create AKS Cluster
print_message "Creating AKS cluster: $AKS_CLUSTER_NAME (this may take 5-10 minutes)..."
az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_CLUSTER_NAME \
    --node-count 2 \
    --node-vm-size Standard_B2s \
    --enable-managed-identity \
    --generate-ssh-keys \
    --network-plugin azure \
    --network-policy azure

# Step 4: Get AKS credentials
print_message "Getting AKS credentials..."
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER_NAME --overwrite-existing

# Step 5: Verify cluster connection
print_message "Verifying cluster connection..."
kubectl cluster-info
kubectl get nodes

# Step 6: Create namespace
print_message "Creating namespace: $NAMESPACE"
kubectl create namespace $NAMESPACE || print_warning "Namespace already exists"

# Step 7: Create Docker registry secret
print_message "Creating Docker registry secret..."
read -p "Enter your Docker Hub username: " DOCKERHUB_USERNAME
read -sp "Enter your Docker Hub password: " DOCKERHUB_PASSWORD
echo

kubectl create secret docker-registry docker-registry-secret \
    --docker-server=docker.io \
    --docker-username=$DOCKERHUB_USERNAME \
    --docker-password=$DOCKERHUB_PASSWORD \
    --namespace=$NAMESPACE \
    --dry-run=client -o yaml | kubectl apply -f -

# Step 8: Update Kubernetes manifests with Docker Hub username
print_message "Updating Kubernetes manifests with Docker Hub username..."
sed -i "s/YOUR_DOCKERHUB_USERNAME/$DOCKERHUB_USERNAME/g" k8s/backend-deployment.yaml
sed -i "s/YOUR_DOCKERHUB_USERNAME/$DOCKERHUB_USERNAME/g" k8s/frontend-deployment.yaml

# Step 9: Deploy MongoDB
print_message "Deploying MongoDB..."
kubectl apply -f k8s/mongodb-pvc.yaml -n $NAMESPACE
kubectl apply -f k8s/mongodb-deployment.yaml -n $NAMESPACE
kubectl apply -f k8s/mongodb-service.yaml -n $NAMESPACE

print_message "Waiting for MongoDB to be ready..."
kubectl wait --for=condition=ready pod -l app=mongodb --timeout=300s -n $NAMESPACE

# Step 10: Deploy Backend
print_message "Deploying Backend..."
kubectl apply -f k8s/backend-deployment.yaml -n $NAMESPACE
kubectl apply -f k8s/backend-service.yaml -n $NAMESPACE

print_message "Waiting for Backend to be ready..."
kubectl wait --for=condition=ready pod -l app=backend --timeout=300s -n $NAMESPACE

# Step 11: Get Backend External IP
print_message "Getting Backend external IP..."
print_warning "Waiting for external IP to be assigned (this may take 2-3 minutes)..."
kubectl wait --for=jsonpath='{.status.loadBalancer.ingress}' service/backend-service -n $NAMESPACE --timeout=300s

BACKEND_IP=$(kubectl get svc backend-service -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
print_message "Backend External IP: $BACKEND_IP"

# Step 12: Update Frontend deployment with Backend IP
print_message "Updating Frontend configuration with Backend IP..."
sed -i "s/BACKEND_EXTERNAL_IP/$BACKEND_IP/g" k8s/frontend-deployment.yaml
sed -i "s/BACKEND_EXTERNAL_IP/$BACKEND_IP/g" k8s/frontend-configmap.yaml

# Step 13: Deploy Frontend
print_message "Deploying Frontend..."
kubectl apply -f k8s/frontend-configmap.yaml -n $NAMESPACE
kubectl apply -f k8s/frontend-deployment.yaml -n $NAMESPACE
kubectl apply -f k8s/frontend-service.yaml -n $NAMESPACE

print_message "Waiting for Frontend to be ready..."
kubectl wait --for=condition=ready pod -l app=frontend --timeout=300s -n $NAMESPACE

# Step 14: Get Frontend External IP
print_message "Getting Frontend external IP..."
kubectl wait --for=jsonpath='{.status.loadBalancer.ingress}' service/frontend-service -n $NAMESPACE --timeout=300s

FRONTEND_IP=$(kubectl get svc frontend-service -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Step 15: Display deployment summary
echo ""
echo "========================================="
echo "         DEPLOYMENT COMPLETE! 🚀         "
echo "========================================="
echo ""
echo "Resource Group: $RESOURCE_GROUP"
echo "AKS Cluster: $AKS_CLUSTER_NAME"
echo "Namespace: $NAMESPACE"
echo ""
echo "Application URLs:"
echo "  Frontend: http://$FRONTEND_IP"
echo "  Backend API: http://$BACKEND_IP:5000"
echo ""
echo "Useful Commands:"
echo "  kubectl get pods -n $NAMESPACE"
echo "  kubectl get svc -n $NAMESPACE"
echo "  kubectl logs -f deployment/backend -n $NAMESPACE"
echo "  kubectl logs -f deployment/frontend -n $NAMESPACE"
echo ""
echo "========================================="

# Step 16: Display pod and service status
print_message "Current deployment status:"
echo ""
kubectl get pods -n $NAMESPACE
echo ""
kubectl get svc -n $NAMESPACE
echo ""

print_message "Deployment script completed successfully!"
