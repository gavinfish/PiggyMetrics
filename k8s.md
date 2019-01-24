# Run PiggyMetrics in Kubernetes

## Overview

The original PiggyMetrics respository contains 10 services. Each service is dockerized and Docker Compose is used to run all of them in one physical machine. It does not use Kubernetes but you get the idea that ochestration is something we want to further work on.

## Essential Steps

### Build & Publish Docker Images

Docker images need to be built and published to a registry. In our case, Docker Hub is the place. Basically, you run 'docker build' and 'docker publish' against each service to achieve that.

A script file is essential to ease the pain. In current implementation, those steps were scripted in `build.bat`. And a personal Docker Hub account was used. Moving forward, we need to replace the personal account with some environment variable, so that user can specify whatever account that is actually working for them.

Also to simply the problem, all ports were unified to 80 in all dockerfiles.

### Centralized Configuration

Spring applications use configurations heavily. In PiggyMetrics, native profile is used, that is to load configuration from local disk. In cloud context, we want to leverage something like a configuration service.

In current implementation, native profile is removed. Instead, we put all the configurations into a [git repository](https://github.com/andxu/config-piggy). And we changed `application.properties` for every service to load config by accessing that git repository specified by `spring.cloud.config.server.git.uri`.

### Kubernetes

To run the services in Kubernetes, we need to model each service using Kubernetes concepts: deployments and services. So you see several manifest yaml files in `scripts` folder.

With those manifest files, you can run `kubectl create` to get them executed in your active cluster.

The sequence of deployment should not matter in Kubernetes context because each service should have builtin resilience. However, we do have extra scripts created and it is recommended that you run it in the following fashion:
1. `scripts/create-reg.bat` to create the registry
2. `scripts/create-base.bat` to create the message queue and configuration service
3. `scripts/create-services.bat` to create all other services

## Code Changes

To check all the code changes, follow [this link](https://github.com/sqshq/PiggyMetrics/compare/master...VSChina:andy-dev1)
