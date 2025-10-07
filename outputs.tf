output "ec2_instance_id" {
  value = aws_instance.web_server.id
}

output "start_lambda_name" {
  value = aws_lambda_function.start_ec2.function_name
}

output "stop_lambda_name" {
  value = aws_lambda_function.stop_ec2.function_name
}
