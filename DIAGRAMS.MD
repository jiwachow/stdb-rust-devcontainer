## **Dev Container Diagrams**

These diagrams illustrate the local setup and common workflows relevant to *using* this dev container template. Diagrams specific to a larger application architecture built *using* this template (like multi-environment K8s deployments, specific auth flows, CI/CD pipelines, or secrets management beyond the included Vault CLI) would belong in the consuming project's documentation.

### **1. Local Development Environment Setup**

This diagram shows the relationship between the host system, the Dev Container CLI, Podman, VS Code, and the running container with its tools.
```mermaid
graph LR
    subgraph HostMachine [Host Machine 'Windows']
        WSL2[WSL2 Environment 'Ubuntu 24.04']
        VSCodeClient[VS Code Client]
    end

    subgraph WSL2
        Podman[Podman Daemon]
        Minikube[Minikube Cluster 'Optional K8s']
        GitHost[Git CLI on Host]
        NodeJS[Node.js / npm] --> DevCLI[Dev Containers CLI]
        SSH_Agent[SSH Agent 'Running w/ Key']
    end

    subgraph DevContainer [Dev Container 'Runs via Podman']
        direction TB %% Change container direction to Top-Bottom

        subgraph ContainerInternals [Container Internals]
            direction LR
            VSC_Server[VS Code Server]
            Terminal[Integrated Terminal 'Zsh']
            Workspace[Project Code 'Mounted']
        end

        subgraph ToolsSubgraph [Included Tools]
             direction TB %% Tools flow Top-Bottom

             subgraph CoreRuntimes [Core Runtimes]
                 direction LR
                 RustToolchain[Rust] --- PythonRuntime[Python/Pip] --- NodeRuntime[Node/Npm] --- TypeScript[TS]
             end

             subgraph SpacetimeK8s [SpacetimeDB & K8s/Containers]
                 direction LR
                 SpacetimeCLI[Spacetime CLI] --- KubernetesTools[kubectl/Helm] --- PodmanClient[Podman Client]
             end

             subgraph DevOpsBuild [DevOps & Build]
                 direction LR
                 VaultClient[Vault CLI] --- BazelBuild[Bazel] --- PreCommit[Pre-commit] --- MiseEnv[mise] --- ArgoCLI[ArgoCD CLI] --- TiltCLI[Tilt CLI]
             end

             subgraph UtilsOther [Utilities & Other]
                 direction LR
                 GitContainer[Git CLI] --- GH_CLI[GitHub CLI] --- ShellUtils[Modern Shell Utils] --- JLess[jless] --- JqUtil[jq/htop] --- SocatUtil[socat/expect]
             end
        end

         %% Connections
         Terminal --> ToolsSubgraph
         PodmanClient --> |Uses Socket Mount| Podman
         GitContainer --> |Uses VSCode Forwarded Agent| VSC_Server
         KubernetesTools --> |Connects to Host| Minikube
         VSC_Server --> |Manages| Terminal
         VSC_Server --> |Accesses| Workspace
    end

    User[Developer] --> |Uses| VSCodeClient
    User --> |Runs Commands In| WSL2
    WSL2 --> |Runs| DevCLI
    DevCLI --> |Creates/Starts| DevContainer
    DevCLI --> |Requires| Podman
    VSCodeClient --> |Attaches to| VSC_Server
    VSC_Server --> |Forwards Agent From| SSH_Agent
    DevContainer --> |Mounts| Workspace
```

**Explanation:** The developer initiates the environment using the Dev Containers CLI (devcontainer up) within WSL2. VS Code attaches to the running container. VS Code Server automatically forwards the running SSH Agent from the WSL host into the container. Tools inside the container use this forwarded agent or interact with the host via the Podman socket mount or network connections.

### **2. Git Feature Branch Workflow**

This diagram illustrates the standard process for contributing code changes *within* the dev container environment.
```mermaid
sequenceDiagram
    participant Dev as Developer (in Container)
    participant LocalRepo as Local Git Repo (in Container)
    participant RemoteRepo as Remote Repo 'GitHub'
    participant CI as GitHub Actions CI (External)
    participant Reviewer as Code Reviewer (External)
    participant DevBranch as dev Branch 'Remote'

    Dev->>LocalRepo: git checkout dev
    Dev->>LocalRepo: git pull origin dev
    Dev->>LocalRepo: git checkout -b feature/new-thing
    Dev->>LocalRepo: Work on code (via VS Code attached)...
    Dev->>LocalRepo: git add .
    Dev->>LocalRepo: git commit -m "feat: Implement new feature"
    Dev->>LocalRepo: git push origin feature/new-thing
    LocalRepo->>RemoteRepo: Push feature branch (uses forwarded SSH agent)
    Dev->>RemoteRepo: Create Pull Request 'PR' targeting 'dev' (via Browser)
    RemoteRepo->>CI: Trigger CI Pipeline 'Build, Lint, Test'
    CI-->>RemoteRepo: Report Status 'Success/Failure'
    alt CI Fails
        Dev->>LocalRepo: Fix code, commit, push
        LocalRepo->>RemoteRepo: Push fixes to feature branch
        RemoteRepo->>CI: Re-trigger CI
    end
    RemoteRepo->>Reviewer: Notify about PR
    Reviewer->>RemoteRepo: Review code, request changes or approve
    alt Changes Requested
        Dev->>LocalRepo: Make changes, commit, push
        LocalRepo->>RemoteRepo: Push updates
        RemoteRepo->>Reviewer: Notify about updates
    end
    Reviewer->>RemoteRepo: Approve PR
    Dev->>RemoteRepo: Merge PR into 'dev' (via Browser/GitHub)
    RemoteRepo->>DevBranch: Update 'dev' branch
    Dev->>LocalRepo: git checkout dev
    Dev->>LocalRepo: git pull origin dev
    Dev->>LocalRepo: git branch -d feature/new-thing
```
**Explanation:** Developers create feature branches from dev, work locally within the container, push the branch using the forwarded SSH agent, and open a Pull Request via the GitHub web UI. CI checks run. After code review and approval, the PR is merged.