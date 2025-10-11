Infraestructura como Código para Plataforma de Clínica Odontológica en AWS

1. Descripción General
Este repositorio contiene el código Terraform para el aprovisionamiento y la gestión de la infraestructura en AWS para una plataforma web de una clínica odontológica. El objetivo principal es establecer una arquitectura robusta, segura y escalable, aplicando las mejores prácticas de Infraestructura como Código (IaC).
La solución despliega una aplicación de tres capas, separando la presentación (frontend), la lógica de negocio (backend) y la persistencia de datos (base de datos) para mejorar la seguridad, el mantenimiento y la escalabilidad de cada componente de forma independiente.

________________________________________

2. Arquitectura General
La infraestructura se despliega dentro de una VPC personalizada (10.0.0.0/16) que aísla los recursos en subredes públicas y privadas. Este diseño garantiza que los componentes críticos, como la base de datos y los servidores de aplicación, no estén expuestos directamente a Internet.
•	Frontend: Una aplicación web estática alojada en un bucket de Amazon S3. El contenido se distribuye a través de Amazon CloudFront para optimizar la latencia y securizar la comunicación mediante HTTPS. El acceso está geográficamente restringido para permitir únicamente a usuarios desde Perú.
•	Backend: La aplicación de backend, como una API REST desarrollada en Spring Boot, se ejecuta en instancias Amazon EC2 (t3.medium) gestionadas por un Grupo de Autoescalado. Esto garantiza una alta disponibilidad con un mínimo de 2 instancias y la capacidad de escalar hasta 4 en momentos de alta demanda.
•	Red y Aislamiento: Una VPC personalizada con subredes públicas para los recursos de cara al público (ALB) y subredes privadas para los servidores de aplicación y la base de datos. La comunicación entre capas está estrictamente controlada por Grupos de Seguridad.
•	Balanceo de Carga: Un Application Load Balancer (ALB) se ubica en las subredes públicas y distribuye el tráfico HTTP entrante en el puerto 80 hacia el grupo de destino (Target Group) que agrupa las instancias EC2, las cuales escuchan en el puerto 8080.
•	Base de Datos: La solución está diseñada para integrarse con un servicio de base de datos relacional como Amazon RDS, el cual se ejecutaría en subredes privadas. Su grupo de seguridad está configurado para aceptar conexiones únicamente desde las instancias del backend a través del puerto 5432.
•	Autenticación: Amazon Cognito proporciona un servicio gestionado para el registro, inicio de sesión y administración de usuarios. Se configura un User Pool con una política de contraseñas segura (mínimo 8 caracteres, mayúsculas, minúsculas y números) y un cliente de aplicación para integrar con el frontend.
Diagrama de Flujo de Red
      Usuarios (Desde Perú)
         │
         ▼
[ Amazon CloudFront ] ◄───── Redirección a HTTPS, Cacheo de contenido
         │
         ▼
[ Bucket S3 (Frontend) ] ◄─── Alojamiento de sitio web estático
         │
         └─ (Llamadas API)
               │
               ▼
[ Application Load Balancer (ALB) ] ◄─── Puerto 80 (público)
         │      └─ Security Group: Permite todo el tráfico entrante en el puerto 80
         ▼
[ Grupo de Autoescalado EC2 (Backend) ] ◄─── Puerto 8080 (privado)
         │      └─ Security Group: Permite tráfico desde el ALB en el puerto 8080
         ▼
[ Amazon RDS (Base de Datos) ] ◄─── Puerto 5432 (privado)
               └─ Security Group: Permite tráfico desde las EC2 en el puerto 5432
   
________________________________________

3. Estructura del Repositorio
El código está organizado modularmente para facilitar su comprensión y mantenimiento.
.
├── terraform/
│   ├── main.tf         # Configuración del proveedor de AWS y versión (~> 6.0)
│   ├── variables.tf    # Variables de entrada (región, nombre del proyecto)
│   ├── network.tf      # Recursos de red (VPC, Subredes, Grupos de Seguridad)
│   ├── alb.tf          # Application Load Balancer, Listener y Target Group
│   ├── ec2.tf          # Launch Template y Auto Scaling Group para el backend
│   ├── s3.tf           # Bucket S3 y política para el frontend
│   ├── cloudfront.tf   # Distribución de CloudFront y Control de Acceso de Origen
│   └── cognito.tf      # User Pool y App Client de Cognito
├── .gitignore          # Archivos y carpetas ignorados por Git (.tfstate, .tfvars)
└── README.md           # Este documento

________________________________________

4. Servicios de AWS Utilizados
•	Amazon S3: Almacena y sirve los archivos estáticos (HTML, CSS, JS) del frontend de la aplicación web. La política del bucket permite el acceso únicamente desde CloudFront.
•	Amazon CloudFront: Actúa como Content Delivery Network (CDN) para distribuir el contenido del frontend globalmente con baja latencia, forzando la comunicación a través de HTTPS.
•	Amazon EC2 (Auto Scaling Group): Proporciona la capacidad de cómputo para la aplicación backend, garantizando la resiliencia y escalabilidad mediante la gestión automática del número de instancias.
•	Elastic Load Balancing (ALB): Sirve como punto de entrada único para el backend, distribuyendo las solicitudes entrantes de manera uniforme entre las instancias EC2 activas para maximizar el rendimiento.
•	Amazon VPC: Crea una red privada y lógicamente aislada en la nube donde se aprovisionan todos los recursos, proporcionando control total sobre el entorno de red.
•	AWS Security Groups: Funcionan como un firewall virtual a nivel de instancia para controlar el tráfico de entrada y salida, aplicando el principio de mínimo privilegio entre las capas de la aplicación.
•	Amazon Cognito: Ofrece un servicio de identidad completamente gestionado para la autenticación y autorización de usuarios, desacoplando esta responsabilidad de la aplicación backend.

________________________________________

5. Guía de Despliegue
Sigue estos pasos para aprovisionar la infraestructura en tu cuenta de AWS.
Requisitos Previos
•	Terraform v1.6.0 o superior (compatible con la versión ~> 6.0 del proveedor AWS).
•	AWS CLI instalada y configurada con credenciales de acceso. El proveedor está configurado para usar el perfil joseph.
•	Git para clonar el repositorio.
Pasos para el Despliegue
1.	Clonar el repositorio:
Bash
git clone https://github.com/jsalinas4/Iac-Proyecto-OD
cd Iac-Proyecto-OD/terraform
2.	Inicializar Terraform: Este comando descarga el proveedor de AWS y prepara el directorio de trabajo.
Bash
terraform init
3.	Planificar la Infraestructura: Terraform creará un plan de ejecución detallando los recursos que serán creados, modificados o eliminados. Revisa cuidadosamente este plan antes de continuar.
Bash
terraform plan
4.	Aplicar los Cambios: Este comando aprovisionará la infraestructura. Se te pedirá una confirmación final antes de proceder.
Bash
terraform apply
Al finalizar, Terraform mostrará los valores de las salidas definidas.
5.	Destruir la Infraestructura: Para eliminar todos los recursos creados por este proyecto y evitar costos, utiliza el siguiente comando:
Bash
terraform destroy

________________________________________

6. Variables y Salidas
Variables Principales (variables.tf)
Estas variables permiten personalizar el despliegue sin modificar el código.

Nombre de la Variable	Descripción	Valor por Defecto
region	La región de AWS donde se desplegarán los recursos.	"us-east-1"
project_name	El nombre del proyecto, usado como prefijo para los recursos.	"odontoclinica"


Salidas (cognito.tf)
Estos valores se muestran después de un despliegue exitoso y son necesarios para configurar las aplicaciones cliente.

Nombre del Output	Descripción
cognito_user_pool_id	El ID del User Pool de Cognito, necesario para la configuración del backend.
cognito_app_client_id	El ID del Cliente de Aplicación, necesario para la configuración del frontend.

________________________________________

7. Pruebas y Validación
Para asegurar la calidad y consistencia del código, utiliza los siguientes comandos nativos de Terraform:
•	Validar la sintaxis:
Bash
terraform validate
•	Formatear el código:
Bash
terraform fmt -recursive

________________________________________

8. Seguridad y Buenas Prácticas
•	Gestión de Credenciales: Las credenciales de AWS no deben ser almacenadas en el código. La configuración actual utiliza perfiles de la AWS CLI. Para entornos de producción, se recomienda usar roles de IAM.
•	Estado Remoto: Para proyectos colaborativos, es crucial configurar un backend remoto (ej. un bucket de S3 con bloqueo de estado en DynamoDB) para almacenar el archivo terraform.tfstate de forma segura y centralizada.
•	Archivos .tfvars: Los archivos que contienen datos sensibles (como terraform.tfvars) deben ser incluidos en el .gitignore para evitar la exposición accidental de secretos en el control de versiones.
•	Principio de Mínimo Privilegio: Los grupos de seguridad están configurados para permitir únicamente el tráfico estrictamente necesario entre los componentes, reduciendo la superficie de ataque.

________________________________________

9. Versionamiento y Convenciones de Commit
Se recomienda seguir la especificación de Conventional Commits para los mensajes de commit. Esto mejora la legibilidad del historial y permite automatizar la generación de registros de cambios (changelogs).
Formato: <tipo>(<ámbito>): <descripción>
•	Ejemplos:
o	feat(cognito): agregar política de contraseñas avanzada
o	fix(network): corregir CIDR de la subred privada
o	docs(readme): actualizar diagrama de arquitectura

________________________________________

10. Licencia
Este proyecto se distribuye bajo la Licencia MIT.

________________________________________

11. Colaboradores:
•	Salinas Rojas, Joseph
•	Lezcano Saavedra, Anthony
•	Chávez Segura, Cristhoper
•	Zevallos Bocanegra, Pierreluiggi
•	Mezones Burgos, Carlos

________________________________________

12. Referencias Oficiales
•	Documentación de Terraform
•	Documentación del Proveedor AWS de Terraform
•	Guía de Buenas Prácticas de Terraform


