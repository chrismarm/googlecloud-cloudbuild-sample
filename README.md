# Google Cloud Build CI/CD pipeline from an app hosted in GitHub deployed on a GKE cluster

In previous project https://github.com/chrismarm/jenkins-on-kubernetes we installed Jenkins on a GKE cluster and configured Jenkins to run a CI/CD pipeline that deployed a simple app on the cluster every time a change was made in the source code hosted in Cloud Source. In the current project, we will build a CI/CD pipeline by deploying the same simple app (an html doc showing a message) using `Google Cloud Build` every time a change is made in the source code hosted in `GitHub`.

As in the mentioned Jenkins project, first we need to push a Docker image with our app to Google Container Registry
```sh
$ gcloud auth configure-docker
$ export GCP_PROJECT=$(gcloud config get-value project)
$ IMAGE_FULLNAME=eu.gcr.io/$GCP_PROJECT/sample-cloudbuild
$ docker build -t sample-cloudbuild .
$ docker tag sample-cloudbuild $IMAGE_FULLNAME
$ docker push $IMAGE_FULLNAME
```
After this, we can create the GKE cluster where our app will run. We also need to create a Kubernetes deployment (that will use the image pushed previously) and a LoadBalancer service to access our app. This is done by running `cluster_install.sh`.
It is important to note that we need to add to our project a IAM policy that binds the service account of Cloud Build with a role "container.developer" able to push GCR images to VM instances, the final step in our pipeline.

After this, we need to navigate in GCP console to Cloud Build/Triggers and create a new trigger:
* specifying a source repository with the URL of this GitHub repository
* setting the type as "Branch", that is, activate the trigger when changes happen in a branch
* typing the branch regex to "master". If we want different environments like in the previous Jenkins project, we can create different triggers with different branches and different behaviours.
* specifying the cloudbuild.yaml file to define the pipeline behaviour

Let's take a look to `cloudbuild-production.yaml`, where several steps are defined for our CI/CD pipeline:
1. First step uses the Docker builder to build the image from the source code in the repo.
2. Next step consists of the same builder pushing the built image to Google Container Registry, using the commit hash as image tag
3. Last step calls `kubectl` builder to change a previous Kubernetes deployment with the new pushed image

With all this, every time we push a new change to the GitHub (for example, a new message in index.html), the trigger gets activated and starts a CI/CD pipeline that updates the pods for our app with the new app code. We can check our updated app  accessing the external-ip of K8S service. It is also possible to see a list of previous executed pipelines and also watch some live logs of current pipeline in Cloud Build/History page of console, very useful for troubleshooting and monitoring.