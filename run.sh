#!/usr/bin/env bash
set -o errexit
set -o nounset

require() {
  if ! command -v "$1" &> /dev/null; then
    echo "Command $1 not found. Exiting."
    exit
  fi
}

require gcloud
require git

if [ $# -eq 0 ]
then
  echo "usage: $0 <command>"
  echo "where <command> is one of:"
  echo -e "\tcreate"
  echo -e "\tquick"
  echo -e "\tdestroy"
  exit 1
fi

# Configuration
export instance_zone="us-east1-b"
export instance_name="remote-dev"
export PROJECT_ID="gmarmstrong" # replace with your GCP project name
export TERRAFORM_VERSION="1.1.9" # refer to https://www.terraform.io/downloads
export TERRAFORM_VERSION_SHA256SUM="9d2d8a89f5cc8bc1c06cb6f34ce76ec4b99184b07eb776f8b39183b513d7798a"
# NOTE: TERRAFORM_VERSION must match sha256sum of CONTENTS of
# https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
# (of the terraform binary itself, not of the archive)

# Set project id
gcloud config set project $PROJECT_ID

set_permissions() {
  ./set_acls.sh "$PROJECT_ID"
}

builders_build() {
  # set up Cloud Build
  git submodule update --init
  (cd cloud-builders-community/packer; gcloud builds submit)
  (cd cloud-builders-community/terraform; gcloud builds submit \
    --substitutions=_TERRAFORM_VERSION="$TERRAFORM_VERSION",_TERRAFORM_VERSION_SHA256SUM="$TERRAFORM_VERSION_SHA256SUM")
}

packer_build() {
  (cd packer; gcloud builds submit)
}

tf_build() {
  (cd terraform/states; gcloud builds submit)
  (cd terraform; gcloud builds submit)
}

destroy() {
  (cd terraform; gcloud builds submit --config=cloudbuild-destroy.yaml)
  (cd terraform/states; gcloud builds submit --config=cloudbuild-destroy.yaml)
  gsutil -m rm -r "gs://${PROJECT_ID}_logs"
  gsutil -m rm -r "gs://${PROJECT_ID}_tf-state"
}

vscode_ssh() {
  # write keys to ~/.google_compute_known_hosts and print the equivalent ssh command
  gcloud compute ssh "$instance_name" --zone="$instance_zone" --tunnel-through-iap --dry-run
  echo Now run gcloud compute ssh "\$instance_name" --zone="\$instance_zone" --tunnel-through-iap
  echo Then see "https://medium.com/@albert.brand/remote-to-a-vm-over-an-iap-tunnel-with-vscode-f9fb54676153"
}

if [ "$1" == "create" ]; then # launch the system
  set_permissions
  builders_build
  packer_build
  tf_build
elif [ "$1" == "vscode" ]; then
  vscode_ssh # prepare for using instance as vscode backend
elif [ "$1" == "quick" ]; then # launch the system, skipping some steps
  packer_build
  tf_build
elif [ "$1" == "destroy" ]; then # shut down the system
  destroy
fi
