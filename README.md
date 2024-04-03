# Nobility
Nobility is an organized colletion of shell functions designed to streamline your terminal interactions, liberating you from the hassle of juggling notes, endless copying and pasting, and tedious command editing. 

This tool is tailored for security consultants with a focus on enhancing red-teaming and network-pentesting endeavors. 
Nobility doesn't cover all tools, it's my own curated collection which I am still adding to and updating in order to automate my workflow. 
I focus on tools I use and that are maintained and current. 

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
* **Built-in Logbook**: Keep on-the-fly notes and save commands with Nobility's built-in logbook feature
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
### Preparation
```bash
# Create a project structure
nb-project-start

# Specify project directory for tools outputs
nb-vars-set-project 

# Set some session variables for the target 
nb-vars-set-domain 

# Generate scope files from the target url
nb-project-rescope

# Save vars for other terminal sessions
nb-vars-save

# Reload previously saved vars (use in new terminal sessions)
nb-vars-load
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
```
