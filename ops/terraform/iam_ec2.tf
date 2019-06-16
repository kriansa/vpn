resource "aws_iam_role" "ec2_vpn" {
  name        = "EC2VPNServer"
  description = "Role to enable EC2 VPN Server to use AWS resources"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "enable_read_access_to_pki_bucket" {
  name = "ReadOnlyAccessToPKIS3Bucket"
  description = "Policy to enable read-only access to the PKI S3 Bucket"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["arn:aws:s3:::${var.pki_s3_bucket}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:HeadObject",
        "s3:GetObject"
      ],
      "Resource": ["arn:aws:s3:::${var.pki_s3_bucket}/*"]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "pki_policy_to_role" {
  role       = aws_iam_role.ec2_vpn.name
  policy_arn = aws_iam_policy.enable_read_access_to_pki_bucket.arn
}

data "aws_iam_policy" "cw_agent" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "cw_agent_to_role" {
  role       = aws_iam_role.ec2_vpn.name
  policy_arn = data.aws_iam_policy.cw_agent.arn
}

# Instance Profile is a abstraction to link a Role with an EC2 instance
# Other services such as ECS allows you to pass a Role directly on launch
resource "aws_iam_instance_profile" "ec2_vpn" {
  name = "EC2VPNServer"
  role = aws_iam_role.ec2_vpn.name
}
