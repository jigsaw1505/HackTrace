#!/bin/bash

# Colors for output
GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
BLUE="\033[34m"
RESET="\033[0m"

# Log file
LOG_FILE="steg_analysis.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Function to check for stegocracker
check_dependencies() {
    if ! command -v stegocracker &> /dev/null; then
        echo -e "${RED}Error: stegocracker is not installed. Please install it and try again.${RESET}"
        exit 1
    fi
}

# Function to analyze files
analyze_files() {
    DIR_TO_ANALYZE="$1"
    echo -e "${GREEN}Analyzing files in $DIR_TO_ANALYZE...${RESET}"

    # Iterate over files in the directory
    for FILE in "$DIR_TO_ANALYZE"/*; do
        if [[ -f "$FILE" ]]; then
            # Check if the file is of a suitable type (image, audio, etc.)
            if file -b --mime-type "$FILE" | grep -qE "^(image|audio)/"; then
                echo -e "${YELLOW}Analyzing $FILE for hidden data...${RESET}"
                # Use stegocracker to attempt to crack hidden data
                OUTPUT=$(stegocracker "$FILE" 2>/dev/null)

                # Check if any hidden data was found
                if echo "$OUTPUT" | grep -q "Password:"; then
                    echo -e "${GREEN}Hidden data found in $FILE:${RESET}"
                    echo "$OUTPUT"
                    log_message "Hidden data found in $FILE."
                else
                    echo -e "${BLUE}No hidden data found in $FILE${RESET}"
                    log_message "No hidden data found in $FILE."
                fi
            else
                echo -e "${RED}Skipping $FILE (not an image or audio file)${RESET}"
                log_message "Skipped $FILE (not an image or audio file)."
            fi
        else
            echo -e "${RED}$FILE is not a valid file.${RESET}"
        fi
    done
}

# Main script execution
main() {
    check_dependencies

    # Prompt for directory input
    echo -e "${BLUE}Enter the directory path to analyze:${RESET}"
    read -r directory_name

    # Validate the directory
    if [ ! -d "$directory_name" ]; then
        echo -e "${RED}Error: Directory $directory_name does not exist.${RESET}"
        exit 1
    fi

    # Clear log file before starting analysis
    > "$LOG_FILE"

    analyze_files "$directory_name"

    echo -e "${GREEN}Steganography analysis completed. Results logged in $LOG_FILE.${RESET}"
}

# Run the main function
main
