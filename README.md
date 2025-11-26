# go-redis-k8s-lab

End-to-end DevOps project: a small Go visitor-counter API that stores state in Redis, is containerized with Docker, and is deployable to a MicroK8s Kubernetes cluster using included manifests.

Table of contents
- Overview
- Features
- Architecture
- Endpoints
- Prerequisites
- Quickstart (local)
- Build and run (Docker)
- Deploy to MicroK8s (Kubernetes)
- Configuration / Environment variables
- Kubernetes manifests
- File layout
- Development notes
- Contributing
- License

Overview
This repository demonstrates the full lifecycle of a simple stateful microservice:
- A single-file Go HTTP API (main.go) that counts visitors and persists the counter in Redis.
- Dockerfile to build a production container (multi-stage).
- Kubernetes manifests and helper scripts (k8s/) to deploy the API and a Redis backend to MicroK8s.

Features
- Small, idiomatic Go HTTP server
- Redis-backed visitor counter
- Health endpoint that validates Redis connectivity
- Dockerized with a minimal runtime image
- Kubernetes manifests for local MicroK8s deployments

Architecture
Client -> HTTP API (Go) -> Redis
The API exposes simple HTTP endpoints that increment/read a counter stored in Redis. Redis is expected to be reachable at redis:6379 by default when deployed to the included Kubernetes manifests.

Endpoints (exact paths implemented in main.go)
- GET /
  - Returns a simple greeting: "🚀 Hello from Go + Redis!"
- GET /visits
  - Increments and returns a visitor counter stored in Redis under the key "visits".
  - Response example: 👋 Visitor Count: 42
- GET /healthz
  - Performs a Redis PING and returns JSON status. 200 when Redis is reachable, 503 when not.
  - Response examples:
    - {"status":"ok","redis":"connected"}
    - {"status":"unhealthy","redis":"unreachable"}

Implementation notes (from code)
- main.go uses github.com/redis/go-redis/v9 and a package-level Redis client.
- Redis is instantiated with Addr: "redis:6379" and no password by default.
- Server listens on port 8080 (port string in code is ":8080").

Prerequisites
- Git
- Go (for local development/build) — repo builds with go build main.go (tested with Go 1.22 in the Dockerfile)
- Docker (to build the container image locally)
- MicroK8s (or another Kubernetes cluster) and kubectl (or microk8s kubectl) to deploy the manifests
- (Optional) redis-cli for debugging Redis

Quickstart — local (developer)
1. Clone the repository:
   git clone https://github.com/Griffindeetox/go-redis-k8s-lab.git
   cd go-redis-k8s-lab
2. Run locally with Go:
   go run main.go
3. Verify endpoints:
   curl http://localhost:8080/
   curl http://localhost:8080/visits
   curl http://localhost:8080/healthz

Build and run with Docker
1. Build the image (example):
   docker build -t griffindeetox/go-redis-k8s-lab:local .
2. Run a Redis container for local testing:
   docker run -d --name redis-test -p 6379:6379 redis:7
3. Run the app container and point it at the local Redis:
   docker run --rm -p 8080:8080 \
     -e REDIS_ADDR=host.docker.internal:6379 \
     griffindeetox/go-redis-k8s-lab:local
   # On Linux, replace host.docker.internal with the host IP or run the containers in the same network.

Deploy to MicroK8s (Kubernetes)
The repository includes k8s/ manifests and a small deploy script (k8s/deploy.sh) that applies the following files in order:
- namespace.yaml
- redis-configmap.yaml
- redis-storage.yaml
- redis.yaml
- app.yaml

Basic steps:
1. Ensure MicroK8s is running:
   microk8s status --wait-ready
2. Run the deploy script (it uses microk8s kubectl):
   bash k8s/deploy.sh
3. Check pods and services in the namespace (k8s/deploy.sh prints pods and svc for the go-redis-app namespace):
   microk8s kubectl get pods,svc -n go-redis-app
4. Port-forward to reach the app locally:
   microk8s kubectl port-forward -n go-redis-app svc/app 8080:8080
   curl http://localhost:8080/visits

Configuration / Environment variables
The application currently reads Redis configuration from the code defaults. You can override connection information by setting these environment variables when running the container (the code will need minimal adjustments if you prefer env var reading):
- REDIS_ADDR — host:port for Redis (default in code: redis:6379)
- REDIS_PASSWORD — Redis password (default: empty)
- PORT — HTTP listen port (default in code: 8080)

For production use in Kubernetes, store secrets (e.g., Redis password) as Kubernetes Secrets and mount or reference them in the Deployment manifest.

Kubernetes manifests and helper scripts
- k8s/deploy.sh — small deploy script that applies the manifests using microk8s kubectl
- k8s/namespace.yaml
- k8s/redis-configmap.yaml
- k8s/redis-storage.yaml
- k8s/redis.yaml
- k8s/app.yaml

File layout (important files)
- main.go         — Go HTTP server and Redis client
- Dockerfile      — multi-stage Dockerfile (builder: golang:1.22-alpine, runtime: alpine:3.18)
- k8s/            — Kubernetes manifests and deploy script
- README.md       — you are reading this file (added on add-readme branch)

Development notes
- Dockerfile uses a multi-stage build and produces a small runtime image. The binary produced in the builder stage is named app and executed in the final image.
- Consider making Redis connection configurable with environment variables and providing an example Deployment patch to set them in k8s/app.yaml.
- Add liveness/readiness probes to app.yaml to make Kubernetes deployments more robust.
- Add a simple CI workflow (GitHub Actions) to run go test ./... and build the Docker image on push.

Contributing
Contributions are welcome. Typical workflow:
- Fork the repository
- Create a branch for your change
- Open a PR against main in this repository

Contact / Support
Open an issue on the repository for bugs or feature requests.
