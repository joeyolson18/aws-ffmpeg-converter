# AWS FFMPEG Converter

## Introduction
This is my first independent AWS CloudFormation / IaC project. In full working form, it will launch a web page to upload videos, convert those videos to configured qualities, then present them back to the user on that same web page.

I will upload each stage of the project as its own **version** section. This README will provide descriptions of each version and its infrastructure, each building on top of the last. Additionally, there will be a **challenges** section for each version, documenting problems that had to be overcome in the making of this project. This can safely be skipped if you're just attempting to understand the infrastructure. Once I complete the project, I will provide a full, ground-up description of the final version so that readers do not have to go through all previous versions.

## Version 1
![Diagram](https://raw.githubusercontent.com/joeyolson18/aws-ffmpeg-converter/main/images/video-converter-v1.svg)

Version 1 is the minimum viable product. To get started, download the yaml file `v1/ffmpeg-cfn-v1.yaml` from this repository. Then, upload it to your AWS environment through CloudFormation or the AWS CLI. Two parameters must be entered: the _Default VPC ID_ and a _Bucket Name_. The _Default VPC ID_ can be found by going to "VPC" then "Your VPCs" in the AWS interface, then copying the VPC ID of the VPC with _Default VPC_ set to _Yes_. The _Bucket Name_ is decided by the user, but must be globally unique to all AWS accounts. 

For the system to work, a folder `uploads/` must be manually created by the user in the bucket made by the template. Uploading an `.mp4` to this folder triggers an Event Notification, and a message is published to SQS. This SQS message is polled (read) by a bash program that continually runs on an EC2 instance.

The bash script is pulled from `v1/convert-v1.bash` in this repository and run on the EC2 instance. Every 10 seconds, the script polls the SQS queue for information about the `uploads/` folder. If a new message is detected, then the instance will download the `.mp4` file from S3 and convert it to 240p using FFMPEG. Then, the instance will upload both the original and low-quality versions to a new folder. This folder will share a name with that of the uploaded file. Finally, the original file will be deleted in the `uploads/` folder.

sample-5s.mp4 uploaded to uploads/ |  lq.mp4 and hq.mp4 pushed to sample-5s.mp4/
:-------------------------:|:-------------------------:
![](https://raw.githubusercontent.com/joeyolson18/aws-ffmpeg-converter/main/images/video-upload.png)  |  ![](https://raw.githubusercontent.com/joeyolson18/aws-ffmpeg-converter/main/images/video-conversion.png)

### Challenges
***Bucket Notifications:*** 
To notify the EC2 insta

***!Sub with EC2 UserData:*** 
You can input commands to run on an EC2 instance startup using UserData. [This Stack Overflow article](https://stackoverflow.com/questions/15904095/how-to-check-whether-my-user-data-passing-to-ec2-instance-is-working) contains the necessary filepaths to properly debug UserData scripts, as it can be tricky without the proper tools. 

Firstly, all setup processes—including UserData scripts—are written to `/var/log/cloud-init-output.log`. You can view error logs if your scripts are running improperly. This is a fantastic resource if your scripts are running, but sometimes UserData fails to run entirely. The following error message will be returned in that case:
```
<TIMESTAMP> - cc_scripts_user.py[WARNING]: Failed to run module scripts-user (scripts in /var/lib/cloud/instance/scripts)
<TIMESTAMP> - util.py[WARNING]: Running module scripts-user (<module 'cloudinit.config.cc_scripts_user' from '/usr/lib/python3.9/site-packages/cloudinit/config/cc_scripts_user.py'>) failed
```
The UserData scripts are simply not running. The article solves our problems here as well, as the commands are run from the text file: `sudo cat /var/lib/cloud/instances/<INSTANCE_ID>/user-data.txt`. If you open this, you can see what commands the instance is attempting to run before failing.

This error returned when I first attempted to use the `!Sub` or `!Join` CloudFormation functions in my UserData string field. After viewing the text file, I noticed that all of the commands were written on the same line, which was easily remedied with newline `\n` characters.


