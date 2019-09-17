#!/bin/bash

set -xe

BOOTSTRAP=false

function usage() {
  echo "Usage: $0 [-b]" 1>&2
  exit 2
}

while getopts ":b" o; do
  case "${o}" in
    b)
      BOOTSTRAP=true
      ;;
    *)
      usage
      ;;
  esac
done

terraform destroy -auto-approve community
if [[ $BOOTSTRAP = true ]]; then
  echo no | terraform init bootstrap
  rm terraform.tfstate
  cp terraform.tfstate.backup terraform.tfstate
  terraform destroy -auto-approve bootstrap
  rm terraform.tfvars
  rm community/backend.tf
fi
