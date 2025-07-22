#!/bin/bash

# Array of URLs
URLS=(
    "https://download.tsl.ti-dienste.de/ECC/ECC-RSA_TSL.xml"
    "https://download.tsl.ti-dienste.de/ECC/ROOT-CA/roots.json"
    "https://download-ref.tsl.ti-dienste.de/ECC/ECC-RSA_TSL-ref.xml"
    "https://download-ref.tsl.ti-dienste.de/ECC/ROOT-CA/roots.json"
    "https://download-test.tsl.ti-dienste.de/ECC/ECC-RSA_TSL-test.xml"
    "https://download-test.tsl.ti-dienste.de/ECC/ROOT-CA/roots.json"
    "http://download.crl.ti-dienste.de/TSL-ECC/ECC-RSA_TSL.sig"
    "http://download.crl.ti-dienste.de/TSL-ECC/ECC-RSA_TSL.xml"
    "http://download-testref.crl.ti-dienste.de/TSL-ECC-ref/ECC-RSA_TSL-ref.xml"
    "http://download-testref.crl.ti-dienste.de/TSL-ECC-ref/ECC-RSA_TSL-ref.sig"
    "https://tl.bundesnetzagentur.de/TL-DE.XML"
)

# update the repository
git pull origin

# Base directory where files will be stored
BASE_DIR="downloads"

# Ensure base directory exists
mkdir -p "$BASE_DIR"

# Iterate over URLs
for URL in "${URLS[@]}"; do
    # Extract FQDN
    FQDN=$(echo "$URL" | sed -E 's~^[a-z]+://([^/]+).*~\1~')

    # Extract filename (strip query and fragment first)
    FILENAME=$(basename "$(echo "$URL" | sed -E 's~[?#].*~~')")

    # Extract the path part
    PATH_PART=$(echo "$URL" | sed -E 's~^[a-z]+://[^/]+(/[^?#]*)?.*~\1~')

    # Determine directory (remove leading slash)
    if [[ -z "$PATH_PART" || "$PATH_PART" == "$FILENAME" ]]; then
        DIR="."
    else
        DIR=$(dirname "$PATH_PART")
        DIR="${DIR#/}"  # Remove leading slash
        [[ -z "$DIR" || "$DIR" == "." ]] && DIR="."
    fi    

    # Create target directory
    TARGET_DIR="./downloads/$FQDN/$DIR"
    mkdir -p "$TARGET_DIR"

    # Check HTTP status
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$URL")

    if [[ "$HTTP_STATUS" == "200" ]]; then
        echo "Downloading '${URL}' to '$TARGET_DIR/$FILENAME'"
        curl -s -L "$URL" -o "$TARGET_DIR/$FILENAME"
        # Add to git and commit
        git add "$TARGET_DIR/$FILENAME"
        git commit -m "Updated $URL"
    else
        echo "Error: HTTP status $HTTP_STATUS for URL: $URL" >&2
    fi

    # If the file is an XML file, generate a pretty-printed version
    if [[ "$FILENAME" == *.xml || "$FILENAME" == *.XML ]]; then
        PRETTY_FILE="$TARGET_DIR/${FILENAME%.xml}-pretty.xml"
        python3 -c 'import sys;import xml.dom.minidom;s=sys.stdin.read();print(xml.dom.minidom.parseString(s).toprettyxml())' < "$TARGET_DIR/$FILENAME" > "$PRETTY_FILE"
        echo "Generated pretty-printed version: '$PRETTY_FILE'"
        # Add pretty-printed file to git and commit
        git add "$PRETTY_FILE"
        git commit -m "Added pretty-printed version of $URL"
    fi
done

# push the changes to the remote repository
git push origin
