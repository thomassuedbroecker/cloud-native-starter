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
  ibmcloud login --apikey $IBMCLOUD_API_KEY -r $IBM_CLOUD_REGION >> $LOG_FILE 2>&1
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
   _out -- Cluster $CLUSTER_NAME is ready for Istio installation
  fi
}

function add_istio() {
  _out Adding Istio to the Kubernetes Cluster on IBM Cloud

  _out Logging into IBM Cloud
  ibmcloud config --check-version=false >> $LOG_FILE 2>&1
  ibmcloud api --unset >> $LOG_FILE 2>&1
  ibmcloud api https://cloud.ibm.com >> $LOG_FILE 2>&1
  ibmcloud login --apikey $IBMCLOUD_API_KEY -r $IBM_CLOUD_REGION >> $LOG_FILE 2>&1

  _out Adding Istio
  ibmcloud ks cluster-addon-enable istio-extras -y --cluster $CLUSTER_NAME >> $LOG_FILE 2>&1

  _out -- Installed cluster add-ons:
  ibmcloud ks cluster-addons $CLUSTER_NAME 

  _out Saving kubectl config
  echo '#!/bin/sh' > cluster-config.sh
  echo $(ibmcloud ks cluster-config $CLUSTER_NAME --export) >> cluster-config.sh
  chmod +x cluster-config.sh
  source cluster-config.sh

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
