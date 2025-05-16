#!/bin/bash
sudo mkdir -p /mnt/azurefileshare
sudo apt-get update -y
sudo apt-get install cifs-utils -y

mount -t cifs //${STORAGE_ACCOUNT_NAME}.file.core.windows.net/myshare /mnt/azurefileshare \
  -o vers=3.0,username=${STORAGE_ACCOUNT_NAME},password=${STORAGE_ACCOUNT_KEY},dir_mode=0777,file_mode=0777,serverino
