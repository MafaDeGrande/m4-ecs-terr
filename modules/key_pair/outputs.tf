output "tf_key" {
  value       = aws_key_pair.deployer.key_name
  description = "The name for the key pair"
}

output "private_key" {
  value       = tls_private_key.rsa.private_key_pem
  description = "Private key data in PEM (RFC 1421) format"
}
