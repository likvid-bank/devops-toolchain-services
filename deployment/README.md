# How to deploy devops-toolchain-services

1. Provide github authentication; for example by setting the env variable GITHUB_TOKEN. 
2. Apply the terraform in this directory.
3. Create a repository secret `WORKFLOW_TOKEN` that holds a personal access token with the permissions `repo`, `workflow`, `admin:org`. This token is used by the main pipeline: 
5. Create a GitHub App with read and write permissions on `Administration`, `Contents`, `Secrets`, `Workflows`.
6. Install the App in your GitHub organization.
7. Create three repository secrets `GH_GITHUB_APP_ID`, `GH_GITHUB_APP_INSTALLATION_ID`, `GH_GITHUB_APP_PEM_FILE`.

Here is how the bits and pieces come together in this deployment:

```mermaid
flowchart LR;

subgraph credentialsForGithubService[Credentials for Azure and GCP]
		azureServicePrincipal[Azure Service Principal]
		gcpServiceAccount[GCP Service Account]
end

githubApp[GitHub App]
pat[GitHub personal access token]

subgraph repo[GitHub Repository]
		repoSecrets[Repository Secrets used by pipeline]
    deployKey[Deploy Key used by UniPipe Service Broker]
    cloneUrl[repository clone URL]
end

subgraph unipipe[UniPipe container in GCP]
    instanceRepoURL[instance repository clone URL]
    sshKey[Private SSH Key]
    username[basic auth username]
    password[basic auth password]
    containerUrl[container URL]
end

tfoutput[Terraform Output]

username --> tfoutput
password --> tfoutput
containerUrl --> tfoutput
sshKey --register public key--> deployKey
pat -. insert manually .-> repoSecrets
githubApp -. insert manually .-> repoSecrets
gcpServiceAccount --> repoSecrets
azureServicePrincipal --> repoSecrets
cloneUrl --register clone URL--> instanceRepoURL
```
