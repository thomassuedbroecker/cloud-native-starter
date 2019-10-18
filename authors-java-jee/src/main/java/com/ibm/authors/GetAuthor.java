package com.ibm.authors;

import javax.enterprise.context.ApplicationScoped;
import javax.json.JsonObject;
import javax.ws.rs.*;
import javax.ws.rs.core.Response;
import org.eclipse.microprofile.openapi.annotations.OpenAPIDefinition;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.enums.SchemaType;
import org.eclipse.microprofile.openapi.annotations.info.Contact;
import org.eclipse.microprofile.openapi.annotations.info.Info;
import org.eclipse.microprofile.openapi.annotations.info.License;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponses;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import javax.ws.rs.QueryParam;
import org.eclipse.microprofile.openapi.annotations.media.Content;
import org.eclipse.microprofile.openapi.annotations.media.Schema;
import org.eclipse.microprofile.openapi.annotations.parameters.Parameter;
import javax.json.Json;

// Java logger
import java.util.logging.Logger;
// Java logger

// Tracing 
import javax.inject.Inject;
// import org.eclipse.microprofile.opentracing.Traced;
import org.eclipse.microprofile.opentracing.*;

//import io.opentracing.Scope;
//import io.opentracing.Tracer;
//import io.opentracing.ActiveSpan; // Problem
//import io.opentracing.Span;
import io.opentracing.*;
// Tracing 

@ApplicationScoped
@Path("/getauthor")
@OpenAPIDefinition(info = @Info(title = "Authors Service", version = "1.0", description = "Authors Service APIs", contact = @Contact(url = "https://github.com/nheidloff/cloud-native-starter", name = "Niklas Heidloff"), license = @License(name = "License", url = "https://github.com/nheidloff/cloud-native-starter/blob/master/LICENSE")))
public class GetAuthor {

	Logger l = Logger.getLogger(GetAuthor.class.getName());
	// tag::custom-tracer[]
    @Inject Tracer tracer;
	// end::custom-tracer[]
	
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

	// Automated enabled for open tracing
	@Traced
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


			System.out.println("... send getAuthor response");
			l.info("... send getAuthor response");

			return Response.ok(this.createJson(author)).build();
	}


	private JsonObject createJson(Author author) {

		// tag::custom-tracer[]
        Scope activeScope = tracer.scopeManager().active();
		if (activeScope != null) {
    		activeScope.span().log("... active scope found");
		}

		Span activeSpan = tracer.activeSpan();
		Tracer.SpanBuilder spanBuilder = tracer.buildSpan("Create JsonObject");

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

		return output;
	}
}