#!/bin/sh

set -euo pipefail
IFS=$(printf ' \n\t')

debug() {
  if [ "${ACTIONS_RUNNER_DEBUG:-}" = "true" ]; then
    echo "DEBUG: :: $*" >&2
  fi
}

if [ -n "${INPUT_AWS_ACCESS_KEY_ID:-}" ]; then
  export AWS_ACCESS_KEY_ID="${INPUT_AWS_ACCESS_KEY_ID}"
fi

if [ -n "${INPUT_AWS_SECRET_ACCESS_KEY:-}" ]; then
  export AWS_SECRET_ACCESS_KEY="${INPUT_AWS_SECRET_ACCESS_KEY}"
fi

if [ -n "${INPUT_AWS_REGION:-}" ]; then
  export AWS_DEFAULT_REGION="${INPUT_AWS_REGION}"
fi

echo "aws version"

aws --version

echo "Updating kubeconfig for aws"

if [ -n "${INPUT_EKS_ROLE_ARN}" ]; then
  aws eks update-kubeconfig --name "${INPUT_CLUSTER_NAME}" --role-arn "${INPUT_EKS_ROLE_ARN}"
else 
  aws eks update-kubeconfig --name "${INPUT_CLUSTER_NAME}"
fi

debug "Starting kubectl collecting output"

function deploymentcheck(){
  isnewberunning="false"
  echo "is it running ? $isnewberunning"
  count=0
  while [ "$isnewberunning" != "true true true" ]; do
     if [ "$count" = "30" ]; then
         exit 1;
     fi
     sleep 15;
     count=$((count+1))
     echo "BE running checking : $count times"
     isnewberunning=$(kubectl get pods -n $INPUT_NAMESPACE -l "app.kubernetes.io/name=$INPUT_APP_NAME" -o jsonpath='{.items[*].status.containerStatuses[0].ready}')
     echo "is it running ? $isnewberunning"
  done
}

output=$( deploymentcheck )

debug "${output}"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  delimiter=$(mktemp -u XXXXXX)

  echo "deployment-check-out<<${delimiter}" >> $GITHUB_OUTPUT
  echo "${output}" >> $GITHUB_OUTPUT
  echo "${delimiter}" >> $GITHUB_OUTPUT
else
  echo ::set-output name=deployment-check-out::"${output}"
fi
