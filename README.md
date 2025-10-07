# EC2 Auto Start/Stop Automation

A project to automatically start and stop AWS EC2 instances during business hours, helping save costs and improve cloud efficiency using **Python, Lambda, CloudWatch, IAM, and Terraform**.

## Project Overview

This project automates EC2 instance management by:

- **Starting and stopping instances automatically** using Python Lambda functions at 9 AM and 5 PM (Monday–Friday).  
- **Scheduling events with CloudWatch** to trigger Lambda functions without manual intervention.  
- **Managing infrastructure with Terraform**, ensuring all AWS resources can be recreated reliably.  
- **Implementing secure IAM roles** so Lambda functions have only the permissions they need.  
- **Using environment variables** to configure region and instance IDs dynamically.  
- **Reducing EC2 runtime and costs**, optimizing AWS usage.

## Tech Stack

- **AWS Services**: EC2, Lambda, CloudWatch Events, IAM  
- **Infrastructure as Code**: Terraform  
- **Programming Language**: Python (Boto3)  
- **Local Development**: VS Code, PowerShell  


## How to Use

1. Set Lambda environment variables:
   - `REGION` → AWS region (e.g., `us-east-1`)  
   - `INSTANCE_ID` → EC2 instance ID  
2. Deploy resources with Terraform:
```bash
terraform init
terraform apply


