# Azure Virtual Machine Deployment with Terraform and Jenkins CI/CD

This repository contains Terraform infrastructure as code (IaC) for deploying a Linux virtual machine on Microsoft Azure, integrated with Jenkins CI/CD pipeline for automated deployment.

## 🏗️ Architecture

The infrastructure creates the following Azure resources:

- **Resource Group**: Container for all resources
- **Virtual Network**: Network with address space `10.0.0.0/16`
- **Subnet**: Subnet with address range `10.0.1.0/24`
- **Public IP**: Dynamic public IP for VM access
- **Network Security Group (NSG)**: Security rules allowing SSH access (port 22)
- **Network Interface**: Connects VM to the network
- **Linux Virtual Machine**: Ubuntu 22.04 LTS VM (Standard_B1s)

## 📋 Prerequisites

### Local Development
- [Terraform](https://www.terraform.io/downloads.html) >= 1.1.3
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- Azure subscription with appropriate permissions

### Jenkins CI/CD
- Jenkins server with Azure CLI installed
- Azure Service Principal credentials configured in Jenkins
- GitHub SSH credentials for code checkout

## 🔧 Configuration

### Required Variables

The Terraform configuration requires the following Azure credentials (configured via environment variables or Jenkins credentials):

- `AZURE_SUBSCRIPTION_ID`: Your Azure subscription ID
- `AZURE_CLIENT_ID`: Service Principal client ID
- `AZURE_CLIENT_SECRET`: Service Principal client secret
- `AZURE_TENANT_ID`: Azure Active Directory tenant ID

### Customizable Variables

- `resource_group_location`: Azure region (default: "West Europe")

## 🚀 Usage

### Manual Deployment

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Azure-Virtual-Machine-Deploy-using-Terraform-with-Jenkins-CI-CD
   ```

2. **Set up Azure credentials**
   ```bash
   export ARM_SUBSCRIPTION_ID="your-subscription-id"
   export ARM_CLIENT_ID="your-client-id"
   export ARM_CLIENT_SECRET="your-client-secret"
   export ARM_TENANT_ID="your-tenant-id"
   ```

3. **Initialize and deploy**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

### Jenkins CI/CD Pipeline

The Jenkins pipeline (`Jenkinsfile`) automates the deployment process:

1. **Build Stage**: Authenticates with Azure using service principal
2. **Checkout Stage**: Pulls code from GitHub repository
3. **Deploy Stage**: Runs Terraform commands to deploy infrastructure

#### Jenkins Configuration

1. **Create Service Principal** in Azure:
   ```bash
   az ad sp create-for-rbac --name "jenkins-terraform-sp" --role Contributor --scopes /subscriptions/{subscription-id}
   ```

2. **Configure Jenkins Credentials**:
   - Add Azure Service Principal credentials with ID `jenkins-test-sp`
   - Add GitHub SSH credentials with ID `github-ssh`

3. **Update Jenkinsfile**:
   - Modify the GitHub repository URL in the checkout stage
   - Update the branch name if needed

## 📁 File Structure

```
├── main.tf              # Main Terraform configuration
├── variables.tf         # Variable definitions
├── providers.tf         # Provider configuration
├── outputs.tf           # Output values
├── Jenkinsfile          # Jenkins CI/CD pipeline
└── README.md           # This documentation
```

## 🔍 Key Resources

### Virtual Machine Specifications
- **OS**: Ubuntu Server 22.04 LTS
- **Size**: Standard_B1s (1 vCPU, 1 GB RAM)
- **Storage**: Standard_LRS (Locally Redundant Storage)
- **Authentication**: SSH key-based (password disabled)

### Network Configuration
- **VNet Address Space**: 10.0.0.0/16
- **Subnet Range**: 10.0.1.0/24
- **Public IP**: Dynamic allocation
- **Security**: SSH (port 22) access allowed from any source

## 📤 Outputs

After successful deployment, Terraform provides:

- `resource_group_name`: Name of the created resource group
- `public_ip_address`: Public IP address of the virtual machine

## 🔒 Security Considerations

- SSH access is open to all sources (`0.0.0.0/0`) - consider restricting this in production
- Service Principal credentials should be stored securely in Jenkins
- Consider using Azure Key Vault for sensitive configuration

## 🧹 Cleanup

To destroy the infrastructure:

```bash
terraform destroy
```

Or through Jenkins pipeline by adding a destroy stage.

## 📝 Notes

- The VM is created without SSH keys - you'll need to add them for access
- All resources use basic naming convention with "basic-terraform-" prefix
- The configuration is designed for development/testing purposes

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the deployment
5. Submit a pull request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
