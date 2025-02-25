#!/usr/bin/env bash
echo "Starting Kubernetes tests..."
node "$@"  # This will run k8s-test.js because of the Kubernetes args

echo "Tests completed. Starting the main application..."
node docker-test.js  # This runs your main application
