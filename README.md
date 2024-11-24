# Terraform Azure Dev Environment

In the following project, I will set up a Development environment with Terraform in Azure. I will be using VS code to deploy:

* Azure Linux machine
* Virtual network
* Subnets
* Security groups ect.

This will serve as a remote Development Environment that can be remotely logged into from VS code. This project will show how to use different tools and functions in Terraform such as:

* Terraform state
* Terraform fmt (format)
* Terraform console
* variables
* conditionals and more...

It will also use Azure Custom Data and a provisioner that will bootstrap the virtual machine with Docker and add its connection information to VScode SSH file which will allow configuration for modification in future projects.

# Initial Setup

For this project I will be using VS Code as a code edditor with a terraform extension and Azure CLI installed to my machine. Once installed I will open up a new bash terminal and enter:

```bash
$ az login --use-device-code
```
That will give a link to a page and a code to enter on that page to login to azure through CLI.

![Azure Login](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/loginAzure.png)

Onece the code has been entered and subscription comfirmed I can get the projected started.

![subscription comfirmed](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/Sub_Comfirm.png)


# Dev Environment

While creating this project I will be using terraform [Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) in order to use the correct configurations for the Dev environment. I'll start off by creating a folder to save the configurations for this project.

![Floder Created](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/1cjx3KcwI3.png)

# Adding a Provider

Now once the folder has been created I will create a file by hovering over the folder name in VS Code I will name the file *__main.tf__*. Now to add the first prot of the code and that is the provider I will be working on in this case Azure:

```terreform
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}
```
Once I have added the provider required information I will run in the terminal:

```bash
terraform fmt
```
*__terraform fmt__* = terrafarm format will clean up the code by removing indentations and lining up the code to make it look organized. This is a good habit to do after adding code and before commiting to a repository. Then I will run:

```bash
terraform init
```
This will initialize a local backend which will store the state in VS code. 

# Resource Group

Next I will add a resource group that will have the name for the resource group, location of where the resource group will be deployed and any tag I would like to use for billing purposes:

```terraform
resource "azurerm_resource_group" "mtc-rg" {
  name     = "mtc-resources"
  location = "East US"
  tags = {
    environment = "dev"
  }
}
```
and in the terminal I will enter:

```bash
terraform fmt
```
to clean up code, then:

```bash
terraform plan
```
which will give me a plan of the resorces that will be deployed in azure which I can review and make sure everything is correct and then run:

```bash
terraform apply
# or
terraform apply -auto-approve
```
*__"terraform apply"__* will give me a review of what will be deployed and will ask to comfirm the deployment and *__"terraform apply -auto-approve"__* will auto approve the deployment without having to type in yes. 

![resource check](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/resource.png)
Apply complete 

And check in Azure under resource groups to verify the resource is created.

![Resource in Azure](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/resource_in_azure.png)

# Virtual Network 

Now I will be adding a Virtual Network which will reference the resource group created.

![Virtual Network](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/VirtualNet.png)

Then clean up code, plan and apply 

```bash
terraform fmt

# next plan 
terraform plan

# next Apply
terraform apply -auto-approve
```

Once I have comfirmation of the Virtual Network being deployed: 

![Virtual Network Comfirmation](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/VirtualnetComfirmation.png)

I can check on the resources that have been deployed by going to Azure portal and viewing the resources or I can use *__State Commands__* .The following are State commands that can be ran after creating a new resource to verify the resource was created and to view the information on the resource created:

```bash
# State list will show resources created
terraform state list
```
![State List](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/statelist.png)

```bash
# State show plus the receouce wanted to be viewed will show the information in the resourece
terraform state show azurerm_virtual_network.mtc-vn
```
![State Show](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/stateshow.png)

```bash
# Show will show all the resource information on all the resources created
terraform show
```
![Show](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/show.png)

# Subnet 

Now I will be adding the subnet:

```terraform
resource "azurerm_subnet" "mtc-subnet" {
  name                 = "mtc-subnet"
  resource_group_name  = azurerm_resource_group.mtc-rg.name
  virtual_network_name = azurerm_virtual_network.mtc-vn.name
  address_prefixes     = ["10.123.1.0/24"]
}
```
Once the subnet has been added I will run in the terminal:

```bash
# Format 
terraform fmt
# Plan
terraform plan
# Apply
terraform apply -auto-approve
# State List to verify
terrraform state list
```
# Security Group & Security Rule

Next I will be adding the security group and rule:

```terraform
resource "azurerm_network_security_group" "mtc-sg" {
  name                = "mtc-sg"
  location            = azurerm_resource_group.mtc-rg.location
  resource_group_name = azurerm_resource_group.mtc-rg.name

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_security_rule" "mtc-dev-rule" {
  name                        = "mtc-dev-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.mtc-rg.name
  network_security_group_name = azurerm_network_security_group.mtc-sg.name
}
```
the security group must refrence the resource group location and name and the rule must refrence resource group and network security group. Once that is done I will run:

```bash
# Format 
terraform fmt
# Plan
terraform plan
# Apply
terraform apply -auto-approve
# State List to verify
terrraform state list
```
to clean up, plan, apply and verify.

# Security Group Association 

Next I will associate the security group to the subnet in order to protect the subnet as well.

```terraform
resource "azurerm_subnet_network_security_group_association" "mtc-sga" {
  subnet_id                 = azurerm_subnet.mtc-subnet.id
  network_security_group_id = azurerm_network_security_group.mtc-sg.id
}
```
I will make sure to refrence subnety and security group in the requested filed and clean up, plan, apply, and verify.

```bash
# Format 
terraform fmt
# Plan
terraform plan
# Apply
terraform apply -auto-approve
# State List to verify
terrraform state list
```

# Public IP

The next resource I will be adding will be a public IP:

```terraform
resource "azurerm_public_ip" "mtc-ip" {
  name                = "mtc-ip"
  resource_group_name = azurerm_resource_group.mtc-rg.name
  location            = azurerm_resource_group.mtc-rg.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev"
  }
}
```
Then I will clean up, plan, apply and check the state:

```bash
# Format
terraform fmt
# Plan
terraform plan
# Apply 
terraform apply -auto-approve
```

The Public IP will refrence resource group name and location, I have also used the allocation method as Dynamic. When setting it to Dynamic azure does not set up an IP address untill it is attaches to somthing and used. To check for the IP address I can run:

```bash
# State Show plu the information for the public IP resource 
terraform state show azurerm_public_ip.mtc-ip
```
this will show that no IP address has been set.

![IP No Show](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/IPNoShow.png)
