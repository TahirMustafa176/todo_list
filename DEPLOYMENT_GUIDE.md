# Todo Application - Final Exam Submission

## 📋 Project Overview
This is a 3-tier full-stack Todo application built with:
- **Frontend**: React + Vite
- **Backend**: Node.js + Express
- **Database**: MongoDB

---

## 🎯 SECTION A: CONTAINERIZATION (10 Marks)

### Task A1: Docker Images ✅

#### 1. Backend Dockerfile
**Location**: `TodoServer/Dockerfile`
```dockerfile
FROM node:18-alpine
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install --production
COPY . .
EXPOSE 5000
CMD ["node", "server.js"]
```

#### 2. Frontend Dockerfile
**Location**: `Todo_frontend/Dockerfile`
- Multi-stage build with Node.js and Nginx
- Optimized for production deployment
- Serves static files via Nginx

#### 3. Database Dockerfile
**Location**: `mongodb/Dockerfile`
- Based on official MongoDB image
- Includes health checks
- Configured for todo_list_db

### Task A2: Multi-Service Setup using Docker Compose ✅

**Location**: `docker-compose.yml`

**Features**:
- ✅ Starts all three services (MongoDB, Backend, Frontend)
- ✅ Common network: `todo-app-network`
- ✅ Persistent DB data with volumes:
  - `mongo_data`: Stores MongoDB database
  - `mongo_config`: Stores MongoDB configuration
- ✅ Health checks for all services
- ✅ Service dependencies managed
- ✅ Automatic restart policy

**Running the Application**:
```bash
# Start all services
docker-compose up -d

# View running containers
docker ps

# View logs
docker-compose logs -f

# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

**Access the Application**:
- Frontend: http://localhost:80
- Backend API: http://localhost:5000
- MongoDB: localhost:27017

---

## 🚀 SECTION B: CI/CD AUTOMATION (14 Marks)

### Task B1: Pipeline Development ✅

**Location**: `.github/workflows/ci-cd.yml`

**Pipeline Stages**:

1. **Build Stage (Frontend + Backend)**
   - Install dependencies
   - Run linting
   - Build frontend application
   - Upload artifacts

2. **Automated Tests**
   - Backend unit tests
   - Frontend unit tests
   - Code quality checks

3. **Docker Image Build and Push**
   - Build backend Docker image
   - Build frontend Docker image
   - Push to Docker Hub registry
   - Tag images with SHA and branch name

4. **Deployment to Kubernetes**
   - Deploy to Azure Kubernetes Service (AKS)
   - Update deployments with latest images
   - Verify deployment status
   - Run smoke tests

### Task B2: Trigger Configuration ✅

**Triggers**:
- ✅ Push to main/master/develop branches
- ✅ Pull requests to main/master/develop
- ✅ Manual workflow dispatch

**Required GitHub Secrets**:
```
DOCKER_USERNAME          # Docker Hub username
DOCKER_PASSWORD          # Docker Hub password
AZURE_CREDENTIALS        # Azure service principal credentials
AZURE_RESOURCE_GROUP     # Azure resource group name
AKS_CLUSTER_NAME         # AKS cluster name
```

**Setting up GitHub Secrets**:
1. Go to your repository Settings
2. Navigate to Secrets and variables > Actions
3. Add the required secrets

**Creating Azure Credentials**:
```bash
az ad sp create-for-rbac --name "github-actions-sp" \
  --role contributor \
  --scopes /subscriptions/{subscription-id}/resourceGroups/{resource-group} \
  --sdk-auth
```

---

## ☸️ SECTION C: KUBERNETES ON AZURE (AKS) (12 Marks)

### Task C1: Kubernetes Manifests ✅

**Location**: `k8s/` directory

**Kubernetes Resources Created**:

1. **MongoDB**:
   - `mongodb-pvc.yaml` - Persistent Volume Claim (5Gi)
   - `mongodb-deployment.yaml` - Deployment with 1 replica
   - `mongodb-service.yaml` - ClusterIP service

2. **Backend**:
   - `backend-deployment.yaml` - Deployment with 2 replicas
   - `backend-service.yaml` - LoadBalancer service (exposes public IP)

3. **Frontend**:
   - `frontend-deployment.yaml` - Deployment with 2 replicas
   - `frontend-service.yaml` - LoadBalancer service (exposes public IP)
   - `frontend-configmap.yaml` - Configuration for backend URL

### Task C2: AKS Deployment Verification ✅

**Creating AKS Cluster**:

#### Option 1: Using Azure Portal
1. Go to Azure Portal
2. Create a resource > Kubernetes Service
3. Fill in the details:
   - Resource Group: `todo-app-rg`
   - Cluster name: `todo-aks-cluster`
   - Region: East US
   - Node size: Standard_B2s
   - Node count: 2

#### Option 2: Using Azure CLI
```bash
# Create resource group
az group create --name todo-app-rg --location eastus

# Create AKS cluster
az aks create \
  --resource-group todo-app-rg \
  --name todo-aks-cluster \
  --node-count 2 \
  --node-vm-size Standard_B2s \
  --enable-managed-identity \
  --generate-ssh-keys

# Get credentials
az aks get-credentials --resource-group todo-app-rg --name todo-aks-cluster
```

#### Option 3: Using Deployment Script (Automated)
**For Linux/Mac**:
```bash
cd k8s
chmod +x deploy-to-aks.sh
./deploy-to-aks.sh
```

**For Windows (PowerShell)**:
```powershell
cd k8s
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\deploy-to-aks.ps1
```

### Deploying Application to AKS

**Step 1: Build and Push Docker Images**
```bash
# Build images
docker build -t YOUR_DOCKERHUB_USERNAME/todo-backend:latest ./TodoServer
docker build -t YOUR_DOCKERHUB_USERNAME/todo-frontend:latest ./Todo_frontend

# Push to Docker Hub
docker login
docker push YOUR_DOCKERHUB_USERNAME/todo-backend:latest
docker push YOUR_DOCKERHUB_USERNAME/todo-frontend:latest
```

**Step 2: Update Kubernetes Manifests**
1. Replace `YOUR_DOCKERHUB_USERNAME` in:
   - `k8s/backend-deployment.yaml`
   - `k8s/frontend-deployment.yaml`

**Step 3: Create Docker Registry Secret**
```bash
kubectl create namespace todo-app

kubectl create secret docker-registry docker-registry-secret \
  --docker-server=docker.io \
  --docker-username=YOUR_USERNAME \
  --docker-password=YOUR_PASSWORD \
  --namespace=todo-app
```

**Step 4: Deploy MongoDB**
```bash
kubectl apply -f k8s/mongodb-pvc.yaml -n todo-app
kubectl apply -f k8s/mongodb-deployment.yaml -n todo-app
kubectl apply -f k8s/mongodb-service.yaml -n todo-app

# Wait for MongoDB to be ready
kubectl wait --for=condition=ready pod -l app=mongodb --timeout=300s -n todo-app
```

**Step 5: Deploy Backend**
```bash
kubectl apply -f k8s/backend-deployment.yaml -n todo-app
kubectl apply -f k8s/backend-service.yaml -n todo-app

# Wait for Backend to be ready
kubectl wait --for=condition=ready pod -l app=backend --timeout=300s -n todo-app

# Get Backend External IP
kubectl get svc backend-service -n todo-app
```

**Step 6: Update Frontend with Backend IP**
```bash
# Get backend external IP
BACKEND_IP=$(kubectl get svc backend-service -n todo-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Update frontend-deployment.yaml
# Replace BACKEND_EXTERNAL_IP with the actual IP
# value: "http://BACKEND_EXTERNAL_IP:5000"  -->  value: "http://20.XX.XX.XX:5000"
```

**Step 7: Deploy Frontend**
```bash
kubectl apply -f k8s/frontend-deployment.yaml -n todo-app
kubectl apply -f k8s/frontend-service.yaml -n todo-app

# Get Frontend External IP
kubectl get svc frontend-service -n todo-app
```

### Verification Commands

**1. Check All Pods are Running**
```bash
kubectl get pods -n todo-app
```
Expected output:
```
NAME                        READY   STATUS    RESTARTS   AGE
mongodb-xxxxxxxxxx-xxxxx    1/1     Running   0          5m
backend-xxxxxxxxxx-xxxxx    1/1     Running   0          4m
backend-xxxxxxxxxx-xxxxx    1/1     Running   0          4m
frontend-xxxxxxxxxx-xxxxx   1/1     Running   0          3m
frontend-xxxxxxxxxx-xxxxx   1/1     Running   0          3m
```

**2. Check Services**
```bash
kubectl get svc -n todo-app
```
Expected output:
```
NAME               TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)
mongodb-service    ClusterIP      10.0.xx.xx     <none>         27017/TCP
backend-service    LoadBalancer   10.0.xx.xx     20.XX.XX.XX    5000:xxxxx/TCP
frontend-service   LoadBalancer   10.0.xx.xx     20.XX.XX.XX    80:xxxxx/TCP
```

**3. Check Deployment Status**
```bash
kubectl get deployments -n todo-app
```

**4. View Logs**
```bash
# Backend logs
kubectl logs -f deployment/backend -n todo-app

# Frontend logs
kubectl logs -f deployment/frontend -n todo-app

# MongoDB logs
kubectl logs -f deployment/mongodb -n todo-app
```

**5. Describe Pod (for troubleshooting)**
```bash
kubectl describe pod <pod-name> -n todo-app
```

### Testing the Application

**1. Test Backend API**
```bash
# Get backend IP
BACKEND_IP=$(kubectl get svc backend-service -n todo-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Test API endpoint
curl http://$BACKEND_IP:5000/todos
```

**2. Test Frontend**
```bash
# Get frontend IP
FRONTEND_IP=$(kubectl get svc frontend-service -n todo-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Open in browser
echo "Frontend URL: http://$FRONTEND_IP"
```

**3. Test Database Connection**
```bash
# Port forward to MongoDB
kubectl port-forward svc/mongodb-service 27017:27017 -n todo-app

# Connect using MongoDB client
mongosh mongodb://localhost:27017/todo_list_db
```

---

## 📸 Screenshots to Submit

### Section A - Docker
1. **All containers running**:
   ```bash
   docker ps
   ```
   Screenshot showing all 3 containers (mongo, backend, frontend)

2. **Docker Compose services**:
   ```bash
   docker-compose ps
   ```

### Section B - CI/CD
1. **Pipeline file**: Screenshot of `.github/workflows/ci-cd.yml`
2. **Pipeline run**: Screenshot showing all stages completed successfully
3. **Docker Hub**: Screenshot showing pushed images

### Section C - Kubernetes
1. **Pods running**:
   ```bash
   kubectl get pods -n todo-app
   ```
   
2. **Services with External IPs**:
   ```bash
   kubectl get svc -n todo-app
   ```
   
3. **Running application**: Screenshot of the frontend in browser showing:
   - Frontend connecting to backend ✅
   - Backend connecting to database ✅
   - Add/Edit/Delete functionality working ✅

4. **AKS Cluster**: Screenshot from Azure Portal showing the cluster

---

## 🔧 Troubleshooting

### Common Issues

**1. Backend can't connect to MongoDB**
```bash
# Check MongoDB is running
kubectl get pods -l app=mongodb -n todo-app

# Check logs
kubectl logs deployment/mongodb -n todo-app
```

**2. Frontend can't reach Backend**
- Ensure Backend service has External IP assigned
- Update frontend-deployment.yaml with correct Backend IP
- Redeploy frontend:
  ```bash
  kubectl rollout restart deployment/frontend -n todo-app
  ```

**3. External IP showing <pending>**
- Wait 2-3 minutes for Azure to assign IP
- Check Azure Load Balancer is being created:
  ```bash
  kubectl describe svc backend-service -n todo-app
  ```

**4. Image pull errors**
- Verify Docker Hub credentials
- Check secret exists:
  ```bash
  kubectl get secrets -n todo-app
  ```
- Recreate secret if needed

**5. Pods in CrashLoopBackOff**
```bash
# Check pod logs
kubectl logs <pod-name> -n todo-app

# Describe pod for events
kubectl describe pod <pod-name> -n todo-app
```

---

## 🧹 Cleanup

**Remove all Kubernetes resources**:
```bash
kubectl delete namespace todo-app
```

**Delete AKS cluster**:
```bash
az aks delete --resource-group todo-app-rg --name todo-aks-cluster --yes --no-wait
```

**Delete resource group (removes everything)**:
```bash
az group delete --name todo-app-rg --yes --no-wait
```

**Stop Docker Compose**:
```bash
docker-compose down -v
```

---

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

---

## ✅ Submission Checklist

### Section A: Containerization
- [ ] TodoServer/Dockerfile
- [ ] Todo_frontend/Dockerfile
- [ ] mongodb/Dockerfile
- [ ] docker-compose.yml
- [ ] Screenshot of `docker ps` showing all containers running

### Section B: CI/CD
- [ ] .github/workflows/ci-cd.yml
- [ ] Screenshot of pipeline run (all stages completed)
- [ ] Screenshot of Docker Hub images

### Section C: Kubernetes
- [ ] k8s/mongodb-deployment.yaml
- [ ] k8s/mongodb-service.yaml
- [ ] k8s/mongodb-pvc.yaml
- [ ] k8s/backend-deployment.yaml
- [ ] k8s/backend-service.yaml
- [ ] k8s/frontend-deployment.yaml
- [ ] k8s/frontend-service.yaml
- [ ] Screenshot of `kubectl get pods -n todo-app`
- [ ] Screenshot of `kubectl get svc -n todo-app`
- [ ] Screenshot of running application with reachable link

---

## 👤 Author
**Student Name**: [Your Name]  
**Student ID**: [Your ID]  
**Date**: December 17, 2025

---

## 📝 Notes

### Important Note about Frontend-Backend Connection in Kubernetes

The frontend needs the backend's external IP address to communicate. This is handled in two ways:

1. **During Deployment**: The deployment script automatically gets the backend IP and updates the frontend configuration before deploying it.

2. **Manual Update**: If needed, update the environment variable:
   ```bash
   kubectl set env deployment/frontend VITE_API_URL=http://BACKEND_IP:5000 -n todo-app
   ```

### Resource Requirements

**Minimum Azure Resources**:
- AKS Cluster: 2 nodes (Standard_B2s)
- Storage: 5Gi for MongoDB
- Public IPs: 2 (Frontend and Backend)

**Estimated Monthly Cost**: ~$50-70 USD (for testing/development)

---

**End of Documentation**
