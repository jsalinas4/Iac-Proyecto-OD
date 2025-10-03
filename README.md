# Infraestructura Clínica Odontológica (AWS + Terraform)

Este proyecto utiliza los siguientes servicios de AWS:

- **Amazon S3** → Almacenamiento de la aplicación web (frontend).  
- **Amazon CloudFront** → CDN para distribuir el frontend con baja latencia y SSL.  
- **Amazon Route53** → Manejo de dominio y DNS.  
- **Amazon EC2 (Auto Scaling Group)** → Servidores de aplicación en mínimo 2 instancias.  
- **Elastic Load Balancer (ALB)** → Balanceo de carga del backend.  
- **Amazon RDS (PostgreSQL o Aurora)** → Base de datos relacional para pacientes, citas y expedientes.



## ⚙️ Requisitos

- Terraform instalado
- Credenciales de AWS configuradas

---

## Pasos para ejecutar Terraform

**Clonar el repositorio**
   ```bash
   git clone https://github.com/jsalinas4/Iac-Proyecto-OD
   cd terraform
   terraform init
   terraform plan
   terraform apply
