#!/bin/bash

gcloud config set compute/zone europe-west1-b

# Cluster creation
gcloud container clusters create sample-cloudbuild --machine-type n1-standard-2 --num-nodes 1
# Auto-configure cluster correctly
gcloud container clusters get-credentials sample-cloudbuild

# Adds role to project to give Cloud Build service account privileges to push containers on GKE cluster
PROJECT="$(gcloud projects describe \
    $(gcloud config get-value core/project -q) --format='get(projectNumber)')"

gcloud projects add-iam-policy-binding $PROJECT \
    --member=serviceAccount:$PROJECT@cloudbuild.gserviceaccount.com \
    --role=roles/container.developer

kubectl apply -f k8s-app/sampleapp-production.yaml
kubectl apply -f k8s-app/sampleapp-service.yaml