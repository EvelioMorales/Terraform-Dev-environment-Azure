![Main Pic](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/AzureDev.png)


# Azure Remote Development Environment with Terraform, Docker, and VS Code SSH

## Project Overview

This project provisions a remote Linux-based development environment in Microsoft Azure using Terraform.

The environment includes:

- Azure Resource Group
- Virtual Network
- Subnet
- Network Security Group
- Public IP Address
- Linux Virtual Machine
- SSH key-based authentication
- Docker installation through Azure Custom Data
- VS Code Remote SSH configuration
- Terraform variables, outputs, and state management

The purpose of this project is to demonstrate Infrastructure as Code skills by automating the deployment of a reusable cloud development workstation.

---

## Real-World Scenario

A development or cloud support team may need a standardized remote development environment that can be quickly deployed, accessed securely, and destroyed when no longer needed.

This project simulates that use case by using Terraform to deploy an Azure Linux VM that can be accessed remotely through SSH and VS Code Remote SSH.

---

## Technologies Used

- Microsoft Azure
- Terraform
- Azure CLI
- Azure Virtual Machines
- Azure Virtual Network
- Azure Network Security Groups
- SSH
- VS Code Remote SSH
- Docker
- Linux
- PowerShell
- Bash

---

## Skills Demonstrated

- Infrastructure as Code with Terraform
- Azure resource provisioning
- Linux VM administration
- SSH key-based authentication
- Network security group configuration
- Docker installation automation
- Terraform variables and outputs
- Terraform state inspection
- VS Code Remote SSH configuration
- Cloud development environment design
- Basic cloud security hardening

---

## Architecture Summary

The Terraform configuration deploys the following Azure resources:

1. Resource Group
2. Virtual Network
3. Subnet
4. Network Security Group
5. Network Security Group Association
6. Public IP Address
7. Network Interface
8. Linux Virtual Machine
9. Custom Data script to install Docker
10. Local SSH configuration for VS Code Remote SSH

### Logical Architecture

```text
Developer Laptop
      |
      | SSH / VS Code Remote SSH
      |
Public IP Address
      |
Network Security Group
      |
Azure Linux Virtual Machine
      |
Docker Development Environment
````

---

## Repository Structure

```text
Terraform-Dev-environment-Azure/
│
├── main.tf
├── providers.tf
├── variables.tf
├── outputs.tf
├── networking.tf
├── compute.tf
├── security.tf
├── customdata.tpl
├── windows-ssh-script.tpl
├── linux-ssh-script.tpl
├── terraform.tfvars.example
├── .gitignore
└── README.md
```

---

## Prerequisites

Before deploying this project, install the following tools:

* [Terraform](https://developer.hashicorp.com/terraform/downloads)
* [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
* [Visual Studio Code](https://code.visualstudio.com/)
* VS Code Terraform Extension
* VS Code Remote SSH Extension
* Git Bash, PowerShell, or a Linux terminal

You also need:

* An active Azure subscription
* SSH installed locally
* Permission to create Azure resources

---

## Initial Azure Login

Open a terminal in VS Code and log in to Azure using the Azure CLI:

```bash
az login --use-device-code
```

Azure will provide:

* A device login URL
* A temporary login code

After entering the code and signing in, confirm that the correct Azure subscription is selected.

![Azure Login](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/loginAzure.png)

![Subscription Confirmed](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/Sub_Comfirm.png)

---

## Terraform Provider Configuration

Create a file named:

```text
providers.tf
```

Add the AzureRM provider configuration:

```terraform
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}
```

Initialize Terraform:

```bash
terraform init
```

Format the Terraform code:

```bash
terraform fmt
```

---

## Resource Group

Create a file named:

```text
main.tf
```

Add the Azure resource group:

```terraform
resource "azurerm_resource_group" "mtc_rg" {
  name     = "mtc-resources"
  location = var.location

  tags = {
    environment = "dev"
  }
}
```

Run:

```bash
terraform fmt
terraform plan
terraform apply
```

Or use:

```bash
terraform apply -auto-approve
```

> Note: `terraform apply` allows you to review the deployment before confirming.
> `terraform apply -auto-approve` deploys without asking for confirmation.

![Resource Group Created](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/resource.png)

Verify the resource group in the Azure Portal.

![Resource in Azure](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/resource_in_azure.png)

---

## Networking Configuration

Create a file named:

```text
networking.tf
```

Add the virtual network and subnet:

```terraform
resource "azurerm_virtual_network" "mtc_vn" {
  name                = "mtc-network"
  address_space       = ["10.123.0.0/16"]
  location            = azurerm_resource_group.mtc_rg.location
  resource_group_name = azurerm_resource_group.mtc_rg.name

  tags = {
    environment = "dev"
  }
}

resource "azurerm_subnet" "mtc_subnet" {
  name                 = "mtc-subnet"
  resource_group_name  = azurerm_resource_group.mtc_rg.name
  virtual_network_name = azurerm_virtual_network.mtc_vn.name
  address_prefixes     = ["10.123.1.0/24"]
}
```

Run:

```bash
terraform fmt
terraform plan
terraform apply -auto-approve
```

![Virtual Network](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/VirtualNet.png)

![Virtual Network Confirmation](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/VirtualnetComfirmation.png)

---

## Terraform State Commands

Terraform state can be used to verify and inspect deployed resources.

List resources in state:

```bash
terraform state list
```

![Terraform State List](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/statelist.png)

Show details for the virtual network:

```bash
terraform state show azurerm_virtual_network.mtc_vn
```

![Terraform State Show](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/stateshow.png)

Show all deployed infrastructure information:

```bash
terraform show
```

![Terraform Show](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/show.png)

---

## Network Security Group

Create a file named:

```text
security.tf
```

Add the Network Security Group:

```terraform
resource "azurerm_network_security_group" "mtc_sg" {
  name                = "mtc-sg"
  location            = azurerm_resource_group.mtc_rg.location
  resource_group_name = azurerm_resource_group.mtc_rg.name

  tags = {
    environment = "dev"
  }
}
```

---

## Secure SSH Rule

For security, inbound access should be restricted to SSH only.

Instead of allowing all TCP ports from every source, this project allows SSH traffic only from a trusted public IP address.

```terraform
resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "allow-ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.my_public_ip
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.mtc_rg.name
  network_security_group_name = azurerm_network_security_group.mtc_sg.name
}
```

> Security Note: Avoid using `source_address_prefix = "*"` for SSH access in real environments. Restrict SSH access to your trusted public IP address whenever possible.

---

## Associate NSG to Subnet

Associate the Network Security Group with the subnet:

```terraform
resource "azurerm_subnet_network_security_group_association" "mtc_sga" {
  subnet_id                 = azurerm_subnet.mtc_subnet.id
  network_security_group_id = azurerm_network_security_group.mtc_sg.id
}
```

Run:

```bash
terraform fmt
terraform plan
terraform apply -auto-approve
terraform state list
```

---

## Public IP Address

Add a public IP address for the virtual machine:

```terraform
resource "azurerm_public_ip" "mtc_ip" {
  name                = "mtc-ip"
  resource_group_name = azurerm_resource_group.mtc_rg.name
  location            = azurerm_resource_group.mtc_rg.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev"
  }
}
```

Run:

```bash
terraform fmt
terraform plan
terraform apply -auto-approve
```

Check the public IP state:

```bash
terraform state show azurerm_public_ip.mtc_ip
```

![Public IP State](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/IPNoShow.png)

> Note: A dynamic public IP may not show an assigned address until it is attached to a network interface and used by the VM.

---

## Network Interface

Add a network interface for the VM:

```terraform
resource "azurerm_network_interface" "mtc_nic" {
  name                = "mtc-nic"
  location            = azurerm_resource_group.mtc_rg.location
  resource_group_name = azurerm_resource_group.mtc_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mtc_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mtc_ip.id
  }

  tags = {
    environment = "dev"
  }
}
```

---

## Generate SSH Key Pair

Generate an SSH key pair for secure VM access.

Recommended command:

```bash
ssh-keygen -t ed25519 -C "azure-dev-environment"
```

If using RSA:

```bash
ssh-keygen -t rsa -b 4096
```

When prompted, save the key in your `.ssh` directory.

Example:

```text
C:\Users\user\.ssh\mtcazurekey
```

Verify that the key was created:

```bash
ls ~/.ssh
```

![SSH Key Generation](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/sshkeygen.png)

> Security Note: In a production environment, SSH private keys should be protected with a passphrase and stored securely.

---

## Linux Virtual Machine

Create a file named:

```text
compute.tf
```

Add the Linux virtual machine:

```terraform
resource "azurerm_linux_virtual_machine" "mtc_vm" {
  name                = "mtc-vm"
  resource_group_name = azurerm_resource_group.mtc_rg.name
  location            = azurerm_resource_group.mtc_rg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"

  network_interface_ids = [
    azurerm_network_interface.mtc_nic.id
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = filebase64("customdata.tpl")

  tags = {
    environment = "dev"
  }
}
```

![Linux VM](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/Linux.png)

Run:

```bash
terraform fmt
terraform plan
terraform apply -auto-approve
```

---

## SSH into the Virtual Machine

Get the public IP address:

```bash
terraform output
```

Or inspect the VM state:

```bash
terraform state show azurerm_linux_virtual_machine.mtc_vm
```

SSH into the VM:

```bash
ssh -i ~/.ssh/mtcazurekey adminuser@<public-ip-address>
```

Example:

```bash
ssh -i ~/.ssh/mtcazurekey adminuser@172.191.107.184
```

Verify the operating system:

```bash
lsb_release -a
```

![Instance Confirmation](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/Instanceconfirm.png)

Exit the VM:

```bash
exit
```

---

## Custom Data: Install Docker

Create a file named:

```text
customdata.tpl
```

Add the following bootstrap script:

```bash
#!/bin/bash

sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg lsb-release

sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo usermod -aG docker adminuser
```

This script installs Docker when the VM is created.

![Custom Data](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/customdata.png)

![Custom Data Argument](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/customdataargument.png)

Apply the configuration:

```bash
terraform fmt
terraform plan
terraform apply -auto-approve
```

SSH into the VM and verify Docker:

```bash
docker --version
```

![Docker Version](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/Dockerversion.png)

---

## VS Code Remote SSH Setup

Install the **Remote SSH** extension in VS Code.

Steps:

1. Open VS Code.
2. Go to **Extensions**.
3. Search for **Remote SSH**.
4. Install the extension.
5. Open the Command Palette.
6. Select **Remote-SSH: Add New SSH Host**.
7. Add your SSH connection string.

Example:

```bash
ssh -i ~/.ssh/mtcazurekey adminuser@<public-ip-address>
```

---

## Windows SSH Script Template

Create a file named:

```text
windows-ssh-script.tpl
```

Add:

```powershell
add-content -path c:/Users/user/.ssh/config -value @'

Host ${hostname}
  HostName ${hostname}
  User ${user}
  IdentityFile ${identityfile}
'@
```

---

## Linux SSH Script Template

Create a file named:

```text
linux-ssh-script.tpl
```

Add:

```bash
cat << EOF >> ~/.ssh/config

Host ${hostname}
  HostName ${hostname}
  User ${user}
  IdentityFile ${identityfile}
EOF
```

These templates automatically add SSH host information to your local SSH config file.

---

## Terraform Provisioner

A Terraform `local-exec` provisioner can be used to automatically update the local SSH config file.

Add this inside the `azurerm_linux_virtual_machine` resource block:

```terraform
provisioner "local-exec" {
  command = templatefile("${var.host_os}-ssh-script.tpl", {
    hostname     = self.public_ip_address,
    user         = "adminuser",
    identityfile = var.ssh_private_key_path
  })

  interpreter = var.host_os == "windows" ? ["PowerShell", "-Command"] : ["bash", "-c"]
}
```

> Note: This project uses a Terraform provisioner for convenience. In production environments, configuration management tools such as Ansible, cloud-init, or Azure VM extensions may be preferred.

![Provisioner](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/provisioner.png)

If the VM already exists, replace it so the provisioner runs again:

```bash
terraform state list
terraform apply -replace="azurerm_linux_virtual_machine.mtc_vm"
```

After replacement, connect using VS Code Remote SSH.

![Remote Window](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/remotewindow.png)

Verify Docker again:

```bash
docker --version
```

Example output:

```text
Docker version 27.3.1, build ce12230
```

---

## Data Source and Output

Add a data source to query the public IP address:

```terraform
data "azurerm_public_ip" "mtc_ip_data" {
  name                = azurerm_public_ip.mtc_ip.name
  resource_group_name = azurerm_resource_group.mtc_rg.name
}
```

Run:

```bash
terraform apply -refresh-only
```

![Data Source](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/datasource.png)

---

## Outputs

Create a file named:

```text
outputs.tf
```

Add:

```terraform
output "public_ip_address" {
  value = "${azurerm_linux_virtual_machine.mtc_vm.name}: ${data.azurerm_public_ip.mtc_ip_data.ip_address}"
}

output "ssh_connection_command" {
  value = "ssh -i ${var.ssh_private_key_path} adminuser@${data.azurerm_public_ip.mtc_ip_data.ip_address}"
}
```

Apply refresh:

```bash
terraform apply -refresh-only
```

View outputs:

```bash
terraform output
```

![Terraform Output](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/output.png)

---

## Variables

Create a file named:

```text
variables.tf
```

Add:

```terraform
variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
  default     = "East US"
}

variable "host_os" {
  description = "Local operating system used for SSH config script"
  type        = string
}

variable "my_public_ip" {
  description = "Trusted public IP address allowed to SSH into the VM"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key"
  type        = string
}
```

---

## Terraform Variables Example

Create a file named:

```text
terraform.tfvars.example
```

Add:

```terraform
location             = "East US"
host_os              = "windows"
my_public_ip         = "YOUR_PUBLIC_IP/32"
ssh_public_key_path  = "C:/Users/user/.ssh/mtcazurekey.pub"
ssh_private_key_path = "~/.ssh/mtcazurekey"
```

Create your real local file:

```text
terraform.tfvars
```

Example:

```terraform
location             = "East US"
host_os              = "windows"
my_public_ip         = "123.123.123.123/32"
ssh_public_key_path  = "C:/Users/user/.ssh/mtcazurekey.pub"
ssh_private_key_path = "~/.ssh/mtcazurekey"
```

> Important: Do not upload your real `terraform.tfvars` file to GitHub if it contains your IP address, usernames, or sensitive values.

---

## .gitignore

Create a `.gitignore` file:

```gitignore
.terraform/
*.tfstate
*.tfstate.*
*.tfvars
crash.log
crash.*.log
override.tf
override.tf.json
*_override.tf
*_override.tf.json
```

This helps prevent sensitive Terraform files from being uploaded to GitHub.

---

## Validation

The deployment was validated using the following checks:

| Test                       | Command                                           | Expected Result                |
| -------------------------- | ------------------------------------------------- | ------------------------------ |
| Verify Terraform resources | `terraform state list`                            | Azure resources are listed     |
| Verify public IP output    | `terraform output`                                | Public IP address is displayed |
| Test SSH access            | `ssh -i ~/.ssh/mtcazurekey adminuser@<public-ip>` | Successful login               |
| Verify Linux OS            | `lsb_release -a`                                  | Linux version is displayed     |
| Verify Docker installation | `docker --version`                                | Docker version is returned     |
| Verify VS Code Remote SSH  | Connect through VS Code                           | Remote terminal opens          |

---

## Security Improvements Added

This project includes several important security improvements:

* SSH access restricted to a trusted public IP address
* SSH key-based authentication instead of password login
* Network Security Group associated with the subnet
* Sensitive Terraform variable values excluded from GitHub
* `.gitignore` added to protect Terraform state files
* Security note added for SSH private key protection

---

## Cost Management

This project uses Azure resources that may create charges.

To avoid unnecessary Azure costs, destroy the infrastructure after testing:

```bash
terraform destroy
```

Confirm the destruction by checking:

```bash
terraform state list
```

You can also verify in the Azure Portal that the resource group has been removed.

---

## Cleanup

Destroy all deployed resources:

```bash
terraform destroy
```

Type:

```text
yes
```

when prompted.

---

## Lessons Learned

Through this project, I learned how to use Terraform to provision and manage Azure infrastructure.

I also gained hands-on experience with:

* Azure CLI authentication
* Terraform provider configuration
* Resource groups
* Virtual networks
* Subnets
* Network Security Groups
* Linux virtual machines
* SSH key authentication
* Docker installation automation
* Terraform variables and outputs
* Terraform state inspection
* VS Code Remote SSH access

This project helped strengthen my understanding of Infrastructure as Code and cloud-based development environments.

---

## Future Improvements

Potential improvements for this project include:

* Store Terraform state in an Azure Storage Account backend
* Add Azure Bastion to remove direct public SSH exposure
* Store SSH keys in Azure Key Vault
* Add Azure Monitor and Log Analytics
* Add GitHub Actions for Terraform plan and apply
* Convert the configuration into reusable Terraform modules
* Add separate dev, test, and production workspaces
* Add Docker container deployment after VM creation
* Add Ansible for post-deployment configuration management

---

## Conclusion

This project demonstrates how Terraform can be used to deploy a remote development environment in Microsoft Azure.

By provisioning Azure networking, security, compute, SSH access, Docker installation, and VS Code Remote SSH integration, this project shows a practical Infrastructure as Code workflow for creating reusable cloud development environments.

