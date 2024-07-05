# Table of Contents
- [Nobility](#Nobility)
  - [Key Features](#Key-Features)
  - [Distributions Compatibility](#Distributions-Compatibility)
  - [Installation](#Installation)
    - [Installation-Method #1: Manually](#Installation-Method-#1:-Manually)
    - [Installation-Method #2: Oh-my-zsh](#Installation-Method-#2:-Oh-my-zsh)
    - [Tip: Zsh completion menu](#Tip:-Zsh-completion-menu)
    - [Updating](#Updating)
- [Getting Started](#Getting-Started)
  - [Installing Dependencies](#Installing-Dependencies)
  - [Workflow Design](#Workflow-Design)
  - [Example Workflow](#Example-Workflow)
    - [Variables](#Variables)
    - [Pre-Engagement](#Pre-Engagement)
    - [Web Recon](#Web-Recon)
    - [Organization OSINT](#Organization-OSINT)
    - [Active Directory Auditing](#Active-Directory-Auditing)

# Nobility
Nobility is an organized colletion of shell modules designed to streamline your pentesting workflow by leveraging shell integrations such as autocompletion and prefilling, optimizing the productivity of your work and liberatating you from the hassle of juggling notes, endless copying and pasting, and tedious command editing. 

This tool is tailored for security consultants. Unlike other pentesting frameworks like Metasploit, which primarily focuses on **post-exploitation**, Nobility provides a customizable arsenal of 50 modules and over 500 commands, fully written in Zsh for comprehensive **workflow automation** which you can call directly from the shell prompt, allowing for seamless adaptation to your specific needs and enhancing red-teaming and network pentesting activities.

Nobility helps you remember how to use every tool in your arsenal and doesn't hide them behind scripting that can be cumbersome to maintain or update. Each Nobility module is interactive, sparing the need to memorize the syntax. Simply execute the module like so: `nb-recon-subs-ffuf`, and Nobility will prompt you for all required options. Utilize Nobility to build a composable, on-the-fly workflow for every scenario. 

## Key Features
* **Prefilled Commands**: Streamlines terminal integrations by automatically prefilling commands
* **Organized Commands**: Well-organized commands with tab auto-completion
* **Seamless Integration**: Zsh/Oh-My-Zsh shell plugin ensures easy integration into your environment
* **Customizable Settings**: Tailor Nobility to your preferences with customizable settings and global variables
* **Recon Phase**: Access OSINT commands for efficient information gathering
* **Enumeration Phase**: Assistance in enumerating common services, saving time in penetration testing
* **Exploit Phase**: Assistance in compiling exploits for simplified vulnerability exploitation
* **AD Phase**: Assistance in **Active Directory** exploitation, enumeration and attacks
* **Reverse Shell Handlers**: Manage reverse shell handlers easily, enhancing network-pentesting capabilities
* **Content Serving Commands**: Serve content effortlessly, making file sharing and testing straightforward
* **Linux System Management**: Optimized for Linux management, simplifying system tasks
* **Dependency Installers**: Includes installers for dependencies, ensuring a smooth and hassle-free setup process

## Distributions Compatibility
Although Nobility only requires zsh to run successfully, the compatibility with system-specific commands like `nb-install` may vary depending on your operating system.
* **Arch Linux**: Very supported and thoroughly tested for all features.
* **Debian**: Mostly supported; while most functionalities work well, the `nb-install-*` commands have not been specifically tested on this platform and their compatibility may vary.
* **macOS**: Partially supported; the `nb-install-*` commands will not work and it's recommended to avoid using them on this platform.

## Installation
Nobility only requires [Zsh](https://github.com/zsh-users/zsh).

### Installation Method #1: Manually
```bash
# Clone the repo to your zsh directory
git clone https://github.com/Twilight4/nobility.git ~/.config/nobility

# Source the plugin in `~/.zshrc`
echo 'source ~/.config/nobility/nobility.plugin.zsh' >> ~/.zshrc

# Source `~/.zshrc` to load the plugin
source ~/.zshrc
```

### Installation Method #2: Oh-my-zsh
```bash
# Clone the repo to your oh-my-zsh custom plugins directory
git clone https://github.com/Twilight4/nobility.git ~/.oh-my-zsh/custom/plugins/nobility

# Edit `~/.zshrc` to load the plugin
plugins=(git nobility)

# Source `~/.zshrc` to load the plugin
source ~/.zshrc
```

### Tip: Zsh completion menu
For enhanced completion selection menu I use [fzf-tab](https://github.com/Aloxaf/fzf-tab).

![screenshot](https://i.imgur.com/Mff6FUg.png)

### Updating
Simply run the `nb-update` command. Assuming you did not modify any of the content in the nobility directory, this should pull the latest code from this GitHub repo, after which you can run nobility modules as usual.

# Getting Started
Nobility categorizes commands into namespaces, denoted by the `nb-` prefix, exemplified by commands like `nb-enum-web` or `nb-recon-domains`. To see an overview of all namespaces simply use `nb-help` command. 

Each namespace features its own dedicated help command, such as `nb-enum-web-help` which provides a listing of available commands. All commands support tab completion and search. 

## Installing Dependencies
To set up the necessary dependencies for each namespace, execute the `nb-<namespace>-install` command. This command ensures the installation of all tools relevant to the specified namespace. For installation of tools across all namespaces, use the `nb-install-all` command.

## Workflow Design
Nobility is designed to offer a sophisticated and flexible workflow. It eliminates the conventional, tedious process of manually navigating through notes, searching for commands, copying, pasting, and adjusting values before execution. 

In contrast to heavily automated scripts or frameworks that execute entire workflows, often obfuscating the underlying tools and techniques which are cumbersome to modify, Nobility strikes a balance. Embracing the principles of the KISS principle (Keep It Simple, Stupid), each module within Nobility is deliberately small and distinct, minimizing unnecessary complications. This design allows you to quickly execute individual commands, providing well-organized output. 

This approach enables you to compose your workflow dynamically, adapting to specific targets and contextual requirements. This flexibility is achieved without the brittleness and complexity associated with fully automated solutions.

## Example Workflow
### Variables
```bash
# Each time you use nb-vars-set-* command or within a namespace,
# you can persist the vars in other terminal sessions using command (namespaces should include this by default):
nb-vars-save

# To load previously saved vars (use in new terminal sessions), use command: (you can set this command in .zshrc file):
nb-vars-load

# You can always clear the variables with command:
nb-vars-clear
```

### Pre-Engagement
```bash
# Create a project structure
nb-project-start

# Set target IP to /etc/hosts
nb-project-host

# Set some session variables for the target 
nb-vars-set-domain
nb-vars-set-network
nb-vars-set-user
nb-vars-set-pass

# Save variables for other terminal sessions
nb-vars-save

# Generate scope files from the target url
nb-project-rescope
```

### Web Recon
```bash
# Scan the network all ports with TCP syn using rustscan
nb-enum-network-rustscan-all

# Identifying technologies
nb-enum-web-whatweb

# Download out robots.txt
nb-enum-web-dirs-robots

# Subdomain enumeration
nb-enum-web-vhosts-gobuster
nb-recon-subs-ffuf
nb-recon-subs-subfinder

# Resolve and parse subdomains
nb-recon-subs-resolve-massdns
nb-recon-subs-resolve-parse

# Directory brute force
nb-enum-web-dirs-gobuster 
nb-enum-web-dirs-ffuf

# Web vuln scanners
nb-enum-web-vuln-nikto

# Enumerate wordpress website
nb-enum-web-wordpress

# Brute force web auth password for post request
nb-enum-web-fuzz-password-hydra-form-post

# Brute force auth login with post request
nb-enum-web-fuzz-login-hydra-form-post

# ID a WAF if present
nb-enum-web-waf

# Parse SSL certs
nb-enum-web-ssl-certs

# Spider the site
nb-enum-web-gospider
```

### Organization OSINT
```bash
# Search for target files
nb-recon-org-files

# Search downloaded files for URLs
nb-recon-org-files-urls

# Mine github repos for secrets
nb-recon-github-gitrob

# Check DNS records
nb-enum-dns-dnsrecon

# Mine data about a target domain
nb-recon-org-theharvester
```

### Active Directory Auditing
```bash
# SMB Relay
nb-ad-smb-relay-enum
nb-ad-smb-responder
nb-ad-smb-relay-ntlmrelay

# IPv6 Attack
nb-ad-ipv6

# Domain Enumeration
nb-ad-enum-ldapdomaindump

# Kerberoasting
nb-ad-kerb-kerberoast

# Hash Dump
nb-ad-dump-secrets

# GPP Attack
nb-ad-gpp

# Dump NTDS
nb-ad-dump-ntds
```
