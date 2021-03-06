# Lab 3 - Understanding the Java Implementation

## 1. Usage of Maven for Java

We begin with the [Maven](https://maven.apache.org/) part for our Java project.

> Maven Apache Maven is a software project management and comprehension tool. Based on the concept of a **project object model** (POM), Maven can manage a project's build, reporting and documentation from a central piece of information.

In the pom file we define the configuration of our Java project with dependencies, build, and properties including the compiler information as you can see in the [pom file](../authors-java-jee/pom.xml) below.

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

		<!-- Zipkin user feature download link -->
        <zipkin.usr.feature>https://github.com/WASdev/sample.opentracing.zipkintracer/releases/download/1.2/liberty-opentracing-zipkintracer-1.2-sample.zip</zipkin.usr.feature>
		
	</properties>
</project>
```

_REMEMBER:_ We use this pom file to build our Authors service with `RUN mvn -f /usr/src/app/pom.xml clean package` inside our **Build environment container**.

```dockerfile
FROM maven:3.5-jdk-8 as BUILD
 
COPY src /usr/src/app/src
COPY pom.xml /usr/src/app
RUN mvn -f /usr/src/app/pom.xml clean package
```

## 2. Configuration the Open Liberty Server

Our Authors microservice will run on an OpenLiberty Server in a container on Kubernetes.

We need to configure the OpenLiberty server with a [server.xml](../authors-java-jee/liberty/server.xml) file. For our Java implementation we decided to use MicroProfile and within the feature definition in the server.xml we provide this information to our server with the entries `webProfile-8.0` and `microProfile-2.1`.
The server must be reached in the network. Therefore we define the  httpEndpoint including httpPort we use for our microservice. For configuration details take a look into the [openliberty documentation](https://openliberty.io/docs/ref/config/).

_IMPORTANT:_ We should remember that this port (`httpPort="3000"`) must be exposed in the Dockerfile for our container and mapped inside the Kubernetes deployment configuration.

Also the name of the executable web application is definied in the server.xml.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<server description="OpenLiberty Server">
	
    <featureManager>
        <feature>webProfile-8.0</feature>
        <feature>microProfile-2.1</feature>
    </featureManager>

    <httpEndpoint id="defaultHttpEndpoint" host="*" httpPort="3000" httpsPort="9443"/>

    <opentracingZipkin host="*" port="9411"/>

    <httpEndpoint id="defaultHttpEndpoint" host="*" httpPort="3000" httpsPort="9443"/>

    <webApplication location="authors.war" contextRoot="api">
        <!-- enable visibility to third party apis -->
        <classloader apiTypeVisibility="api,ibm-api,spec,stable,third-party"/>
    </webApplication>

</server>
```

_Note:_ Later we will change the **contextRoot**.

## 3. Implementation of the REST GET endpoint with MicroProfile

### 3.1 MicroProfile basics

Some definitions:

> Microservice architecture is a popular approach for building cloud-native applications in which each capability is developed as an independent service. It enables small, autonomous teams to develop, deploy, and scale their respective services independently.

> Eclipse MicroProfile is a modular set of technologies designed so that you can write cloud-native Java™ microservices. In this introduction, learn how MicroProfile helps you develop and manage cloud-native microservices. Then, follow the Open Liberty MicroProfile guides to gain hands-on experience with MicroProfile so that you can build microservices with Open Liberty.


### 3.2 Java classes needed to expose the Authors service

For the Authors service to expose the REST API we need to implement three classes:

* [AuthorsApplication](../src/main/java/com/ibm/authors/AuthorsApplication.java) class repesents our web application.
* [Author](../src/main/java/com/ibm/authors/Author.java) class repesents the data structure we use for the Author.
* [GetAuthor](../src/main/java/com/ibm/authors/GetAuthor.java) class repesents the REST API.

![class diagramm authors](images/authors-java-classdiagram-01.png)



#### 3.2.1 **Class AuthorsApplication**

Our web application does not implement any business or other logic, it simply needs to run on a server with no UI. The AuthorsApplication class extends the [javax.ws.rs.core.Application](https://www.ibm.com/support/knowledgecenter/en/SSEQTP_9.0.0/com.ibm.websphere.base.doc/ae/twbs_jaxrs_configjaxrs11method.html) class to do this. 

The `AuthorsApplication` class provides access to the classes from the `com.ibm.authors` package at runtime.
The implementation of the interface class _Application_ enables the usage of easy REST implementation provided by MircoProfile. 

With `@ApplicationPath` from MicroProfile we define the base path of the application.

```java
package com.ibm.authors;

import javax.ws.rs.core.Application;
import javax.ws.rs.ApplicationPath;

@ApplicationPath("v1")
public class AuthorsApplication extends Application {
}
```

_Note:_ Later we will change the ApplicationPath in this class.

#### 3.2.2 Class Author

This class simply repesents the data structure we use for the [Author](../src/main/java/com/ibm/authors/Author.java). No MircoProfile feature is used here.

```java
package com.ibm.authors;

public class Author {
public String name;
public String twitter;
public String blog;
}
```

#### 3.2.3 Class GetAuthor

This class implements the REST API response for our Authors microservice. We implement the REST client using the [MicroProfile REST Client](https://github.com/eclipse/microprofile-rest-client/blob/master/README.adoc). We use  `@Path` and `@Get` statements from [JAX-RS](https://jcp.org/en/jsr/detail?id=339) and for the [OpenAPI](https://www.openapis.org/) documentation `@OpenAPIDefinition` statements from [MicroProfile OpenAPI](https://github.com/eclipse/microprofile-open-api) which automatically creates an OpenAPI explorer.

_REMEMBER:_ In the server.xml configuration we added **MicroProfile** to the Open Liberty server as a feature, as you see in the code below.

```xml
<featureManager>
        <feature>microProfile-2.1</feature>
        ....
</featureManager> 
```

With the combination of the server.xml and our usage of MicroProfile features in the GetAuthor class we will be able to access an OpenAPI explorer with this URL `http://host:http_port/openapi` later.

This is the source code of the [GetAuthors class](../src/main/java/com/ibm/authors/GetAuthor.java) with the mentioned MicroProfile features:

```java
@ApplicationScoped
@Path("/getauthor")
@OpenAPIDefinition(info = @Info(title = "Authors Service", version = "1.0", description = "Authors Service APIs", contact = @Contact(url = "https://github.com/nheidloff/cloud-native-starter", name = "Niklas Heidloff"), license = @License(name = "License", url = "https://github.com/nheidloff/cloud-native-starter/blob/master/LICENSE")))
public class GetAuthor {

	@GET
	@APIResponses(value = {
		@APIResponse(
	      responseCode = "404",
	      description = "Author Not Found"
	    ),
	    @APIResponse(
	      responseCode = "200",
	      description = "Author with requested name",
	      content = @Content(
	        mediaType = "application/json",
	        schema = @Schema(implementation = Author.class)
	      )
	    ),
	    @APIResponse(
	      responseCode = "500",
	      description = "Internal service error"  	      
	    )
	})
	@Operation(
		    summary = "Get specific author",
		    description = "Get specific author"
	)
	public Response getAuthor(@Parameter(
            description = "The unique name of the author",
            required = true,
            example = "Niklas Heidloff",
            schema = @Schema(type = SchemaType.STRING))
			@QueryParam("name") String name) {
		
			Author author = new Author();
			author.name = "Niklas Heidloff";
			author.twitter = "https://twitter.com/nheidloff";
			author.blog = "http://heidloff.net";

			return Response.ok(this.createJson(author)).build();
	}

	private JsonObject createJson(Author author) {
		JsonObject output = Json.createObjectBuilder().add("name", author.name).add("twitter", author.twitter)
				.add("blog", author.blog).build();
		return output;
	}
}
```

_Note:_ Later we will change the return values for the response in the local source code.

### 3.3 Supporting live and readiness probes in Kubernetes with HealthCheck

We have added the class HealthEndpoint into the Authors package as you can see in the following diagram.

![class diagramm HealthEndpoint](images/authors-java-classdiagram-02.png)

We want to support this [Kubernetes function](https://github.com/OpenLiberty/guide-kubernetes-microprofile-health#checking-the-health-of-microservices-on-kubernetes):

> Kubernetes provides liveness and readiness probes that are used to check the health of your containers. These probes can check certain files in your containers, check a TCP socket, or make HTTP requests. MicroProfile Health exposes readiness and liveness endpoints on your microservices. Kubernetes polls these endpoints as specified by the probes to react appropriately to any change in the microservice’s status.

For more information check the [Kubernetes Microprofile Health documentation](https://openliberty.io/guides/kubernetes-microprofile-health.html) and the documentation on [GitHub](https://github.com/eclipse/microprofile-health).

This is the implementation of the Health Check for Kubernetes in the [HealthEndpoint class](../authors-java-jee/src/main/java/com/ibm/authors/HealthEndpoint.java) of the Authors service:

```java
@Health
@ApplicationScoped
public class HealthEndpoint implements HealthCheck {

    @Override
    public HealthCheckResponse call() {
        return HealthCheckResponse.named("authors").withData("authors", "ok").up().build();
    }
}
```

_Note:_ Later we will change return information of the **HealthCheckResponse**.

This HealthEndpoint is configured in the Kubernetes deployment yaml. In the following yaml extract we see the `livenessProbe` definition.

```yaml
    livenessProbe:
      exec:
        command: ["sh", "-c", "curl -s http://localhost:3000/"]
      initialDelaySeconds: 20
    readinessProbe:
      exec:
        command: ["sh", "-c", "curl -s http://localhost:3000/health | grep -q authors"]
      initialDelaySeconds: 40
```

## Change the code of the authors microservice and run the service in a container locally

_Note_: Here are some additional instructions based on your choosen setup.

### [Tools - Option 1](./1-prereqs.md#tools---option-1-prebuilt-image-with-local-code)

Step |  |
--- | --- 
1 | You need to open a new local terminal |
2 |  Navigate to your local project folder ```cloud-native-starter/authors-java-jee```
3 | [Move on with the lab](./3-java.md#step-1-in-getauthorjava-change-the-returned-author-name-to-something-else-like-my-name).


### [Tools - Option 2](./1-prereqs.md#tools---option-2-prebuilt-image-with-code-in-container)

Step |  |
--- | --- 
1 | You need to download or clone the project onto your local PC, first. ```$ git clone https://github.com/IBM/cloud-native-starter.git ``` 
2 |  Open a new terminal and navigate tp your local project folder ```cloud-native-starter/authors-java-jee```
3 | [Move on with the lab](./3-java.md#step-1-in-getauthorjava-change-the-returned-author-name-to-something-else-like-my-name).


#### Step 1: Change the contextRoot in [server.xml](../authors-java-jee/liberty/server.xml) to something similar like "myapi".

Open the file ```cloud-native-starter/authors-java-jee/liberty/server.xml``` in a editor and change the value.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<server description="OpenLiberty Server">
	
    <featureManager>
        <feature>webProfile-8.0</feature>
        <feature>microProfile-2.1</feature>
    </featureManager>

    <httpEndpoint id="defaultHttpEndpoint" host="*" httpPort="3000" httpsPort="9443"/>

    <webApplication location="authors.war" contextRoot="myapi"/>

</server>
```

### Step 2: Change the @ApplicationPath in the class [AuthorsApplication.java](../authors-java-jee/src/main/java/com/ibm/authors/AuthorsApplication.java) something similar like "myv1".

Open the file ```cloud-native-starter/authors-java-jee/src/main/java/com/ibm/authors/AuthorsApplication.java``` in a editor and change the value.

```java
package com.ibm.authors;

import javax.ws.rs.core.Application;
import javax.ws.rs.ApplicationPath;

@ApplicationPath("myv1")
public class AuthorsApplication extends Application {
}
```

#### Step 3: In the class [GetAuthor.java](../authors-java-jee/src/main/java/com/ibm/authors/GetAuthor.java) change the returned author name to something similar like "MY NAME".

Open the file ```cloud-native-starter/authors-java-jee/src/main/java/com/ibm/authors/GetAuthor.java``` in a editor and change the value.

``` java
public Response getAuthor(@Parameter(
            description = "The unique name of the author",
            required = true,
            example = "MY NAME",
            schema = @Schema(type = SchemaType.STRING))
			@QueryParam("name") String name) {
		
			Author author = new Author();
			author.name = "MY NAME";
			author.twitter = "https://twitter.com/MY NAME";
			author.blog = "http://MY NAME.net";

			return Response.ok(this.createJson(author)).build();
	}
```

#### Step 4: In the class [HealthEndpoint.java](../authors-java-jee/src/main/java/com/ibm/authors/HealthEndpoint.java) change the returned information to something similar like "ok for the workshop".

```java
@Health
@ApplicationScoped
public class HealthEndpoint implements HealthCheck {

    @Override
    public HealthCheckResponse call() {
        return HealthCheckResponse.named("authors").withData("authors", "ok for the workshop").up().build();
    }
}
```

#### Step 5: To test and see how the code works you can run the code locally as a Docker container:

```sh
$ cd $ROOT_FOLDER/authors-java-jee
$ docker build -t authors .
$ docker run -i --rm -p 3000:3000 authors
```

With open tracing:

```sh
$ docker run -i --rm -p 3000:3000 -p 9411:9411 authors
```

#### Step 6: Open the swagger UI of the mircoservice in a browser and verfiy the changes

```http://localhost:3000/openapi/ui/```

![Swagger UI](images/changed-authors-open-api.png)

#### Step 7: Open the health check of the mircoservice in a browser and verfiy the changes

```http://localhost:3000/health```

![health](images/changed-authors-healthcheck.png)

---

#### Optional: Enable the logging inside the liberty server and access the running Docker container with your running microservice

Now we will take a closer look to tracing and logging.

We will use [Zipkin](https://zipkin.io/), which is a distributed tracing system. It helps gather timing data needed to troubleshoot latency problems in service architectures. Features include both the collection and lookup of this data.
You can find more detailed imformation in that blog post[monitoring Java microservices with Microprofile opentracing](https://www.ibm.com/cloud/blog/monitoring-java-microservices-with-microprofile-opentracing)

[Youtube](https://www.youtube.com/watch?v=eFXCMQGEpXU&t=359s)


Sample to delete images:

```sh
IMAGE_TO_DELETE=$(docker image ls | awk '/<none>/ {print $3;exit;}'); echo "Image to delete $IMAGE_TO_DELETE"; while [ "$IMAGE_TO_DELETE" != "" ]; do  IMAGE_TO_DELETE=$(docker image ls | awk '/<none>/ {print $3;exit;}'); echo "Image to delete $IMAGE_TO_DELETE"; docker rmi -f dangling=true image $IMAGE_TO_DELETE; echo "$IMAGE_TO_DELETE deleted"; done;
```

Later we will copy the needed "zipkintracer" Framework into our production server.

```sh
$ cd $ROOT_FOLDER/authors-java-jee
$ curl -L -o $file https://github.com/WASdev/sample.opentracing.zipkintracer/releases/download/1.2/liberty-opentracing-zipkintracer-1.2-sample.zip
$ unzip -o liberty-opentracing-zipkintracer-1.2-sample.zip -d liberty-opentracing-zipkintracer/
```


### Changes in the pom file

We insert following changes into our pom.xml file.
We do that, because we need when we use custom opentracing. 

```xml
    <!-- https://mvnrepository.com/artifact/io.opentracing/opentracing-api -->
	<dependency>
		<groupId>io.opentracing</groupId>
		<artifactId>opentracing-api</artifactId>
		<version>0.31.0</version>
	</dependency>
```

Add the zipkin feature as a download to our project.
_Note:_ We will do a additional download later.

```xml
    <!-- Zipkin user feature download link -->
    <zipkin.usr.feature>https://github.com/WASdev/sample.opentracing.zipkintracer/releases/download/1.2/liberty-opentracing-zipkintracer-1.2-sample.zip</zipkin.usr.feature>
```

Add servlet information to extract Request.

```xml
		<!-- https://mvnrepository.com/artifact/javax.servlet/servlet-api -->
		<dependency>
			<groupId>javax.servlet</groupId>
			<artifactId>servlet-api</artifactId>
			<version>2.5</version>
			<scope>provided</scope>
		</dependency>
```

### Changes in the server file

We insert following change to connect later locally to our zipkin server on running on docker in our local machine.

```xml
    <opentracingZipkin host="zipkinhost" port="9411"/>
```

We add the logging to our server to inspect later the logs on our Docker container.

```xml
    <logging traceSpecification="com.ibm.ws.opentracing.*=all:com.ibm.ws.microprofile.opentracing.*=all"/>
```

### Changes in the source code

#### Common logging

* We add following imports to the classes:

```java
import java.util.logging.Logger;
import org.eclipse.microprofile.opentracing.*;
```

* We add a logger to the classes:

```java
    Logger l = Logger.getLogger([CLASSNAME].class.getName());
```

* We do some logging:

```java
    l.info("... logger start [CLASSNAME]");
    System.out.println("... start [CLASSNAME]");
```

#### Debugging

[Debugger for VS Code](https://marketplace.visualstudio.com/items?itemName=Open-Liberty.liberty-dev-vscode-ext)
[Need to enable OpenLiberty in pom filehttps://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker maven](https://github.com/OpenLiberty/ci.maven)
[Docker for visual studio code](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)

```sh
$ docker run -i --rm --link zipkin:zipkinhost -p 3000:3000 -p 7777:7777 authors server debug
```

#### Tracing

With mircoprofile you don't have to define traces for the rest calls the will be created automatically.

##### Custom tracing with open tracing:


Extract imformation to log the request:

```java
// Export information of requests
import javax.servlet.http.*;
import javax.ws.rs.core.Context;
// Export information of requests
```

The relevant part is `@Context HttpServletRequest request

```java
public Response getAuthor(@Parameter(
            description = "The unique name of the author",
            required = true,
            example = "Niklas Heidloff",
            schema = @Schema(type = SchemaType.STRING))
			@QueryParam("name") String name, @Context HttpServletRequest request){
				logHeaders(request);
				....
```


```java
private void logHeaders (HttpServletRequest request){
		// tag::custom-tracer[]
        Scope activeScope = tracer.scopeManager().active();
		if (activeScope != null) {
    		activeScope.span().log("... active scope found");
		}

		Span activeSpan = tracer.activeSpan();
		Tracer.SpanBuilder spanBuilder = tracer.buildSpan("Custom logHeaders");

		if (activeSpan != null){
			spanBuilder.asChildOf(activeSpan.context());
		}

		Span childSpan = spanBuilder.startManual();
		childSpan.setTag("JsonCreated",true);
		childSpan.log("Just created childSpam");
		if( activeSpan == null){
			//activeSpan = tracer.activateSpan(childSpan);
			tracer.scopeManager().activate(childSpan,true);
		}
		// end::custom-tracer[]
		
		Enumeration<String> headerNames = request.getHeaderNames();
		while (headerNames.hasMoreElements()) {
			String header = headerNames.nextElement();
			System.out.println(header+": "+request.getHeader(header));
		}

	    // tag::custom-tracer[]
        childSpan.finish();
		// end::custom-tracer[]

	}
```

We using [Inject](https://javaee.github.io/javaee-spec/javadocs/javax/inject/package-summary.html)

```java
	import javax.inject.Inject;
```

Here we inject the opentracing `class Tracer`.

```java
	// tag::custom-tracer[]
    @Inject Tracer tracer;
	// end::custom-tracer[]
```

Here you can define own traces using opentracing.
You need to import the `io.opentracing.*`.

```java
	import io.opentracing.*;
```

Here you can see we use **Scope**, **Tracer.SpanBuilder** and **Tracer** to do that.

```java
	// tag::custom-tracer[]
    Scope activeScope = tracer.scopeManager().active();
	if (activeScope != null) {
    		activeScope.span().log("... active scope found");
	}

	Span activeSpan = tracer.activeSpan();
	Tracer.SpanBuilder spanBuilder = tracer.buildSpan("Custom create a JsonObject");

	if (activeSpan != null){
			spanBuilder.asChildOf(activeSpan.context());
	}

	Span childSpan = spanBuilder.startManual();
	childSpan.setTag("JsonCreated",true);
	childSpan.log("Just created childSpam");
	if( activeSpan == null){
			//activeSpan = tracer.activateSpan(childSpan);
			tracer.scopeManager().activate(childSpan,true);
	}
	// end::custom-tracer[]
		
	JsonObject output = Json.createObjectBuilder().add("name", author.name).add("twitter", author.twitter)
				.add("blog", author.blog).build();
		
	// tag::custom-tracer[]
    childSpan.finish();
	// end::custom-tracer[]

	l.info("... create json object for Author");
	System.out.println("... create json object for Author");
```

Working with zipkin and docker locally:

[Understand the Docker network](https://docs.docker.com/engine/reference/commandline/network_connect/)

* Start the zipkin server:
```sh
$ docker run --name zipkin -it -p 9411:9411 openzipkin/zipkin
```

* Start the mircoservice and link the container to the zipkin container.

```sh
$ docker run -i --rm --link zipkin:zipkinhost -p 3000:3000 authors
```
* Now invoce the authors api and inspect the call in zipkin

![zipkin](images/zipkin-01-authors.png)

* Enable logging to your server.xml:

```xml
    <logging traceSpecification="com.ibm.ws.opentracing.*=all:com.ibm.ws.microprofile.opentracing.*=all"/>
```

* Full server.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<server description="OpenLiberty Server">
	
    <featureManager>
        <feature>webProfile-8.0</feature>
        <feature>microProfile-2.1</feature>
        <!-- tag::zipkinUsr[] -->
        <feature>usr:opentracingZipkin-0.31</feature>
        <!-- end::zipkinUsr[] -->
    </featureManager>
     
    <opentracingZipkin host="zipkinhost" port="9411"/>

    <httpEndpoint id="defaultHttpEndpoint" host="0.0.0.0" httpPort="3000" httpsPort="9443"/>

    <webApplication location="authors.war" contextRoot="api">
        <!-- enable visibility to third party apis -->
        <classloader apiTypeVisibility="api,ibm-api,spec,stable,third-party"/>
    </webApplication>

    <logging traceSpecification="com.ibm.ws.opentracing.*=all:com.ibm.ws.microprofile.opentracing.*=all"/>
</server>
```

* Start zipkin server in Docker:

```sh
$ docker run -it -p 9411:9411 openzipkin/zipkin
```

* Get get running container on your local machine

```sh
$ docker container list
$ IMAGE 				COMMAND 					CREATED 	   PORTS			NAMES
$ d69a8da6dd55	authors	"/opt/ol/helpers/run..."	32 seconds ago 9080/tcp, 9411/tcp, 0.0.0.0:3000->3000/tcp, 9443/tcp condescending_khayyam
$ 4fbd857042c8	openzipkin/zipkin	"/busybox/sh run.sh"	19 minutes ago 9410/tcp, 0.0.0.0:9411->9411/tcp	exciting_ellis
```

* Access the running Docker container in the terminal interactive mode

```sh
$ docker exec -it d69a8da6dd55 /bin/bash
```

* Liberty server on you Docker image

```sh
$ liberty/usr/servers/defaultServer
$ apps configDropins dropins server.env server.xml
```

* Find liberty logs on your running Docker container

```sh
$ ls 
$ config etc lib liberty logs mnt output root sbin sys usr dev	home lib64 lib.index.cache media ...
$ cd /logs
$ ls 
$ messages.log trace.log
```

* Copy trace logs, from your running Docker container to your local machine:

```sh
$ docker cp d69a8da6dd55:/logs/trace.log /Users/thoma
ssuedbroecker/Downloads
```

---

:star: __Continue with [Lab 4 - Deploying to Kubernetes](./4-kubernetes.md)__