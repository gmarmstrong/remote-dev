#!/usr/bin/env bash
set -eu

# Configuration

export PROJECT_ID="gmarmstrong" # replace with your GCP project name
export TERRAFORM_VERSION="1.1.9" # refer to https://www.terraform.io/downloads
export TERRAFORM_VERSION_SHA256SUM="9d2d8a89f5cc8bc1c06cb6f34ce76ec4b99184b07eb776f8b39183b513d7798a"
# NOTE: TERRAFORM_VERSION must match sha256sum of CONNTENTS of
# https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
# (of the terraform binary itself, not of the archive)

# Set project id
gcloud config set project $PROJECT_ID

if [ "$1" == "create" ] # launch the system
then
    # set up permissions
    ./set_acls.sh $PROJECT_ID
    # set up Cloud Build
    (cd cloud-builders-community/packer; gcloud builds submit)
    (cd cloud-builders-community/terraform; gcloud builds submit --substitutions=_TERRAFORM_VERSION="$TERRAFORM_VERSION",_TERRAFORM_VERSION_SHA256SUM="$TERRAFORM_VERSION_SHA256SUM")
    rm -rf gcloud
    # build the packer image
    (cd packer; gcloud builds submit)
    # deploy the server
    (cd terraform/states; gcloud builds submit)
    (cd terraform; gcloud builds submit)
elif [ "$1" == "destroy" ] # shut down the system
then
    (cd terraform; gcloud builds submit --config=cloudbuild-destroy.yaml)
    (cd terraform/states; gcloud builds submit --config=cloudbuild-destroy.yaml)
fi
