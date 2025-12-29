# Valores locales y transformaciones

locals {
  # Prefijo base de gobernanza (PC-IAC-003)
  governance_prefix = "${var.client}-${var.project}-${var.environment}"
  
  # Construcción de nombres para gateways (PC-IAC-003)
  gateway_names = {
    for key, config in var.gateways : key => "${local.governance_prefix}-agentcore-gateway-${key}"
  }
  
  # Etiquetas base del módulo (PC-IAC-004)
  base_module_tags = {
    "managed-by" = "terraform"
    "module"     = "bedrock-agentcore-gateway"
    "service"    = "bedrock-agentcore"
  }
  
  # Transformación de configuración de gateways con valores por defecto (PC-IAC-009)
  gateways_with_defaults = {
    for key, config in var.gateways : key => merge(config, {
      # Aplicar valores por defecto si no están especificados
      protocol_type   = try(config.protocol_type, "MCP")
      exception_level = try(config.exception_level, "ERROR")
      enable_encryption = try(config.enable_encryption, true)
      
      # Configuración del protocolo con valores por defecto
      protocol_config = config.protocol_config != null ? merge({
        search_type        = "SEMANTIC"
        supported_versions = ["2025-03-26"]
      }, config.protocol_config) : null
    })
  }
  
  # Aplanamiento de targets para iteración con for_each (PC-IAC-012)
  all_targets_flat = flatten([
    for gateway_key, gateway_config in local.gateways_with_defaults : [
      for target_key, target_config in gateway_config.targets : {
        gateway_key    = gateway_key
        target_key     = target_key
        gateway_id     = aws_bedrockagentcore_gateway.this[gateway_key].gateway_id
        target_name    = "${local.governance_prefix}-target-${gateway_key}-${target_key}"
        config         = target_config
      }
    ]
  ])
  
  # Mapa de targets para for_each (PC-IAC-010)
  targets_map = {
    for target in local.all_targets_flat : 
    "${target.gateway_key}-${target.target_key}" => target
  }
}