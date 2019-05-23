[home](README.md)
# Optional Lab - Replace the Node.JS Authors microservice with a simple Java implementation

****** **UNDER CONSTRUCTION** ******

In that optional Lab we will replace the existing Authors microservices written in Node.JS.

IMAGE ARCHITECTURE

In that service we only need to implement a REST API which provides a get author information. Normally we would implement to get the information from a database, but in our case, we will only return sample data information. That sounds not a lot, but with this sample we touch following topics:

•	Usage of [Maven](https://maven.apache.org/) for Java 

•	Configuration of an [Open Liberty Server](https://openliberty.io)

•	Implementation of a [REST GET endpoint with MicroProfile](https://openliberty.io/blog/2018/01/31/mpRestClient.html)

•	Definition of a [Dockerfile](https://docs.docker.com/engine/reference/builder/) with the reuse for existing containers from the [Dockerhub](https://hub.docker.com)

•	[Health check](https://openliberty.io/guides/kubernetes-microprofile-health.html#adding-a-health-check-to-the-inventory-microservice) implementation using Open Liberty with MicroProfile for Kubernetes 

•	[Kubernetes deployment configuration](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)



---

# 1. Usage of Maven for Java

Let’s start with the [Maven](https://maven.apache.org/)
project for our Java project.

> Maven Apache Maven is a software project management and comprehension tool. Based on the concept of a project object model (POM), Maven can manage a project's build, reporting and documentation from a central piece of information.

In the pom file we define the configuation of our Java project, with the **dependencies**, the **build** and the **properties** including for example the complier as you can see in the [pom file](authors-java-jee/pom.xml) below.

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>
	<groupId>com.ibm.cloud</groupId>
	<artifactId>authors</artifactId>
	<version>1.0-SNAPSHOT</version>
	<packaging>war</packaging>

	<dependencies>
		<dependency>
			<groupId>javax</groupId>
			<artifactId>javaee-api</artifactId>
			<version>8.0</version>
			<scope>provided</scope>
		</dependency>
		<dependency>
			<groupId>org.eclipse.microprofile</groupId>
			<artifactId>microprofile</artifactId>
			<version>2.1</version>
			<scope>provided</scope>
			<type>pom</type>
		</dependency>
	</dependencies>

	<build>
		<finalName>authors</finalName>
	</build>

	<properties>
		<maven.compiler.source>1.8</maven.compiler.source>
		<maven.compiler.target>1.8</maven.compiler.target>
		<failOnMissingWebXml>false</failOnMissingWebXml>
		<project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
	</properties>
</project>
```
---

# 2. Configuration of an Open Liberty Server

Our **Authors** mircroserice runs on Open Liberty Server in a container in Kubernetes later.

IMAGE

We need to configure the **Open Liberty** server in the [server.xml](authors-java-jee/liberty/server.xml) file. In our Java implementation we will use the MicroProfile, with the feature definition in the server.xml we define ```webProfile-8.0``` and ```microProfile-2.1``` for our server.
The server must be reached in the network, therefore we define the  **httpEndpoint** including **http ports** we use for our microservice. For configuration details we can take a look into the [openliberty documentation](https://openliberty.io/docs/ref/config/).

These **ports** must be exposed later in the **Dockerfile** container definition.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<server description="OpenLiberty Server">
	
    <featureManager>
        <feature>webProfile-8.0</feature>
        <feature>microProfile-2.1</feature>
    </featureManager>

    <httpEndpoint id="defaultHttpEndpoint" host="*" httpPort="3000" httpsPort="9443"/>

    <webApplication location="authors.war" contextRoot="api"/>

</server>
```

---

## 2. Hands-on tasks - Replace the Node.JS Authors microservice with a simple Java implementation

---

Resources:

* ['Simplest possible Microservice in Java'](../authors-java-jee/README.md)