#!/bin/bash

# Locally, using Cloud Shell or via ssh running "gcloud alpha cloud-shell ssh"
gcloud config set compute/zone europe-west1-b

# Cluster creation
 # storage-rw to access Google Container inside Google Cloud Storage
 # projecthosting to access Google Cloud Source Repositories
gcloud container clusters create sample-cloudbuild --machine-type n1-standard-2 --num-nodes 1
# Auto-configure cluster correctly
gcloud container clusters get-credentials sample-cloudbuild

# Add our GCP account as cluster administrator through a new binding
#kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value account)

# Creation of a service account in the kube-system namespace
#kubectl create -f serviceaccount.yaml
# Add the new service account for Tiller (the Helm server agent) to have the role of cluster admin
#kubectl create -f rolebinding.yaml