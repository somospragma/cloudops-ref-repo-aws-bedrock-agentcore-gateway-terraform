# Data sources del módulo
# Según PC-IAC-011, los Data Sources deben residir en el Módulo Raíz (IaC Root).
# Este módulo de referencia NO debe contener Data Sources para recursos externos.
# Cualquier dependencia externa (VPC, Security Groups, IAM Roles) debe ser
# inyectada como variable de entrada desde el módulo consumidor.