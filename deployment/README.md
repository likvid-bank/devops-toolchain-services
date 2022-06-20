# How to deploy devops-toolchain-services

1. Apply the terraform in this directory
2. Create a repository secret `WORKFLOW_TOKEN` that holds a personal access token with the permissions `repo`, `workflow`, `admin:org`
3. Create a GitHub App with read and write permissions on `Administration`, `Contents`, `Secrets`, `Workflows`.
4. Install the APp in your GitHub organization.
5. Create three repository secrets `GH_GITHUB_APP_ID`, `GH_GITHUB_APP_INSTALLATION_ID`, `GH_GITHUB_APP_PEM_FILE`.
