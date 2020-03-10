#!/bin/bash

set -e

data_catalog="${1}"
PROJECT_ID="${2}"
KMS_KEYRING_REGION="${3}"
KMS_KEYRING="${4}"
KMS_KEY="${5}"
ENCRYPTED_GITHUB_TOKEN="${6}"

if [ -z "${ENCRYPTED_GITHUB_TOKEN}" ]
then
    echo "Usage: $0 <data_catalog> <project_id> <keyring_region> <keyring> <key> <encrypted_github_token>"
    exit 1
fi

basedir="$(dirname "$0")"

echo "${ENCRYPTED_GITHUB_TOKEN}" | gcloud kms decrypt \
    --location="${KMS_KEYRING_REGION}" --keyring="${KMS_KEYRING}" \
    --key="${KMS_KEY}" --project="${PROJECT_ID}" \
    --ciphertext-file=- --plaintext-file=github_token.key

${basedir}/reposupdate.sh "${data_catalog}" . pull github_token.key
${basedir}/reposstatus.sh "${data_catalog}" .
${basedir}/check_pipeline_security_scans.sh .
