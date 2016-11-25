#!/usr/bin/env bash

: ' Spin-up Docker4Acquia containers

    '

# bash parameters
set -e  #   errexit  - Abort script at first error, when a command exits with non-zero status (except in until or while loops, if-tests, list constructs)
set -u  #   nounset  - Attempt to use undefined variable outputs error message, and forces an exit
#set -x  #   xtrace   - Enable print commands and their arguments as they are executed.

# binaries
DOCKER_COMPOSE=$(which docker-compose)

## variables
export ACQUIA_SUBSCRIPTION="AcquiaSubscriptionName"

"${DOCKER_COMPOSE}" up -d
