# Get the latest AMI for ECS
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["amazon"]
}

resource "aws_key_pair" "main" {
  key_name = "deploy-key"
  public_key = "${var.main_public_ssh_key}"
}

resource "aws_instance" "main" {
  ami = "${data.aws_ami.amazon_linux.id}"
  key_name = "${aws_key_pair.main.key_name}"

  # This instance size is enough for a VPN
  instance_type = "t3.nano"

  # The role used for this EC2
  iam_instance_profile = "${aws_iam_instance_profile.ec2_vpn.name}"

  # Networking
  subnet_id = "${aws_subnet.main.id}"
  associate_public_ip_address = true
  vpc_security_group_ids = [
    "${aws_default_security_group.main.id}",
    "${aws_security_group.allow_vpn_traffic_from_internet.id}",
    "${aws_security_group.allow_ssh_from_admin.id}"
  ]

  # Disable the default T3 'unlimited' for t3 instances
  credit_specification {
    cpu_credits = "standard"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name = "VPN Server"
  }

  provisioner local-exec {
    command = "../bin/provision ec2-user@${self.public_ip}"
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name = "EC2 ${aws_instance.main.tags["Name"]} - CPU usage above 80%"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "60"
  statistic = "Maximum"
  threshold = "80"

  dimensions = {
    InstanceId = "${aws_instance.main.id}"
  }

  alarm_actions = ["${aws_sns_topic.alarms.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "memory_alarm" {
  alarm_name = "EC2 ${aws_instance.main.tags["Name"]} - Memory usage above 80%"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "mem_used_percent"
  namespace = "CWAgent"
  period = "60"
  statistic = "Maximum"
  threshold = "80"

  dimensions = {
    InstanceId = "${aws_instance.main.id}"
  }

  alarm_actions = ["${aws_sns_topic.alarms.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "disk_alarm" {
  alarm_name = "EC2 ${aws_instance.main.tags["Name"]} - Disk usage above 80%"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "disk_used_percent"
  namespace = "CWAgent"
  period = "300"
  statistic = "Maximum"
  threshold = "80"

  dimensions = {
    InstanceId = "${aws_instance.main.id}"
    device = "nvme0n1p1"
    fstype = "xfs"
    path = "/"
  }

  alarm_actions = ["${aws_sns_topic.alarms.arn}"]
}
