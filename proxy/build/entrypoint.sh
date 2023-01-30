#!/bin/bash

if [[ -z "$HEIMDALL_SVC" ]]; then
    echo "WARNING: No 'HEIMDALL_SVC' variable set. Defaulting to 'heimdall'."
    HEIMDALL_SVC=heimdall
fi

if [[ -z "$HEIMDALL_NAMESPACE" ]]; then
    echo "WARNING: No 'HEIMDALL_NAMESPACE' variable set. Defaulting to 'heimdall'."
    HEIMDALL_NAMESPACE=heimdall
fi

if [[ -z "$HEIMDALL_PORT" ]]; then
    echo "WARNING: No 'HEIMDALL_PORT' variable set. Defaulting to '80'."
    HEIMDALL_PORT=80
fi

if [[ -z "$K8S_DNS" ]]; then
    # No need for a warning. These are pretty standard
    K8S_DNS=10.43.0.1
fi

if [[ -z "$PROXY_PORT" ]]; then
    # No need for a warning. These are pretty standard
    PROXY_PORT=8080
fi

echo "Replacing nginx.conf placeholders (Proxy: $HEIMDALL_SVC.$HEIMDALL_NAMESPACE.svc.cluster.local:$HEIMDALL_PORT).."
sed -i'' -e "s/HEIMDALL_SVC_PLACEHOLDER/$HEIMDALL_SVC/g; s/HEIMDALL_NAMESPACE_PLACEHOLDER/$HEIMDALL_NAMESPACE/g; s/HEIMDALL_PORT_PLACEHOLDER/$HEIMDALL_PORT/g;  s/PROXY_PORT_PLACEHOLDER/$PROXY_PORT/g; s/K8S_DNS_PLACEHOLDER/$K8S_DNS/g" /etc/nginx/nginx.conf

echo "Starting NGINX.."
nginx