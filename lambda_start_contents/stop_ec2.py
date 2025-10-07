import boto3, os

def lambda_handler(event,context):
    ec2 = boto3.client("ec2", region_name=os.environ["REGION"])
    instance_id = os.environ["INSTANCE_ID"]
    ec2.stop_instances(InstanceIds=[instance_id])
    print(f"Stopped instance: {instance_id}.")