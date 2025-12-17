# Todo Application - Final Exam Project

A 3-tier full-stack Todo application with complete CI/CD pipeline and Kubernetes deployment.

## 🏗️ Architecture

- **Frontend**: React + Vite + Nginx
- **Backend**: Node.js + Express
- **Database**: MongoDB
- **Containerization**: Docker + Docker Compose
- **Orchestration**: Kubernetes (AKS)
- **CI/CD**: GitHub Actions

## 🚀 Quick Start

### Local Development with Docker Compose
```bash
# Start all services
docker-compose up -d

# Access the application
# Frontend: http://localhost:80
# Backend: http://localhost:5000
# MongoDB: localhost:27017
```

### Deploy to Azure Kubernetes Service (AKS)

**Windows**:
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

## 📚 Documentation

- **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)** - Complete deployment instructions for all sections
- **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - Quick command reference
- **[SUBMISSION_SUMMARY.md](SUBMISSION_SUMMARY.md)** - Final exam submission summary

## 📋 Project Structure

```
├── .github/workflows/       # CI/CD Pipeline (GitHub Actions)
├── k8s/                     # Kubernetes manifests & deployment scripts
├── mongodb/                 # MongoDB Dockerfile
├── TodoServer/              # Backend (Node.js + Express)
├── Todo_frontend/           # Frontend (React + Vite)
├── scripts/                 # Helper scripts
└── docker-compose.yml       # Multi-service orchestration
```

## 🎯 Final Exam Sections

### ✅ Section A: Containerization (10 Marks)
- Dockerfiles for all services (Frontend, Backend, Database)
- Docker Compose with networking and persistent storage

### ✅ Section B: CI/CD Automation (14 Marks)
- GitHub Actions pipeline with build, test, and deploy stages
- Automated Docker image builds and push to registry
- Triggered on push/PR

### ✅ Section C: Kubernetes on Azure (12 Marks)
- Complete AKS deployment with 3-tier architecture
- All pods running, services exposed with public IPs
- Full connectivity: Frontend → Backend → Database

## 📸 Screenshots

Run the screenshot helper:
```powershell
.\scripts\capture-screenshots.ps1
```

## 🔧 Technologies

| Component | Technology |
|-----------|-----------|
| Frontend | React 19, Vite 7, Bootstrap 5 |
| Backend | Node.js 18, Express 4 |
| Database | MongoDB (latest) |
| Web Server | Nginx (Alpine) |
| Container | Docker |
| Orchestration | Kubernetes |
| Cloud | Azure (AKS) |
| CI/CD | GitHub Actions |

## 📝 Requirements

- Docker & Docker Compose
- Node.js 18+
- Azure CLI (for AKS deployment)
- kubectl (for Kubernetes)
- Docker Hub account
- Azure subscription

## 🎓 Features Implemented

- ✅ Multi-stage Docker builds
- ✅ Health checks on all services
- ✅ Persistent storage for database
- ✅ High availability (2 replicas for frontend & backend)
- ✅ Automated CI/CD pipeline
- ✅ Infrastructure as Code (Docker Compose + K8s YAML)
- ✅ LoadBalancer services with public IPs
- ✅ Production-ready configuration

## 🆘 Troubleshooting

See the [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md#troubleshooting) for common issues and solutions.

## 📅 Submission

**Date**: December 17, 2025  
**Status**: ✅ Complete and Ready for Submission

---

**Note**: This project fulfills all requirements for Sections A, B, and C of the final exam.
