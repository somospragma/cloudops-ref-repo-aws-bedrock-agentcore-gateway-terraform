# Requisitos de versión de Terraform y providers
terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 4.31.0"
      configuration_aliases = [aws.project] # Alias consumidor obligatorio (PC-IAC-005)
    }
  }
}