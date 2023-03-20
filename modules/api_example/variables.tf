variable "pool_name" {
  type        = string
  default     = "API_POOL"
  description = "Cognito User Pool Name"
}

variable "protocol_type" {
  type        = string
  default     = "HTTP"
  description = "API Gateway Protocol Type"
}

