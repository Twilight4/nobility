# Nobility

Nobility is an organized colletion of shell functions designed to streamline your terminal interactions, liberating you from the hassle of juggling notes, endless copying and pasting, and tedious command editing. This tool is tailored for Arch-based Linux systems, with a focus on enhancing red-teaming and network-pentesting endeavors. Nobility doesn't cover all tools, it's my own curated collection which I am still adding to and updating in order to automate my workflow. I focus on tools I use and that are maintained and current. Nobility helps you remember how to use every tool in your arsenal and doesn't hide them behind scripting that can be cumbersome to maintain or update. Instead you can use nobility to build a composable, on-the-fly workflow for every situation. 

# Key Features
* **Prefilled Commands**: Streamlines terminal interactions by automatically prefilling commands
* **Organized Commands**: Well-organized commands with tab auto-completion
* **Seamless Integration**: ZSH/Oh-My-ZSH shell plugin ensures easy integration into your environment
* **Customizable** Settings: Tailor Nobility to your preferences with customizable settings and global variables
* **Recon Phase**: Access OSINT commands for efficient information gathering
* **Enumeration** Phase: Effortlessly enumerate common services, saving time in penetration testing
* **Exploit Phase**: Assistance in compiling exploits for simplified vulnerability exploitation
* **Reverse Shell** Handlers: Manage reverse shell handlers easily, enhancing network-pentesting capabilities
* **Content Serving** Commands: Serve content effortlessly, making file sharing and testing straightforward
* **Built-in Logbook**: Keep on-the-fly notes and save commands with Quiver's built-in logbook feature
* **Org Mode Rendering**: Render Org mode notes directly to the command line for a streamlined reading experience
* **Arch Linux System** Management: Optimized for Arch Linux systems, simplifying system management tasks
* **Update Notifications**: Stay informed with update notifications for the latest features and improvements
* **Dependency Installers**: Includes installers for dependencies, ensuring a smooth and hassle-free setup process

# Installation
Nobility requires the following:

* [Zsh](https://github.com/zsh-users/zsh)
* [Oh-my-zsh](https://ohmyz.sh/)
* [Arch Linux](https://archlinux.org/)


```bash
# Clone the repo to your oh-my-zsh custom plugins folder
git clone https://github.com/Twilight4/nobility.git ~/.oh-my-zsh/custom/plugins/nobility

# Edit `~/.zshrc` to load the plugin
plugins=(git nobility)

# Source `.zshrc` to load the plugin and you're done. On first load, nobility will install a few core packages
source ~/.zshrc

```

# Getting Started
nobility organizes commands into namespaces starting with `nb-`, such as `nb-enum-web` or `nb-recon-domains`.
To see an overview of all namespaces simply use `nb-help`. Each namespace also has it's own help command, such as `nb-enum-web-help` that provides a listing of available commands. All commands support tab completion and search. 

## Installing Dependencies
Every namespace was a `nb-namespace-install` command that will install all of the tools relevant to that namespace. You can install just the tools you need, or use `nb-install-all` to run the installers of all namespaces.

## Workflow
nobility is meant to provide a composable, on-the-fly workflow. It replaces the common painful raw workflow of reading your notes, finding a command, copy, paste, replace the values with target values, copy, paste, run. Some rely heavily on completely automated scripts or frameworks that run all the commands for a workflow and output well-formatted data. While these scripts are great for many use cases, they can often be brittle, hide the underlying tools and techniques and be cumbersome to modify. Instead, nobility gives you a happy medium, you can run commands quickly and easy with well-organized output, composing your workflow as you go depending on the targets and context. 

## Example Workflow
### Preparation
```bash

# If you have markdown notes, configure the path 
nb-vars-global-set-notes

# Set some session variables for the bounty target 
nb-vars-set-project 
nb-vars-set-domain 

# Generate scope files from the bounty url
nb-project-rescope

# Save vars for other terminal sessions, nb-vars-load
nb-vars-save

```

### Passive Recon
```bash

# Search for target files
nb-recon-org-files

# Search downloaded files for URLs
nb-recon-org-files-urls

# Mine github repos for secrets
nb-recon-github-gitrob

# Check DNS records
nb-enum-dns-dnsrecon

# Look for ASNs and networks
nb-recon-networks-amass-asns
nb-recon-networks-bgpview-ipv4

# Get subdomains
nb-recon-subs-subfinder

# Resolve and parse subdomains
nb-recon-subs-resolve-massdns
nb-recon-subs-resolve-parse

```

### Active Web Enumeration
```bash

# Download out robots.txt
nb-enum-web-dirs-robots

# ID a WAF if present
nb-enum-web-waf

# Parse SSL certs
nb-enum-web-ssl-certs

# Spider the site
nb-enum-web-gospider

# Brute force URIs
nb-enum-web-dirs-ffuf

# Read your notes
nb-notes

```
