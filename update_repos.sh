#!/bin/bash

# update_repos.sh - Script to manage the Old School Shandalar patch repository

# Configuration
PATCH_REPO="/Users/vanja/Creative Cloud Files Company Account a0651756@univie.ac.at 84723D5B5A2AE3390A495C11@AdobeID/Coding/decks"

# Console colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
CHECK_MARK="${GREEN}✓${NC}"

# Function to display commands being executed
execute() {
    echo -e "${YELLOW}$ $@${NC}"
    "$@"
}

# Function to check command success
check_success() {
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Command failed. Exiting.${NC}"
        exit 1
    fi
}

# Process command line arguments
COMMIT_MESSAGE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--commit)
            COMMIT_MESSAGE="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  -c, --commit \"message\"     Commit changes with the given message"
            echo "  -h, --help                 Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help to see available options."
            exit 1
            ;;
    esac
done

# If patch repository exists and has changes, commit them
if [ -d "$PATCH_REPO/.git" ]; then
    cd "$PATCH_REPO"
    check_success
    
    # Pull latest changes
    echo -e "${BLUE}=== Updating patch repository from remote ===${NC}"
    execute git pull origin main
    
    # If commit message provided, commit changes
    if [ ! -z "$COMMIT_MESSAGE" ]; then
        echo -e "${BLUE}=== Committing changes to patch repository ===${NC}"
        
        # Check if there are changes to commit
        if [[ ! $(git status --porcelain) ]]; then
            echo -e "${YELLOW}No changes detected in the repository.${NC}"
        else
            # Add all changes
            execute git add .
            check_success
            
            # Commit changes
            execute git commit -m "$COMMIT_MESSAGE"
            check_success
            
            # Push changes
            execute git push origin main
            check_success
            
            echo -e "$CHECK_MARK Changes committed and pushed to the repository."
        fi
    fi
else
    echo -e "${RED}Error: The patch repository at $PATCH_REPO does not appear to be a git repository.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Repository has been successfully updated!${NC}" 