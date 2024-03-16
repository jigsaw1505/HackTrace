#!/bin/bash

# Directory containing files to analyze
echo "Enter The Directory Path : "
read directory_name
DIR_TO_ANALYZE="$directory_name"

# Iterate over files in the directory
for FILE in "$DIR_TO_ANALYZE"/*; do
    # Check if the file is of a suitable type (e.g., image files)
    # You may need to adjust the file type check based on your requirements
    if file -b --mime-type "$FILE" | grep -q "^image/"; then
        echo "Analyzing $FILE for hidden data..."
        # Use stegocracker to attempt to crack hidden data
        OUTPUT=$(stegocracker "$FILE")
        # Check if any hidden data was found
        if echo "$OUTPUT" | grep -q "Password:"; then
            echo "Hidden data found in $FILE:"
            echo "$OUTPUT"
        else
            echo "No hidden data found in $FILE"
        fi
    else
        echo "Skipping $FILE (not an image file)"
    fi
done
