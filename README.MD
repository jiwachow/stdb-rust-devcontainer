# **SpacetimeDB Dev Container Template**

This repository provides a comprehensive, pre-configured [Dev Container](https://containers.dev/) environment designed for SpacetimeDB (and general Rust/Python/Node.js) development, particularly optimized for use with Podman on WSL2 (Windows Subsystem for Linux 2).

It aims to provide a consistent, reproducible, and isolated development environment with essential tools included.

## **Features**

* **Base:** Ubuntu 24.04  
* **Shell:** Zsh \+ Oh My Zsh \+ Plugins (Syntax Highlighting, Autosuggestions) \+ Persistent History  
* **Core Tools:** Git, Common Utils (curl, sudo, etc.), jq, htop, expect  
* **Languages/Runtimes:** Rust (latest), Python (3.11 \+ pip), Node.js (LTS \+ npm), TypeScript  
* **SpacetimeDB:** spacetime CLI (installed via script)  
* **Cloud Native/K8s:** kubectl, helm, Podman CLI Client (via brew feature)  
* **DevOps/Build:** Vault CLI, Bazel, Pre-commit, GitHub CLI, mise (Env Manager), ArgoCD CLI, Tilt  
* **Utilities:** socat, jless (via cargo), Modern Shell Utils (eza, bat, etc.)  
* **Configuration:** VS Code defaults (settings & extensions), Podman socket mount, VS Code SSH Agent Forwarding integration.

## **Workflow**

The primary workflow involves:

1. Using the **Dev Containers CLI** (devcontainer up) from your WSL2 terminal for initial setup and subsequent container starts/updates.  
2. Connecting **VS Code** (running on Windows) to the *already running* container using the Dev Containers: Attach to Running Container... command.

See [GETTING\_STARTED.md](http://docs.google.com/GETTING_STARTED.md) for detailed setup instructions and [WORKFLOW.md](http://docs.google.com/WORKFLOW.md) for contribution guidelines.

## **Configuration Explained**

* **.devcontainer/devcontainer.json:** Defines the environment using a base image and Dev Container Features. It mounts the Podman socket from the host and relies on VS Code's built-in SSH agent forwarding. Configures VS Code settings/extensions.  
* **.devcontainer/post-create.sh:** Runs once after container creation. Installs tools not available as features (expect, jq, htop, spacetime CLI, jless), configures Zsh, sets Git defaults, and installs Python requirements.  
* **.devcontainer/install\_spacetime.exp:** An expect script used by post-create.sh to automate the SpacetimeDB CLI installation prompt.

## **Project-Specific Integration (Removed from this Template)**

This template provides the core development environment. For a full application deployment similar to the original project this was derived from, you would typically need to add/integrate:

* **Kubernetes Cluster:** Setup and configuration for Minikube (or another K8s distribution).  
* **Deployment Tooling:** Makefile targets or scripts (make init, make deploy-dev, etc.) for bootstrapping secrets, deploying applications (like Keycloak, Postgres, your SpacetimeDB module, web apps) via Helm/ArgoCD/Tilt.  
* **Secrets Management:** Integration with HashiCorp Vault beyond just the CLI (e.g., setting up Vault server, policies, potentially External Secrets Operator).  
* **Application Code:** Your actual SpacetimeDB module code, web backend, frontend, etc.  
* **CI/CD Pipelines:** GitHub Actions or similar for building, testing, and deploying the application stack and potentially pre-building this dev container image.  
* **Specific Documentation:** READMEs and guides related to the application architecture, deployment process, and specific services used.  
* **Diagrams:** Architectural diagrams showing service interactions, authentication flows, etc. (See original project's Diagrams.md).

## **Troubleshooting**

Refer to the Troubleshooting section in [GETTING\_STARTED.md](http://docs.google.com/GETTING_STARTED.md).

## **License**

This Dev Container configuration is licensed under the GNU General Public License v3.0. See the LICENSE file.