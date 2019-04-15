#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function templates() {
  _out Preparing YAML files for Kubernetes Deployment

  # Check if config file exists, in this case it will have been modified
  template=${root_folder}/scripts/template.deploy-authors-nodejs.cfg
  cfgfile=${root_folder}/scripts/deploy-authors-nodejs.cfg
  if [ ! -f $cfgfile ]; then
     cp $template $cfgfile
  fi   

  source $cfgfile
  #echo "DB is " $DB
  #echo "Cloudant URL is " $CLOUDANTURL
  # CLOUDANTURL is read from cfgfile
  # '##*@' removes everything up to and including the @ sign
  CLOUDANTHOST=${CLOUDANTURL##*@}
  cd ${root_folder}/authors-nodejs/deployment
  sed -e "s|<URL>|$CLOUDANTURL|g" -e "s|<DB>|$DB|g" deployment.yaml.template > deployment.yaml
  sed "s|<HOST>|$CLOUDANTHOST|g" istio-egress-cloudant.yaml.template > istio-egress-cloudant.yaml
  cd ${root_folder}/authors-nodejs
  sed -e "s|<URL>|$CLOUDANTURL|g" -e "s|<DB>|$DB|g" config.json.template > config.json
}

function setup() {

  _out Clean-up Minikube
  if [ $DB != "local" ]; then
     kubectl delete serviceentry cloudant --ignore-not-found
     kubectl delete virtualservice cloudant --ignore-not-found
  fi

  kubectl delete all -l app=authors --ignore-not-found

  
  _out Build Docker Image
  cd ${root_folder}/authors-nodejs
  eval $(minikube docker-env)
  docker build -f Dockerfile -t  authors:1 .

  _out Deploy to Minikube
  cd ${root_folder}/authors-nodejs/deployment
  kubectl apply -f deployment.yaml
  kubectl apply -f istio.yaml

  if [ $DB != "local" ]; then
     kubectl create -f istio-egress-cloudant.yaml
  fi

  _out Done deploying authors-nodejs
  _out Wait until the pod has been started: "kubectl get pod --watch | grep authors"
}

_out Deploying authors-nodejs
templates
setup