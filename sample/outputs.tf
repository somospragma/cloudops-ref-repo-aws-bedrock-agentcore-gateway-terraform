# Outputs del ejemplo

# Información de los gateways creados
output "gateway_arns" {
  description = "ARNs de los gateways creados"
  value       = module.bedrock_agentcore_gateway.gateway_arns
}

output "gateway_ids" {
  description = "IDs de los gateways creados"
  value       = module.bedrock_agentcore_gateway.gateway_ids
}

output "gateway_urls" {
  description = "URLs de endpoints de los gateways"
  value       = module.bedrock_agentcore_gateway.gateway_urls
}

# Información detallada por clave
output "gateway_details" {
  description = "Detalles completos de los gateways por clave"
  value = {
    arns = module.bedrock_agentcore_gateway.gateway_arns_by_key
    ids  = module.bedrock_agentcore_gateway.gateway_ids_by_key
    urls = module.bedrock_agentcore_gateway.gateway_urls_by_key
  }
}

# Información de targets
output "target_ids" {
  description = "IDs de los targets creados"
  value       = module.bedrock_agentcore_gateway.target_ids
}

output "target_ids_by_key" {
  description = "IDs de targets por clave compuesta"
  value       = module.bedrock_agentcore_gateway.target_ids_by_key
}

# Identidades de workload
output "workload_identity_arns" {
  description = "ARNs de las identidades de workload"
  value       = module.bedrock_agentcore_gateway.workload_identity_arns
}

# Información de configuración
output "configuration_summary" {
  description = "Resumen de la configuración desplegada"
  value = {
    client      = var.client
    project     = var.project
    environment = var.environment
    region      = var.region
    gateways_count = length(module.bedrock_agentcore_gateway.gateway_ids)
    targets_count  = length(module.bedrock_agentcore_gateway.target_ids)
  }
}