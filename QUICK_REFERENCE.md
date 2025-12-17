# Quick Reference Guide - Todo App Deployment

## 🚀 Quick Start Commands

### Docker Compose (Local Development)
```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Build and Push Docker Images
```bash
# Set your Docker Hub username
export DOCKERHUB_USERNAME="your-username"

# Build images
docker build -t $DOCKERHUB_USERNAME/todo-backend:latest ./TodoServer
docker build -t $DOCKERHUB_USERNAME/todo-frontend:latest ./Todo_frontend

# Login to Docker Hub
docker login

# Push images
docker push $DOCKERHUB_USERNAME/todo-backend:latest
docker push $DOCKERHUB_USERNAME/todo-frontend:latest
```

### Deploy to AKS (Automated)

**Windows (PowerShell)**:
```powershell
cd k8s
.\deploy-to-aks.ps1
```

**Linux/Mac**:
```bash
cd k8s
chmod +x deploy-to-aks.sh
./deploy-to-aks.sh
```

### Manual AKS Deployment

```bash
# 1. Create AKS cluster
az aks create --resource-group todo-app-rg --name todo-aks-cluster --node-count 2

# 2. Get credentials
az aks get-credentials --resource-group todo-app-rg --name todo-aks-cluster

# 3. Create namespace
kubectl create namespace todo-app

# 4. Create Docker secret
kubectl create secret docker-registry docker-registry-secret \
  --docker-server=docker.io \
  --docker-username=YOUR_USERNAME \
  --docker-password=YOUR_PASSWORD \
  --namespace=todo-app

# 5. Deploy MongoDB
kubectl apply -f k8s/mongodb-pvc.yaml -n todo-app
kubectl apply -f k8s/mongodb-deployment.yaml -n todo-app
kubectl apply -f k8s/mongodb-service.yaml -n todo-app

# 6. Deploy Backend
kubectl apply -f k8s/backend-deployment.yaml -n todo-app
kubectl apply -f k8s/backend-service.yaml -n todo-app

# 7. Get Backend IP
kubectl get svc backend-service -n todo-app

# 8. Update frontend-deployment.yaml with Backend IP

# 9. Deploy Frontend
kubectl apply -f k8s/frontend-deployment.yaml -n todo-app
kubectl apply -f k8s/frontend-service.yaml -n todo-app
```

### Verification Commands

```bash
# Check pods
kubectl get pods -n todo-app

# Check services
kubectl get svc -n todo-app

# View logs
kubectl logs -f deployment/backend -n todo-app
kubectl logs -f deployment/frontend -n todo-app

# Get application URLs
kubectl get svc -n todo-app -o wide
```

## 📋 GitHub Secrets Required

Add these in: Repository Settings → Secrets and variables → Actions

```
DOCKER_USERNAME          # Your Docker Hub username
DOCKER_PASSWORD          # Your Docker Hub password/token
AZURE_CREDENTIALS        # Azure service principal JSON
AZURE_RESOURCE_GROUP     # e.g., todo-app-rg
AKS_CLUSTER_NAME         # e.g., todo-aks-cluster
```

### Create Azure Service Principal
```bash
az ad sp create-for-rbac --name "github-actions-sp" \
  --role contributor \
  --scopes /subscriptions/{subscription-id} \
  --sdk-auth
```

## 🔧 Common Issues & Fixes

### Issue: External IP Pending
```bash
# Wait 2-3 minutes, then check again
kubectl get svc -n todo-app -w
```

### Issue: Image Pull Error
```bash
# Verify secret
kubectl get secrets -n todo-app

# Recreate secret
kubectl delete secret docker-registry-secret -n todo-app
kubectl create secret docker-registry docker-registry-secret \
  --docker-server=docker.io \
  --docker-username=YOUR_USERNAME \
  --docker-password=YOUR_PASSWORD \
  --namespace=todo-app
```

### Issue: Pod CrashLoopBackOff
```bash
# Check logs
kubectl logs <pod-name> -n todo-app

# Describe pod
kubectl describe pod <pod-name> -n todo-app
```

### Issue: Frontend can't connect to Backend
```bash
# Get backend IP
BACKEND_IP=$(kubectl get svc backend-service -n todo-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Update frontend environment
kubectl set env deployment/frontend VITE_API_URL=http://$BACKEND_IP:5000 -n todo-app

# Restart frontend
kubectl rollout restart deployment/frontend -n todo-app
```

## 📸 Screenshot Commands

### For Submission

```bash
# Docker - All containers running
docker ps

# Kubernetes - All pods
kubectl get pods -n todo-app

# Kubernetes - Services with External IPs
kubectl get svc -n todo-app

# Get application URL
kubectl get svc frontend-service -n todo-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

## 🧹 Cleanup

```bash
# Delete namespace (removes all app resources)
kubectl delete namespace todo-app

# Delete AKS cluster
az aks delete --resource-group todo-app-rg --name todo-aks-cluster --yes

# Delete resource group (removes everything)
az group delete --name todo-app-rg --yes

# Stop Docker Compose
docker-compose down -v
```

## 📱 Access URLs

After deployment, get URLs:

```bash
# Frontend URL
FRONTEND_IP=$(kubectl get svc frontend-service -n todo-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Frontend: http://$FRONTEND_IP"

# Backend URL
BACKEND_IP=$(kubectl get svc backend-service -n todo-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Backend: http://$BACKEND_IP:5000"
```

## 🎯 Expected Output

### Docker PS
```
CONTAINER ID   IMAGE                    STATUS
abc123def456   todo-frontend:latest     Up 2 minutes
def456ghi789   todo-backend:latest      Up 2 minutes
ghi789jkl012   mongo:latest             Up 2 minutes
```

### kubectl get pods
```
NAME                        READY   STATUS    RESTARTS   AGE
mongodb-xxx-xxx             1/1     Running   0          5m
backend-xxx-xxx             1/1     Running   0          4m
backend-xxx-xxx             1/1     Running   0          4m
frontend-xxx-xxx            1/1     Running   0          3m
frontend-xxx-xxx            1/1     Running   0          3m
```

### kubectl get svc
```
NAME               TYPE           EXTERNAL-IP     PORT(S)
mongodb-service    ClusterIP      10.0.xx.xx      27017/TCP
backend-service    LoadBalancer   20.XX.XX.XX     5000:xxxxx/TCP
frontend-service   LoadBalancer   20.XX.XX.XX     80:xxxxx/TCP
```

---

**Happy Deploying! 🚀**
