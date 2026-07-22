# Variables de entrada del módulo

# Variables de Gobernanza (PC-IAC-002) - Obligatorias para nomenclatura y tags
variable "client" {
  type        = string
  description = "Nombre del cliente/unidad de negocio para la construcción de nombres y tags"

  validation {
    condition     = length(var.client) > 0 && length(var.client) <= 10
    error_message = "El cliente debe tener entre 1 y 10 caracteres."
  }
}

variable "project" {
  type        = string
  description = "Nombre del proyecto específico para la construcción de nombres y tags"

  validation {
    condition     = length(var.project) > 0 && length(var.project) <= 15
    error_message = "El proyecto debe tener entre 1 y 15 caracteres."
  }
}

variable "environment" {
  type        = string
  description = "Entorno de despliegue (dev, qa, pdn, prod) para la construcción de nombres y tags"

  validation {
    condition     = contains(["dev", "qa", "pdn", "prod"], var.environment)
    error_message = "El ambiente debe ser uno de: dev, qa, pdn, prod."
  }
}

# Variables de Configuración Principal (PC-IAC-002, PC-IAC-009)
variable "gateways" {
  type = map(object({
    description       = string
    authorizer_type   = string
    protocol_type     = optional(string, "MCP")
    exception_level   = optional(string, "DEBUG")
    enable_encryption = optional(bool, true)

    # Configuración JWT (requerida cuando authorizer_type = "CUSTOM_JWT")
    jwt_config = optional(object({
      discovery_url    = string
      allowed_audience = optional(list(string), [])
      allowed_clients  = optional(list(string), [])
      allowed_scopes   = optional(list(string), [])
      custom_claims = optional(list(object({
        inbound_token_claim_name       = string
        inbound_token_claim_value_type = string # "STRING" o "STRING_ARRAY"
        authorizing_claim_match_value = object({
          claim_match_operator    = string                 # "EQUALS", "CONTAINS", "CONTAINS_ANY"
          match_value_string      = optional(string)       # Para STRING+EQUALS o STRING_ARRAY+CONTAINS
          match_value_string_list = optional(list(string)) # Para STRING_ARRAY+CONTAINS_ANY
        })
      })), [])
    }))

    # Configuración del protocolo MCP
    protocol_config = optional(object({
      instructions       = optional(string)
      search_type        = optional(string, "SEMANTIC")
      supported_versions = optional(list(string), ["2025-03-26"])
    }))

    # Configuración de interceptores
    interceptor_config = optional(object({
      interception_points  = list(string)
      lambda_arn           = string
      pass_request_headers = optional(bool, true)
    }))

    # Targets del gateway
    targets = optional(map(object({
      type        = string # "lambda", "openapi", "smithy", "mcp_server"
      description = optional(string)

      # Para targets Lambda
      lambda_arn = optional(string)

      # Para targets MCP Server
      mcp_endpoint = optional(string)
      listing_mode = optional(string, "DEFAULT") # "DEFAULT" o "DYNAMIC" - Modo de listado para targets MCP Server

      # Para targets OpenAPI/Smithy
      schema_config = optional(object({
        type            = string # "inline" o "s3"
        payload         = optional(string)
        s3_uri          = optional(string)
        s3_bucket_owner = optional(string)
      }))

      # Configuración del proveedor de credenciales
      credential_provider = object({
        type = string # "gateway_iam_role", "api_key", "oauth"

        # Para API Key
        api_key_config = optional(object({
          provider_arn              = string
          credential_location       = optional(string, "HEADER")
          credential_parameter_name = optional(string)
          credential_prefix         = optional(string)
        }))

        # Para OAuth
        oauth_config = optional(object({
          provider_arn       = string
          scopes             = optional(list(string), [])
          grant_type         = optional(string, "CLIENT_CREDENTIALS") # CLIENT_CREDENTIALS, AUTHORIZATION_CODE, TOKEN_EXCHANGE
          custom_parameters  = optional(map(string), {})
          default_return_url = optional(string) # Requerido para AUTHORIZATION_CODE
        }))
      })

      # Configuración de propagación de headers y query parameters
      metadata_configuration = optional(object({
        allowed_request_headers  = optional(list(string), [])
        allowed_response_headers = optional(list(string), [])
        allowed_query_parameters = optional(list(string), [])
      }))

      # Esquema de herramienta (para targets Lambda)
      tool_schema = optional(object({
        type = optional(string, "inline") # "inline" o "s3"

        # Para esquema inline
        name        = optional(string)
        description = optional(string)

        # Esquema de entrada
        input_schema = optional(object({
          type        = string
          description = optional(string)
          properties = optional(list(object({
            name        = string
            type        = string
            description = optional(string)
            required    = optional(bool, false)

            # Para propiedades de tipo array
            items = optional(object({
              type = string
            }))

            # Para propiedades de tipo object (JSON serializado)
            properties_json = optional(string)
            items_json      = optional(string)
          })), [])
        }))

        # Esquema de salida
        output_schema = optional(object({
          type        = string
          description = optional(string)
          properties = optional(list(object({
            name        = string
            type        = string
            description = optional(string)
            required    = optional(bool, false)
          })), [])
        }))

        # Para esquema S3
        s3_uri          = optional(string)
        s3_bucket_owner = optional(string)
      }))

      additional_tags = optional(map(string), {})
    })), {})

    additional_tags = optional(map(string), {})
  }))

  description = "Configuración de los gateways de Bedrock AgentCore a crear"

  validation {
    condition = alltrue([
      for k, v in var.gateways : contains(["CUSTOM_JWT", "AWS_IAM"], v.authorizer_type)
    ])
    error_message = "El tipo de autorizador debe ser 'CUSTOM_JWT' o 'AWS_IAM'."
  }

  validation {
    condition = alltrue([
      for k, v in var.gateways :
      v.authorizer_type != "CUSTOM_JWT" || v.jwt_config != null
    ])
    error_message = "jwt_config es requerido cuando authorizer_type es 'CUSTOM_JWT'."
  }

  validation {
    condition = alltrue([
      for k, v in var.gateways : contains(["MCP"], v.protocol_type)
    ])
    error_message = "El tipo de protocolo debe ser 'MCP'."
  }

  validation {
    condition = alltrue([
      for k, v in var.gateways :
      v.jwt_config == null || alltrue([
        for claim in coalesce(v.jwt_config.custom_claims, []) :
        contains(["STRING", "STRING_ARRAY"], claim.inbound_token_claim_value_type)
      ])
    ])
    error_message = "inbound_token_claim_value_type debe ser 'STRING' o 'STRING_ARRAY'."
  }

  validation {
    condition = alltrue([
      for k, v in var.gateways :
      v.jwt_config == null || alltrue([
        for claim in coalesce(v.jwt_config.custom_claims, []) :
        contains(["EQUALS", "CONTAINS", "CONTAINS_ANY"], claim.authorizing_claim_match_value.claim_match_operator)
      ])
    ])
    error_message = "claim_match_operator debe ser 'EQUALS', 'CONTAINS' o 'CONTAINS_ANY'."
  }

  validation {
    condition = alltrue([
      for k, v in var.gateways : alltrue([
        for tk, tv in coalesce(v.targets, {}) :
        tv.credential_provider.type != "oauth" ||
        tv.credential_provider.oauth_config == null ||
        contains(["CLIENT_CREDENTIALS", "AUTHORIZATION_CODE", "TOKEN_EXCHANGE"], coalesce(tv.credential_provider.oauth_config.grant_type, "CLIENT_CREDENTIALS"))
      ])
    ])
    error_message = "grant_type debe ser 'CLIENT_CREDENTIALS', 'AUTHORIZATION_CODE' o 'TOKEN_EXCHANGE'."
  }

  validation {
    condition = alltrue([
      for k, v in var.gateways : alltrue([
        for tk, tv in coalesce(v.targets, {}) :
        tv.type != "mcp_server" || contains(["DEFAULT", "DYNAMIC"], coalesce(tv.listing_mode, "DEFAULT"))
      ])
    ])
    error_message = "listing_mode debe ser 'DEFAULT' o 'DYNAMIC' para targets de tipo mcp_server."
  }

  validation {
    condition = alltrue([
      for k, v in var.gateways :
      coalesce(try(v.protocol_config.search_type, "SEMANTIC"), "SEMANTIC") != "SEMANTIC" || !anytrue([
        for tk, tv in coalesce(v.targets, {}) :
        tv.type == "mcp_server" && coalesce(tv.listing_mode, "DEFAULT") == "DYNAMIC"
      ])
    ])
    error_message = "Los targets con listing_mode 'DYNAMIC' no son compatibles con search_type 'SEMANTIC'. Cambie search_type del gateway o use listing_mode 'DEFAULT' en los targets MCP server."
  }
}

# Variables de Dependencias Externas (PC-IAC-023)
variable "gateway_role_arn" {
  type        = string
  description = "ARN del rol IAM que el gateway asume para acceder a servicios AWS. Debe ser proporcionado desde el dominio de Seguridad."

  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/.+", var.gateway_role_arn))
    error_message = "El ARN del rol debe tener el formato válido de ARN de IAM role."
  }
}

variable "kms_key_arn" {
  type        = string
  description = "ARN de la clave KMS para cifrar los datos del gateway. Si no se proporciona, se usará la clave administrada por AWS."
  default     = null

  validation {
    condition     = var.kms_key_arn == null || can(regex("^arn:aws:kms:[a-z0-9-]+:[0-9]{12}:key/[a-f0-9-]+", var.kms_key_arn))
    error_message = "El ARN de la clave KMS debe tener el formato válido de ARN de KMS key."
  }
}