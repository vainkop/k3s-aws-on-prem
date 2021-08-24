#!/bin/bash

export APPS_DIR="$1"
export APP_NAME="$2"
export NAMESPACE="$3"

kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f - && \
kubectl config set-context --current --namespace=$NAMESPACE && \
helm upgrade -i $APP_NAME $APPS_DIR/$APP_NAME --values=$APPS_DIR/$APP_NAME/values.yaml