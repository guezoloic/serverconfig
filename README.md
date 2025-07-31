<h1 align=center> ServerConfig </h1>
my own configuration management tool designed to quickly setup a server. It provides a simple way to deploy all my configuration needs.

## Table of Content

- [Features](#Features)
- [Notification Scripts](#auto-notification)

## Features

- **Notifications**: Real-time alert system via Telegram.  
- **AWS Backup**: Automated backup system via AWS s3.
- **Docker Script**: Custom docker script.

## Prerequisites

Ensure you have the following **programs** installed:
- **curl**
- **aws**
- **docker** 

## Installation

```bash
git clone https://github.com/guezoloic/serverconfig.git
cd serverconfig && \
chmod +x ./install.sh && ./install.sh
```

## Contributing

Feel free to fork the repository, submit issues or pull requests.