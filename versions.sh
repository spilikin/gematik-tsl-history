#!/bin/bash

# Move to the root of the Git repository
REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT" || exit

BASE_DIR="versions"
DOWNLOADS_DIR="downloads"

# Ensure base directory exists
mkdir -p "$BASE_DIR"

# Find all files in the downloads directory
find "$DOWNLOADS_DIR" -type f | while read -r FILE_PATH; do
    RELATIVE_PATH="${FILE_PATH#$DOWNLOADS_DIR/}"
    FILE_DIR="${BASE_DIR}/${RELATIVE_PATH%/*}/$(basename "$RELATIVE_PATH")"
    FILE_NAME="$(basename "$RELATIVE_PATH")"
    
    mkdir -p "$FILE_DIR"
    
    # Iterate through file history
    git log --format="%H %at" -- "$FILE_PATH" | while read -r COMMIT_HASH TIMESTAMP; do
        if [[ "$(uname)" == "Darwin" ]]; then
            FORMATTED_TIME=$(date -r $TIMESTAMP "+%Y%m%d%H%M%S")
        else
            FORMATTED_TIME=$(date -d @$TIMESTAMP "+%Y%m%d%H%M%S")
        fi
        VERSION_FILE="${FILE_DIR}/${FORMATTED_TIME}_${COMMIT_HASH}_${FILE_NAME}"
        git show "$COMMIT_HASH:$FILE_PATH" > "$VERSION_FILE"
    done

done
