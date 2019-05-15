#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function _err() {
  echo "$@" >&4
  echo "$(date +'%F %H:%M:%S') $@"
}

readonly CFG_FILE=${root_folder}/local.env
# Check if config file exists, in this case it will have been modified
if [ ! -f $CFG_FILE ]; then
     _out Config file local.env is missing!
     _out -- Copy template.local.env to local.env and edit according to our instructions!
     exit 1
fi  
source $CFG_FILE

# SETUP logging (redirect stdout and stderr to a log file)
readonly LOG_FILE=${root_folder}/iks-scripts/cluster-add-istio-custom.log 
touch $LOG_FILE

function login_ibmcloud() {
  _out Logging into IBM Cloud
  ibmcloud config --check-version=false >> $LOG_FILE 2>&1
  ibmcloud api --unset >> $LOG_FILE 2>&1
  ibmcloud api https://cloud.ibm.com >> $LOG_FILE 2>&1
  ibmcloud login -u $IBM_CLOUD_USER --apikey $IBMCLOUD_API_KEY -r $IBM_CLOUD_REGION >> $LOG_FILE 2>&1
  ibmcloud target
}

function connect_to_cluster() {
  _out Connect to cluster
  _out Set region
  ibmcloud ks region-set $IBM_CLOUD_CLUSTER_REGION >> $LOG_FILE 2>&1
  _out List clusters
  ibmcloud ks clusters >> $LOG_FILE 2>&1
  _out Get cluster $CLUSTER_NAME details
  ibmcloud ks cluster-get $CLUSTER_NAME --json >> $LOG_FILE 2>&1
  _out Get cluster $CLUSTER_NAME config
  CMD_KUBECONFIG=$(ibmcloud ks cluster-config $CLUSTER_NAME -admin | awk '/export/{ print $0 }') >> $LOG_FILE 2>&1
  _out Set cluster $CMD_KUBECONFIG environment
  $CMD_KUBECONFIG >> $LOG_FILE 2>&1
  _out Test kubectl for cluster $CLUSTER_NAME
  kubectl get pods >> $LOG_FILE 2>&1
}

function test_cluster() {
  _out Check if Kubernetes Cluster is available ...
  STATE=$(ibmcloud ks cluster-get $CLUSTER_NAME -s | awk '/State:/ {print $2}') 
  if [ $STATE != "normal" ]; then 
   _out -- Your Kubernetes cluster is in $STATE state and not ready
   _out ---- Please wait a few more minutes and then try this command again 
   exit 1
   else
   _out Cluster $CLUSTER_NAME is ready for Istio installation
  fi
}

function add_istio() {

  _out Adding Istio

  _out Download Istio 1.1.4
  curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.1.4 sh -

  _out - Set installation source PATH variable
  export PATH=$root_folder/workshop/istio-1.1.1/bin:$PATH >> $LOG_FILE 2>&1

  _out 
  cd $root_folder/workshop/istio-1.1.1 >> $LOG_FILE 2>&1

  _out - Install Istio
  for i in install/kubernetes/helm/istio-init/files/crd*yaml; do kubectl apply -f $i;  done >> $LOG_FILE 2>&1

  _out - Waiting 5 sec for the next step
  sleep 5 >> $LOG_FILE 2>&1

  _out - Install Istio demo
  kubectl apply -f install/kubernetes/istio-demo.yaml >> $LOG_FILE 2>&1
  
  _out - Verify the pods for istio-system are available
  kubectl get pod -n istio-system >> $LOG_FILE 2>&1

  _out Istio is installed on your cluster
  _out Please check if the Istio pods are all up with
  _out $ source iks-scripts/cluster-config.sh  -- this is only needed once
  _out $ kubectl get pod -n istio-system
  _out before continuing with the next script iks-sripts/create-registry.sh

}

login_ibmcloud
test_cluster
connect_to_cluster
#add_istio  ## Removed: managed Istio not supported on Lite cluster
