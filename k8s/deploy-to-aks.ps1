# Todo App - Kubernetes Deployment Script for AKS (PowerShell)
# This script deploys the complete 3-tier application to Azure Kubernetes Service

# Variables - UPDATE THESE
$RESOURCE_GROUP = "todo-app-rg"
$AKS_CLUSTER_NAME = "todo-aks-cluster"
$LOCATION = "eastus"
$NAMESPACE = "todo-app"
$DOCKERHUB_USERNAME = "YOUR_DOCKERHUB_USERNAME"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Todo App - AKS Deployment Script" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Check if Azure CLI is installed
if (!(Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] Azure CLI is not installed. Please install it first." -ForegroundColor Red
    exit 1
}

# Check if kubectl is installed
if (!(Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] kubectl is not installed. Please install it first." -ForegroundColor Red
    exit 1
}

# Step 1: Azure Login
Write-Host "[INFO] Logging in to Azure..." -ForegroundColor Green
az login

# Step 2: Create Resource Group
Write-Host "[INFO] Creating resource group: $RESOURCE_GROUP" -ForegroundColor Green
az group create --name $RESOURCE_GROUP --location $LOCATION

# Step 3: Create AKS Cluster
Write-Host "[INFO] Creating AKS cluster: $AKS_CLUSTER_NAME (this may take 5-10 minutes)..." -ForegroundColor Green
az aks create `
    --resource-group $RESOURCE_GROUP `
    --name $AKS_CLUSTER_NAME `
    --node-count 2 `
    --node-vm-size Standard_B2s `
    --enable-managed-identity `
    --generate-ssh-keys `
    --network-plugin azure `
    --network-policy azure

# Step 4: Get AKS credentials
Write-Host "[INFO] Getting AKS credentials..." -ForegroundColor Green
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER_NAME --overwrite-existing

# Step 5: Verify cluster connection
Write-Host "[INFO] Verifying cluster connection..." -ForegroundColor Green
kubectl cluster-info
kubectl get nodes

# Step 6: Create namespace
Write-Host "[INFO] Creating namespace: $NAMESPACE" -ForegroundColor Green
kubectl create namespace $NAMESPACE 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "[WARNING] Namespace already exists" -ForegroundColor Yellow
}

# Step 7: Create Docker registry secret
Write-Host "[INFO] Creating Docker registry secret..." -ForegroundColor Green
$DOCKERHUB_USERNAME = Read-Host "Enter your Docker Hub username"
$DOCKERHUB_PASSWORD = Read-Host "Enter your Docker Hub password" -AsSecureString
$DOCKERHUB_PASSWORD_PLAIN = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($DOCKERHUB_PASSWORD))

kubectl create secret docker-registry docker-registry-secret `
    --docker-server=docker.io `
    --docker-username=$DOCKERHUB_USERNAME `
    --docker-password=$DOCKERHUB_PASSWORD_PLAIN `
    --namespace=$NAMESPACE `
    --dry-run=client -o yaml | kubectl apply -f -

# Step 8: Update Kubernetes manifests with Docker Hub username
Write-Host "[INFO] Updating Kubernetes manifests with Docker Hub username..." -ForegroundColor Green
(Get-Content k8s/backend-deployment.yaml) -replace 'YOUR_DOCKERHUB_USERNAME', $DOCKERHUB_USERNAME | Set-Content k8s/backend-deployment.yaml
(Get-Content k8s/frontend-deployment.yaml) -replace 'YOUR_DOCKERHUB_USERNAME', $DOCKERHUB_USERNAME | Set-Content k8s/frontend-deployment.yaml

# Step 9: Deploy MongoDB
Write-Host "[INFO] Deploying MongoDB..." -ForegroundColor Green
kubectl apply -f k8s/mongodb-pvc.yaml -n $NAMESPACE
kubectl apply -f k8s/mongodb-deployment.yaml -n $NAMESPACE
kubectl apply -f k8s/mongodb-service.yaml -n $NAMESPACE

Write-Host "[INFO] Waiting for MongoDB to be ready..." -ForegroundColor Green
kubectl wait --for=condition=ready pod -l app=mongodb --timeout=300s -n $NAMESPACE

# Step 10: Deploy Backend
Write-Host "[INFO] Deploying Backend..." -ForegroundColor Green
kubectl apply -f k8s/backend-deployment.yaml -n $NAMESPACE
kubectl apply -f k8s/backend-service.yaml -n $NAMESPACE

Write-Host "[INFO] Waiting for Backend to be ready..." -ForegroundColor Green
kubectl wait --for=condition=ready pod -l app=backend --timeout=300s -n $NAMESPACE

# Step 11: Get Backend External IP
Write-Host "[INFO] Getting Backend external IP..." -ForegroundColor Green
Write-Host "[WARNING] Waiting for external IP to be assigned (this may take 2-3 minutes)..." -ForegroundColor Yellow
kubectl wait --for=jsonpath='{.status.loadBalancer.ingress}' service/backend-service -n $NAMESPACE --timeout=300s

$BACKEND_IP = kubectl get svc backend-service -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
Write-Host "[INFO] Backend External IP: $BACKEND_IP" -ForegroundColor Green

# Step 12: Update Frontend deployment with Backend IP
Write-Host "[INFO] Updating Frontend configuration with Backend IP..." -ForegroundColor Green
(Get-Content k8s/frontend-deployment.yaml) -replace 'BACKEND_EXTERNAL_IP', $BACKEND_IP | Set-Content k8s/frontend-deployment.yaml
(Get-Content k8s/frontend-configmap.yaml) -replace 'BACKEND_EXTERNAL_IP', $BACKEND_IP | Set-Content k8s/frontend-configmap.yaml

# Step 13: Deploy Frontend
Write-Host "[INFO] Deploying Frontend..." -ForegroundColor Green
kubectl apply -f k8s/frontend-configmap.yaml -n $NAMESPACE
kubectl apply -f k8s/frontend-deployment.yaml -n $NAMESPACE
kubectl apply -f k8s/frontend-service.yaml -n $NAMESPACE

Write-Host "[INFO] Waiting for Frontend to be ready..." -ForegroundColor Green
kubectl wait --for=condition=ready pod -l app=frontend --timeout=300s -n $NAMESPACE

# Step 14: Get Frontend External IP
Write-Host "[INFO] Getting Frontend external IP..." -ForegroundColor Green
kubectl wait --for=jsonpath='{.status.loadBalancer.ingress}' service/frontend-service -n $NAMESPACE --timeout=300s

$FRONTEND_IP = kubectl get svc frontend-service -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# Step 15: Display deployment summary
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "         DEPLOYMENT COMPLETE! 🚀         " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Resource Group: $RESOURCE_GROUP" -ForegroundColor White
Write-Host "AKS Cluster: $AKS_CLUSTER_NAME" -ForegroundColor White
Write-Host "Namespace: $NAMESPACE" -ForegroundColor White
Write-Host ""
Write-Host "Application URLs:" -ForegroundColor Yellow
Write-Host "  Frontend: http://$FRONTEND_IP" -ForegroundColor Green
Write-Host "  Backend API: http://$BACKEND_IP:5000" -ForegroundColor Green
Write-Host ""
Write-Host "Useful Commands:" -ForegroundColor Yellow
Write-Host "  kubectl get pods -n $NAMESPACE"
Write-Host "  kubectl get svc -n $NAMESPACE"
Write-Host "  kubectl logs -f deployment/backend -n $NAMESPACE"
Write-Host "  kubectl logs -f deployment/frontend -n $NAMESPACE"
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan

# Step 16: Display pod and service status
Write-Host "[INFO] Current deployment status:" -ForegroundColor Green
Write-Host ""
kubectl get pods -n $NAMESPACE
Write-Host ""
kubectl get svc -n $NAMESPACE
Write-Host ""

Write-Host "[INFO] Deployment script completed successfully!" -ForegroundColor Green
