#!/bin/bash

set -evx

# Start a simple HTTP server for sharing some config files
HTTP_SRV_CMD="python3 -m http.server"
pushd ..
setsid --fork ${HTTP_SRV_CMD} >/dev/null 2>&1
popd

# Needed to install Cypress plugins
npm install

# Start Cypress tests with docker
docker run -v $PWD:/e2e -w /e2e                            \
    -e RANCHER_USER=$RANCHER_USER                          \
    -e RANCHER_PASSWORD=$RANCHER_PASSWORD                  \
    -e RANCHER_URL=$RANCHER_URL                            \
    -e K8S_VERSION_TO_PROVISION=$K8S_VERSION_TO_PROVISION  \
    -e UI_ACCOUNT=$UI_ACCOUNT                              \
    -e OPERATOR_VERSION=$OPERATOR_VERSION                  \
    --add-host host.docker.internal:host-gateway           \
    --ipc=host                                             \
    $CYPRESS_DOCKER                                        \
    -s /e2e/$SPEC

# Kill the HTTP server
pkill -f "${HTTP_SRV_CMD}"
