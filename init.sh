#!/bin/bash

set -xe

PROJECT=titan-data
REGION=$(aws configure get region)
BOOTSTRAP=false

function usage() {
  echo "Usage: $0 [-p project-name] [-r region] [-b]" 1>&2
  exit 2
}

while getopts ":p:r:b" o; do
  case "${o}" in
    p)
      PROJECT=$OPTARG
      ;;
    r)
      REGION=$OPTARG
      ;;
    b)
      BOOTSTRAP=true
      ;;
    *)
      usage
      ;;
  esac
done

cat > terraform.tfvars <<EOF
project = "$PROJECT"
region = "$REGION"
EOF

cat community/backend.tf.tmpl | \
  sed -e s/BACKEND_STATE/$PROJECT-state/ -e s/AWS_REGION/$REGION/ > \
  community/backend.tf

if [[ $BOOTSTRAP = true ]]; then
  terraform init -input=false bootstrap
  terraform plan -out=tfplan -input=false bootstrap
  terraform apply -input=false tfplan
  echo no | terraform init -reconfigure community
else
  terraform init community
fi
