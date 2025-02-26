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
   cd devops assignment
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

## Key Decisions: 

1. Handling the CMD/ENTRYPOINT Conflict:

   During the assignment, I initially attempted to set the command as node with args: k8s-test.js in the values file. 
   However, I encountered issues because this configuration was overwriting the CMD/ENTRYPOINT defined in the Dockerfile. 
   To resolve this, I removed these parameters from the values file so that the Dockerfile's ENTRYPOINT (which calls start.sh) is used. This ensures that the correct startup sequence is maintained.

2. Pre-deployment Database Check:
   A critical requirement was to verify the MongoDB connection before the application is deployed. 
   To achieve this, I implemented an init container that runs the k8s-test.js script. 
   This init container attempts to connect to MongoDB and only allows the main application container to start if the connection is successful. 

   This approach guarantees that the application doesn’t run unless the necessary database dependency is available.

3. Learning from Multi-Stage Docker Builds:
The assignment gave me the opportunity to work with multi-stage Docker builds. By separating the build and runtime environments, I was able to create an optimized Docker image with a smaller footprint.

4. Clean and Parameterized Helm Chart:
For the deployment, I created a clean, parameterized Helm chart. The idea was to keep all configurable parameters in the values.yaml file, allowing easy adjustments without modifying the chart templates. This makes the solution flexible and maintainable. 

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

