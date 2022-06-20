# How to deploy devops-toolchain-services

1. Provide github authentication; for example by setting the env variable GITHUB_TOKEN. 
2. Apply the terraform in this directory.
3. Create a repository secret `WORKFLOW_TOKEN` that holds a personal access token with the permissions `repo`, `workflow`, `admin:org`
4. Create a GitHub App with read and write permissions on `Administration`, `Contents`, `Secrets`, `Workflows`.
5. Install the APp in your GitHub organization.
6. Create three repository secrets `GH_GITHUB_APP_ID`, `GH_GITHUB_APP_INSTALLATION_ID`, `GH_GITHUB_APP_PEM_FILE`.
