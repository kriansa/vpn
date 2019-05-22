resource "aws_sns_topic" "alarms" {
  name = "InfrastructureAlarms"
  display_name = "InfrastructureAlarms"

  provisioner local-exec {
    command = "echo \"Please, manually add subscriptions to the SNS Topic ${self.name}!\""
  }
}
