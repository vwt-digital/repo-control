#!/bin/bash

set -e

DATA_CATALOG="${1}"
PROJECT_ID="${2}"
SECRET_ID="${6}"

if [ -z "${SECRET_ID}" ]
then
    echo "Usage: $0 <data_catalog> <project_id> <secret_id>"
    exit 1
fi

basedir="$(dirname "$0")"

github_token=$(gcloud secrets versions access latest --secret="${SECRET_ID}" --project="${PROJECT_ID}")

echo "Updating repositories"
"${basedir}"/reposupdate.sh "${data_catalog}" . pull github_token

echo
echo "Checking commits behind"
"${basedir}"/reposstatus.sh "${data_catalog}" . | grep -v " 0 " | tee repository_status.txt
gsutil cp repository_status.txt gs://"${PROJECT_ID}"-reports-stg/repository_status."$(date "+%Y%m%dT%H%M%S")".txt

echo
echo "Checking pipeline security scans"
"${basedir}"/check_pipeline_security_scans.sh . | tee security_scan_status.txt
gsutil cp security_scan_status.txt gs://"${PROJECT_ID}"-reports-stg/security_scan_status."$(date "+%Y%m%dT%H%M%S")".txt
