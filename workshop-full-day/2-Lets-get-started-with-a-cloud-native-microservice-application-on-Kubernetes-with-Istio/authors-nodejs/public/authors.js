const log4js = require('log4js');
const appName = require('./../package').name;
const logger = log4js.getLogger(appName);
logger.level = process.env.LOG_LEVEL || 'info';


if ( process.env.DATABASE=="local" ) {

    //  LOCAL DATABASE

    logger.info("Using local database");
    // authordata.json is the "database"
    const author = require('../authordata.json');
    const jsonQuery = require('json-query');

    // Display details of single author
    //
    // GET w/ query
    //
    //  /getauthor?name=firstname%20lastname
    //
    exports.author_get = function(req, res) {  
        var name = req.query.name;
        logger.info('Query for: ' + name);
        var result = jsonQuery('docs[name=' + name + ']', {data: author}).value;
        if (result == null) {
            res.writeHead(204, { "Content-Type": "application/json" }); 
            res.end('{"Msg": "No result"}'); 
        } else  {   
            res.writeHead(200, { "Content-Type": "application/json" });  
            res.end(JSON.stringify(result)); 
            logger.info(JSON.stringify(result)); 
        };    
    };        
} else {

    // CLOUDANT on IBM Cloud

    const CloudantSDK = require('@cloudant/cloudant');

    if (process.env.CLOUDANT_URL) {
        var cloudant_db = require('@cloudant/cloudant')(process.env.CLOUDANT_URL); 
        logger.info("Using DB: " + process.env.CLOUDANT_URL);
    } else {
        logger.info("You need to set the environment variable CLOUDANT_URL");
    }
    
    const authors = cloudant_db.use("authors");
    
    // Test read authors db and print rows count to console.log
    authors.view("authorview", "data_by_name", function (err, body, header) { 
        if (err) { 
            logger.error('Cloudant: ' + err ); } 
        else { 
            if ( JSON.stringify(body.rows.length) > 0 ) {  //do we have a result?
                logger.info("Test connect to authors_db successful -- rows count: " + JSON.stringify(body.total_rows)); }  
            else {
                logger.info("Test connect to authors_db successful -- no rows, authors db is empty"); 
            }
        } 
    });
    
    // Display details of single author
    //
    // GET w/ query
    //
    //  /getauthor?name=firstname%20lastname
    //
    exports.author_get = function(req, res, next) {  
        var name = req.query.name;
        logger.info('Query for: ' + name);
        authors.view("authorview", "data_by_name", {key: name}, function (err, body, header) { 
            if (err) { 
                res.writeHead(500, { "Content-Type": "application/json" }); 
                res.end('{"error": "' + err +  '"}');
                logger.error('500 - Cloudant read failed. ' + err); 
            } else {
                if ( JSON.stringify(body.rows.length) > 0 ) {  //do we have a result?
                    var _n = body.rows[0].value.name;
                    var _t = body.rows[0].value.twitter;
                    var _b = body.rows[0].value.blog;
                    var authorData = JSON.stringify({'name': _n, 'twitter': _t, 'blog': _b});
                    res.writeHead(200, { "Content-Type": "application/json" }); 
                    res.end(authorData); 
                    logger.info('200 - Cloudant read successful'); 
                } else {
                    res.writeHead(204, { "Content-Type": "application/json" }); 
                    res.end('{"msg": "no result"}');
                    logger.info('204 - Cloudant read successful but returned no results'); 
                }
            } 
        });       
    
    };

}

   


