# Requisitos de versión de Terraform y providers
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 6.50.0"   # listing_mode (6.50.0), session_configuration (6.49.0), gateway/target (6.17.0)
      configuration_aliases = [aws.project] # Alias consumidor obligatorio (PC-IAC-005)
    }
  }
}