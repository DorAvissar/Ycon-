# DevOps Assignment
## Overview

This project demonstrates containerization, orchestration, and deployment of a Node.js application alongside a MongoDB instance. The solution leverages:
- **Docker multi-stage builds** to create an optimized image.
- **Kubernetes** for container orchestration.
- **Helm** for parameterized, reusable deployments.
- **Rolling updates** to ensure zero downtime.
- **Service connectivity** 

## Prerequisites 
1. Docker – for building and running containers.
2. Local Kubernetes Cluster – I used the docker sedktop k8s
3. kubectl CLI – for interacting with Kubernetes cluster.
4. Helm CLI 

### Multi-Stage Dockerfile Highlights

**Stage 1 (Builder):**  
- Sets the working directory to /app
- Copies package.json and installs dependencies via npm install
- Copies the entire application source code into the builder stage.

**Stage 2 (Final Image):**  
- Uses an Alpine-based Node.js image
- Installs required system packages (ca-certificates, bash, vim, procps, curl)
- Creates a dedicated user and group with ID 1500, and sets up /home/user
- Copies the built artifacts from the builder stage
- Ensures that the start.sh script is executable and is used as the container’s entrypoint
- Exposes port 8080 for the application

### how to Build the Docker Image

1. **Clone the Repository**  

   ```bash
   git clone <repo-url>
   cd ycon-
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
Deploys one container running the application. 

- MongoDB Deployment:
Deploys a separate MongoDB container using the official MongoDB image.

- InitContainer for Pre-deployment Testing:
An initContainer is configured in the application deployment. This initContainer runs a pre-deployment test script (k8s-test.js) that attempts to connect to the MongoDB service. If the script successfully connects, it exits with a zero exit code, allowing the main application container to start. If the MongoDB connection fails, the initContainer exits with a non-zero code, and Kubernetes will not proceed with starting the main container.

### The Helm chart is fully parameterized via values.yaml.  can customize the  parameters without changing the chart templates.

## how to deploy? 
open the k8s on docker desktop

Navigate to the Helm chart directory:
```
cd ..
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

To inspect the pre-deployment check, run:
```
kubectl logs <pod-name> -c pre-deployment
```
( I simulate a failure (e.g., by stopping MongoDB) to verify that the initContainer prevents the main container from starting )

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

