# S3 Bucket Auto-Mounter

This script provides a fully automated way to mount an AWS S3 bucket as a local filesystem on Linux using `s3fs-fuse`. It handles dependency installation, directory creation, and boot-time persistence.

## 🚀 Features

* **Smart Installation**: Automatically detects your OS (Ubuntu, Debian, Amazon Linux, CentOS, RHEL) and installs the correct `s3fs` package.
* **Dynamic Paths**: Prompts you for a custom directory name and automatically creates it under `/mnt/`.
* **Automated Mounting**: Configures the initial mount with the `allow_other` flag so non-root users can access files.
* **Persistence**: Adds a clean entry to `/etc/fstab` so the bucket stays mounted after a system reboot.



## 📋 Prerequisites

* An **AWS S3 Bucket**.
* **IAM Credentials** (Access Key and Secret Key) with S3 permissions.
* **Sudo access** on the target Linux machine.

## 🛠️ Getting Started

### 1. Create the Script
```bash
nano mount_s3.sh
