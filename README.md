#123 test-jenkins
In this section, we will create Jenkins pipelines to deploy our infrastructure to Azure Portal. In our Terraform scripts, we would like to create a Virtual machine and its resources on Azure. To achieve this goal first we would like to install Jenkins on our Ubuntu system.

```bash
docker pull jenkins/jenkins
docker create volume jenkins-volume
docker run -d -v jenkins-volume:/var/jenkins_home -p 8080:8080 jenkins/jenkins
```

We can see that our jenkins now runs in a docker container;

![Screenshot 2024-12-30 at 23.14.28.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/7749701e-51b4-4de6-b807-b0f3aa206a0f/5fc836ae-99fa-4a08-9c80-58a7778fa300/Screenshot_2024-12-30_at_23.14.28.png)

![Screenshot 2024-12-30 at 23.14.10.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/7749701e-51b4-4de6-b807-b0f3aa206a0f/51ebbdbc-8496-4987-87d1-20e6e97eb086/Screenshot_2024-12-30_at_23.14.10.png)

We need to install our plugins to Jenkins such as Terraform and Azure Credentials;

![Screenshot 2024-12-31 at 12.41.38.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/7749701e-51b4-4de6-b807-b0f3aa206a0f/74bf11e9-ba7c-4754-807a-f24332d85ae2/Screenshot_2024-12-31_at_12.41.38.png)

![Screenshot 2024-12-31 at 12.41.44.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/7749701e-51b4-4de6-b807-b0f3aa206a0f/1980a045-04f7-4565-99d0-7b8765a36586/Screenshot_2024-12-31_at_12.41.44.png)

We need to add Terraform tool;

![Screenshot 2024-12-31 at 12.42.26.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/7749701e-51b4-4de6-b807-b0f3aa206a0f/4187eb76-1975-44ff-ae1d-24c601d41e7a/Screenshot_2024-12-31_at_12.42.26.png)

Now we would like to create an Azure Service Principle to use RBAC to provision our infrastructure (owner or contributor role).

Let’s move over to Azure CLI;

![Screenshot 2024-12-30 at 23.19.33.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/7749701e-51b4-4de6-b807-b0f3aa206a0f/98e98355-5c53-45fb-879c-5537761f324a/Screenshot_2024-12-30_at_23.19.33.png)

```bash
**az account show --subscription 1570fddf-1398-4447-bc7b-c981b7f9fa98 --query id

az ad sp create-for-rbac --name "jenkins-test-sp" --role contributor --scopes /subscriptions/ba38195f-caaf-46fd-8149-0ee5f6d5b2cc/

#If you want to assign new permissions to a service principal for example "owner"

az role assignment create --assignee cd15bdaa-5a08-4440-a8af-babfb22e4d07 --role Contributor --scope /subscriptions/ba38195f-caaf-46fd-8149-0ee5f6d5b2cc**
```

![Screenshot 2024-12-30 at 23.42.01.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/7749701e-51b4-4de6-b807-b0f3aa206a0f/796d4a55-fb13-42ba-aeb2-8f06032b718e/Screenshot_2024-12-30_at_23.42.01.png)

We will use these to create a secret inside Jenkins Credentials to manage resources in Azure. To create a service principle you can follow this guide if you do not have necessary permissions;

https://learn.microsoft.com/en-us/entra/identity-platform/howto-create-service-principal-portal

We will add the service principle to Jenkins Credentials as azure service principal. To add this as a credential on Jenkins, you need to install azure credentials plugin to Jenkins. 

For more detailed steps;

https://learn.microsoft.com/en-us/azure/developer/jenkins/deploy-to-azure-app-service-using-azure-cli

For code checkout step from Github repo I added ssh key into Jenkins as a credential as well;

![Screenshot 2024-12-31 at 12.46.37.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/7749701e-51b4-4de6-b807-b0f3aa206a0f/3ed8789d-eda2-4277-87b5-77a09c63fe2a/Screenshot_2024-12-31_at_12.46.37.png)

Our pipeline will consist of 3 basic steps, 1) azure login, 2) checkout terraform codes from github 3) terraform init and apply

Here is the pipeline:

```bash
pipeline {
    agent any
    environment {
        credentials = credentials('jenkins-test-sp')
    }

    stages {

        stage('Az-login') {
            steps {
                script {
                    withCredentials([azureServicePrincipal('azure-service-principle')]) {
                    // Authenticate with Azure
                    sh '''
                    az login --service-principal \
                    --username $AZURE_CLIENT_ID \
                    --password $AZURE_CLIENT_SECRET \
                    --tenant $AZURE_TENANT_ID 
                    '''
                    }
                
                }
            }
        }
        stage('Checkout Code') {
            steps {
                git url: 'git@github.com:0x24dazzle/test-jenkins.git',
                    credentialsId: 'github-ssh',
                    branch: 'deploy-vm2'
            }
        }
        stage('Deploy') {
            steps {
                script {
                    //withAzureServicePrincipal('azure-service-principle') {
                    sh '''
                
                    
                    
                    
                    export ARM_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID 
                    export ARM_CLIENT_ID=$AZURE_CLIENT_ID 
                    export ARM_CLIENT_SECRET=$AZURE_CLIENT_SECRET 
                    export ARM_TENANT_ID=$AZURE_TENANT_ID 

                    terraform init -upgrade
                    terraform init
                    terraform apply -auto-approve
                '''
                    //}
                }        

            }
        }
    }
}
```

Now let’s move over to our linux terminal to create and push our terraform code.

Password authentication to github was removed. Create a public ssh and add it to your github repository. Then add your ssh repository url to .git/config file. For further information;
https://mkyong.com/git/github-keep-asking-for-username-password-when-git-push/

Initialize our branch

```bash
git branch deploy-vm2
git checkout deploy-vm2
git commit -m "first commit message"
git add .
git push -u origin deploy-vm2
```

![Screenshot 2024-12-31 at 12.50.20.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/7749701e-51b4-4de6-b807-b0f3aa206a0f/3ff55a97-06f4-4ab3-b749-2b891a678c81/Screenshot_2024-12-31_at_12.50.20.png)

Now we can create our terraform files;

We will use [providers.tf](http://providers.tf) to use azure provider;

```bash
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.1.3"
}
provider "azurerm" {
	features{}
}
```

Here is the [variables.tf](http://variables.tf) file:

```bash
variable "resource_group_name" {
  description = "Name of the resource group"
  default     = "test-jenkins2"
}

variable "location" {
  description = "Azure region for the resources"
  default     = "West Europe"
}

variable "admin_username" {
  description = "Admin username for the VM"
  default     = "azureuser"
}

variable "admin_password" {
  description = "Admin password for the VM"
  default     = "P@ssw0rd1234!"
}
```

Here is the outputs.tf:

```bash
output "public_ip_address" {
  description = "Public IP address of the virtual machine"
  value       = azurerm_public_ip.public_ip.ip_address
}
```

In [main.tf](http://main.tf) we have several resources; resource group, virtual network, subnet, public_ip, network security group (with the security rules for allowing inbound ssh connections over port22), network interface card (with the IP configuration that uses our newly created subnet and public IP explicitly),  and lastly, our virtual machine with the necessary components such as storage and virtual machines image, username and password etc.

main.tf:

```bash
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "myVnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "mySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "public_ip" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "nsg" {
  name                = "myNSG"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "myNIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myNICConfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "myVM"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = "Standard_B1s"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  disable_password_authentication = false
}
```

![Screenshot 2024-12-31 at 01.23.31.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/7749701e-51b4-4de6-b807-b0f3aa206a0f/f411a501-d844-47d3-98f9-74a24513bab0/Screenshot_2024-12-31_at_01.23.31.png)

After adding our files we will push to our github repository;

```bash
git branch
git add .
git commit -m "message" 
git push -u origin deploy-vm2
```

Our github looks like this;

![Screenshot 2024-12-31 at 13.03.45.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/7749701e-51b4-4de6-b807-b0f3aa206a0f/b470a6b5-8f97-4fbd-bda8-6d7ab95be21a/Screenshot_2024-12-31_at_13.03.45.png)

![Screenshot 2024-12-31 at 13.04.32.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/7749701e-51b4-4de6-b807-b0f3aa206a0f/c3d8076b-847b-437a-8fe9-5e287ba6ff29/Screenshot_2024-12-31_at_13.04.32.png)

After building our pipeline, we can see that the resources are getting created on Azure;

![Screenshot 2024-12-31 at 13.06.18.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/7749701e-51b4-4de6-b807-b0f3aa206a0f/d69c89fe-bc2f-4636-a0d2-24fdb4fe680d/Screenshot_2024-12-31_at_13.06.18.png)

![Screenshot 2024-12-31 at 13.07.27.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/7749701e-51b4-4de6-b807-b0f3aa206a0f/c4da5d7d-b136-4ae1-a297-00a902a6a07a/Screenshot_2024-12-31_at_13.07.27.png)

![Screenshot 2024-12-31 at 13.14.10.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/7749701e-51b4-4de6-b807-b0f3aa206a0f/c9488b70-d51e-4b16-aeb5-4227a6654e9a/Screenshot_2024-12-31_at_13.14.10.png)

![Screenshot 2024-12-31 at 13.08.34.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/7749701e-51b4-4de6-b807-b0f3aa206a0f/89a77799-a3ef-42da-b37e-b5f95246c06f/Screenshot_2024-12-31_at_13.08.34.png)

![Screenshot 2024-12-31 at 13.08.42.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/7749701e-51b4-4de6-b807-b0f3aa206a0f/e2750992-2035-4802-86a3-900d7af0f4f1/Screenshot_2024-12-31_at_13.08.42.png)

Let’s connect to our VM using public IP address and username password;

![Screenshot 2024-12-31 at 13.10.21.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/7749701e-51b4-4de6-b807-b0f3aa206a0f/a662a61e-3021-4d55-8329-7b164d25ad09/Screenshot_2024-12-31_at_13.10.21.png)

![Screenshot 2024-12-31 at 13.10.59.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/7749701e-51b4-4de6-b807-b0f3aa206a0f/6a1aeb81-705c-44d5-ba1f-422d99e01661/Screenshot_2024-12-31_at_13.10.59.png)

What could be improved further;

1. Ssh keys could be added to enhance security
2. Instead of using public IP address, a bastion or a load balancer could be used
3. Tags can be used to improve resource organization and cost tracking
4. depends_on can be used to be sure to implement resources in the right order
5. Diagnostic tools can be used to troubleshoot any issues
