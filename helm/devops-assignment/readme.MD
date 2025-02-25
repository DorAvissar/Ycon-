# DevOps Assignment
## Overview

This project demonstrates containerization, orchestration, and deployment of a Node.js application alongside a MongoDB instance. The solution leverages:
- **Docker multi-stage builds** to create an optimized image.
- **Kubernetes** for container orchestration.
- **Helm** for parameterized, reusable deployments.
- **Rolling updates** to ensure zero downtime.
- **Service connectivity** 

### Multi-Stage Dockerfile Highlights

- **Stage 1 (Builder):**  

- **Stage 2 (Final Image):**  


### how to Build the Docker Image

1. **Clone the Repository**  
   ```bash
   git clone <repo-url>
   cd devops-assignment
   ```

open docker desktop 

run: 

```bash
docker build -t devops-assignment:latest .
```

## Part 2: Deploying with Helm

The deployment is orchestrated using Helm with a parameterized chart that includes:

- Application Deployment:
Deploys one container running the application. The built image defaults to executing a startup script that first runs k8s-test.js (to test connectivity to MongoDB) followed by docker-test.js (the main application).

- MongoDB Deployment:
Deploys a separate MongoDB container using the official MongoDB image.

### The Helm chart is fully parameterized via values.yaml. You can customize the  parameters without changing the chart templates.

## how to deploy? 
open the k8s on docker desktop

Navigate to the Helm chart directory:
```
cd helm
cd devops assignment 
```
Deploy the chart using Helm with a custom release name (e.g., myrelease):
```
helm install <release name> .

```
Verify deployments and services:
```
kubectl get deployments
kubectl get pods
kubectl get svc
```

run the following command the expose the service:
```
kubectl port-forward svc/<svc name> 8080:80
```
enter  http://localhost:8080


## Customizing Parameters
1. Rolling Updates
The Deployment manifest uses a RollingUpdate strategy with:
```
maxUnavailable: 1
maxSurge: 1
```
This ensures that only one old pod is taken down at a time and only one new pod is brought up at a time, preserving uptime.


2. Service Connectivity:

- Inter-Container Communication:
A dedicated Service for MongoDB (defined in mongodb-deployment.yaml) allows the application container to reference the MongoDB instance by a stable DNS name (e.g., mongodb).

- Application Exposure:
A separate Service (defined in service.yaml) exposes the application on port 80, mapped to the container’s port 8080.

