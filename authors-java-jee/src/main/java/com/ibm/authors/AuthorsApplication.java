package com.ibm.authors;

import javax.ws.rs.core.Application;
import javax.ws.rs.ApplicationPath;
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

@ApplicationPath("v1")
public class AuthorsApplication extends Application {
    Logger l = Logger.getLogger(AuthorsApplication.class.getName());
    
    public AuthorsApplication(){
        l.info("... start AuthorsApplication");
        System.out.println("... start AuthorsApplication");
	}
}