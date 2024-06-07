#!/bin/bash
sudo yum update -y
sudo yum upgrade -y
sudo yum install maven git -y
sudo su -c "git clone https://github.com/CloudHight/application-assessment-repo.git" ec2-user