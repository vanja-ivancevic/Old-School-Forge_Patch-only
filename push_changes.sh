#!/bin/bash

# push_changes.sh - Script to commit and push changes to both repositories
# Run this after editing any files in the patch repository

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
CHECK_MARK="${GREEN}✓${NC}"

# Configuration - Use the same paths as in update_repos.sh
PATCH_REPO="/Users/vanja/Creative Cloud Files Company Account a0651756@univie.ac.at 84723D5B5A2AE3390A495C11@AdobeID/Coding/decks"
FORK_REPO="/Users/vanja/Creative Cloud Files Company Account a0651756@univie.ac.at 84723D5B5A2AE3390A495C11@AdobeID/Coding/decks/fresh_clone/forge-full-oldschool"

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

# Ask for commit message
echo -e "${BLUE}Enter commit message:${NC}"
read -r COMMIT_MESSAGE

if [ -z "$COMMIT_MESSAGE" ]; then
    echo -e "${RED}Error: Commit message cannot be empty.${NC}"
    exit 1
fi

# 1. First commit and push to patch repository
echo -e "${BLUE}=== Committing changes to patch repository ===${NC}"
cd "$PATCH_REPO"
check_success

# Check if there are changes to commit
if [[ ! $(git status --porcelain) ]]; then
    echo -e "${YELLOW}No changes detected in patch repository.${NC}"
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
    
    echo -e "$CHECK_MARK Changes committed and pushed to patch repository."
fi

# 2. Run update_repos.sh to sync changes to fork
echo -e "${BLUE}=== Running update_repos.sh to sync changes to fork ===${NC}"
execute "$PATCH_REPO/update_repos.sh"

echo -e "${GREEN}✅ Changes have been committed and pushed to both repositories!${NC}" 