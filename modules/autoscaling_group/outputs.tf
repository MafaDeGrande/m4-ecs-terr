output "asg_arn" {
  value = aws_autoscaling_group.finance_app.arn
  description = "The arn of the aws_autoscaling_group"
}
