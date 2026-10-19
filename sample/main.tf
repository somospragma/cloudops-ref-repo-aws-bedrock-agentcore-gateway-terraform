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
      description       = "Gateway principal para agentes AI con autorización JWT"
      authorizer_type   = "CUSTOM_JWT"
      protocol_type     = "MCP"
      exception_level   = "DEBUG"
      enable_encryption = true

      # Configuración JWT
      jwt_config = {
        discovery_url    = var.jwt_discovery_url
        allowed_audience = var.jwt_allowed_audience
        allowed_clients  = var.jwt_allowed_clients
        allowed_scopes   = ["read", "write", "admin"]
        custom_claims = [
          {
            inbound_token_claim_name       = "department"
            inbound_token_claim_value_type = "STRING"
            authorizing_claim_match_value = {
              claim_match_operator    = "EQUALS"
              match_value_string      = "engineering"
              match_value_string_list = null
            }
          },
          {
            inbound_token_claim_name       = "roles"
            inbound_token_claim_value_type = "STRING_ARRAY"
            authorizing_claim_match_value = {
              claim_match_operator    = "CONTAINS_ANY"
              match_value_string      = null
              match_value_string_list = ["admin", "developer"]
            }
          }
        ]
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
      description       = "Gateway secundario con autorización IAM"
      authorizer_type   = "AWS_IAM"
      protocol_type     = "MCP"
      enable_encryption = false

      # Sin configuración JWT para autorización IAM
      jwt_config = null

      # Configuración básica del protocolo
      # Omitir search_type permite usar targets con listing_mode "DYNAMIC"
      protocol_config = {
        instructions       = "Gateway secundario para pruebas con listado dinámico"
        supported_versions = ["2025-03-26"]
      }

      # Targets con diferentes modos de listado
      targets = {
        # Target MCP Server con listado dinámico (descubrimiento en tiempo real)
        dynamic_mcp = {
          type         = "mcp_server"
          description  = "MCP server con listado dinámico - herramientas personalizadas por usuario"
          mcp_endpoint = "https://mcp.internal.example.com/mcp"
          listing_mode = "DYNAMIC"

          credential_provider = {
            type = "gateway_iam_role"
          }
        }
      }

      additional_tags = {
        Purpose = "Testing"
        Type    = "Secondary"
      }
    }

    # Gateway con sesiones MCP habilitadas (retorna el header Mcp-Session-Id)
    sessions = {
      description       = "Gateway con sesiones MCP habilitadas y streaming de respuesta"
      authorizer_type   = "AWS_IAM"
      protocol_type     = "MCP"
      enable_encryption = false

      # Sin configuración JWT para autorización IAM
      jwt_config = null

      # Configuración del protocolo con sesiones y streaming
      protocol_config = {
        instructions       = "Gateway con estado de sesión y streaming de respuesta"
        supported_versions = ["2025-03-26", "2025-06-18"]

        # Al habilitar sesiones, el gateway genera y retorna el header Mcp-Session-Id
        # en el primer initialize. Rango del timeout: 900-28800 segundos (default 3600).
        session_configuration = {
          session_timeout_in_seconds = 3600
        }

        # Requerido para elicitation/sampling
        streaming_configuration = {
          enable_response_streaming = true
        }
      }

      targets = {
        # Target MCP Server con sesiones
        session_tools = {
          type         = "mcp_server"
          description  = "Servidor MCP con sesiones habilitadas"
          mcp_endpoint = "https://mcp.internal.example.com/mcp"

          credential_provider = {
            type = "gateway_iam_role"
          }

          # IMPORTANTE: con sesiones habilitadas NO se debe incluir Mcp-Session-Id
          # en metadata_configuration; AWS lo gestiona internamente (HTTP 400 en caso contrario).
          metadata_configuration = {
            allowed_request_headers  = ["Authorization"]
            allowed_response_headers = []
          }
        }
      }

      additional_tags = {
        Purpose = "Sessions"
        Type    = "Sessions"
      }
    }
  }

  # Dependencias externas (PC-IAC-023)
  gateway_role_arn = data.aws_iam_role.gateway_role.arn
  kms_key_arn      = var.kms_key_id != null ? data.aws_kms_key.gateway_key[0].arn : null
}