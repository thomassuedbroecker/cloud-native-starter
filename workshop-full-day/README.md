# How to develop and run microservices on IBM Cloud?

This one day workshop has three major sections.

* Build and deploy your first Java microservice to Kubernetes on IBM Cloud
* Let’s get started with a cloud native microservice application on Kubernetes with Istio
* Build and deploy a Java microservices to OpenShift


## 1. Build and deploy your first Java microservice to Kubernetes on IBM Cloud (60 - 90 min)

This workshop demonstrates how to build a microservice with Java and how to deploy it to Kubernetes on the IBM Cloud.

The microservice is kept as simple as possible, so that it can be used as a starting point for other microservices. The microservice has been developed with Java EE and [Eclipse MicroProfile](https://microprofile.io/).

_Note:_ Useful YouTube playlist [Build and deploy a microservice to Kubernetes](https://ibm.biz/BdzVRY)


### Labs

This workshop has four labs. It should take between 60 and 90 minutues to complete the workshop.

1. Installing prerequisites: [lab](1-prereqs.md)
2. Running the Java microservice locally: [lab](2-docker.md) 
3. Understanding the Java implementation: [lab](3-java.md)
4. Deploying to Kubernetes: [lab](4-kubernetes.md)

The first lab describes how to install all required prerequisites. In the easiest case this is only Docker Desktop and an image with all other tools.

Lab 2 and 3 describe how to develop a microservice with Java EE and Eclipse MicroProfile.

The last labs ways to deploy applications to Kubernetes on IBM Cloud.

## 2. Let’s get started with a cloud native microservice application on Kubernetes (90 min)

[![Let's get started with cloud native Java applications on Kubernetes](https://img.youtube.com/vi/DQFeqFKQ3dE/0.jpg)](https://www.youtube.com/watch?v=DQFeqFKQ3dE "Click play on youtube")

In this hands-workshop we do address the question: 

> How to start with **cloud native Java applications** in Kubernetes?

We will cover the following major topics and we learn along the given **source code** and **bash scripts** inside this end-to-end microservices example cloud-native-starter project:

* Java development with [MicroProfile](https://microprofile.io/) 
* [Kubernetes](https://en.wikipedia.org/wiki/Kubernetes)
* [Containers](https://en.wikipedia.org/wiki/OS-level_virtualisation)
* [REST APIs](https://en.wikipedia.org/wiki/Representational_state_transfer)
* [Traffic management](https://istio.io/docs/concepts/traffic-management/) 
* [Resiliency](https://www.ibm.com/it-infrastructure/z/capabilities/resiliency)
 
Hands-on workshop lab instructions:

* [Prerequisites](00-prerequisites.md) 
* [Introduction](01-introduction.md) 
* [Lab - Building and deploying Containers](02-container.md)
* [Lab - Defining and exposing REST APIs](03-rest-api.md) 
* [Lab - Using traffic management in Kubernetes](04-traffic-management.md)
* [Lab - Resiliency](05-resiliency.md) 
* [Optional - Lab - Replace the Node.js Authors microservice with a simple Java implementation](06-java-development.md)


## 3. Deploy a Java Microservices to OpenShift on IBM Cloud (60 - 90 min)

This workshop demonstrates how to build a microservice with Java and how to deploy it to OpenShift on the IBM Cloud.

The microservice is kept as simple as possible, so that it can be used as a starting point for other microservices. The microservice has been developed with Java EE and [Eclipse MicroProfile](https://microprofile.io/).

There are [various ways to deploy applications to OpenShift](http://heidloff.net/article/deploying-open-liberty-microservices-openshift/). The options have different advantages and disadvantages which are explained in the following labs.

### Labs

This workshop has seven labs. It should take between 60 and 90 minutues to complete the workshop.

0. [Overview video (1:41 mins)](https://youtu.be/8361HGR_O_s)
1. Installing prerequisites: [lab](documentation/1-prereqs.md) and [video (2:58 mins)](https://youtu.be/c5CtqijWXL4)
2. Running the Java microservice locally: [lab](documentation/2-docker.md) and [video (3:51 mins)](https://youtu.be/4dT2jg6wGF4)
3. Understanding the Java implementation: [lab](documentation/3-java.md) and [video (9:09 mins)](https://www.youtube.com/watch?v=ugpYSPV9jAs)
4. Deploying to OpenShift via 'oc' CLI: [lab](documentation/4-openshift.md) and [video (14:32 mins)](https://youtu.be/4MDfalo2Fg0)
5. Deploying existing images to OpenShift: [lab](documentation/5-existing-image.md) and [video (7:09 mins)](https://youtu.be/JhxsS7l6DhA)
6. Deployments of code in GitHub repos: [lab](documentation/6-github.md) and [video (3:52 mins)](https://youtu.be/b3upMuZOpsY)
7. Source to Image deployments: [lab](documentation/7-source-to-image.md) and [video (7:06 mins)](https://youtu.be/p6lVc6MDrcM)

The first lab describes how to install all required prerequisites. In the easiest case this is only Docker Desktop and an image with all other tools.

Lab 2 and 3 describe how to develop a microservice with Java EE and Eclipse MicroProfile.

The last four labs explain four different ways to deploy applications to OpenShift with their pros and cons in this specific scenario:

| Option | Dockerfile | yaml Files | Java Build | Docker Build |
| - | - | - | - | - |
| Lab 4: Kubernetes-like | required | required | OpenShift | OpenShift |
| Lab 5: Existing Image  | not required  | not required | N/A | N/A |
| Lab 6: Git Repo | required  | not required | OpenShift | OpenShift |
| Lab 7: Source to Image | not required | not required | Desktop | OpenShift |
