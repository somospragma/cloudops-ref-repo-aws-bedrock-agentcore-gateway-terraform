# Recursos principales del módulo

# Amazon Bedrock AgentCore Gateway (PC-IAC-010, PC-IAC-020, PC-IAC-023)
resource "aws_bedrockagentcore_gateway" "this" {
  provider = aws.project # Referencia explícita al alias (PC-IAC-005)
  
  for_each = local.gateways_with_defaults # Uso de for_each para estabilidad (PC-IAC-010)
  
  # Configuración básica
  name        = local.gateway_names[each.key]
  description = each.value.description
  role_arn    = var.gateway_role_arn
  
  # Configuración de autorización
  authorizer_type = each.value.authorizer_type
  
  # Configuración JWT (condicional)
  dynamic "authorizer_configuration" {
    for_each = each.value.authorizer_type == "CUSTOM_JWT" && each.value.jwt_config != null ? [each.value.jwt_config] : []
    
    content {
      custom_jwt_authorizer {
        discovery_url    = authorizer_configuration.value.discovery_url
        allowed_audience = authorizer_configuration.value.allowed_audience
        allowed_clients  = authorizer_configuration.value.allowed_clients
      }
    }
  }
  
  # Configuración del protocolo
  protocol_type = each.value.protocol_type
  
  # Configuración del protocolo MCP (condicional)
  dynamic "protocol_configuration" {
    for_each = each.value.protocol_config != null ? [each.value.protocol_config] : []
    
    content {
      mcp {
        instructions       = protocol_configuration.value.instructions
        search_type        = protocol_configuration.value.search_type
        supported_versions = protocol_configuration.value.supported_versions
      }
    }
  }
  
  # Configuración de interceptores (condicional)
  dynamic "interceptor_configuration" {
    for_each = each.value.interceptor_config != null ? [each.value.interceptor_config] : []
    
    content {
      interception_points = interceptor_configuration.value.interception_points
      
      interceptor {
        lambda {
          arn = interceptor_configuration.value.lambda_arn
        }
      }
      
      input_configuration {
        pass_request_headers = interceptor_configuration.value.pass_request_headers
      }
    }
  }
  
  # Seguridad: Cifrado en reposo (PC-IAC-020)
  kms_key_arn = each.value.enable_encryption ? var.kms_key_arn : null
  
  # Configuración de excepciones
  exception_level = each.value.exception_level
  
  # Etiquetas (PC-IAC-004)
  tags = merge(
    { Name = local.gateway_names[each.key] }, # Etiqueta Name explícita
    local.base_module_tags,                   # Tags base del módulo
    each.value.additional_tags                # Tags adicionales del usuario
  )
  
  # Ciclo de vida para proteger recursos críticos (PC-IAC-010)
  lifecycle {
    prevent_destroy = true # Protección contra eliminación accidental
  }
}

# Gateway Targets (PC-IAC-010, PC-IAC-014, PC-IAC-023)
resource "aws_bedrockagentcore_gateway_target" "this" {
  provider = aws.project # Referencia explícita al alias (PC-IAC-005)
  
  for_each = local.targets_map # Uso de for_each para estabilidad (PC-IAC-010)
  
  # Configuración básica
  name               = each.value.target_name
  description        = each.value.config.description
  gateway_identifier = each.value.gateway_id
  
  # Configuración del proveedor de credenciales (PC-IAC-014)
  dynamic "credential_provider_configuration" {
    for_each = each.value.config.credential_provider.type != null ? [each.value.config.credential_provider] : []
    
    content {
      # Gateway IAM Role
      dynamic "gateway_iam_role" {
        for_each = credential_provider_configuration.value.type == "gateway_iam_role" ? [1] : []
        content {}
      }
      
      # API Key
      dynamic "api_key" {
        for_each = credential_provider_configuration.value.type == "api_key" && credential_provider_configuration.value.api_key_config != null ? [credential_provider_configuration.value.api_key_config] : []
        
        content {
          provider_arn              = api_key.value.provider_arn
          credential_location       = api_key.value.credential_location
          credential_parameter_name = api_key.value.credential_parameter_name
          credential_prefix         = api_key.value.credential_prefix
        }
      }
      
      # OAuth
      dynamic "oauth" {
        for_each = credential_provider_configuration.value.type == "oauth" && credential_provider_configuration.value.oauth_config != null ? [credential_provider_configuration.value.oauth_config] : []
        
        content {
          provider_arn      = oauth.value.provider_arn
          scopes           = oauth.value.scopes
          custom_parameters = oauth.value.custom_parameters
        }
      }
    }
  }
  
  # Configuración del target (PC-IAC-014)
  target_configuration {
    mcp {
      # Target Lambda
      dynamic "lambda" {
        for_each = each.value.config.type == "lambda" ? [each.value.config] : []
        
        content {
          lambda_arn = lambda.value.lambda_arn
          
          # Esquema de herramienta
          dynamic "tool_schema" {
            for_each = lambda.value.tool_schema != null ? [lambda.value.tool_schema] : []
            
            content {
              # Esquema inline
              dynamic "inline_payload" {
                for_each = tool_schema.value.type == "inline" || tool_schema.value.type == null ? [tool_schema.value] : []
                
                content {
                  name        = inline_payload.value.name
                  description = inline_payload.value.description
                  
                  # Esquema de entrada
                  dynamic "input_schema" {
                    for_each = inline_payload.value.input_schema != null ? [inline_payload.value.input_schema] : []
                    
                    content {
                      type        = input_schema.value.type
                      description = input_schema.value.description
                      
                      # Propiedades del esquema
                      dynamic "property" {
                        for_each = input_schema.value.properties != null ? input_schema.value.properties : []
                        
                        content {
                          name        = property.value.name
                          type        = property.value.type
                          description = property.value.description
                          required    = property.value.required
                          
                          # Items para arrays
                          dynamic "items" {
                            for_each = property.value.items != null ? [property.value.items] : []
                            
                            content {
                              type = items.value.type
                            }
                          }
                          
                          # JSON serializado para estructuras complejas
                          # properties_json = property.value.properties_json
                          # items_json     = property.value.items_json
                        }
                      }
                    }
                  }
                  
                  # Esquema de salida
                  dynamic "output_schema" {
                    for_each = inline_payload.value.output_schema != null ? [inline_payload.value.output_schema] : []
                    
                    content {
                      type        = output_schema.value.type
                      description = output_schema.value.description
                      
                      # Propiedades del esquema de salida
                      dynamic "property" {
                        for_each = output_schema.value.properties != null ? output_schema.value.properties : []
                        
                        content {
                          name        = property.value.name
                          type        = property.value.type
                          description = property.value.description
                          required    = property.value.required
                        }
                      }
                    }
                  }
                }
              }
              
              # Esquema S3
              dynamic "s3" {
                for_each = tool_schema.value.type == "s3" ? [tool_schema.value] : []
                
                content {
                  uri                      = s3.value.s3_uri
                  bucket_owner_account_id  = s3.value.s3_bucket_owner
                }
              }
            }
          }
        }
      }
      
      # Target MCP Server
      dynamic "mcp_server" {
        for_each = each.value.config.type == "mcp_server" ? [each.value.config] : []
        
        content {
          endpoint = mcp_server.value.mcp_endpoint
        }
      }
      
      # Target OpenAPI
      dynamic "open_api_schema" {
        for_each = each.value.config.type == "openapi" ? [each.value.config] : []
        
        content {
          # Esquema inline
          dynamic "inline_payload" {
            for_each = open_api_schema.value.schema_config != null && open_api_schema.value.schema_config.type == "inline" ? [open_api_schema.value.schema_config] : []
            
            content {
              payload = inline_payload.value.payload
            }
          }
          
          # Esquema S3
          dynamic "s3" {
            for_each = open_api_schema.value.schema_config != null && open_api_schema.value.schema_config.type == "s3" ? [open_api_schema.value.schema_config] : []
            
            content {
              uri                      = s3.value.s3_uri
              bucket_owner_account_id  = s3.value.s3_bucket_owner
            }
          }
        }
      }
      
      # Target Smithy Model
      dynamic "smithy_model" {
        for_each = each.value.config.type == "smithy" ? [each.value.config] : []
        
        content {
          # Esquema inline
          dynamic "inline_payload" {
            for_each = smithy_model.value.schema_config != null && smithy_model.value.schema_config.type == "inline" ? [smithy_model.value.schema_config] : []
            
            content {
              payload = inline_payload.value.payload
            }
          }
          
          # Esquema S3
          dynamic "s3" {
            for_each = smithy_model.value.schema_config != null && smithy_model.value.schema_config.type == "s3" ? [smithy_model.value.schema_config] : []
            
            content {
              uri                      = s3.value.s3_uri
              bucket_owner_account_id  = s3.value.s3_bucket_owner
            }
          }
        }
      }
    }
  }
  
  # Dependencia explícita del gateway
  depends_on = [aws_bedrockagentcore_gateway.this]
}