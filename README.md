# Nobility
Nobility is an organized colletion of shell modules designed to streamline your terminal workflow by leveraging Zsh integrations such as autocompletion and prefilling, optimizing the productivity of your work and liberatating you from the hassle of juggling notes, endless copying and pasting, and tedious command editing. 

This tool is tailored for security consultants. Unlike other pentesting frameworks like Metasploit, which primarily focuses on **post-exploitation**, Nobility provides a customizable arsenal of modules fully written in Zsh for comprehensive **workflow automation** which you can directly call from the shell prompt, allowing for seamless adaptation to your specific needs and enhancing red-teaming and network-pentesting endeavors.

Nobility helps you remember how to use every tool in your arsenal and doesn't hide them behind scripting that can be cumbersome to maintain or update. 
Instead you can use nobility to build a composable, on-the-fly workflow for every situation. 

# Key Features
* **Prefilled Commands**: Streamlines terminal interactions by automatically prefilling commands
* **Organized Commands**: Well-organized commands with tab auto-completion
* **Seamless Integration**: Zsh/Oh-My-Zsh shell plugin ensures easy integration into your environment
* **Customizable Settings**: Tailor Nobility to your preferences with customizable settings and global variables
* **Recon Phase**: Access OSINT commands for efficient information gathering
* **Enumeration Phase**: Effortlessly enumerate common services, saving time in penetration testing
* **Exploit Phase**: Assistance in compiling exploits for simplified vulnerability exploitation
* **AD Phase**: Assistance in **Active Directory** types of attack
* **Reverse Shell Handlers**: Manage reverse shell handlers easily, enhancing network-pentesting capabilities
* **Content Serving Commands**: Serve content effortlessly, making file sharing and testing straightforward
* **Linux System Management**: Optimized for Linux management, simplifying system tasks
* **Dependency Installers**: Includes installers for dependencies, ensuring a smooth and hassle-free setup process

# Installation
Nobility requires the following:
* [Zsh](https://github.com/zsh-users/zsh)
* [Oh-my-zsh](https://ohmyz.sh/) (optional)

## Installation with Oh-my-zsh
```bash
# Clone the repo to your oh-my-zsh custom plugins directory
git clone https://github.com/Twilight4/nobility.git ~/.oh-my-zsh/custom/plugins/nobility

# Edit `~/.zshrc` to load the plugin
plugins=(git nobility)

# Source `.zshrc` to load the plugin and you're done. On first load, nobility will install a few core packages
source ~/.zshrc
```

## Manual installation
```bash
# Clone the repo to your zsh directory
git clone https://github.com/Twilight4/nobility.git ~/.config/nobility

# Source the plugin in `~/.zshrc`
echo 'source ~/.config/nobility/nobility.plugin.zsh' >> ~/.zshrc

# Source `.zshrc` to load the plugin
source ~/.zshrc
```

# Getting Started
Nobility categorizes commands into namespaces, denoted by the `nb-` prefix, exemplified by commands like `nb-enum-web` or `nb-recon-domains`. To see an overview of all namespaces simply use `nb-help` command. 

Each namespace features its own dedicated help command, such as `nb-enum-web-help` which provides a listing of available commands. All commands support tab completion and search. 

## Installing Dependencies
To set up the necessary dependencies for each namespace, execute the `nb-namespace-install` command. This command ensures the installation of all tools relevant to the specified namespace. For installation of tools across all namespaces, use the `nb-install-all` command.

# Workflow
Nobility is designed to offer a sophisticated and flexible workflow. It eliminates the conventional, tedious process of manually navigating through notes, searching for commands, copying, pasting, and adjusting values before execution. 

In contrast to heavily automated scripts or frameworks that execute entire workflows, often obfuscating the underlying tools and techniques whcih are cumbersome to modify, nobility strikes a balance. Embracing the principles of the KISS principle (Keep It Simple, Stupid), each module within nobility is deliberately small and distinct, minimizing unnecessary complications. This design allows you to quickly execute individual commands, providing well-organized output. 

This approach enables you to compose your workflow dynamically, adapting to specific targets and contextual requirements. This flexibility is achieved without the brittleness and complexity associated with fully automated solutions.

## Example Workflow
### Variables
```bash
# Each time you use nb-vars-set-* command or within a namespace,
# to persist the vars in other terminal sessions you need to use command (namespaces should include this by default):
nb-vars-save

# To load previously saved vars (use in new terminal sessions), use command: (you can set this command in .zshrc file):
nb-vars-load

# If you made a mistake you can clear the variables
nb-vars-clear
```

### Preparation
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
# Scan individual host all ports with TCP syn using rustscan
nb-enum-host-rustscan-all

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

### Active Directory Exploitation
```bash
# LLMNR Poisoning
nb-ad-smb-relay-responder

# AS-REP Roasting
nb-ad-asrep-brute

# SMB Relay
nb-ad-smb-relay-enum

# IPv6 Attack
nb-ad-ipv6

# Internal Enumeration
nb-ad-enum-ldapdomaindump

# Kerberoasting
nb-ad-kerb-kerberoast

# Pass Attack
nb-ad-pth-pass

# Hash Dump
nb-ad-dump-secrets

# GPP Attack
nb-ad-gpp

# Dump NTDS
nb-ad-dump-ntds
```
