#!/bin/sh

if [[ "$APP_HEIMDALL_NAMESPACE" == "" ]]; then
  APP_HEIMDALL_NAMESPACE="compliance-operator-system"
fi

if [[ "$APP_HEIMDALL_PROXY_SERVICE" == "" ]]; then
  APP_HEIMDALL_PROXY_SERVICE="heimdall-proxy"
fi

if [[ "$APP_HEIMDALL_PROXY_PORT" == "" ]]; then
  APP_HEIMDALL_PROXY_PORT="80"
fi

if [[ "$RCIDF_ID_PATH" == "" ]]; then
  RCIDF_ID_PATH="/rancher/id"
fi

if [[ "$RCIDF_URL_PATH" == ""  ]]; then
  RCIDF_URL_PATH="/rancher/url"
fi

if [[ "$RANCHER_CLUSTER_ID" == "" ]]; then
  # no rancher cluster id
  # try via rcidf, otherwise bail
  export RANCHER_CLUSTER_ID=$(cat $RCIDF_ID_PATH) # THIS IS USED IN HEIMDALL
  if [[ "$RANCHER_CLUSTER_ID" == "" ]]; then
    echo "Unable to configure Rancher Cluster ID. Exiting"
    exit 1
  fi
fi

if [[ "$RANCHER_URL" == "" ]]; then
  # no rancher url 
  # try via rcidf, otherwise bail
  export RANCHER_URL=$(cat $RCIDF_URL_PATH) # THIS IS USED IN HEIMDALL
  if [[ "$RANCHER_URL" == "" ]]; then
    echo "Unable to configure Rancher URL. Exiting"
    exit 1
  fi
fi

if [ ! -f "$RCIDF_ID_PATH" ]; then
  if [[ "$PUBLIC_PATH" == "" ]]; then
    echo "One of $RCIDF_ID_PATH or PUBLIC_PATH must be defined."
    exit 1
  fi
else
  # RCIDF PATH exists
  # use it to construct PUBIC_PATH
  PUBLIC_PATH="/k8s/clusters/$RANCHER_CLUSTER_ID/api/v1/namespaces/$APP_HEIMDALL_NAMESPACE/services/http:$APP_HEIMDALL_PROXY_SERVICE:$APP_HEIMDALL_PROXY_PORT/proxy"
fi

if [[ "$ROUTER_BASE_PATH" == "" ]]; then
  ROUTER_BASE_PATH=$PUBLIC_PATH
fi

if [[ "$AXIOS_BASE_URL" == "" ]]; then
  AXIOS_BASE_URL=$PUBLIC_PATH
fi

sed -i "s|#####PUBLIC_PATH#####|$PUBLIC_PATH|g;" /app/dist/frontend/js/*

sed -i "s|#####ROUTER_BASE_PATH#####|$ROUTER_BASE_PATH|g;" /app/dist/frontend/js/*
sed -i "s|#####AXIOS_BASE_URL#####|$AXIOS_BASE_URL|g;" /app/dist/frontend/js/*

echo "Configured with... "
echo "PUBLIC_PATH=$PUBLIC_PATH"
echo "ROUTER_BASE_PATH=$ROUTER_BASE_PATH"
echo "AXIOS_BASE_URL=$AXIOS_BASE_URL"
echo "RANCHER_CLUSTER_ID=$RANCHER_CLUSTER_ID"
echo "RANCHER_URL=$RANCHER_URL"
echo "APP_HEIMDALL_NAMESPACE=$APP_HEIMDALL_NAMESPACE"
echo "APP_HEIMDALL_PROXY_SERVICE=$APP_HEIMDALL_PROXY_SERVICE"
echo "APP_HEIMDALL_PROXY_PORT=$APP_HEIMDALL_PROXY_PORT"

set -e
yarn backend sequelize-cli db:migrate
yarn backend sequelize-cli db:seed:all
yarn backend start
