#!/bin/bash

root_folder=$(cd $(dirname $0); cd ..; pwd)

exec 3>&1

function login() {
  oc login -u developer -p developer
  oc project cloud-native-starter
}

function _out() {
  echo "$(date +'%F %H:%M:%S') $@"
}

function setup() {
  _out Deleting authors-nodejs
  
  cd ${root_folder}/authors-nodejs
  oc delete all -l app=authors --ignore-not-found
  oc delete all -l app=authors --ignore-not-found
  kubectl delete -f deployment/istio.yaml --ignore-not-found

  _out Done Deleting authors-nodejs
}

login
setup
