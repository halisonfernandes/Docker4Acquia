#!/usr/bin/env bash

: ' Spin-up Nginx proxy container

    '

# bash parameters
set -u  #   nounset  - Attempt to use undefined variable outputs error message, and forces an exit
#set -x  #   xtrace   - Enable print commands and their arguments as they are executed.

# binaries
DOCKER=$(which docker)
DOCKER_COMPOSE=$(which docker-compose)
TR=$(which tr)

## variables
# transform subscription to lower case
export ACQUIA_SUBSCRIPTION=$("${TR}" '[:upper:]' '[:lower:]' <<< "${ACQUIA_SUBSCRIPTION}")

# pull images first, check for updated versions
"${DOCKER_COMPOSE}" \
    --file infrastructure/proxy/docker-compose.yaml \
    --project-name "proxy" \
    pull

# build
"${DOCKER_COMPOSE}" \
    --file infrastructure/proxy/docker-compose.yaml \
    --project-name "proxy" \
    build

# spin-up container
"${DOCKER_COMPOSE}" \
    --file infrastructure/proxy/docker-compose.yaml \
    --project-name "proxy" \
    up -d

# connect nginx proxy to the project network
"${DOCKER}" network connect ""${ACQUIA_SUBSCRIPTION}"_default" nginx
