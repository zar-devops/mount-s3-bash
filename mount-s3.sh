#!/bin/bash

echo "===== Dynamic S3 Bucket Mount Script ====="
echo ""

# ----- Ask for AWS Credentials -----
read -p "Enter AWS Access Key ID: " AWS_KEY
read -s -p "Enter AWS Secret Access Key: " AWS_SECRET
echo ""
read -p "Enter AWS Region (default: us-east-1): " AWS_REGION
AWS_REGION=${AWS_REGION:-us-east-1}

# ----- Ask for S3 bucket & Local Path -----
read -p "Enter S3 bucket name (e.g., my-bucket-name): " BUCKET_NAME
read -p "Enter the folder name to create in /mnt/ (e.g., project): " DIR_NAME

# Define the full path
MOUNT_POINT="/mnt/$DIR_NAME"

# ----- Install s3fs -----
echo "Detecting OS and installing s3fs..."
if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
        ubuntu|debian)
            sudo apt update && sudo apt install -y s3fs
            ;;
        amzn|amazon)
            sudo amazon-linux-extras install epel -y
            sudo yum install -y s3fs-fuse
            ;;
        centos|rhel)
            sudo yum install -y epel-release s3fs-fuse
            ;;
        *)
            echo "Unsupported OS. Please install s3fs manually."
            exit 1
            ;;
    esac
fi

# ----- Setup AWS credentials -----
echo "$AWS_KEY:$AWS_SECRET" | sudo tee /etc/passwd-s3fs > /dev/null
sudo chmod 600 /etc/passwd-s3fs

# ----- Create dynamic mount point -----
if [ ! -d "$MOUNT_POINT" ]; then
    echo "Creating directory $MOUNT_POINT..."
    sudo mkdir -p "$MOUNT_POINT"
else
    echo "Directory $MOUNT_POINT already exists."
fi

# ----- Mount bucket -----
echo "Mounting S3 bucket $BUCKET_NAME to $MOUNT_POINT..."

sudo s3fs "$BUCKET_NAME" "$MOUNT_POINT" \
    -o passwd_file=/etc/passwd-s3fs \
    -o url=https://s3.$AWS_REGION.amazonaws.com \
    -o use_path_request_style \
    -o allow_other

if [ $? -eq 0 ]; then
    echo "Mount successful!"
else
    echo "Mount failed. Check your credentials or bucket permissions."
    exit 1
fi

# ----- Add to fstab for persistence -----
# We check if the entry already exists to avoid duplicates
if ! grep -q "$MOUNT_POINT" /etc/fstab; then
    echo "Adding mount to /etc/fstab..."
    echo "s3fs#$BUCKET_NAME $MOUNT_POINT fuse _netdev,allow_other,passwd_file=/etc/passwd-s3fs,url=https://s3.$AWS_REGION.amazonaws.com,use_path_request_style 0 0" \
        | sudo tee -a /etc/fstab
fi

echo ""
echo "========================================================="
echo "Success: s3://$BUCKET_NAME is mounted at $MOUNT_POINT"
echo "========================================================="
