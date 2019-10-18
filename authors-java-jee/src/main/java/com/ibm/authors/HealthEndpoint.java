package com.ibm.authors;

import org.eclipse.microprofile.health.Health;
import org.eclipse.microprofile.health.HealthCheck;
import org.eclipse.microprofile.health.HealthCheckResponse;

import javax.enterprise.context.ApplicationScoped;

// Java logger
import java.util.logging.Logger;
// Java logger

// Tracing 
// import javax.inject.Inject;
// import org.eclipse.microprofile.opentracing.Traced;
import org.eclipse.microprofile.opentracing.*;
// import io.opentracing.Scope;
// import io.opentracing.Tracer;
// Tracing 


@Health
@ApplicationScoped
public class HealthEndpoint implements HealthCheck {
    Logger l = Logger.getLogger(HealthEndpoint.class.getName());
    // tag::custom-tracer[]
    // @Inject Tracer tracer;
    // end::custom-tracer[]
    
    @Traced
    @Override
    public HealthCheckResponse call() {
        l.info("... send HealthEndpoint information");
        System.out.println("... send getAuthor response");
        return HealthCheckResponse.named("authors").withData("authors", "ok").up().build();
    }
}
