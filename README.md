docker build -t sample-cloudbuild .
docker tag sample-cloudbuild $IMAGE_FULLNAME
docker push $IMAGE_FULLNAME
