#!/bin/bash

$name = $USERDOMAIN

read -p "Enter Your AWS_ACCESS_KEY_ID: " AWS_ACCESS_KEY_ID
read -p "Enter Your AWS_SECRET_ACCESS_KEY: " AWS_SECRET_ACCESS_KEY
read -p "Enter Your AWS_DEFAULT_REGION: " AWS_DEFAULT_REGION
read -p "Enter Your INSTANCE_ID: " INSTANCE_ID
read -p "Enter Your SQL_PRIVATE_HOST: " SQL_PRIVATE_HOST
read -p "Enter Your BASTION_HOST_IP: " BASTION_HOST_IP
read -p "Enter Your LISTEN_PORT_DB: " PORT

export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION

# Change this to the path of your PEM file
pem_file="$USERPROFILE\\.ssh\\good_life_dev_bastion_$name"  

# Find the process ID using netstat and kill it using kill
netstat -ano | grep -E ":$PORT\b" | awk '{print $NF}' | while read pid; do
    kill -9 "$pid"
done

# Create the security public key
if [ ! -f "$pem_file" ]; then
    # Create the PEM file
    ssh-keygen -t rsa -b 2048 -f $pem_file -N  ""
else
    echo "Public key file already exists!"
fi

# Run AWS command
echo $pem_file

aws ec2-instance-connect send-ssh-public-key --instance-id $INSTANCE_ID --instance-os-user ec2-user --ssh-public-key file://$pem_file.pub

# Agent forwarding
ssh -i $pem_file -f -N -L $PORT:$SQL_PRIVATE_HOST:5432 ec2-user@$BASTION_HOST_IP -v -o StrictHostKeyChecking=no
