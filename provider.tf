terraform {

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.71.0"
    }
  }
}
provider "azurerm" {
  features {}
  subscription_id = "d1628de0-f424-48b6-b5f9-194ee0354cad"
}
