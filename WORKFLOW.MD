## **Development Workflow using this Dev Container**

This document outlines the general workflow for using this pre-configured Dev Container environment.

**Philosophy:**

* **Consistency:** Provide a stable, identical environment for all users.  
* **Automation:** Automate tool setup and basic configuration.  
* **Standard Tools:** Include common tools for Rust, Python, Node.js, SpacetimeDB, and Cloud Native development.  
* **Visualize:** Encourage the use of diagrams (like Mermaid) for documenting project-specific architecture built *on top* of this environment.

**Development Environment:**

* We use **Dev Containers** run via the devcontainer CLI on WSL2+Podman.  
* Please follow the setup instructions in **GETTING\_STARTED.md** carefully, especially the **host SSH Agent prerequisites**.  
* All development work (coding, running commands like git, cargo, spacetime, python, npm, kubectl, etc.) should happen **inside the attached Dev Container** via the VS Code terminal.

**Git Workflow: Feature Branches & Pull Requests**

A standard feature branch workflow is recommended. *All Git commands should be run inside the Dev Container terminal.* VS Code's SSH agent forwarding handles authentication to services like GitHub.

1. **Get the Latest:** Before starting work, ensure your main branch (e.g., main or dev) is up-to-date:  
   \# Inside Dev Container Terminal  
   git checkout main \# or your primary branch  
   git pull origin main

2. **Create a Feature Branch:** Create a new branch for your task, named descriptively (e.g., feature/add-new-tool, docs/update-readme, fix/script-bug).  
   \# Inside Dev Container Terminal  
   git checkout \-b feature/your-task-name

3. **Work & Commit:** Make your changes using VS Code (which is attached to the container). Commit frequently from the **Dev Container terminal** with clear messages.  
   \# Inside Dev Container Terminal  
   git add .  
   git commit \-m "feat: Add installation for tool XYZ in post-create"

4. **Push Your Branch:**  
   \# Inside Dev Container Terminal  
   git push origin feature/your-task-name

5. **Create a Pull Request (PR):** Use the GitHub (or other provider) website. Target the appropriate base branch. Assign reviewers if applicable.  
6. **Review & Merge:** Address feedback. Merge once approved.  
7. **Clean Up:** After merging:  
   \# Inside Dev Container Terminal  
   git checkout main \# or your primary branch  
   git pull origin main  
   git branch \-d feature/your-task-name

**Using LLMs:**

AI assistants can be helpful\! Provide context (e.g., "inside the dev container based on this template") for best results when asking for:

* Code Explanations  
* Debugging Assistance  
* Code Generation (review carefully\!)  
* Documentation Help  
* Diagram Generation (e.g., Mermaid for your project's specifics)