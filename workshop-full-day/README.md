# Cloud Native Apps: Build and deploy a Java EE Microservice with Kubernetes and Istio on IBM Cloud

Cloud native apps use Cloud technologies and are based on loosely coupled microservices. This saves time for development and increases flexibility. Cloud native apps can be deployed to all kinds of Cloud platforms.

In this hands-on workshop we will build a cloud native application that is a simple example but still covers all topics relevant in real life scenarios. 

There are 3 parts:

**Part 1: Build and deploy your first Java microservice to Kubernetes on IBM Cloud**
We will build a single microservice based on Java EE and Eclipse MicroProfile and deploy it to Kubernetes on the IBM Cloud. Eclipse MicroProfile has features and modules that help develop Java based microservices and we will cover exposing and documenting REST APIs and health checks.

**Part 2: Build a cloud native microservices application on Kubernetes and Istio**
We will deploy two more microservices to create a microservice architecture and also deploy a browser based frontend.
We will look into:
* Consuming REST APIs with Java
* Traffic Management with Istio to test a new version of a microservice
* Resiliency functions of MicroProfile to help our application stay responsive in case of an error

**Part 3: Deploy Applications on Red Hat OpenShift**
Red OpenShift offers several options to deploy an application.
We will use one of our Microservices as an example to look into some of these options.

---

## 1. Build and deploy your first Java microservice to Kubernetes on IBM Cloud [(60 - 90 min)](./workshop-full-day/1-Build-and-deploy-your-first-Java-microservice-to-Kubernetes)

This workshop demonstrates how to build a microservice with Java and how to deploy it to Kubernetes on the IBM Cloud.

The microservice is kept as simple as possible, so that it can be used as a starting point for other microservices. The microservice has been developed with Java EE and [Eclipse MicroProfile](https://microprofile.io/).

_Note:_ Useful YouTube playlist [Build and deploy a microservice to Kubernetes](https://ibm.biz/BdzVRY)

## 2. Let’s get started with a cloud native microservice application on Kubernetes and Istio [(90 - 120 min)](workshop-full-day/2-Lets-get-started-with-a-cloud-native-microservice-application-on-Kubernetes-with-Istio)

In this hands-workshop we do address the question: 

> How to start with **cloud native Java applications** in Kubernetes?

We will cover the following major topics and we learn along the given **source code** and **bash scripts** inside this end-to-end microservices example cloud-native-starter project:

* Java development with [MicroProfile](https://microprofile.io/) 
* [Kubernetes](https://en.wikipedia.org/wiki/Kubernetes)
* [Containers](https://en.wikipedia.org/wiki/OS-level_virtualisation)
* [REST APIs](https://en.wikipedia.org/wiki/Representational_state_transfer)
* [Traffic management](https://istio.io/docs/concepts/traffic-management/) 
* [Resiliency](https://www.ibm.com/it-infrastructure/z/capabilities/resiliency)
 
## 3. Deploy a Java Microservices to OpenShift on IBM Cloud [(60 - 90 min)](./workshop-full-day/3-deploy-microservice-to-openshift)

This workshop demonstrates how to build a microservice with Java and how to deploy it to OpenShift.

The microservice is kept as simple as possible, so that it can be used as a starting point for other microservices. The microservice has been developed with Java EE and [Eclipse MicroProfile](https://microprofile.io/).

There are [various ways to deploy applications to OpenShift](http://heidloff.net/article/deploying-open-liberty-microservices-openshift/). The options have different advantages and disadvantages which are explained in the following labs.
