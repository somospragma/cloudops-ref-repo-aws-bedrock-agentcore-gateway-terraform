# Variables del ejemplo

# Variables de Gobernanza
variable "client" {
  type        = string
  description = "Nombre del cliente/unidad de negocio"
}

variable "project" {
  type        = string
  description = "Nombre del proyecto específico"
}

variable "environment" {
  type        = string
  description = "Entorno de despliegue (dev, qa, pdn)"
}

# Variables de Configuración AWS
variable "region" {
  type        = string
  description = "Región de AWS donde desplegar los recursos"
  default     = "us-east-1"
}

# Variables de Dependencias Externas
variable "gateway_role_name" {
  type        = string
  description = "Nombre del rol IAM existente para el gateway"
}

variable "lambda_function_name" {
  type        = string
  description = "Nombre de la función Lambda existente que actuará como target"
}

variable "kms_key_id" {
  type        = string
  description = "ID de la clave KMS existente para cifrado (opcional)"
  default     = null
}

# Variables de Configuración JWT
variable "jwt_discovery_url" {
  type        = string
  description = "URL de descubrimiento para configuración JWT"
  default     = "https://accounts.google.com/.well-known/openid-configuration"
}

variable "jwt_allowed_audience" {
  type        = list(string)
  description = "Audiencias permitidas para tokens JWT"
  default     = ["test-client"]
}

variable "jwt_allowed_clients" {
  type        = list(string)
  description = "Clientes permitidos para tokens JWT"
  default     = ["client-123"]
}

# Tags adicionales
variable "additional_tags" {
  type        = map(string)
  description = "Tags adicionales para aplicar a los recursos"
  default = {
    Purpose = "Example"
    Team    = "DevOps"
  }
}