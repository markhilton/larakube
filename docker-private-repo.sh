#!/bin/bash

export DOCKER_USER=docker.user
export DOCKER_EMAIL=emal@domain.com
export DOCKER_PASSWORD=my.password
export DOCKER_REGISTRY_SERVER=https://index.docker.io/v1/

kubectl delete secret docker-auth

kubectl create secret docker-registry docker-auth \
  --docker-server=$DOCKER_REGISTRY_SERVER \
  --docker-username=$DOCKER_USER \
  --docker-password=$DOCKER_PASSWORD \
  --docker-email=$DOCKER_EMAIL

 kubectl get secret docker-auth --output=yaml
