## Scripts in /ibm-scripts

The scripts in this directory create resources on the IBM Cloud that can be used for Minikube and IBM Kubernetes Service deployments

### create-app-id

Required for the [Demo: Authentication and Authorization](../documentation/DemoAuthentication.md)

Creates an instance of the AppID service on IBM Cloud and performs the necessary setup of the instance. Parameters required for the deployment are stored in local.env.

### create-cloudant

Cloudant is a database option for the [Authors service](../authors-nodejs/README.md)

The script will

* create a Cloudant instance in the Cloud region set in local.env (us-south is default)
* create the "authors" database 
* create a view (authors-nodejs/authorview.json)
* populate the database with our sample data (authors-nodejs/authordata.json)
* set the correct values in scripts/deploy-authors-nodejs.cfg which is used by the deployment script for the authors service.
