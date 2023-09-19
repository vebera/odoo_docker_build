#!/bin/bash

#maintainer vasyl.melnychuk@accessholding.com

# Error handling
set -o errexit          # Exit on most errors
set -o errtrace         # Make sure any error trap is inherited
set -o pipefail         # Use last non-zero exit code in a pipeline

declare RED='\033[0;31m'
declare BLUE='\033[0;34m'
declare NC='\033[0m'
declare config='.env'

if [ ! -r $config ]
then 
  printf "Missing config file ${RED} "$config" ${NC}. Make sure to fix it and try again.\n"
  exit 1
else
  source $config
fi

# Checksums-SHA1 from the file `odoo_15.0.XXXXXXXX_amd64.changes`
# url https://nightly.odoo.com/15.0/nightly/deb/
# line across the .deb filename (odoo_15.0.XXXXXXXX_all.deb)
ODOO_SHA="$(curl -o odoo.sha -sSL http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/odoo_${ODOO_VERSION}.${ODOO_RELEASE}_amd64.changes \
          && cat odoo.sha | grep -m 1 odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb | cut -f 2 -d ' ')"

printf "===============================================================\n"
printf "  DOCKER_USER:       ${BLUE}${DOCKER_USER}${NC}\n"
printf "  DOCKER_PASS:       ${BLUE}${DOCKER_PASS}${NC}\n"
printf "  ODOO_VERSION:      ${BLUE}${ODOO_VERSION}${NC}\n"
printf "  VERSION TAG:       ${BLUE}${TAG}${NC}\n"
printf "  ODOO_RELEASE:      ${BLUE}${ODOO_RELEASE}${NC}\n"
printf "  ODOO_SHA:          ${BLUE}${ODOO_SHA}${NC}\n"
printf "===============================================================\n"

DOCKER_BUILDKIT=1 docker build --build-arg ODOO_VERSION=${ODOO_VERSION} \
    --build-arg ODOO_RELEASE=${ODOO_RELEASE} \
    --build-arg ODOO_SHA=${ODOO_SHA} . -t ${DOCKER_USER}/odoo:${TAG}.${ODOO_RELEASE}
docker login -u "${DOCKER_USER}" -p "${DOCKER_PASS}" docker.io
docker push ${DOCKER_USER}/odoo:${TAG}.${ODOO_RELEASE}

printf "  BUILD: ${BLUE}${DOCKER_USER}/odoo:${TAG}.${ODOO_RELEASE}${NC} COMPLETED. \n"
