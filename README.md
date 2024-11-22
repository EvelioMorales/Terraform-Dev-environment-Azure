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

While creating this project I will be using terraform [Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) in order to user the correct configurations for the Dev environment. 

