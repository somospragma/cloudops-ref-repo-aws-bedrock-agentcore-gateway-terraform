# Outputs del módulo

# ARNs de los gateways creados (PC-IAC-007)
output "gateway_arns" {
  description = "ARNs de los gateways de Bedrock AgentCore creados"
  value       = values(aws_bedrockagentcore_gateway.this)[*].gateway_arn
}

# IDs únicos de los gateways (PC-IAC-007)
output "gateway_ids" {
  description = "IDs únicos de los gateways de Bedrock AgentCore creados"
  value       = values(aws_bedrockagentcore_gateway.this)[*].gateway_id
}

# URLs de endpoints de los gateways (PC-IAC-007)
output "gateway_urls" {
  description = "URLs de endpoints de los gateways de Bedrock AgentCore"
  value       = values(aws_bedrockagentcore_gateway.this)[*].gateway_url
}

# Mapa de ARNs por clave de gateway (PC-IAC-007)
output "gateway_arns_by_key" {
  description = "Mapa de ARNs de gateways indexados por clave de configuración"
  value = {
    for key, gateway in aws_bedrockagentcore_gateway.this : key => gateway.gateway_arn
  }
}

# Mapa de IDs por clave de gateway (PC-IAC-007)
output "gateway_ids_by_key" {
  description = "Mapa de IDs de gateways indexados por clave de configuración"
  value = {
    for key, gateway in aws_bedrockagentcore_gateway.this : key => gateway.gateway_id
  }
}

# Mapa de URLs por clave de gateway (PC-IAC-007)
output "gateway_urls_by_key" {
  description = "Mapa de URLs de gateways indexados por clave de configuración"
  value = {
    for key, gateway in aws_bedrockagentcore_gateway.this : key => gateway.gateway_url
  }
}

# IDs de los targets creados (PC-IAC-007, PC-IAC-014)
output "target_ids" {
  description = "IDs de los targets de gateway creados"
  value       = values(aws_bedrockagentcore_gateway_target.this)[*].target_id
}

# Mapa de IDs de targets por clave compuesta (PC-IAC-007)
output "target_ids_by_key" {
  description = "Mapa de IDs de targets indexados por clave compuesta (gateway-target)"
  value = {
    for key, target in aws_bedrockagentcore_gateway_target.this : key => target.target_id
  }
}

# Detalles de identidad de workload (PC-IAC-007)
output "workload_identity_arns" {
  description = "ARNs de las identidades de workload de los gateways"
  value = {
    for key, gateway in aws_bedrockagentcore_gateway.this : 
    key => gateway.workload_identity_details[0].workload_identity_arn
  }
}