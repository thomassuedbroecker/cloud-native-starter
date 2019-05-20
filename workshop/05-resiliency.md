[home](README.md)
# Resiliency

****** **UNDER CONSTRUCTION** ******

As stated in the [reactive manifesto](https://www.reactivemanifesto.org/) cloud-native reactive applications need to be **resilient**:

**The system stays responsive in the face of failure.** This applies not only to highly-available, mission-critical systems – any system that is not resilient will be unresponsive after a failure. Resilience is achieved by replication, containment, isolation …

In distributed systems you need to **design for failure**. For example microservices, which invoke other microservices, must be intelligent enough to continue to work even if some of their dependencies are currently not available.

There are several different ways to build resilient service meshes with Istio, for example via [circuit breakers](https://istio.io/docs/concepts/traffic-management/#circuit-breakers) and [retries](https://istio.io/docs/concepts/traffic-management/#timeouts-and-retries).

The Istio functionality for resilient cloud-native applications is generic and independent from the implementation of the microservices. However in some cases the **handling of failures depends on the business logic** of the applications which is why this needs to be implemented in the microservices.

The Web-app frontend implemented in Vue.js displays articles. The service ‘web-api’ implements the BFF (backend for frontend) pattern. The web application accesses the ‘web-api’ service which invokes both the ‘articles’ and ‘authors’ services.

The initial page shows the five most recent articles including information about the authors.



Now, we've finished the **Resiliency**.

You have finished this workshop :-).

---

Resources:

* ['Developing resilient Microservices with Istio and MicroProfile'](http://heidloff.net/article/resiliency-microservice-microprofile-java-istio)
* ['Demo: Resiliency'](../documentation/DemoResiliency.md)

