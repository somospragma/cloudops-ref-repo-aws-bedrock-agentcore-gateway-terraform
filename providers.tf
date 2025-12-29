# Configuración de providers
# Según PC-IAC-005, el provider se inyecta desde el Módulo Raíz (IaC Root)
# utilizando el alias 'aws.project'. Este módulo NO debe declarar su propio
# bloque provider, sino consumir el inyectado desde el Root.