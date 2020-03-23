# Source repository control

The code in this repository implements GitHub repository management. The actual creation and permissioning on GitHub repositories is implemented in [dcat-deploy](https://github.com/vwt-digital/dcat-deploy). Repo-control can be used in a GCP project running a dcat-deploy to deploy a data catalog containing GitHub repositories. For each of the repositories found in the data catalog, the [scripts/run_control.sh](scripts/run_control.sh) will report the number of commits that the master branch is behind on the develop branch. Next to that it will report on security scanners found in the cloudbuild.yaml build pipelines.

## Usage

The output reports of repo-control are stored in a bucket in de GCP project. This bucket must be created before and it should be named _{PROJECT_ID}-reports-stg_.
Repo-control runs through a cloudbuild:
```
$ cd repo-control
$ gcloud builds submit --no-source --config=cloudbuild_control.json --substitutions=<substitutions>
```
The substitution variables are
|Variable|Description|
|--------|-----------|
|_DEPLOY_BRANCH_NAME|Branch name of repo-control to use (master or develop)|
|_ENCRYPTED_GITHUB_TOKEN|Base64 encoded encrypted GitHub token permissioned to create and clone repositories and to grant/revoke access|
|_KEYRING_REGION|Location of KMS keyring to decrypt encrypted GitHub token|
|_KEYRING|Name of KMS keyring to decrypt encrypted GitHub token|
|_KEY|KMS Key to decrypt encrypted GitHub token|
