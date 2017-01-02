#!/usr/bin/env bash

: ' Stops running Docker container(s), delete it and remove its Docker image

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

# clean message
echo -e "\n  _______________________________________________________________________________\n"
echo -e "\n  -- Docker Clean\n\n  Cleaning up\n  Please wait..."

# disconnect nginx proxy to the project network if it is attached
echo -en "\n  Disconnect Nginx proxy if it is running: \n\n"
"${DOCKER}" network disconnect -f ""${ACQUIA_SUBSCRIPTION}"_default" nginx >/dev/null 2>&1 || true

# stop and remove containers, networks, images, and volumes
echo -en "\n  Stopping and removing containers, networks, images, and volumes: \n\n"
"${DOCKER_COMPOSE}" \
    --file infrastructure/docker-compose.yaml \
    --project-name "${ACQUIA_SUBSCRIPTION}" \
    down

echo -e "  _______________________________________________________________________________\n"
