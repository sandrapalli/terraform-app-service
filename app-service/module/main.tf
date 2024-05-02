##main.tf
# Terraform Module: Azure App Service within Virtual Network

This Terraform module deploys an Azure App Service within a Virtual Network, ensuring the setup includes staging slots and adheres to best practices in code reusability and documentation.

## Usage

module "azure_app_service" {
  source              = "./modules/azure_app_service"
  resource_group_name = "app-service-rg"
  app_service_name    = "sample-app-service"
  location            = "East US"
  virtual_network_id  = "virtual_network_id"
}
