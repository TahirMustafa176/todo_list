# 📋 Final Exam Submission Checklist

## Before Submission - Verify All Items

### Section A: Containerization (10 Marks)

#### Files to Submit:
- [ ] `TodoServer/Dockerfile` - Backend Dockerfile
- [ ] `Todo_frontend/Dockerfile` - Frontend Dockerfile  
- [ ] `Todo_frontend/nginx.conf` - Nginx configuration
- [ ] `mongodb/Dockerfile` - Database Dockerfile
- [ ] `docker-compose.yml` - Multi-service setup

#### Screenshots:
- [ ] Screenshot: `docker ps` showing all 3 containers running
- [ ] Screenshot: `docker-compose ps` showing services

#### Verification:
```bash
# Test locally
docker-compose up -d
docker ps
# Should show: mongo, backend, frontend containers

# Test access
# Frontend: http://localhost:80
# Backend: http://localhost:5000/todos
```

---

### Section B: CI/CD Automation (14 Marks)

#### Files to Submit:
- [ ] `.github/workflows/ci-cd.yml` - GitHub Actions pipeline

#### Pipeline Features Checklist:
- [ ] Build stage for frontend
- [ ] Build stage for backend
- [ ] Automated tests (frontend & backend)
- [ ] Docker image build
- [ ] Docker image push to registry
- [ ] Deployment to Kubernetes/AKS
- [ ] Triggered on push/commit
- [ ] Triggered on pull request

#### Screenshots:
- [ ] Screenshot: Workflow file (.github/workflows/ci-cd.yml)
- [ ] Screenshot: Pipeline run showing ALL stages completed (green checkmarks)
- [ ] Screenshot: Docker Hub showing pushed images

#### GitHub Secrets Required:
- [ ] `DOCKER_USERNAME`
- [ ] `DOCKER_PASSWORD`
- [ ] `AZURE_CREDENTIALS`
- [ ] `AZURE_RESOURCE_GROUP`
- [ ] `AKS_CLUSTER_NAME`

#### Verification:
```bash
# Push to GitHub and verify pipeline runs
git add .
git commit -m "Final exam submission"
git push origin main

# Check GitHub Actions tab for pipeline execution
```

---

### Section C: Kubernetes on Azure (AKS) (12 Marks)

#### Files to Submit:
- [ ] `k8s/mongodb-pvc.yaml` - Persistent Volume Claim
- [ ] `k8s/mongodb-deployment.yaml` - MongoDB deployment
- [ ] `k8s/mongodb-service.yaml` - MongoDB service
- [ ] `k8s/backend-deployment.yaml` - Backend deployment
- [ ] `k8s/backend-service.yaml` - Backend LoadBalancer service
- [ ] `k8s/frontend-deployment.yaml` - Frontend deployment
- [ ] `k8s/frontend-service.yaml` - Frontend LoadBalancer service
- [ ] `k8s/frontend-configmap.yaml` - Frontend configuration
- [ ] `k8s/deploy-to-aks.sh` - Linux/Mac deployment script
- [ ] `k8s/deploy-to-aks.ps1` - Windows deployment script

#### Screenshots Required:
- [ ] Screenshot: `kubectl get pods -n todo-app` (all pods in Running state)
- [ ] Screenshot: `kubectl get svc -n todo-app` (services with External IPs)
- [ ] Screenshot: Browser showing frontend with accessible link/URL
- [ ] Screenshot: Azure Portal showing AKS cluster
- [ ] Screenshot: Application working (add/edit/delete todo items)

#### Deployment Checklist:
- [ ] AKS cluster created
- [ ] Docker images pushed to Docker Hub
- [ ] Docker registry secret created in Kubernetes
- [ ] MongoDB deployed and running
- [ ] Backend deployed and running
- [ ] Backend External IP obtained
- [ ] Frontend updated with Backend IP
- [ ] Frontend deployed and running
- [ ] Frontend External IP obtained

#### Verification Commands:
```bash
# Check pods are running
kubectl get pods -n todo-app
# Expected: All pods should show 1/1 READY and Running status

# Check services have External IPs
kubectl get svc -n todo-app
# Expected: backend-service and frontend-service should have External IPs

# Test backend API
curl http://BACKEND_IP:5000/todos

# Test frontend
# Open http://FRONTEND_IP in browser
```

#### Application Connectivity:
- [ ] Frontend can load in browser
- [ ] Frontend can connect to Backend (add todo works)
- [ ] Backend can connect to Database (todos are persisted)
- [ ] All CRUD operations work (Create, Read, Update, Delete)

---

### Documentation

#### Files to Submit:
- [ ] `README.md` - Project overview
- [ ] `DEPLOYMENT_GUIDE.md` - Complete deployment instructions
- [ ] `QUICK_REFERENCE.md` - Quick command reference
- [ ] `SUBMISSION_SUMMARY.md` - Submission summary
- [ ] `.gitignore` - Git ignore file

---

### Additional Files

- [ ] `Todo_frontend/.env.example` - Environment variable template
- [ ] `scripts/capture-screenshots.ps1` - Screenshot helper script

---

## Final Verification Steps

### 1. Test Docker Compose Locally
```bash
cd /path/to/todo-list
docker-compose down -v  # Clean start
docker-compose up -d
docker ps  # Take screenshot
# Open http://localhost:80 and test the app
```

### 2. Verify GitHub Pipeline
```bash
# Check your repository's Actions tab
# Ensure latest push triggered the pipeline
# Verify all stages completed successfully
# Take screenshot
```

### 3. Verify AKS Deployment
```bash
# Connect to AKS
az aks get-credentials --resource-group todo-app-rg --name todo-aks-cluster

# Check all resources
kubectl get all -n todo-app

# Get URLs
kubectl get svc -n todo-app

# Test application in browser
```

### 4. Organize Screenshots
```
screenshots/
├── section-a-docker-ps.png
├── section-a-docker-compose-ps.png
├── section-b-workflow-file.png
├── section-b-pipeline-success.png
├── section-b-dockerhub-images.png
├── section-c-pods-running.png
├── section-c-services.png
├── section-c-app-running.png
├── section-c-aks-cluster.png
└── section-c-app-working.png
```

---

## Submission Package Contents

Your submission should include:

### 1. Source Code
- All Dockerfiles
- docker-compose.yml
- Kubernetes manifests (k8s/ directory)
- GitHub Actions workflow
- Application source code

### 2. Documentation
- README.md
- DEPLOYMENT_GUIDE.md
- QUICK_REFERENCE.md
- SUBMISSION_SUMMARY.md

### 3. Screenshots (10 total)
- Section A: 2 screenshots
- Section B: 3 screenshots
- Section C: 5 screenshots

### 4. Scripts
- Deployment scripts (deploy-to-aks.sh, deploy-to-aks.ps1)
- Screenshot helper (capture-screenshots.ps1)

---

## Pre-Submission Commands

Run these to verify everything works:

```bash
# 1. Test Docker Compose
docker-compose up -d && docker ps

# 2. Build and push Docker images
docker build -t YOUR_USERNAME/todo-backend:latest ./TodoServer
docker build -t YOUR_USERNAME/todo-frontend:latest ./Todo_frontend
docker push YOUR_USERNAME/todo-backend:latest
docker push YOUR_USERNAME/todo-frontend:latest

# 3. Deploy to AKS (Windows)
cd k8s
.\deploy-to-aks.ps1

# 4. Verify deployment
kubectl get pods -n todo-app
kubectl get svc -n todo-app

# 5. Test application
# Open frontend URL in browser
```

---

## Common Issues to Check

- [ ] Docker images are public or pull secret is configured
- [ ] Backend External IP is updated in frontend-deployment.yaml
- [ ] All pods show "Running" status
- [ ] External IPs are assigned to LoadBalancer services
- [ ] Application is accessible from public internet
- [ ] GitHub secrets are all configured correctly
- [ ] Screenshots clearly show required information

---

## Grading Criteria Checklist

### Section A (10 marks):
- [ ] 3 Dockerfiles created correctly
- [ ] docker-compose.yml with all services
- [ ] Network configuration
- [ ] Volume persistence
- [ ] Screenshots showing containers running

### Section B (14 marks):
- [ ] Pipeline file with all required stages
- [ ] Build stage implemented
- [ ] Test stage implemented
- [ ] Docker build/push stage implemented
- [ ] Deployment stage implemented
- [ ] Triggered on push/PR
- [ ] Screenshots showing successful pipeline run

### Section C (12 marks):
- [ ] AKS cluster created
- [ ] Kubernetes manifests for all services
- [ ] All pods in Running state
- [ ] Services with External IPs
- [ ] Application accessible via public IP
- [ ] Screenshots showing deployment and working app

---

## Final Check - Everything Ready?

- [ ] All code files present
- [ ] All documentation complete
- [ ] All 10 screenshots captured
- [ ] Tested locally with Docker Compose
- [ ] Tested in Azure AKS
- [ ] Application fully functional
- [ ] Repository pushed to GitHub
- [ ] Pipeline ran successfully

---

## 🎉 Ready to Submit!

If all items above are checked, your project is ready for submission.

**Good luck! 🚀**

---

**Submission Date**: December 17, 2025  
**Project Status**: ✅ COMPLETE
