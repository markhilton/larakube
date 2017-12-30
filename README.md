# Laravel 
Walk through deploying a Laravel application on auto scaled Kubernetes cluster. 

Goal: Deploy PHP app that will auto scale based on average CPU utilization across deployed instance. 

## install Laravel with composer
```
composer global require "laravel/installer"
```

## create new project
```
composer create-project --prefer-dist laravel/laravel laravel-project
```

# Docker 
For the purpose of this demo I've built a public docker image and pushed to my Docker account. `Dockerfile` adds laravel app into a lightweight alpine image.

## build application docker image
```
docker build -t crunchgeek/laravel-project .
```

## push image to the repository
```
docker push crunchgeek/laravel-project
```

# Kubernetes

## load environment variables
```
kubectl create -f env-app.yaml 
kubectl create -f env-php.yaml 
kubectl create -f env-nginx.yaml 
```

## deploy application
```
kubectl create -f deployment.yaml 
```

## expose service
this step requires a different `service yaml` depending where the app is being deployed:

### minikube
```
kubectl create -f service.node.yaml 
```

#### open browser
```
minikube service laravel-project
```

### Google Cloud
```
kubectl create -f service.yaml 
```

### Amazon AWS
```
kubectl create -f service.aws.yaml 
```

## deploy auto scaler 
```
kubectl create -f autoscaler.yaml
```

That's it! Now the infrastructure will auto adjust itself to the app resources demand.
