#!/bin/sh

if [[ "$APP_HEIMDALL_NAMESPACE" == "" ]]; then
  APP_HEIMDALL_NAMESPACE="cattle-compliance-system"
fi

if [[ "$APP_HEIMDALL_NGINX_WORKLOAD" == "" ]]; then
  echo "beep"
  APP_HEIMDALL_NGINX_WORKLOAD="heimdall-nginx"
fi

if [[ "$APP_HEIMDALL_NGINX_PORT" == "" ]]; then
  APP_HEIMDALL_NGINX_PORT="80"
fi

if [[ "$RCIDF_PATH" == "" ]]; then
  RCIDF_PATH="/rancher/id"
fi

if [ ! -f "$RCIDF_PATH" ]; then
  echo "Retrieving the Cluster ID from cluster.."
  CLUSTERID=$(kubectl get cm -n cattle-fleet-system fleet-agent -o json | jq -r '.data.config' | jq -r '.labels."management.cattle.io/cluster-name"')
else
  # RCIDF PATH exists
  # use it to construct PUBIC_PATH
  CLUSTERID=$(cat $RCIDF_PATH)
fi

PUBLIC_PATH="/k8s/clusters/$CLUSTERID/api/v1/namespaces/$APP_HEIMDALL_NAMESPACE/services/http:$APP_HEIMDALL_NGINX_WORKLOAD:$APP_HEIMDALL_NGINX_PORT/proxy"

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

set -e
yarn backend sequelize-cli db:migrate
yarn backend sequelize-cli db:seed:all
yarn backend start
