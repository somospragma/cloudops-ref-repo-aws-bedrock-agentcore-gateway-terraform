# Ejemplo de Uso del Módulo Bedrock AgentCore Gateway

Este directorio contiene un ejemplo funcional de cómo usar el módulo de Bedrock AgentCore Gateway.

## Prerrequisitos

1. **Rol IAM**: Crear un rol IAM con los permisos necesarios para Bedrock AgentCore
2. **Función Lambda**: Crear una función Lambda que actuará como target del gateway
3. **Clave KMS** (opcional): Para cifrado personalizado
4. **Configuración JWT**: Configurar un proveedor de identidad JWT si se usa autorización personalizada

## Configuración del Rol IAM

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "bedrock-agentcore.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

## Ejecución del Ejemplo

1. **Configurar variables**: Editar `terraform.tfvars` con los valores específicos de tu entorno
2. **Inicializar Terraform**: 
   ```bash
   terraform init
   ```
3. **Planificar despliegue**:
   ```bash
   terraform plan
   ```
4. **Aplicar configuración**:
   ```bash
   terraform apply
   ```

## Limpieza

Para eliminar los recursos creados:

```bash
terraform destroy
```

## Estructura de Archivos

- `main.tf`: Invocación del módulo con configuración de ejemplo
- `variables.tf`: Variables necesarias para el ejemplo
- `terraform.tfvars`: Valores de ejemplo (personalizar según tu entorno)
- `providers.tf`: Configuración del provider AWS
- `outputs.tf`: Outputs que muestran los resultados del módulo
- `data.tf`: Data sources necesarios para el ejemplo