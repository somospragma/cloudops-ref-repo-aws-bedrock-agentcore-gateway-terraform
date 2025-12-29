# Data sources necesarios para el ejemplo

# Obtener información de la región actual
data "aws_region" "current" {}

# Obtener información de la cuenta actual
data "aws_caller_identity" "current" {}

# Buscar el rol IAM para el gateway (debe existir previamente)
data "aws_iam_role" "gateway_role" {
  name = var.gateway_role_name
}

# Buscar la función Lambda que actuará como target (debe existir previamente)
data "aws_lambda_function" "processor" {
  function_name = var.lambda_function_name
}

# Buscar la clave KMS si se especifica (opcional)
data "aws_kms_key" "gateway_key" {
  count  = var.kms_key_id != null ? 1 : 0
  key_id = var.kms_key_id
}