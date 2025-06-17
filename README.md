<h1 align=center> ServerConfig </h1>

## Table of Content

- [Overview](#overview)
- [AWS Backup](#aws-backup)
- [Notification Scripts](#auto-notification)

## Overview 
`ServerConfig` is my own configuration management tool designed to quickly setup a server. It provides a simple way to deploy all my configuration needs.

# AWS Backup

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [How It Works](#how-it-works)
- [Troubleshooting](#troubleshooting)

## Overview

This Bash script automates the process of backing up files and directories to an Amazon S3 bucket. It reads paths from a backup file, checks their existence, and synchronizes them to a specified AWS server using the AWS CLI.

## Features

- Synchronizes files and directories to an S3 bucket.
- Creates a backup file if it does not exist.
- Logs errors and success messages to a specified log file.
- Supports deletion of files from S3 if they no longer exist in the source.

## Prerequisites

Before using this script, ensure you have:

- **Bash**: The script is written for a Bash environment.
- **AWS CLI**: Install the [AWS Command Line Interface](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) and configure it with your credentials and default region.
- **Permissions**: The script requires appropriate permissions to read from the specified directories and write to the log file.

## Installation

1. **Clone the repository**:
    ```bash
    git clone https://github.com/guezoloic/ServerConfig.git
    cd aws_backup/
    ```

2. **Ensure the script is executable**:
    ```bash
    chmod +x ./aws-bak.sh
    ```

## Configuration

Before running this script, update the following variables in the script:

- **AWS**: Set this to your AWS S3 bucket name.
    ```bash
    AWS="<AWS-server Name>"
    ```

- **BACKUP**: This is the path where the backup file will be created. By default, it is set to "$DIR/backup_file.bak".

- **LOG**: Set the path where you want to save the log file. The default is set to /var/log/save-aws.log.

## Usage

1. **Create a backup file**:
The script requires a backup file (backup_file.bak) that contains the list of directories or files to be backed up. Each path should be on a new line.

2. **Run the script**:
- Execute the script by running the following command in your terminal:
    ```bash
    ./aws-bak.sh
    ```

- You can also execute the script without changing the AWS variable
    ```bash
    ./aws-bak.sh <AWS-server Name>
    ```
3.	**Automate the script**:
You can automate the backup process by adding the script to crontab:
- Run crontab -e and add an entry to run the script at a desired interval, for example:
    ```bash
    0 12 * * * /path/to/aws-bak.sh
    ```
4. **Cleanup and Purge**:
If you need to remove all installed files or clean up AWS-related configurations, the script provides two options:
- Clean Up AWS: To remove AWS configurations and related artifacts (e.g., credentials, CLI configuration), use the following command:
    
    ```bash
    ./aws-bak.sh clean aws
    ```
- Purge the Program: This option deletes all program-related files (e.g., script, logs, backup files), but it does not clean up AWS configurations:
    
    ```bash
    ./aws-bak.sh clean
    ```

## How It Works

1. **Backup File Check**: The script first checks if the backup file exists. If not, it creates one and logs an error.

2.	**Read Paths**: It reads each line from the backup file and checks if the path is a directory or file.

3.	**Synchronization**: For valid paths, the script uses aws s3 sync to synchronize the files to the specified S3 bucket.

4.	**Logging**: It logs any errors encountered during execution and confirms successful synchronization.

5.	**Exit Codes**: The script exits with a status code of 1 in case of an error and logs appropriate messages.

## Troubleshooting

- If the script fails, check the log file at the specified path for detailed error messages.

- Ensure that the AWS CLI is configured correctly and that you have the necessary permissions to access the S3 bucket.

---

# Auto-Notification

This repository contains two Bash scripts designed for monitoring user logins and system disk usage. Notifications are sent via **Telegram Bot**. Below is a detailed explanation of each script, their functionality, and how to set them up.

---

## Scripts Overview

### 1. **PAM Hook Script**
- **Purpose:** Monitors user sessions (login and logout) and sends notifications via Telegram whenever a user connects or disconnects from the system.
- **Trigger:** The script is invoked by **PAM (Pluggable Authentication Module)** during session events (e.g., SSH login).
- **Notification Content:**
  - Username (`$PAM_USER`)
  - Remote host (`$PAM_RHOST`)
  - Timestamp (`$(date)`)

---

### 2. **Disk Monitoring Script**
- **Purpose:** Monitors disk usage on the root filesystem (`/`) and sends an alert if the usage exceeds a predefined threshold.
- **Trigger:** Can be run manually, or scheduled to run periodically using **Cron**.
- **Notification Content:**
  - Current disk usage percentage.
  - Total disk size, used space, and available space.

---

## Prerequisites

1. **Linux Environment:**
   - Both scripts are designed to work on Linux systems.
   - Ensure **PAM** is available for the login monitoring script.

2. **Telegram Bot Setup:**
   - Create a Telegram bot by talking to [BotFather](https://core.telegram.org/bots#botfather).
   - Save the bot token (`TOKEN`).
   - Get your `CHAT_ID` by sending a message to the bot and using an API call like:
     ```bash
     curl https://api.telegram.org/bot<YOUR_TOKEN>/getUpdates
     ```
   - Add these variables (`TOKEN` and `CHAT_ID`) to the `.env` file.

3. **Environment File (`.env`):**
   - Place the `.env` file in `/etc/serverconfig/.env`.
   - Example `.env` file:
     ```bash
     TOKEN=your_bot_token_here
     CHAT_ID=your_chat_id_here
     ```

4. **Dependencies:**
   - Ensure `curl` is installed:
     ```bash
     sudo apt install curl
     ```

---
## Installation & Configuration

### 1. **PAM Hook Script**

1. **Place the Script:**
   - Save the script as `/usr/local/bin/sshd-login.sh`.
   - Make it executable:
     ```bash
     sudo chmod +x /usr/local/bin/sshd-login.sh
     ```

2. **Configure PAM:**
   - Edit the PAM configuration for the service you want to monitor. For SSH:
     ```bash
     sudo nano /etc/pam.d/sshd
     ```
   - Add the following line to trigger the script:
     ```bash
     session optional pam_exec.so /usr/local/bin/sshd-login.sh
     ```

3. **Test the Setup:**
   - Log in and out of the system via SSH.
   - Check Telegram for notifications.

---

### 2. **Disk Monitoring Script**

1. **Place the Script:**
   - Save the script as `/usr/local/bin/disk-monitor.sh`.
   - Make it executable:
     ```bash
     sudo chmod +x /usr/local/bin/disk-monitor.sh
     ```

2. **Run Manually:**
   - Execute the script with a threshold percentage:
     ```bash
     /usr/local/bin/disk-monitor.sh
     ```

3. **Automate with Cron:**
   - Schedule the script to run periodically:
     ```bash
     crontab -e
     ```
   - Add a cron job, e.g., to check disk usage every hour:
     ```bash
     0 * * * * /usr/local/bin/disk-monitor.sh
     ```

---

## Security Considerations

1.	Restrict Access to Scripts and .env:
- Ensure only root or authorized users can access these files:
```
sudo chmod 600 /etc/serverconfig/.env
sudo chmod 700 /usr/local/bin/sshd-login.sh
sudo chmod 700 /usr/local/bin/disk-monitor.sh
```

---
## Conclusion

These scripts provide a lightweight solution for real-time session monitoring and disk usage alerts via Telegram. By integrating with PAM and automating periodic checks, they enhance system monitoring and improve administrator response time to critical events.