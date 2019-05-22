data "aws_caller_identity" "current" {}

# Get the available zones from this region
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}
