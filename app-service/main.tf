# main.tf

# Define input variables
variable "resource_group_name" {
  description = "The name of the resource group in which to create the Azure App Service"
}

variable "app_service_name" {
  description = "The name of the Azure App Service to create"
}

variable "location" {
  description = "The Azure region in which to create the resources"
}

variable "virtual_network_id" {
  description = "The ID of the Virtual Network in which to deploy the Azure App Service"
}

# Define the Azure App Service resource
resource "azurerm_app_service" "app_service" {
  name                = var.app_service_name
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id

  site_config {
    always_on = true
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }

  # Enable staging slots
  site_config {
    app_command_line = "dotnet %s -- %s"
    use_64_bit_worker_process = true
    websockets_enabled = false

    # Staging slots configuration
    app_setting = {
      "STAGING_ENABLED" = "true"
      "STAGING_ALLOW_WHEN_SLOT_IS_ACTIVE" = "false"
    }
  }

  depends_on = [azurerm_app_service_plan.app_service_plan]
}

# Define the Azure App Service Plan resource
resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "${var.app_service_name}-plan"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

# Assign the Azure App Service to the Virtual Network
resource "azurerm_web_app_virtual_network_swift_connection" "app_vnet_connection" {
  app_service_id          = azurerm_app_service.app_service.id
  virtual_network_id      = var.virtual_network_id
  swift_connection_name   = "${var.app_service_name}-vnet-connection"
  subnet_name             = "default"
}

# outputs.tf

output "app_service_endpoint" {
  description = "The endpoint URL of the Azure App Service"
  value       = azurerm_app_service.app_service.default_site_hostname
}


