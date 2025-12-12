# Go + Redis Kubernetes Lab (MicroK8s + Helm + Ingress)

A beginner-friendly DevOps lab that takes a tiny Go + Redis app from **local code → Docker image → Kubernetes → Helm chart → Ingress hostname**.

## What you’ll learn
- How Kubernetes Deployments + Services connect an app to Redis
- How to package the stack as a **Helm chart** (reusable installs)
- How to add **readiness/liveness probes** for safer rollouts
- How to expose the app via **Ingress + local hostname** (`go-app.local`)

## Architecture (simple)
- **Go API** exposes `GET /visits` and stores a counter in Redis
- **Redis** runs inside the cluster (ClusterIP Service)
- **Ingress (NGINX)** routes `http://go-app.local/visits` → Go service

## Prerequisites
On the Ubuntu VM:
- MicroK8s installed and running
- Addons enabled:

  ```bash
  sudo microk8s enable dns ingress helm3

## Quick start
1. Build & push the image (or use the pre-built one)
2. Install the Helm chart
3. Add `go-app.local` to `/etc/hosts` and browse!



# 🚀 Go + Redis + Kubernetes Demo Application
A simple **Go web application** backed by **Redis**, containerized with **Docker**, and deployed on **Kubernetes (MicroK8s)**.  
This project demonstrates real-world DevOps skills across:

- Go application development  
- Redis integration  
- Docker containerization  
- Kubernetes manifests & deployments  
- MicroK8s local cluster operation  
- Service exposure (NodePort & LoadBalancer)  
- CI/CD readiness for GHCR (GitHub Container Registry)

---

## 📌 Features
- `/` → Basic welcome message  
- `/visits` → Redis-backed visitor counter  
- `/healthz` → Health check endpoint  
- Microservice architecture using Go + Redis  
- Works locally with Docker or on Kubernetes  
- Production-friendly YAML manifests  
- Ready for CI/CD pipeline integration  

---

# 🏗️ Architecture

               ┌────────────────────────────┐
               │        Go Web App          │
               │  (Docker Container)        │
               └──────────────┬─────────────┘
                              │ REST Calls
                              ▼
                  ┌─────────────────────┐
                  │      Redis DB       │
                  │ (Docker/Kubernetes) │
                  └─────────────────────┘

┌─────────────────────────────── Kubernetes Cluster ───────────────────────────────┐
│ │
│ ┌────────────────────┐ ┌────────────────────┐ ┌────────────────────┐ │
│ │ Deployment (Go) │ --> │ Service (NodePort) │ --> │ External Access │ │
│ └────────────────────┘ └────────────────────┘ └────────────────────┘ │
│ │
│ ┌────────────────────┐ ┌────────────────────┐ │
│ │ Deployment (Redis) │ --> │ ClusterIP Service │ │
│ └────────────────────┘ └────────────────────┘ │
│ │
└──────────────────────────────────────────────────────────────────────────────────┘

---

# 📁 Project Structure

go-redis-k8s-lab/
│
├── app/ # Go application code
│ ├── main.go
│ └── go.mod
│
├── k8s/ # Kubernetes manifests
│ ├── redis.yaml
│ ├── redis-storage.yaml
│ ├── redis-configmap.yaml
│ ├── go-app-deployment.yaml
│ ├── go-app-service.yaml
│
├── Dockerfile # Multi-stage Go build
├── docker-compose.yaml # Local test with Docker/Redis
└── README.md


---

# 🚀 Running Locally (Docker)

### 1️⃣ Build the Docker image
```bash
docker build -t go-redis-app .
docker-compose up
curl localhost:8080
curl localhost:8080/visits

☸️ Deploying on Kubernetes (MicroK8s)
0️⃣ Enable needed addons
sudo microk8s enable dns storage

1️⃣ Create namespace
sudo microk8s kubectl create ns go-redis-app

2️⃣ Deploy Redis
sudo microk8s kubectl apply -f k8s/redis-configmap.yaml -n go-redis-app
sudo microk8s kubectl apply -f k8s/redis-storage.yaml -n go-redis-app
sudo microk8s kubectl apply -f k8s/redis.yaml -n go-redis-app

Check Redis:
sudo microk8s kubectl get pods -n go-redis-app

3️⃣ Deploy Go App
sudo microk8s kubectl apply -f k8s/go-app-deployment.yaml -n go-redis-app
sudo microk8s kubectl apply -f k8s/go-app-service.yaml -n go-redis-app

4️⃣ Test the Service
Find NodePort:
sudo microk8s kubectl get svc -n go-redis-app
Example:
go-app   NodePort   10.152.183.104   <none>   8080:31980/TCP
Test the app:
curl localhost:31980/visits
Expected result:
👋 Visitor Count: 1

🔄 CI/CD (GitHub Actions + GHCR)

This repo is ready for CI/CD.
Create a workflow at:
.github/workflows/cicd.yml
Required secrets:

GHCR_TOKEN

(optional) GHCR_USERNAME

Pipeline workflow:

Build Go binary

Build Docker image

Push to GHCR

Trigger Kubernetes rollout

🩺 Health Endpoints
| Endpoint   | Description              |
| ---------- | ------------------------ |
| `/`        | Hello message            |
| `/visits`  | Redis-backed counter     |
| `/healthz` | Liveness/health endpoint |

🐛 Troubleshooting
❌ App fails with: redis: i/o timeout
Go app deployed before Redis was ready.
Fix:
sudo microk8s kubectl rollout restart deployment go-app -n go-redis-app

❌ No space left (MicroK8s)
Enable cleaning:
sudo rm -rf /var/lib/snapd/cache/*
sudo apt autoremove -y
df -h

⭐ Author

Adeyemi (Adey) — DevOps | Cloud | SRE | AI Integrations
GitHub: https://github.com/Griffindeetox

