import os
import boto3

ami_name = "al2023-ami-kernel-default-arm64"


regions = ['af-south-1', 'ap-east-1', 'ap-northeast-1', 'ap-northeast-2', 'ap-northeast-3', 'ap-south-1', 'ap-south-2', 'ap-southeast-1', 'ap-southeast-2', 'ap-southeast-3', 'ap-southeast-4', 'ca-central-1', 'eu-central-1',
           'eu-central-2', 'eu-north-1', 'eu-south-1', 'eu-south-2', 'eu-west-1', 'eu-west-2', 'eu-west-3', 'me-central-1', 'me-south-1', 'sa-east-1', 'us-east-1', 'us-east-2', 'us-gov-east-1', 'us-gov-west-1', 'us-west-1', 'us-west-2']
regions.sort()

amis = []

for region in regions:
    try:
        ssm = boto3.client('ssm', region_name=region)
    except:
        print("could not access region: " + region)
        ami = parameter = ssm.get_parameter(
            Name="/aws/service/ami-amazon-linux-latest/" + ami_name)
        ami = ami["Parameter"]["Value"]
        amis.append((region, ami))

        print("recorded ami for region: " + region)


ami_yaml = ""

for entry in amis:
    ami_yaml += entry[0] + ":\n  ALinuxArm: " + entry[1] + "\n"
print(ami_yaml)
