#!/bin/bash

# exit if a command returns a non-zero exit code and also print the commands and their args as they are executed.
set -e -x

# Download and install required tools.
# pulumi
curl -L https://get.pulumi.com/ | sh -s -- --version ${PULUMI_VERSION}
export PATH=$PATH:$HOME/.pulumi/bin

cd ${WORKING_DIRECTORY}

# Restore dependencies
python -m pip install -r requirements.txt

# Login into pulumi. This will require the PULUMI_ACCESS_TOKEN environment variable.
pulumi login

# Create stack if not exists. This will require a GCP KMS encryption key to store secrets in Pulumi
pulumi stack init ${STACK} --secrets-provider="gcpkms://projects/${GOOGLE_PROJECT}/locations/global/keyRings/${GOOGLE_KEY_RING}/cryptoKeys/${GOOGLE_CRYPTO_KEY}" || { echo "stack already exists, continue with that stack."; }

# Select the appropriate stack.
#pulumi stack select org/project/stack
pulumi stack select ${PULUMI_STACK}

# set stack configurations
pulumi config set gcp:project ${GOOGLE_PROJECT} --non-interactive 
pulumi config set gcp:region ${GOOGLE_REGION} --non-interactive 
pulumi config set gcp:zone ${GOOGLE_ZONE} --non-interactive 
pulumi config set serviceAccountName ${SERVICE_ACCOUNT} --non-interactive

case $BUILD_TYPE in
  PullRequest)
      pulumi preview
    ;;
  *)
      pulumi up --yes
    ;;
esac