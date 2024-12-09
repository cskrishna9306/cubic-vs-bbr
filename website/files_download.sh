#!/bin/bash

# Base URL where the files are hosted
BASE_URL="http://{SERVER_IP_ADDRESS:PORT}/files" # Replace with the websites IP address and port
DOWNLOAD_DIR="./files"

# Loop to download files from 1 to 100
for i in {1..100}; do
  FILE_NAME="file$i.bin"
  FILE_URL="$BASE_URL/$FILE_NAME"

  echo "Downloading $FILE_NAME from $FILE_URL..."

  # Use curl to download the file
  curl -o "$DOWNLOAD_DIR/$FILE_NAME" "$FILE_URL"
done

echo "Download process completed."