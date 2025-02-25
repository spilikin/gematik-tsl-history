#!/bin/bash

# Array of URLs
URLS=(
    "https://download.tsl.ti-dienste.de/ECC/ECC-RSA_TSL.xml"
    "https://download-ref.tsl.ti-dienste.de/ECC/ECC-RSA_TSL-ref.xml"
    "https://download-test.tsl.ti-dienste.de/ECC/ECC-RSA_TSL-test.xml"
)

# Base directory where files will be stored
BASE_DIR="downloads"

# Ensure base directory exists
mkdir -p "$BASE_DIR"

# Iterate over URLs
for URL in "${URLS[@]}"; do
    # Extract domain name
    DOMAIN=$(echo "$URL" | awk -F/ '{print $3}')
    
    # Create subdirectory for the domain
    DIR="$BASE_DIR/$DOMAIN"
    mkdir -p "$DIR"
    
    # Extract filename
    FILE_NAME=$(basename "$URL")
    FILE_PATH="$DIR/$FILE_NAME"
    
    # Download the file
    curl -s -o "$FILE_PATH" "$URL"
    
    # Check if the file has changed
    cd "$DIR" || exit
    git add "$FILE_NAME"
    if ! git diff --cached --quiet; then
        git commit -m "Updated $FILE_NAME from $URL"
    fi
    cd - > /dev/null

done
