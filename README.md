# Laravel
*Things evolve faster than my commitment to this documentation, but may still be helpful...*

Walk through deploying a [Laravel](https://laravel.com/) application on auto scaled [Kubernetes](https://kubernetes.io/) cluster. 

**Goal**: Deploy Laravel [PHP](http://php.net/) app that will auto scale based on average CPU utilization across cluster nodes.

### Install Laravel with [composer](https://getcomposer.org/)
```bash
composer global require "laravel/installer"
```

### Create new Laravel project
```bash
composer create-project --prefer-dist laravel/laravel laravel-project
```

## Local development
I have created `docker-compose.yml` with a typical infrastructure stack that includes: 
- MySQL (default database) 
- Redis (default cache engine)
- Node (for auto compiling VUE components into app.js & css.js using webpack)

Linked following folders to Docker volumes:
- MySQL data storage 
- Laravel `vendors/`
- Laravel `storage/`
- Laravel `storage/public`
- Laravel `node_modules`

Therefore it's **important** to remember that while you work with this stack, the Laravel logs, compiled templates, cache files, vendor libraries, user uploads and application storage files, as well as MySQL database files will be saved in [Docker volumes](https://docs.docker.com/storage/volumes/). 

If you installed [docker-compose](https://docs.docker.com/compose/install/) already, simply run: 
```bash
docker-compose up
```
and watch logs as Docker will pull all required stack images and provision application environment:
- install required Laravel storage folders
- run pending database migrations
- run composer to install all vendor libraries
- run node to install all dependencies to compile: app.js & app.css

Both composer and node container will remain running. Node will monitor (watch) for changes in resourse/js/ files to re-compile them on the fly.

Composer will remain running if you need to install additional vendor libraries, simply enter composer container shell with and for example install [Redis](https://laravel.com/docs/5.7/redis) support libs:

```bash
docker exec -ti composer bash
composer require predis/predis
composer require laravel/horizon
```

Node container:

```bash
docker exec -ti node bash
npm install
```

[Laravel Horizon](https://laravel.com/docs/5.7/horizon#installation) is a great package to manage Laravel queues with Redis.

# Docker 
For the purpose of this demo I've built a public Docker image and pushed to my account. `Dockerfile` adds Laravel app into a lightweight alpine image.

## build application docker image
```
docker build -t crunchgeek/laravel-project .
```

## push image to the repository
```
docker push crunchgeek/laravel-project
```

# Kubernetes
Having to work with Kubernetes for the last year I got to get some experience with [Google Cloud](https://cloud.google.com/) and [AWS services](https://aws.amazon.com/). First I installed K8s on AWS using [KOPS](https://github.com/kubernetes/kops) - and I do not recommend this for production workloads. I run into multiple issues around performance with Docker overlay. [AWS EKS](https://aws.amazon.com/eks/) does not appeal to me like [GKE](https://cloud.google.com/kubernetes-engine/). Google K8s is really hands off master node, with easy upgrades. So this ended up as my go to solution.

I also learned about [Helm](https://helm.sh/), Kubernetes package manager. So once you get your K8s cluster up on GKE I recommend [this tutorial](https://cloud.google.com/solutions/continuous-integration-helm-concourse) to install Helm.

## load environment variables
```bash
helm install --name laravel-labs --dry-run --debug ./laravel > tmp.yaml
```

That's it! Now the infrastructure will auto adjust itself to the app resources demand.

## SSL support 
Every time you deploy a completely independent application on Kubernetes exposed to the public network - it will probably come with a Load Balancer service. This may be costly if you have to deploy several of them. 

Instead better solution is to use [Nginx Ingress Helm Chart](https://github.com/helm/charts/tree/master/stable/nginx-ingress) with a single Load Balancer and IP address. 

Then you can deploy as many new services you need and use [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) to route the traffic to a specific host domain (app).

The easiest way to deploy SSL protected application is to use [Cert Manager](https://github.com/helm/charts/tree/master/stable/cert-manager) Helm Chart, which will provision SSL certificates using free [Let's Encrypt](https://letsencrypt.org/) service.

Adding SSL protected sites is as simple as adding a single line in your ingress.yaml