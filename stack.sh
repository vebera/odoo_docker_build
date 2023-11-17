#!/bin/bash

# Error handling
set -o errexit          # Exit on most errors
set -o errtrace         # Make sure any error trap is inherited
set -o pipefail         # Use last non-zero exit code in a pipeline
#set -o nounset          # Exits if any of the variables is not set


GRN='\033[0;32m' && YEL='\033[1;33m' && RED='\033[0;31m' && BLU='\033[0;34m' && NC='\033[0m'
declare env=".env"

##reading .env parameters from the script folder
if [ ! -r $env ]; then
  printf "  Build: missing config file ${RED}$env${NC} in the folder ${RED}$PWD${NC}. Fix it and try again.\n"
  exit 1
else
  source $env
fi

showenv() {
  # Checksums-SHA1 from the file `odoo_17.0.XXXXXXXX_amd64.changes`
  # url https://nightly.odoo.com/17.0/nightly/deb/
  # line across the .deb filename (odoo_17.0.XXXXXXXX_all.deb)
  ODOO_VERSION=17.0
  if ! ODOO_SHA="$(curl -o odoo.sha -sSL http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/odoo_${ODOO_VERSION}.${ODOO_RELEASE}_amd64.changes \
            && cat odoo.sha | grep -m 1 odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb | cut -f 2 -d ' ')";
  then
    printf "\n${RED}Error getting ${ODOO_VERSION}.${ODOO_RELEASE}${NC}\n\n";
    exit 1
  fi

  printf "===============================================================\n"
  printf "  DOCKER_REGISTRY:   ${BLU}${DOCKER_REGISTRY}${NC}\n"
  printf "  DOCKER_USER:       ${BLU}${DOCKER_USER}${NC}\n"
  printf "  VERSION TAG:       ${BLU}${TAG}${NC}\n"
  printf "  ODOO_RELEASE:      ${BLU}${ODOO_RELEASE}${NC}\n"
  printf "  ODOO_SHA:          ${BLU}${ODOO_SHA}${NC}\n"
  printf "===============================================================\n"  
}

main() {
    case "${1}" in
        --build | -b )
            DOCKER_BUILDKIT=${DOCKER_BUILDKIT} docker build -f ${DOCKER_FILE} -t ${DOCKER_USER}/${DOCKER_IMAGE}:${TAG}.${ODOO_RELEASE} \
              --build-arg ODOO_RELEASE=${ODOO_RELEASE} \
              --build-arg ODOO_SHA=${ODOO_SHA} .
            echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin $DOCKER_REGISTRY
            docker push $DOCKER_REGISTRY/${DOCKER_USER}/${DOCKER_IMAGE}:${TAG}.${ODOO_RELEASE}
            ;;
        --prune )
            printf "Docker prune images with filter ${GRN}${PRUNE_FILTER}${NC} \n"
            docker image prune -a --force --filter "${PRUNE_FILTER}"
            ;;
        * ) 
            printf "usage: ${0} $GRN[arg]$NC\n \
                    $GRN--build,-b$NC\t\t Build the image\n \
                    $GRN--prune$NC\t\t Prune images ${PRUNE_FILTER}\n \
                    \n\
                    Example: ${BLU} ${0} ${GRN}-b${NC}\n \
                    "
            ;;
    esac

}

printf "${NC}Started: ${YEL}" && date && printf "${NC}\n"
showenv "$@"
time main "$@"
printf "${NC}Finished: ${YEL}" && date && printf "${NC}\n"
