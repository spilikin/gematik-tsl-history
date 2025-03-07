#!/bin/bash

# Array of URLs
URLS=(
    "https://download.tsl.ti-dienste.de/ECC/ECC-RSA_TSL.xml"
    "https://download.tsl.ti-dienste.de/ECC/ROOT-CA/roots.json"
    "https://download-ref.tsl.ti-dienste.de/ECC/ECC-RSA_TSL-ref.xml"
    "https://download-ref.tsl.ti-dienste.de/ECC/ROOT-CA/roots.json"
    "https://download-test.tsl.ti-dienste.de/ECC/ECC-RSA_TSL-test.xml"
    "https://download-test.tsl.ti-dienste.de/ECC/ROOT-CA/roots.json"
    "http://download.crl.ti-dienste.de/TSL-ECC/ECC-RSA_TSL.ocsp"
    "http://download.crl.ti-dienste.de/TSL-ECC/ECC-RSA_TSL.sig"
    "http://download.crl.ti-dienste.de/TSL-ECC/ECC-RSA_TSL.xml"
    "http://download-testref.crl.ti-dienste.de/TSL-RSA-ref/TSL-ref.ocsp"
    "http://download-testref.crl.ti-dienste.de/TSL-RSA-ref/TSL-ref.sig"
    "http://download-testref.crl.ti-dienste.de/TSL-RSA-ref/TSL-ref.xml"
)

# update the repository
git pull origin

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
    echo "Updated $FILE_NAME from $URL"
    if ! git diff --cached --quiet; then
        git commit -m "Updated $FILE_NAME from $URL"
    fi
    cd - > /dev/null

done

# push the changes to the remote repository
git push origin