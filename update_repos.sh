#!/bin/bash

# update_repos.sh - Script to update both fork and patch repositories

# Configuration - Update these paths
FORK_REPO="/Users/vanja/Creative Cloud Files Company Account a0651756@univie.ac.at 84723D5B5A2AE3390A495C11@AdobeID/Coding/decks/temp_forge/forge-full-oldschool"
PATCH_REPO="/Users/vanja/Creative Cloud Files Company Account a0651756@univie.ac.at 84723D5B5A2AE3390A495C11@AdobeID/Coding/decks"
UPSTREAM_URL="https://github.com/Card-Forge/forge.git"

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

echo -e "${BLUE}=== Updating Fork Repository ===${NC}"
cd "$FORK_REPO"
check_success

# Check if upstream remote exists
if ! git remote | grep -q "upstream"; then
    execute git remote add upstream "$UPSTREAM_URL"
    check_success
fi

execute git fetch upstream
check_success
execute git checkout master
check_success
execute git merge upstream/master
check_success
execute git push origin master
check_success

echo -e "${BLUE}=== Applying Patch Repository Changes to Fork ===${NC}"
cd "$PATCH_REPO"
check_success
execute git pull origin main
check_success

# Define Source Paths (in patch repository)
SOURCE_SHOPS_FILE="$PATCH_REPO/shops/shops.json"
SOURCE_ENEMIES_FILE="$PATCH_REPO/rewards/enemies.json"
SOURCE_CONFIG_FILE="$PATCH_REPO/config.json"
SOURCE_DECKS_DIR="$PATCH_REPO/decks/"
SOURCE_BLOCKS_FILE="$PATCH_REPO/draft/blocks.txt"

# Define Destination Paths (in fork repository)
DEST_SHOPS_DIR="$FORK_REPO/forge-gui/res/adventure/Shandalar/world"
DEST_ENEMIES_DIR="$FORK_REPO/forge-gui/res/adventure/common/world"
DEST_CONFIG_DIR="$FORK_REPO/forge-gui/res/adventure/common"
DEST_DECKS_DIR="$FORK_REPO/forge-gui/res/adventure/common/decks"
DEST_BLOCKS_DIR="$FORK_REPO/forge-gui/res/blockdata"

# Ensure directories exist
mkdir -p "$DEST_SHOPS_DIR"
mkdir -p "$DEST_ENEMIES_DIR"
mkdir -p "$DEST_CONFIG_DIR"
mkdir -p "$DEST_DECKS_DIR"
mkdir -p "$DEST_BLOCKS_DIR"

# Copy files to fork
echo -e "${BLUE}[1/5] Copying decks...${NC}"
execute cp -r "$SOURCE_DECKS_DIR"/* "$DEST_DECKS_DIR/"
check_success
echo -e "$CHECK_MARK Decks copied successfully"

echo -e "${BLUE}[2/5] Copying config.json...${NC}"
execute cp "$SOURCE_CONFIG_FILE" "$DEST_CONFIG_DIR/config.json"
check_success
echo -e "$CHECK_MARK Config copied successfully"

echo -e "${BLUE}[3/5] Copying shops.json...${NC}"
execute cp "$SOURCE_SHOPS_FILE" "$DEST_SHOPS_DIR/shops.json"
check_success
echo -e "$CHECK_MARK Shops data copied successfully"

echo -e "${BLUE}[4/5] Copying enemies.json...${NC}"
execute cp "$SOURCE_ENEMIES_FILE" "$DEST_ENEMIES_DIR/enemies.json"
check_success
echo -e "$CHECK_MARK Enemy rewards copied successfully"

echo -e "${BLUE}[5/5] Copying blocks.txt...${NC}"
execute cp "$SOURCE_BLOCKS_FILE" "$DEST_BLOCKS_DIR/blocks.txt"
check_success
echo -e "$CHECK_MARK Draft blocks copied successfully"

# Commit changes in fork
cd "$FORK_REPO"
check_success
execute git add "$DEST_DECKS_DIR/"
execute git add "$DEST_CONFIG_DIR/config.json"
execute git add "$DEST_SHOPS_DIR/shops.json"
execute git add "$DEST_ENEMIES_DIR/enemies.json"
execute git add "$DEST_BLOCKS_DIR/blocks.txt"
execute git commit -m "Apply Old School Shandalar patch updates"
check_success
execute git push origin master
check_success

echo -e "${BLUE}=== Updating Patch Repository with Latest Changes ===${NC}"
# In case any changes were made directly to the fork
cd "$PATCH_REPO"
check_success

# Ensure directories exist in patch repo
mkdir -p "$SOURCE_DECKS_DIR"
mkdir -p "$(dirname "$SOURCE_CONFIG_FILE")"
mkdir -p "$(dirname "$SOURCE_SHOPS_FILE")"
mkdir -p "$(dirname "$SOURCE_ENEMIES_FILE")"
mkdir -p "$(dirname "$SOURCE_BLOCKS_FILE")"

# Copy files from fork back to patch repo to ensure sync
execute cp -r "$DEST_DECKS_DIR/"* "$SOURCE_DECKS_DIR/"
execute cp "$DEST_CONFIG_DIR/config.json" "$SOURCE_CONFIG_FILE"
execute cp "$DEST_SHOPS_DIR/shops.json" "$SOURCE_SHOPS_FILE"
execute cp "$DEST_ENEMIES_DIR/enemies.json" "$SOURCE_ENEMIES_FILE"
execute cp "$DEST_BLOCKS_DIR/blocks.txt" "$SOURCE_BLOCKS_FILE"

# Check if there are changes to commit
if [[ $(git status --porcelain) ]]; then
    execute git add "$SOURCE_DECKS_DIR/"
    execute git add "$SOURCE_CONFIG_FILE"
    execute git add "$SOURCE_SHOPS_FILE"
    execute git add "$SOURCE_ENEMIES_FILE"
    execute git add "$SOURCE_BLOCKS_FILE"
    execute git commit -m "Sync changes from fork repository"
    check_success
    execute git push origin main
    check_success
    echo -e "$CHECK_MARK Patch repository updated with latest changes."
else
    echo -e "$CHECK_MARK No changes to commit in patch repository."
fi

echo -e "${GREEN}✅ Repositories have been successfully updated!${NC}" 