resource "aws_cognito_user_pool" "user_pool" {
  name                     = "${var.project_name}-user-pool"

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = false
  }

  username_attributes = ["email"]
  auto_verified_attributes = ["email"]
  mfa_configuration = "OFF"
}

resource "aws_cognito_user_pool_client" "app_client" {
  name                          = "${var.project_name}-app-client"
  user_pool_id                  = aws_cognito_user_pool.user_pool.id
  generate_secret               = false
  allowed_oauth_flows_user_pool = true
  supported_identity_providers  = ["COGNITO"]

  # Este parte corresponde a mi aporte como estudiante, y acutalmente la parte del dominicio administrado en el cloudfront no está habilitada en un 100%
  callback_urls = [
    "https://${aws_cloudfront_distribution.s3_distribution.domain_name}/", # Aquí correspondería ir la URL correspondiente del  CloudFront
    "http://localhost:4200/", 
  ]
  logout_urls = [
    "https://${aws_cloudfront_distribution.s3_distribution.domain_name}/",
    "http://localhost:4200/",
  ]
}

output "cognito_user_pool_id" {
  description = "ID del Cognito User Pool para configuración."
  value       = aws_cognito_user_pool.user_pool.id
}

output "cognito_app_client_id" {
  description = "ID del Cliente de Aplicación de Cognito para configuración."
  value       = aws_cognito_user_pool_client.app_client.id
}