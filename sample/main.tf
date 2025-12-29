# Invocación del módulo de Bedrock AgentCore Gateway

module "bedrock_agentcore_gateway" {
  source = "../" # Referencia al módulo padre
  
  # Inyección del provider (PC-IAC-005)
  providers = {
    aws.project = aws.principal
  }
  
  # Variables de Gobernanza (PC-IAC-003)
  client      = var.client
  project     = var.project
  environment = var.environment
  
  # Configuración de Gateways
  gateways = {
    # Gateway principal con autorización JWT
    main = {
      description     = "Gateway principal para agentes AI con autorización JWT"
      authorizer_type = "CUSTOM_JWT"
      protocol_type   = "MCP"
      exception_level = "ERROR"
      enable_encryption = true
      
      # Configuración JWT
      jwt_config = {
        discovery_url    = var.jwt_discovery_url
        allowed_audience = var.jwt_allowed_audience
        allowed_clients  = var.jwt_allowed_clients
      }
      
      # Configuración del protocolo MCP
      protocol_config = {
        instructions       = "Gateway para manejo de solicitudes MCP de agentes AI"
        search_type        = "SEMANTIC"
        supported_versions = ["2025-03-26", "2025-06-18"]
      }
      
      # Targets del gateway
      targets = {
        # Target Lambda para procesamiento
        lambda_processor = {
          type        = "lambda"
          description = "Procesador de solicitudes Lambda"
          lambda_arn  = data.aws_lambda_function.processor.arn
          
          # Configuración del proveedor de credenciales
          credential_provider = {
            type = "gateway_iam_role"
          }
          
          # Esquema de herramienta
          tool_schema = {
            name        = "process_request"
            description = "Procesa solicitudes entrantes de agentes AI"
            
            # Esquema de entrada
            input_schema = {
              type        = "object"
              description = "Esquema de procesamiento de solicitudes"
              properties = [
                {
                  name        = "message"
                  type        = "string"
                  description = "Mensaje a procesar"
                  required    = true
                },
                {
                  name        = "priority"
                  type        = "string"
                  description = "Prioridad del procesamiento"
                  required    = false
                },
                {
                  name        = "options"
                  type        = "object"
                  description = "Opciones adicionales de procesamiento"
                  required    = false
                  properties_json = jsonencode({
                    properties = {
                      "timeout" = { type = "number" }
                      "retry"   = { type = "boolean" }
                    }
                  })
                }
              ]
            }
            
            # Esquema de salida
            output_schema = {
              type        = "object"
              description = "Resultado del procesamiento"
              properties = [
                {
                  name        = "status"
                  type        = "string"
                  description = "Estado del procesamiento"
                  required    = true
                },
                {
                  name        = "result"
                  type        = "string"
                  description = "Resultado del procesamiento"
                  required    = false
                },
                {
                  name        = "timestamp"
                  type        = "string"
                  description = "Timestamp del procesamiento"
                  required    = true
                }
              ]
            }
          }
          
          additional_tags = {
            TargetType = "Lambda"
            Function   = "RequestProcessor"
          }
        }
      }
      
      additional_tags = var.additional_tags
    }
    
    # Gateway secundario con autorización IAM (ejemplo adicional)
    secondary = {
      description     = "Gateway secundario con autorización IAM"
      authorizer_type = "AWS_IAM"
      protocol_type   = "MCP"
      exception_level = "WARN"
      enable_encryption = false
      
      # Sin configuración JWT para autorización IAM
      jwt_config = null
      
      # Configuración básica del protocolo
      protocol_config = {
        instructions       = "Gateway secundario para pruebas"
        search_type        = "SEMANTIC"
        supported_versions = ["2025-03-26"]
      }
      
      # Targets vacíos para este ejemplo
      targets = {}
      
      additional_tags = {
        Purpose = "Testing"
        Type    = "Secondary"
      }
    }
  }
  
  # Dependencias externas (PC-IAC-023)
  gateway_role_arn = data.aws_iam_role.gateway_role.arn
  kms_key_arn      = var.kms_key_id != null ? data.aws_kms_key.gateway_key[0].arn : null
}