# AWS FFMPEG Converter

## Introduction
This is my first independent AWS CloudFormation / IaC project. In full working form, it will launch a web page to upload videos, convert those videos to configured qualities, then present them back to the user on that same web page.

I will upload each stage of the project as its own verson. This readme will provide descriptions of the infrastructure of the specific versions, each one building on the last. Once I complete the project, I will provide a full, ground-up description of the final version so that readers do not have to go through all previous versions.

## Version 1
Version 1 s
![Diagram](https://raw.githubusercontent.com/joeyolson18/aws-ffmpeg-converter/main/images/video-converter-v1.svg)
### Challenges
**Queue / Bucket synchronization:**

**!Sub with EC2 UserData:**
You can input commands to run on an EC2 instance startup using UserData. While very useful, debugging can be difficult if you do not know where to look. [This](https://stackoverflow.com/questions/15904095/how-to-check-whether-my-user-data-passing-to-ec2-instance-is-working) Stack Overflow article helped tremendously. Firstly, all setup processes—including UserData scripts—are written to `/var/log/cloud-init-output.log`. You can view error logs if your scripts are running improperly.

Sometimes, UserData will return this error:
```
/var/lib/cloud/instance/scripts/part-001: line 2: cd: too many arguments
<TIMESTAMP> - cc_scripts_user.py[WARNING]: Failed to run module scripts-user (scripts in /var/lib/cloud/instance/scripts)
<TIMESTAMP> - util.py[WARNING]: Running module scripts-user (<module 'cloudinit.config.cc_scripts_user' from '/usr/lib/python3.9/site-packages/cloudinit/config/cc_scripts_user.py'>) failed
```
 This was the case for me when I first attempted to use the `!Sub` or `!Join` CloudFormation functions to input variables such as the S3 bucket name. If you scroll down further in the above article, you will see how to return a text file of your UserData:
```
sudo cat /var/lib/cloud/instances/$INSTANCE_ID/user-data.txt
```
In my case, all of my commands were on the same line, so I had line breaks to my UserData file.
