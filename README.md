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


# Requirements 

* VSCode installed
* Azure CLI installed
* Terraform extension istalled

