#!/usr/bin/env bash

: ' Spin-up Docker4Acquia containers

    '

## bash parameters
set -u  #   nounset  - Attempt to use undefined variable outputs error message, and forces an exit
#set -x  #   xtrace   - Enable print commands and their arguments as they are executed.

## binaries
CAT=$(which cat)
DOCKER_COMPOSE=$(which docker-compose)
TR=$(which tr)

## variables
# transform subscription to lower case
export ACQUIA_SUBSCRIPTION=$("${TR}" '[:upper:]' '[:lower:]' <<< "${ACQUIA_SUBSCRIPTION}")

## functions
# get Docker container IP
function get_docker_container_ip()
{

  # local function variables
  local _PROJECT_NAME="${1:-}"
  local _CONTAINER_NAME="${2:-}"

  # inspect the container and get the IP address
  local _CONTAINER_IP=$(\
          docker inspect \
            --type \
              container \
            --format \
              "{{ .NetworkSettings.Networks."${_PROJECT_NAME}"_default.IPAddress }}" \
            "${_CONTAINER_NAME}" \
          )

  # return the IP address
  echo "${_CONTAINER_IP}"

} # end of get_docker_container_ss

function is_linux()
{
  if [[ "$OSTYPE" == "linux-gnu" ]]; then
    return 0
  else
    return 1
  fi
}

function is_mac()
{
  if [[ "$OSTYPE" == "darwin"* ]]; then
    return 0
  else
    return 1
  fi
}

function is_windows()
{
  if [[ "$OSTYPE" == "msys" ]]; then
    return 0
  else
    return 1
  fi
}

function remove_hosts_entries() {
  # Mac expects a different paramter format
  if is_mac; then
    _TFILE=`mktemp /tmp/tfile.XXXXX`
  else
    _TFILE=`mktemp --tmpdir tfile.XXXXX`
  fi

  trap "rm -f ${_TFILE}" 0 1 2 3 15

  # copy hosts to temporary folder
  cp "${_HOSTS_FILE}" "${_TFILE}"

  # if the ip or hostname is already in hosts remove it
  $_USER bash -c "sed --in-place "/""${ACQUIA_SUBSCRIPTION}"-memcached"/d" "${_TFILE}""
  $_USER bash -c "sed --in-place "/""${ACQUIA_SUBSCRIPTION}"-mysql"/d" "${_TFILE}""
  $_USER bash -c "sed --in-place "/""${ACQUIA_SUBSCRIPTION}"-mail"/d" "${_TFILE}""
  $_USER bash -c "sed --in-place "/""${ACQUIA_SUBSCRIPTION}"-solr"/d" "${_TFILE}""

  IFS=',' read -r -a _URLS <<< "${URLS}"
  for url in "${_URLS[@]}"; do
    $_USER bash -c "sed --in-place "/"${url}"/d" "${_TFILE}""
  done

  # put temporary content inside of hosts
  $_USER bash -c "cat "${_TFILE}" | $_USER tee "${_HOSTS_FILE}" 1>/dev/null"

  # exit OK
  return 0
}

function add_unix_hosts_entries() {
  # write the ip address and hostname
  $_USER bash -c "echo "${MEMCACHED_IP}" ""${ACQUIA_SUBSCRIPTION}"-memcached."${ENVIRONMENT}"" | $_USER tee -a "${_HOSTS_FILE}""
  $_USER bash -c "echo "${PERCONA_IP}" ""${ACQUIA_SUBSCRIPTION}"-mysql."${ENVIRONMENT}"" | $_USER tee -a "${_HOSTS_FILE}""
  $_USER bash -c "echo "${MAIL_IP}" ""${ACQUIA_SUBSCRIPTION}"-mail."${ENVIRONMENT}"" | $_USER tee -a "${_HOSTS_FILE}""
  $_USER bash -c "echo "${SOLR_IP}" ""${ACQUIA_SUBSCRIPTION}"-solr."${ENVIRONMENT}"" | $_USER tee -a "${_HOSTS_FILE}""

  IFS=',' read -r -a _URLS <<< "${URLS}"
  for url in "${_URLS[@]}"; do
    $_USER bash -c "echo "${PHP_IP}" "${url}" | $_USER tee -a "${_HOSTS_FILE}""
  done
}

function add_macwindows_hosts_entries() {
  # write the ip address and hostname
  $_USER bash -c "echo 127.0.0.1 ""${ACQUIA_SUBSCRIPTION}"-mail."${ENVIRONMENT}"" | $_USER tee -a "${_HOSTS_FILE}" 1>/dev/null"
  $_USER bash -c "echo 127.0.0.1 ""${ACQUIA_SUBSCRIPTION}"-solr."${ENVIRONMENT}"" | $_USER tee -a "${_HOSTS_FILE}" 1>/dev/null"

  IFS=',' read -r -a _URLS <<< "${URLS}"
  for url in "${_URLS[@]}"; do
    $_USER bash -c "echo 127.0.0.1 "${url}" | $_USER tee -a "${_HOSTS_FILE}" 1>/dev/null"
  done
}

## flow
# start message
echo "  _______________________________________________________________________________"
echo -en "\n  -- Docker run\n\n  Spinning-up Docker container(s)\n\n"

# spin-up containers
"${DOCKER_COMPOSE}" \
    --file infrastructure/docker-compose.yaml \
    --project-name "${ACQUIA_SUBSCRIPTION}" \
    up -d

# print messages if docker run was successful or not
if [ $? -eq 0 ]; then

  # change bash parameter
  set -e  #   errexit  - Abort script at first error, when a command exits with non-zero status (except in until or while loops, if-tests, list constructs)

  # collect IPs
  SOLR_IP=$(get_docker_container_ip "${ACQUIA_SUBSCRIPTION//[-]/}" ""${ACQUIA_SUBSCRIPTION}"-solr."${ENVIRONMENT}"")
  MAIL_IP=$(get_docker_container_ip "${ACQUIA_SUBSCRIPTION//[-]/}" ""${ACQUIA_SUBSCRIPTION}"-mail."${ENVIRONMENT}"")
  MEMCACHED_IP=$(get_docker_container_ip "${ACQUIA_SUBSCRIPTION//[-]/}" ""${ACQUIA_SUBSCRIPTION}"-memcached."${ENVIRONMENT}"")
  PERCONA_IP=$(get_docker_container_ip "${ACQUIA_SUBSCRIPTION//[-]/}" ""${ACQUIA_SUBSCRIPTION}"-percona."${ENVIRONMENT}"")
  PHP_IP=$(get_docker_container_ip "${ACQUIA_SUBSCRIPTION//[-]/}" ""${ACQUIA_SUBSCRIPTION}"-php."${ENVIRONMENT}"")

  # declare hosts file location
  if is_linux; then
    _HOSTS_FILE="/etc/hosts"
    _USER="sudo"
    remove_hosts_entries
    add_linux_hosts_entries
    IFS=',' read -r -a _URLS <<< "${URLS}"
    PHP_URLS='';
    for url in "${_URLS[@]}"; do
      PHP_URLS+="${url}:80
    ${url}:443
  "
    done
    "${CAT}" << EOM
  _______________________________________________________________________________

  Your Docker containers are UP and RUNNING

  Solr is avaiable at:
  ${ACQUIA_SUBSCRIPTION}-solr.${ENVIRONMENT}:8983

  Memcached is avaiable at:
  ${ACQUIA_SUBSCRIPTION}-memcached.${ENVIRONMENT}:11211

  Mailhog is avaiable at:
  ${ACQUIA_SUBSCRIPTION}-mail.${ENVIRONMENT}:8025

  Percona (MySQL) is avaiable at:
  ${ACQUIA_SUBSCRIPTION}-percona.${ENVIRONMENT}:3306

  PHP/Apache is avaiable at:
  ${PHP_URLS}
  _______________________________________________________________________________

EOM

  else
    if is_mac; then
      _HOSTS_FILE="/etc/hosts"
      _USER="sudo"
    else
      _HOSTS_FILE="/c/Windows/System32/drivers/etc/hosts"
      _USER=""
    fi
    remove_hosts_entries
    add_macwindows_hosts_entries
  fi

else

"${CAT}" << EOM

  There are already Docker containers running!!!
  Please stop and delete it before running this commmand again

  _______________________________________________________________________________

EOM

  exit 1

fi
