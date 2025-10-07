terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}



resource "aws_instance" "web_server" {
  ami           = "ami-091d7d61336a4c68f"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name        = "web-server"
  }
}

resource "aws_iam_role" "lambda_ec2_role" {
  name = "LambdaEC2ControlRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_full_access" {
  role       = aws_iam_role.lambda_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "start_ec2" {
  filename         = "lambda_start.zip"
  function_name    = "StartEC2Instance"
  role             = aws_iam_role.lambda_ec2_role.arn
  handler          = "start_ec2.lambda_handler"
  runtime          = "python3.11"
  source_code_hash = filebase64sha256("lambda_start.zip")
  timeout          = 10 

  environment {
    variables = {
      INSTANCE_ID = aws_instance.web_server.id
      REGION      = "us-east-1"
    }
  }
}

resource "aws_lambda_function" "stop_ec2" {
  filename         = "lambda_stop.zip"
  function_name    = "StopEC2Instance"
  role             = aws_iam_role.lambda_ec2_role.arn
  handler          = "stop_ec2.lambda_handler"
  runtime          = "python3.11"
  source_code_hash = filebase64sha256("lambda_stop.zip")
  timeout          = 10

  environment {
    variables = {
      INSTANCE_ID = aws_instance.web_server.id
      REGION      = "us-east-1"
    }
  }
}

resource "aws_cloudwatch_event_rule" "start_rule" {
  name                = "StartEC2"
  schedule_expression = "cron(0 9 ? * MON-FRI *)"
}

resource "aws_cloudwatch_event_target" "start_target" {
  rule      = aws_cloudwatch_event_rule.start_rule.name
  target_id = "StartLambda"
  arn       = aws_lambda_function.start_ec2.arn
}

resource "aws_cloudwatch_event_rule" "stop_rule" {
  name                = "StopEC2Evening"
  schedule_expression = "cron(0 17 ? * MON-FRI *)"
}

resource "aws_cloudwatch_event_target" "stop_target" {
  rule      = aws_cloudwatch_event_rule.stop_rule.name
  target_id = "StopLambda"
  arn       = aws_lambda_function.stop_ec2.arn
}

resource "aws_lambda_permission" "allow_start_event" {
  statement_id  = "AllowExecutionFromEventBridgeStart"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_ec2.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start_rule.arn
}

resource "aws_lambda_permission" "allow_stop_event" {
  statement_id  = "AllowExecutionFromEventBridgeStop"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stop_ec2.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop_rule.arn
}