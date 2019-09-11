# Deploying Java Microservices to OpenShift on IBM Cloud

This workshop demonstrates how to build a microservice with Java and how to deploy it to OpenShift on the IBM Cloud.

The microservice is kept as simple as possible, so that it can be used as a starting point for other microservices. The microservice has been developed with Java EE and [Eclipse MicroProfile](https://microprofile.io/).

There are [various ways to deploy applications to OpenShift](http://heidloff.net/article/deploying-open-liberty-microservices-openshift/). The options have different advantages and disadvantages which are explained in the following labs.

## Labs

This workshop has four labs. It should take between 60 and 90 minutues to complete the workshop.

1. Installing prerequisites: [lab](1-prereqs.md)
2. Running the Java microservice locally: [lab](2-docker.md) 
3. Understanding the Java implementation: [lab](3-java.md)
4. Deploying to Kubernetes: [lab](documentation/4-kubernetes.md)

The first lab describes how to install all required prerequisites. In the easiest case this is only Docker Desktop and an image with all other tools.

Lab 2 and 3 describe how to develop a microservice with Java EE and Eclipse MicroProfile.

The last labs ways to deploy applications to Kubernetes on IBM Cloud.
