# **Spacetime Rust Dev Template \- Dev Container**

This directory contains the configuration for the project's development container, providing a consistent and reproducible environment for all contributors.

## **Development Environment Setup**

This project utilizes **Dev Containers** ([spec](https://containers.dev/)) built using Podman within WSL2. Dev Container Features are leveraged to package necessary tools and configurations.

**Workflow:** The primary workflow is:

1. Using the **Dev Containers CLI** (devcontainer up) from your WSL2 terminal for initial setup and subsequent container starts/updates.  
2. Connecting **VS Code** (running on Windows) to the *already running* container using the Dev Containers: Attach to Running Container... command.

This approach ensures stability for permissions and SSH agent forwarding with Podman on WSL2.

### **Included Features & Tools**

The dev container comes pre-configured with the following tools:

\# Base & Shell  
\- Ubuntu 24.04  
\- Zsh \+ Oh My Zsh \+ Plugins (Syntax Highlighting, Autosuggestions)  
\- Git  
\- Common Utils (curl, sudo, etc.)

\# Languages & Runtimes  
\- Rust (latest)  
\- Python (3.11) \+ pip  
\- Node.js (LTS) \+ npm  
\- TypeScript

\# SpacetimeDB  
\- spacetime CLI (installed via post-create script using expect)

\# Cloud Native / K8s  
\- kubectl  
\- helm  
\- Podman CLI Client (via brew feature)  
\- ArgoCD CLI  
\- Tilt

\# DevOps & Build Tools  
\- Vault CLI  
\- Bazel  
\- Pre-commit  
\- GitHub CLI  
\- mise (Environment Manager)

\# Utilities  
\- socat (for SSH agent forwarding robustness)  
\- jq & htop (general utilities)  
\- expect (for automating spacetime install)  
\- jless (JSON viewer, installed via cargo)  
\- Modern Shell Utils (eza, bat, fd, ripgrep)

### **Prerequisites**

Ensure the following are installed and configured **before** running the setup:

1. **WSL2:** Install [Windows Subsystem for Linux 2](https://learn.microsoft.com/en-us/windows/wsl/install).  
   * **Distribution:** **Ubuntu 24.04 LTS** is strongly recommended.  
2. **Podman on WSL:** Install Podman **within your WSL2 distribution**.  
   * **Installation:** sudo apt update && sudo apt install podman.  
   * **User Socket:** Ensure the user socket service is running: systemctl \--user enable \--now podman.socket & verify (systemctl \--user status podman.socket).  
3. **Node.js & npm on WSL:** The Dev Containers CLI tool requires Node.js.  
   * **Installation (Recommended: nvm):** Follow instructions for [nvm (Node Version Manager)](https://github.com/nvm-sh/nvm) to install it, then install the current LTS: nvm install \--lts && nvm use \--lts.  
4. **Dev Containers CLI on WSL:** Install the CLI globally via npm.  
   * **Installation:** npm install \-g @devcontainers/cli. Verify with devcontainer \--version.  
5. **Minikube on WSL (Optional but Recommended):** For running the local K8s cluster.  
   * Install [Minikube](https://minikube.sigs.k8s.io/docs/start/) **within WSL2**.  
   * Start with Podman: minikube start \--driver=podman \--container-runtime=cri-o.  
6. **VS Code:** Install [Visual Studio Code](https://code.visualstudio.com/) on **Windows**.  
7. **VS Code Dev Containers Extension:** Install from the Marketplace (ms-vscode-remote.remote-containers).  
8. **Git:** Install Git within WSL2 (sudo apt update && sudo apt install git). 
   * *(Note: Ensure your GitHub SSH key is set up in WSL2. If you use a different SSH key, ensure it's added to your SSH agent.)*
   * **SSH Key:** If you don't have an SSH key, generate one using ssh-keygen -t rsa -b 4096 -C
   * **Add SSH Key to GitHub:** Follow [GitHub's guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account) to add your SSH key to your GitHub account.
9. **SSH Agent on WSL (Crucial):**  
   * **Requirement:** A running SSH agent with your GitHub key added is needed *in the terminal session where you run devcontainer up*. The container explicitly mounts the agent's socket path defined by the $SSH\_AUTH\_SOCK environment variable.  
   * **Action:** *Before each devcontainer up command*, ensure your agent is running and the key is added in that specific terminal:  
     eval $(ssh-agent \-s)      \# Start agent if needed  
     ssh-add \~/.ssh/id\_rsa   \# Add your key (adjust path if necessary)  
     ssh-add \-l              \# Verify key is listed  
     echo $SSH\_AUTH\_SOCK     \# IMPORTANT: Verify this outputs a path (e.g., /tmp/ssh-XYZ/agent.1234)

   * *(Note: The default agent socket path changes on reboot. If you restart WSL/your PC, you'll need to repeat the eval/ssh-add steps before running devcontainer up again. We are investigating more persistent solutions like keychain.)*  
10. **Powerline/Nerd Font (Optional but Recommended):**  
    * Install a Powerline/Nerd Font (e.g., [MesloLGS NF](https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k)) on **Windows host**.  
    * Set VS Code's terminal.integrated.fontFamily setting to the font name (e.g., MesloLGS NF) for correct Zsh theme rendering.

### **Launching the Dev Environment (CLI Workflow)**

1. **Clone the Repository:** (In WSL terminal)  
   git clone \<your-repo-url\>  
   cd \<your-repo-directory\>

2. **Ensure Prerequisites:** Double-check Podman socket and **SSH Agent** (eval/ssh-add/echo $SSH\_AUTH\_SOCK) are running correctly in your *current* WSL terminal.  
3. **Run Initial Setup (Using Dev Containers CLI):**  
   * *(Note: This step might eventually be wrapped by a project setup script, e.g., python scripts/setup.py install)*  
   * Run the devcontainer up command directly from the project root:  
     \# Ensure SSH\_AUTH\_SOCK is set in this terminal\!  
     devcontainer up \--workspace-folder . \--remove-existing-container

   * This command will:  
     * Read .devcontainer/devcontainer.json.  
     * Build the container image (pulling base, installing features) if needed. This can take time initially.  
     * Start the container with configured mounts (including Podman & SSH sockets).  
     * Execute onCreateCommand and postCreateCommand (.devcontainer/post-create.sh).  
   * Monitor the terminal output. A successful run ends with {"outcome":"success", ...}. Redirect output if needed: devcontainer up ... \> \~/devcontainer-build.log 2\>&1.  
4. **Connect VS Code:**  
   * Open VS Code on Windows.  
   * Open the Command Palette (Ctrl+Shift+P).  
   * Run **Dev Containers: Attach to Running Container...**.  
   * Select the container associated with this project (e.g., vsc-stdb-rust-dc-...).  
   * VS Code will connect its UI to the running container. The status bar should turn green.  
5. **First-Time Setup Inside Container:**  
   * **Git Identity:** The post-create.sh script attempts to read GIT\_AUTHOR\_NAME and GIT\_AUTHOR\_EMAIL from your host environment (pass them when running devcontainer up if needed, e.g., GIT\_AUTHOR\_NAME="Your Name" devcontainer up ...). If not set, it will print instructions. Run these commands in the VS Code terminal *inside the container* if prompted:  
     git config \--global user.name "Your Name"  
     git config \--global user.email "you@example.com"

6. **Working:** You are now ready\! Your terminal is Zsh, tools are available, SSH works for Git, and files are shared.

### **Dev Container Configuration Explained**

* **.devcontainer/devcontainer.json:** Defines the environment using a base image and Dev Container Features. It explicitly mounts the Podman and SSH agent sockets from the host (${env:SSH\_AUTH\_SOCK}). It configures VS Code settings and extensions specific to the container.  
* **.devcontainer/post-create.sh:** Runs once after container creation. It installs expect, jq, htop, the spacetime CLI (using the expect script), and jless. It configures Zsh (theme, plugins, persistent history via volume mount), sets Git safe directory/aliases/template, and installs Python requirements from requirements.txt.  
* **.devcontainer/install\_spacetime.exp:** An expect script used by post-create.sh to automate the interactive prompt during the SpacetimeDB CLI installation.

### **Troubleshooting & Known Issues**

* **devcontainer up Fails:**  
  * **Error: host directory cannot be empty (for SSH mount):** The $SSH\_AUTH\_SOCK variable was likely empty on your host when devcontainer up was run. Ensure the SSH agent is running and the variable is set in your terminal (see Prerequisites step 9). Re-run eval $(ssh-agent \-s) and ssh-add ... in that terminal before trying devcontainer up again.  
  * **Errors during post-create.sh:** Check the script output for failures (e.g., apt install failed, expect script failed, cargo install failed). Ensure network connectivity.  
  * Check feature installation logs for errors.  
* **Cannot Attach VS Code:** Ensure the container is running (podman ps). Check the devcontainer up logs for errors during startup.  
* **SSH Fails Inside Container (Permission denied (publickey)):**  
  * Verify SSH Agent was running on host *before* devcontainer up and $SSH\_AUTH\_SOCK was set correctly in that terminal session.  
  * Inside container: Check echo $SSH\_AUTH\_SOCK (should be /ssh-agent). Check ls \-l /ssh-agent. Test ssh \-T git@github.com.  
* **Container Fails to podman start After Host Reboot:**  
  * **Cause:** The explicit SSH agent socket mount (source=${env:SSH\_AUTH\_SOCK}) uses a path that likely became invalid after reboot.  
  * **Workaround:** You need to remove the old container (podman rm \<container\_id\>) and run devcontainer up \--workspace-folder . again (ensure agent is running first\!). It will reuse the image but create a new container with the *current* SSH socket path.  
  * *(Solution: Investigating persistent SSH socket solutions like keychain)*.  
* **Git Identity Prompt:** If GIT\_AUTHOR\_NAME/EMAIL aren't passed from the host, post-create.sh will prompt you to set them manually inside the container.  
* **Zsh Theme Looks Wrong:** Install a Powerline/Nerd Font on the host and configure VS Code's terminal.integrated.fontFamily.

### **License**

This Dev Container configuration is licensed under the GNU General Public License v3.0. See the LICENSE file in the project root.