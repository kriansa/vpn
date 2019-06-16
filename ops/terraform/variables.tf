variable "admin_ips" {
  type        = list(string)
  description = "The IP list that should have SSH enabled on the instances"
}

variable "main_public_ssh_key" {
  type        = string
  description = "The public SSH key used for using with AWS CodeCommit and EC2"
}

variable "pki_s3_bucket" {
  type        = string
  description = "The S3 bucket where the PKI infrastructure is located"
}

variable "base_domain_name" {
  type        = string
  description = "The base domain name (e.g. mydomain.com) that you have set up on AWS Route53"
}

variable "vpn_subdomain" {
  type        = string
  description = "The subdomain that your vpn will prepend to `base_domain_name` (e.g. vpn)"
}
