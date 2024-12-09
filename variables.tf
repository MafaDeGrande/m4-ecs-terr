variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = null
}

variable "domain" {
  description = "The domain name"
  type        = string
  default     = "ipp.gzttk.org"
}

variable "db_username" {
  description = "Database administrator username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}

variable "ACCESS_TOKEN_SALT" {
  description = "Example of the access token for the app"
  type        = string
  sensitive   = true
}

variable "JWT_SECRET_KEY" {
  description = "Example of the jwt key for the app"
  type        = string
  sensitive   = true
}

variable "image" {
  type = string
  description = "Image of the app"
}
