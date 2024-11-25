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

# Linux VM & SSH Key Pair

Now I will be addin a linux virtual machine 

![Linux VM](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/Linux.png)

and next I will generate a key pair 

```bash
ssh-keygen -t rsa
```
 Then it will ask to enter file in which to save key and I will use the same location gived and rename the file as shown:

 ![SSH Keygen](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/sshkeygen.png)

 Once saved I will skip the passphrase and now I can make surre the ssh key was save by running 

 ```bash
ls ~/.ssh
```
That will show the file saved and now I can add the ssh key pair to the code 

 ```terraform
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("C:/Users/user/.ssh/mtcazurekey.pub")
  }
```
![SSH To Code](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/sshtocode.png)

Now I can run 

```bash
terraform fmt
terraform plan
terraform apply -auto-approve
```
Now that it has been applyed I can ssh in to the instance by first getting the Public IP address

```bash
# State lsit to show list of resources
terraform state list
# Show command plus VM info
terraform state show azurerm_linux_virtual_machine.mtc-vm
```
![IP Address Copy](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/copyIP.png)

Now that an IP address is showing I will copy the IP address and run 

```bash
ssh -i ~/.ssh/mtcazurekey adminuser@172.191.107.184
```
Once I am loged in to the instance i can verify by running

```bash
lsb_release -a
```

![instance confirmation](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/Instanceconfirm.png)

This will show thew instance information and I'll jsut run exit to extix the instance.

# Custom Data

Next I will be adding Custom Data to bootstrap the instance and install Docker engine. This will allow me to have a Linux VM instance deployed with Docker for all development needs. To start I will create a new file and name it *__customdata.tpl__* . I will save this in a template file just incase later I would like to add variables.

![Custom Data](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/customdata.png)

Once I have created the file I will add the shown script and save. Now I can add the custom data argument

![Custom data argument](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/customdataargument.png)

Now run clean up, plan, and apply 

```bash
terraform mft
terraform plan
terraform apply -auto-approve
```

Netx I will verify that Docker was installed by coppying the new IP address taht was generated do to a new instance that was created. 

```bash
# State list to get the VM information 
terraform state lsit
# State Show plus VM information
terraform state show
# Once new IP address is copyed run 
ssh -i ~/.ssh/mtcazurekey adminuser@52.170.88.73

# Once logged in to the instance
docker --version
```
![Docker Version](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/Dockerversion.png)

Once in the instance *__docker --version__* will show docker information. 

# Remote SSH 

Next I will be adding a remote ssh extension in VS Code that will open up a remote terminal in the VM, and add the configuration scripts to insert VM host information such as the IP address in to the ssh config file that VS Code will use to connect to those instances. 

First I will install the __Remote SSH__ from the extensions tab. Once that is installed I will click on __View__ and open the __Command Palette__ and start typing __Remote SSH__ and selec __Remote SSH ADD New SSH Host__ then type in __ssh admin@admin.com__ and hit enter. It will show a few options and I will select the first one __ C:\Users\user\.ssh\config__ and click on the pop up window open config.

The config file will show teh format that I will be using which will need Host, Host Name, User, and IdentityFile. I will need to extract that information from the instance.

I will start by creating a new file and since I'm on Windows I will name it __windows-ssh-script.tpl__ and with in that file I will add the following script 

```windows 
add-content -path c:/Users/user/.ssh/config -value @'

Host ${hostname}
  HostName ${hostname}
  User ${user}
  IdentityFile ${identityfile}
'@
```

I will also create a Lunix file incase I logg in with a Linux OS and I will name it __linux-ssh-script.tpl__

```linux
cat << EOF >> ~/.ssh/config

Host ${hostname}
  HostName ${hostname}
  User ${user}
  IdentityFile ${identityfile}
EOF
```

The script are what will be used to add the information needed to ssh in to the remote VM.

# Provisioner

I will be using a provisioner now this is not optional if I would be configuring an instance but for this simple task it is perfect for configuration using user data custom data or ansible. Now I will add the following to VS Code in the same block of the instance. 

```terraform
provisioner "local-exec" {
    command = templatefile("$windows-ssh-script.tpl", {
      hostname     = self.public_ip_address,
      user         = "adminuser",
      identityfile = "~/.ssh/mtcazurekey"
    })
    interpreter = ["Powershell", "-Command"]
  }
```
![Provisioner](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/provisioner.png)

Once added if I run a *__terraform plan__* it will show that no changes are made since the state will not pick up the provisioner. In this case I will have to destroy the current VM and create a new one by replasing it which is also call tainting.

```bash
# State list to get the VM info
terraform state list
# Copy teh VM info and Apply
terrafrom apply -replace azurerm_linux_virtual_machine.mtc-vm
```

Once the replace command is ran type in yes to apply the actions and tha VM will be destroyed and a new one created with the new configuration. To verify that it has worked I will click on __View__ and select __Command Palette__ selcet __Remote SSH Connect to Host__ and selct IP address. If done correct a new VS Code window will open and I will select lilnux, continue and open up a new terminal. 

![Remote Window](https://github.com/EvelioMorales/Terraform-Dev-environment-Azure/blob/main/remotewindow.png)

Run the following to verify that Dcker is installed 

```bash
docker --version
# a similar confirmation should show
Docker version 27.3.1, build ce12230
```

That indicates that the provisioner was added correctly.

# Data Sources 

I will be adding a data sourn ce to query the public IP to show hnopw it work
