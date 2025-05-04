#!/bin/bash
# .devcontainer/post-create.sh
#
# Runs once after the container is created and features are installed.
# Configures Git identity, Zsh, installs jless, etc.
# Assumes Eza and TypeScript are installed by features.

# Exit immediately if a command fails (safer default)
set -e
# Optional: Print each command before executing (useful for debugging)
# set -x

echo "--- [post-create.sh] Starting setup (v13 - Refined Features) ---"

# --- Configuration ---
TARGET_USER="vscode"
TARGET_GROUP="vscode"
USER_HOME="/home/${TARGET_USER}"
ZSH_CUSTOM="${USER_HOME}/.oh-my-zsh/custom"
WORKSPACE_FOLDER="${containerWorkspaceFolder:-/workspaces/spacetime-zet-dev-template}"

# --- Source Cargo Environment ---
# Ensure cargo command is available for this script's execution.
CARGO_ENV_PATH="/usr/local/cargo/env" # Default path when installed as root by feature
ALT_CARGO_ENV_PATH="${USER_HOME}/.cargo/env" # Path if installed as user
echo "[post-create.sh] Attempting to source Cargo environment..."
if [ -f "${CARGO_ENV_PATH}" ]; then
    . "${CARGO_ENV_PATH}"
    echo "[post-create.sh] Sourced ${CARGO_ENV_PATH}."
elif [ -f "${ALT_CARGO_ENV_PATH}" ]; then
    . "${ALT_CARGO_ENV_PATH}"
    echo "[post-create.sh] Sourced ${ALT_CARGO_ENV_PATH}."
else
    echo "[post-create.sh] Warning: Cargo env file not found. Subsequent cargo commands might fail."
fi
command -v cargo >/dev/null 2>&1 || echo "Warning: 'cargo' still not found in PATH after attempting to source env."

# --- Install Expect ---
echo "[post-create.sh] Installing expect tool..."
if ! command -v expect >/dev/null 2>&1; then
    sudo apt-get update && sudo apt-get install -y expect || echo "Warning: Failed to install expect."
    command -v expect >/dev/null 2>&1 || { echo "Error: expect command not found after install attempt. Exiting."; exit 1; }
    echo "[post-create.sh] expect installed."
else
    echo "[post-create.sh] expect already installed."
fi

# --- Install jq and htop---
echo "[post-create.sh] Installing jq and htop..."
if ! command -v jq >/dev/null 2>&1; then
    sudo apt-get update && sudo apt-get install -y jq htop || echo "Warning: Failed to install jq and htop."
    command -v jq >/dev/null 2>&1 || { echo "Error: jq command not found after install attempt. Exiting."; exit 1; }
    echo "[post-create.sh] jq and htop installed."
else
    echo "[post-create.sh] jq and htop already installed."
fi

# --- Tool Verification ---
# Verify tools expected to be installed by features.
echo "[post-create.sh] Verifying tool installations..."
command -v git >/dev/null 2>&1 || echo "Warning: 'git' not found."
command -v zsh >/dev/null 2>&1 || echo "Warning: 'zsh' not found."
command -v cargo >/dev/null 2>&1 || echo "Warning: 'cargo' (Rust) not found."
command -v python3 >/dev/null 2>&1 || echo "Warning: 'python3' not found."
command -v pip3 >/dev/null 2>&1 || echo "Warning: 'pip3' not found."
command -v node >/dev/null 2>&1 || echo "Warning: 'node' not found."
command -v npm >/dev/null 2>&1 || echo "Warning: 'npm' not found."
command -v tsc >/dev/null 2>&1 || echo "Warning: 'tsc' (TypeScript) not found - Feature might have failed."
command -v kubectl >/dev/null 2>&1 || echo "Warning: 'kubectl' not found."
command -v helm >/dev/null 2>&1 || echo "Warning: 'helm' not found."
command -v gh >/dev/null 2>&1 || echo "Warning: 'gh' (GitHub CLI) not found."
if command -v /opt/homebrew/bin/podman >/dev/null 2>&1 || command -v podman >/dev/null 2>&1; then echo "'podman' CLI found."; else echo "Warning: 'podman' CLI not found."; fi
command -v socat >/dev/null 2>&1 || echo "Warning: 'socat' not found."
command -v bat >/dev/null 2>&1 || echo "Info: 'bat' not found (modern-shell-utils might not provide it)."
command -v eza >/dev/null 2>&1 || echo "Warning: 'eza' not found - modern-shell-utils feature might have failed."
echo "[post-create.sh] Tool verification complete."

# --- Install Additional Global Tools ---
# Install jless via cargo (requires Rust feature and xcb deps from onCreateCommand)
echo "[post-create.sh] Installing 'jless' via cargo..."
if ! command -v jless >/dev/null 2>&1; then
    if command -v cargo >/dev/null 2>&1; then
        echo "[post-create.sh] Running 'cargo install jless' as user ${TARGET_USER}..."
        # Run directly as vscode user. Use || true to make it non-fatal.
        cargo install jless || echo "Warning: 'cargo install jless' failed. Check if xcb dependencies were installed. Jless may not be available."
        export PATH="${USER_HOME}/.cargo/bin:${PATH}" # Update PATH for potential immediate use
    else
        echo "[post-create.sh] Warning: 'cargo' not found, cannot install 'jless'."
    fi
else
    echo "[post-create.sh] 'jless' is already installed."
fi
command -v jless >/dev/null 2>&1 || echo "Warning: 'jless' still not found after install attempts."

# --- Install SpacetimeDB CLI ---
# (As there's no standard feature yet)
echo "[post-create.sh] Installing SpacetimeDB CLI using expect..."
if ! command -v spacetime >/dev/null 2>&1; then
    # 1. Download the installer script (Optional if expect script curls directly)
    # echo "[post-create.sh] Downloading SpacetimeDB installer..."
    # curl -sSf https://install.spacetimedb.com -o "${INSTALLER_SCRIPT_PATH}" || { echo "Error: Failed to download SpacetimeDB installer."; exit 1; }
    # chmod +x "${INSTALLER_SCRIPT_PATH}" || { echo "Error: Failed to make installer executable."; exit 1; }
    # echo "[post-create.sh] Installer downloaded to ${INSTALLER_SCRIPT_PATH}"

    # 2. Execute the expect script to handle the interactive prompt
    expect .devcontainer/install_spacetime.exp || echo "Warning: SpacetimeDB CLI installation via expect failed."

    # 3. Clean up the downloaded script (Optional if expect script curls directly)
    # rm -f "${INSTALLER_SCRIPT_PATH}" || echo "Warning: Failed to remove temporary installer script ${INSTALLER_SCRIPT_PATH}."
    # echo "[post-create.sh] Cleaned up installer script."
else
    echo "[post-create.sh] SpacetimeDB CLI already installed."
fi
command -v spacetime >/dev/null 2>&1 || echo "Warning: 'spacetime' still not found after install attempt."

# --- Git Configuration ---
# Configure Git settings for the TARGET_USER (vscode)
echo "[post-create.sh] Configuring git..."
if [ -d "${WORKSPACE_FOLDER}" ]; then
    # 1. Configure safe.directory (essential for mounted workspaces)
    echo "[post-create.sh] Setting safe.directory for ${WORKSPACE_FOLDER}";
    git config --global --add safe.directory "${WORKSPACE_FOLDER}" || echo "Warning: Failed to set git safe.directory as current user.";

    # 2. Configure Git User Identity (Name and Email)
    echo "[post-create.sh] Configuring Git user name and email..."
    # Read values passed into the container environment via 'containerEnv'
    # These are expected to be set from the host's ${localEnv:GIT_...} in devcontainer.json
    CONTAINER_USER_NAME="${GIT_AUTHOR_NAME:-}" # Use :- to default to empty string if unset
    CONTAINER_USER_EMAIL="${GIT_AUTHOR_EMAIL:-}"

    # Get current git config values inside the container
    CURRENT_USER_NAME=$(git config --global --get user.name || echo "")
    CURRENT_USER_EMAIL=$(git config --global --get user.email || echo "")

    # Set user.name if not already set OR if the container env var has a value
    if [ -z "${CURRENT_USER_NAME}" ] || [ -n "${CONTAINER_USER_NAME}" ]; then
        if [ -n "${CONTAINER_USER_NAME}" ]; then
            echo "[post-create.sh] Setting git user.name from container env var GIT_AUTHOR_NAME."
            git config --global user.name "${CONTAINER_USER_NAME}" || echo "Warning: Failed to set git user.name from env var."
        elif [ -z "${CURRENT_USER_NAME}" ]; then
             # Only warn if the variable wasn't passed AND it wasn't already set
             echo "[post-create.sh] WARNING: Git user.name not set and GIT_AUTHOR_NAME env var not passed from host."
             echo "[post-create.sh] Please configure it manually in the container:"
             echo "[post-create.sh]   git config --global user.name \"Your Name\""
             echo "[post-create.sh] (Or set GIT_AUTHOR_NAME env var on your host machine before building)."
        fi
    else
         echo "[post-create.sh] Git user.name already configured as '${CURRENT_USER_NAME}'."
    fi

    # Set user.email if not already set OR if the container env var has a value
    if [ -z "${CURRENT_USER_EMAIL}" ] || [ -n "${CONTAINER_USER_EMAIL}" ]; then
         if [ -n "${CONTAINER_USER_EMAIL}" ]; then
            echo "[post-create.sh] Setting git user.email from container env var GIT_AUTHOR_EMAIL."
            git config --global user.email "${CONTAINER_USER_EMAIL}" || echo "Warning: Failed to set git user.email from env var."
        elif [ -z "${CURRENT_USER_EMAIL}" ]; then
             # Only warn if the variable wasn't passed AND it wasn't already set
             echo "[post-create.sh] WARNING: Git user.email not set and GIT_AUTHOR_EMAIL env var not passed from host."
             echo "[post-create.sh] Please configure it manually in the container:"
             echo "[post-create.sh]   git config --global user.email \"you@example.com\""
             echo "[post-create.sh] (Or set GIT_AUTHOR_EMAIL env var on your host machine before building)."
        fi
    else
        echo "[post-create.sh] Git user.email already configured as '${CURRENT_USER_EMAIL}'."
    fi

    # 3. Configure commit template
    GIT_TEMPLATE_PATH="${WORKSPACE_FOLDER}/.devcontainer/.gitmessage"; GIT_TEMPLATE_TARGET_PATH="${USER_HOME}/.gitmessage";
    echo "[post-create.sh] Configuring git commit template...";
    if [ -f "${GIT_TEMPLATE_PATH}" ]; then cp "${GIT_TEMPLATE_PATH}" "${GIT_TEMPLATE_TARGET_PATH}" || echo "Warning: Failed to copy commit template."; git config --global commit.template "${GIT_TEMPLATE_TARGET_PATH}" || echo "Warning: Failed to set commit template config."; echo "[post-create.sh] Set commit template.";
    else echo "[post-create.sh] Warning: Commit template ${GIT_TEMPLATE_PATH} not found. Skipping config."; fi;

    # 4. Add useful Git aliases
    echo "[post-create.sh] Adding Git aliases..."; add_git_alias() { local alias_name="$1"; local alias_command="$2"; git config --global "alias.${alias_name}" "${alias_command}" || echo "Warning: Failed to set git alias '${alias_name}'."; };
    add_git_alias "fblame" "blame -w -C -C -C"; add_git_alias "st" "status"; add_git_alias "co" "checkout"; add_git_alias "cb" "checkout -b"; add_git_alias "br" "branch"; add_git_alias "logp" "log --pretty=format:'%C(yellow)%h %Cred%ad %Cblue%an %Cgreen%s' --date=short"; add_git_alias "l" "log --oneline --decorate --graph"; add_git_alias "pullr" "pull --rebase"; add_git_alias "pushf" "push --force-with-lease"; echo "[post-create.sh] Git aliases added.";
else echo "[post-create.sh] Warning: Workspace folder ${WORKSPACE_FOLDER} not found. Skipping git config."; fi

# --- Shell Profile Configuration (Zsh Focus) ---
# (No changes needed here, runs as vscode user, uses sudo only for initial dir/file creation/chown)
echo "[post-create.sh] Configuring Zsh environment..."
if [ ! -d "${ZSH_CUSTOM}/plugins" ] || [ ! -O "${ZSH_CUSTOM}/plugins" ]; then sudo mkdir -p "${ZSH_CUSTOM}/plugins" || echo "Warning: Failed to create Zsh custom plugins directory."; sudo chown -R "${TARGET_USER}:${TARGET_GROUP}" "${USER_HOME}/.oh-my-zsh" || echo "Warning: Failed to chown .oh-my-zsh"; fi;
ZSH_SYNTAX_HIGHLIGHTING_DIR="${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"; ZSH_AUTOSUGGESTIONS_DIR="${ZSH_CUSTOM}/plugins/zsh-autosuggestions";
clone_zsh_plugin() { local repo_url="$1"; local target_dir="$2"; if [ ! -d "${target_dir}" ]; then echo "[post-create.sh] Cloning Zsh plugin $(basename ${target_dir})..."; git clone --depth 1 "${repo_url}" "${target_dir}" || echo "Warning: Failed to clone Zsh plugin $(basename ${target_dir})."; else echo "[post-create.sh] Zsh plugin $(basename ${target_dir}) already exists."; fi; };
clone_zsh_plugin "https://github.com/zsh-users/zsh-syntax-highlighting.git" "${ZSH_SYNTAX_HIGHLIGHTING_DIR}"; clone_zsh_plugin "https://github.com/zsh-users/zsh-autosuggestions.git" "${ZSH_AUTOSUGGESTIONS_DIR}";
ZSHRC_PATH="${USER_HOME}/.zshrc";
if [ -f "${ZSHRC_PATH}" ]; then
    echo "[post-create.sh] Modifying ${ZSHRC_PATH}..."; sed -i '/^ZSH_THEME=/c\ZSH_THEME="agnoster"' "${ZSHRC_PATH}" || echo "Warning: Failed to set Zsh theme in ${ZSHRC_PATH}.";
    if ! grep -q "plugins=(git zsh-syntax-highlighting zsh-autosuggestions)" "${ZSHRC_PATH}"; then echo "[post-create.sh] Enabling zsh-syntax-highlighting and zsh-autosuggestions plugins..."; sed -i '/^plugins=/c\plugins=(git zsh-syntax-highlighting zsh-autosuggestions)' "${ZSHRC_PATH}" || echo "Warning: Failed to set Zsh plugins in ${ZSHRC_PATH}."; fi;
    HISTORY_DIR="/home/vscode/commandhistory"; HISTORY_FILE="${HISTORY_DIR}/.zsh_history"; echo "[post-create.sh] Configuring Zsh history file to ${HISTORY_FILE}";
    if [ ! -d "${HISTORY_DIR}" ]; then sudo mkdir -p "${HISTORY_DIR}" || echo "Warning: Failed to create history directory ${HISTORY_DIR}."; sudo chown "${TARGET_USER}:${TARGET_GROUP}" "${HISTORY_DIR}" || echo "Warning: Failed to chown history directory ${HISTORY_DIR}."; fi;
    if [ ! -f "${HISTORY_FILE}" ]; then sudo touch "${HISTORY_FILE}" || echo "Warning: Failed to touch history file ${HISTORY_FILE}."; sudo chown "${TARGET_USER}:${TARGET_GROUP}" "${HISTORY_FILE}" || echo "Warning: Failed to chown history file ${HISTORY_FILE}."; fi;
    sudo chown -R "${TARGET_USER}:${TARGET_GROUP}" "${HISTORY_DIR}" || echo "Warning: Failed to ensure ownership on history directory ${HISTORY_DIR}.";
    if ! grep -q "HISTFILE=${HISTORY_FILE}" "${ZSHRC_PATH}"; then echo "[post-create.sh] Adding Zsh history settings..."; printf "\n# Persistent History Config (Dev Container)\n" >> "${ZSHRC_PATH}"; printf "HISTFILE=%s\n" "${HISTORY_FILE}" >> "${ZSHRC_PATH}"; printf "HISTSIZE=10000\nSAVEHIST=10000\nsetopt APPEND_HISTORY\nsetopt SHARE_HISTORY\nsetopt INC_APPEND_HISTORY\n" >> "${ZSHRC_PATH}"; fi;
    # Add eza aliases only if eza was successfully installed (by feature)
    if command -v eza >/dev/null 2>&1; then echo "[post-create.sh] Adding eza aliases to ${ZSHRC_PATH}..."; if ! grep -q "# Eza Aliases" "${ZSHRC_PATH}"; then printf "\n# Eza Aliases (Modern ls)\n" >> "${ZSHRC_PATH}"; printf "alias ls='eza --color=auto --icons'\n" >> "${ZSHRC_PATH}"; printf "alias l='eza --color=auto --icons'\n" >> "${ZSHRC_PATH}"; printf "alias ll='eza -l --color=auto --icons'\n" >> "${ZSHRC_PATH}"; printf "alias la='eza -a --color=auto --icons'\n" >> "${ZSHRC_PATH}"; printf "alias lla='eza -la --color=auto --icons'\n" >> "${ZSHRC_PATH}"; fi; else echo "[post-create.sh] 'eza' not found, skipping eza aliases."; fi;
else echo "[post-create.sh] Warning: ${ZSHRC_PATH} not found. Cannot configure Zsh."; fi

# --- Install Python Dependencies ---
# (No changes needed here, runs as vscode user)
PYTHON_REQS_PATH="${WORKSPACE_FOLDER}/requirements.txt"
echo "[post-create.sh] Checking for Python requirements at ${PYTHON_REQS_PATH}..."
if [ -f "${PYTHON_REQS_PATH}" ]; then if command -v pip3 &> /dev/null; then echo "[post-create.sh] Found ${PYTHON_REQS_PATH}, installing dependencies for user ${TARGET_USER}..."; pip3 install --user --no-cache-dir -r "${PYTHON_REQS_PATH}" || echo "Warning: pip3 install failed."; else echo "[post-create.sh] Warning: pip3 command not found. Cannot install Python dependencies."; fi; else echo "[post-create.sh] No requirements file found at ${PYTHON_REQS_PATH}. Skipping pip install."; fi

# --- Finalization ---
echo "--- [post-create.sh] Setup finished successfully ---"

# Explicitly exit with 0, even if some non-critical warnings occurred
exit 0
