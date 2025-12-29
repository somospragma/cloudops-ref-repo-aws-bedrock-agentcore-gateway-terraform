# Configuración de providers para el ejemplo

terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.20.0"
    }
  }
}

# Provider principal con configuración de tags por defecto
provider "aws" {
  alias  = "principal"
  region = var.region
  
  # Tags por defecto aplicados a todos los recursos (PC-IAC-004)
  default_tags {
    tags = {
      Client      = var.client
      Project     = var.project
      Environment = var.environment
      Owner       = "DevOps-Team"
      CostCenter  = "IT-Infrastructure"
      ManagedBy   = "Terraform"
    }
  }
}