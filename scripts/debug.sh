#!/usr/bin/env bash

: ' Runs Docker container(s) and attaches stdout/stderr to host machine

    '

# bash parameters
set -u  #   nounset  - Attempt to use undefined variable outputs error message, and forces an exit
#set -x  #   xtrace   - Enable print commands and their arguments as they are executed.

# binaries
DOCKER_COMPOSE=$(which docker-compose)

## variables
# transform subscription to lower case
export ACQUIA_SUBSCRIPTION=${ACQUIA_SUBSCRIPTION,,}

# run containers and attach stdout/stderr
"${DOCKER_COMPOSE}" \
    --file infrastructure/docker-compose.yaml \
    --project-name "${ACQUIA_SUBSCRIPTION}" \
    up


# "${DOCKER}" run --name "${DOCKER_CONTAINER_NAME}" \
#                 --tty \
#                 --attach stdout \
#                 --attach stderr \
#                 --env-file \
#                   "conf/"${APP_NAME}"."${ENVIRONMENT}".env" \
#                 ""${DOCKER_IMAGE_NAME}":"${DOCKER_DEFAULT_TAG}""
