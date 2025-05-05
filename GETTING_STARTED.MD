# **Getting Started: SpacetimeDB Dev Container**

This guide walks you through setting up the standalone SpacetimeDB Dev Container environment.

**Goal:** Launch the containerized environment so you can start developing.

**Prerequisites:**

1. **WSL2:** Install [Windows Subsystem for Linux 2](https://learn.microsoft.com/en-us/windows/wsl/install).  
   * **Distribution:** **Ubuntu 24.04 LTS** is strongly recommended.  
2. **Podman on WSL:** Install Podman **within your WSL2 distribution**.  
   * **Installation:** sudo apt update && sudo apt install podman.  
   * **User Socket:** Ensure the user socket service is running: systemctl \--user enable \--now podman.socket & verify (systemctl \--user status podman.socket).  
3. **Node.js & npm on WSL:** The Dev Containers CLI tool requires Node.js.  
   * **Installation (Recommended: nvm):** Follow instructions for [nvm (Node Version Manager)](https://github.com/nvm-sh/nvm) to install it, then install the current LTS: nvm install \--lts && nvm use \--lts.  
4. **Dev Containers CLI on WSL:** Install the CLI globally via npm.  
   * **Installation:** npm install \-g @devcontainers/cli. Verify with devcontainer \--version.  
5. **Git:** Install Git within WSL2 (sudo apt update && sudo apt install git).  
6. **SSH Agent on WSL (Crucial for Git over SSH):**  
   * **Requirement:** A running SSH agent with your GitHub key added is needed on your WSL host *before* starting the container. VS Code will forward this agent.  
   * **Action:** Before starting the container, ensure your agent is running and the key is added in your WSL terminal:  
     eval $(ssh-agent \-s)      \# Start agent if needed  
     ssh-add \~/.ssh/id\_rsa   \# Add your key (adjust path if necessary)  
     ssh-add \-l              \# Verify key is listed

7. **VS Code:** Install [Visual Studio Code](https://code.visualstudio.com/) on **Windows**.  
8. **VS Code Dev Containers Extension:** Install from the Marketplace (ms-vscode-remote.remote-containers).  
9. **(Optional) Powerline/Nerd Font:** Install on Windows host for best terminal theme rendering. Configure terminal.integrated.fontFamily in VS Code settings.

**Setup Steps:**

1. **Clone this Repository:**  
   * Open your WSL2 terminal.  
   * Navigate to your development directory (e.g., cd \~/dev).  
   * Clone this template repository:  
     git clone \<this-repo-url\>  
     cd \<this-repo-directory\> \# e.g., cd stdb-rust-dc

2. **Ensure Host SSH Agent is Running:**  
   * In the *same WSL2 terminal* you will use for the next step, verify the agent:  
     eval $(ssh-agent \-s)   \# Start if needed  
     ssh-add \~/.ssh/id\_rsa \# Add key if needed  
     ssh-add \-l           \# Verify key is listed

3. **Build & Start the Dev Container (CLI):**  
   * From the project root directory in your WSL2 terminal:  
     \# Use \--remove-existing-container for the first build or after config changes  
     devcontainer up \--workspace-folder . \--remove-existing-container

   * This builds the image (first time) and starts the container. Monitor the output for success ({"outcome":"success", ...}). This can take several minutes initially.  
4. **Connect VS Code:**  
   * Open VS Code on Windows.  
   * Use the Command Palette (Ctrl+Shift+P or Cmd+Shift+P) and run **Dev Containers: Attach to Running Container...**.  
   * Select the container named similarly to vsc-stdb-rust-dc-... (the name might vary based on your folder).  
   * VS Code will connect. The status bar (bottom-left) will turn green.  
5. **Verify Environment Inside Container:**  
   * Open a terminal within VS Code (Terminal \> New Terminal).  
   * Verify user: whoami (should be vscode).  
   * Test file permissions: mkdir testdir && rm \-r testdir (should succeed).  
   * **Test Git SSH access:** ssh \-T git@github.com (should authenticate successfully via VS Code forwarding).  
   * **Check SSH Agent Variable:** echo $SSH\_AUTH\_SOCK (should show a path like /tmp/vscode-ssh-auth-...).  
   * **Verify Agent Connection:** ssh-add \-l (should list your key).  
   * Verify key tools are present (check versions): cargo, python3, kubectl, helm, gh, podman, vault, spacetime, jless, bazel, tilt, argocd, pre-commit, mise, expect, jq, htop.  
6. **First-Time Git Config (If Needed):**  
   * If prompted by post-create.sh warnings (because host env vars GIT\_AUTHOR\_NAME/EMAIL weren't set), configure Git manually *inside the container terminal*:  
     git config \--global user.name "Your Name"  
     git config \--global user.email "you@example.com"

**You're Ready\!**

You now have the development environment running inside the Dev Container. You can modify code within the workspace and use the installed tools via the integrated terminal.

**Troubleshooting:**

* **devcontainer up Fails:** Check terminal output for errors (feature install, script errors). Ensure Podman socket is running on host. Check network connectivity.  
* **Cannot Attach VS Code:** Ensure the container is running (podman ps on host). Check the devcontainer up logs for errors during startup.  
* **SSH Fails Inside Container (Permission denied (publickey)):**  
  * **Verify Host Agent:** Ensure the SSH agent is running on the WSL host and your key is added (ssh-add \-l) *before* you start/attach to the container.  
  * **Verify VS Code Setting:** Check VS Code settings (Ctrl+,) and search for Remote.SSH.ForwardAgent. Ensure it is **enabled** (checked \- this is the default).  
  * **Check Container Socket:** Inside the container terminal, run echo $SSH\_AUTH\_SOCK. It should show a path like /tmp/vscode-ssh-auth-.... Run ls \-l $SSH\_AUTH\_SOCK to check its existence and permissions. Run ssh-add \-l inside the container \- it should list your keys.  
* **Container Restarts:** Container restarts should work correctly without SSH issues, provided the host agent is running before you start/attach.  
* **Zsh Theme Looks Wrong:** Install a Powerline/Nerd Font on the host and configure VS Code's terminal.integrated.fontFamily.