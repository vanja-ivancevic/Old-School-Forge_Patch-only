# Forge Repository Management Guide

This guide helps you maintain both your fork of the main Forge repository and your patch repository.

## Repository Structure

- **Main Fork**: Your fork of the official Forge repository
- **Patch Repository**: Repository containing your custom decks and modifications

## Update Workflow

### 1. Update Your Fork with Upstream Changes

```bash
# Navigate to your fork repository
cd path/to/forge-fork

# Add upstream repository if not already added
git remote add upstream https://github.com/Card-Forge/forge.git  # Use the actual upstream URL

# Fetch upstream changes
git fetch upstream

# Checkout your main branch
git checkout master

# Merge upstream changes
git merge upstream/master

# Push changes to your fork
git push origin master
```

### 2. Apply Custom Changes from Patch Repository

```bash
# Navigate to your patch repository
cd path/to/patch-repo

# Make sure it's up to date with your latest changes
git pull origin main

# Copy the necessary files to your fork
# Decks
cp -r decks/* /path/to/forge-fork/forge-gui/res/adventure/common/decks/

# Configuration
cp config.json /path/to/forge-fork/forge-gui/res/adventure/common/config.json

# Shop inventory
cp shops/shops.json /path/to/forge-fork/forge-gui/res/adventure/Shandalar/world/shops.json

# Enemy rewards
cp rewards/enemies.json /path/to/forge-fork/forge-gui/res/adventure/common/world/enemies.json

# Navigate back to your fork
cd /path/to/forge-fork

# Add and commit changes
git add forge-gui/res/adventure/common/decks/
git add forge-gui/res/adventure/common/config.json
git add forge-gui/res/adventure/Shandalar/world/shops.json
git add forge-gui/res/adventure/common/world/enemies.json
git commit -m "Apply Old School Shandalar patch updates"

# Push changes to your fork
git push origin master
```

### 3. Update Patch Repository with New Changes

If you make new changes directly in your fork:

```bash
# Navigate to your patch repository
cd path/to/patch-repo

# Copy the updated files from your fork
cp -r /path/to/forge-fork/forge-gui/res/adventure/common/decks/* decks/
cp /path/to/forge-fork/forge-gui/res/adventure/common/config.json config.json
cp /path/to/forge-fork/forge-gui/res/adventure/Shandalar/world/shops.json shops/shops.json
cp /path/to/forge-fork/forge-gui/res/adventure/common/world/enemies.json rewards/enemies.json

# Add and commit changes
git add decks/
git add config.json
git add shops/shops.json
git add rewards/enemies.json
git commit -m "Sync changes from fork repository"

# Push changes to your patch repository
git push origin main
```

## Automation Script

For easier updates, you can use the provided shell script:

```bash
#!/bin/bash

# update_repos.sh - Script to update both fork and patch repositories

# Configuration - Update these paths
FORK_REPO="/path/to/forge-fork"
PATCH_REPO="/path/to/patch-repo"
UPSTREAM_URL="https://github.com/Card-Forge/forge.git"  # Use the actual upstream URL

# Function to display commands being executed
execute() {
    echo "$ $@"
    "$@"
}

# Function to check command success
check_success() {
    if [ $? -ne 0 ]; then
        echo "Error: Command failed. Exiting."
        exit 1
    fi
}

echo "=== Updating Fork Repository ==="
cd "$FORK_REPO"
check_success

# Check if upstream remote exists
if ! git remote | grep -q "upstream"; then
    execute git remote add upstream "$UPSTREAM_URL"
    check_success
fi

# Update from upstream
execute git fetch upstream
check_success
execute git checkout master
check_success
execute git merge upstream/master
check_success
execute git push origin master
check_success

echo "=== Applying Patch Repository Changes to Fork ==="
cd "$PATCH_REPO"
check_success
execute git pull origin main
check_success

# Define source and destination paths
SOURCE_SHOPS_FILE="$PATCH_REPO/shops/shops.json"
SOURCE_ENEMIES_FILE="$PATCH_REPO/rewards/enemies.json"
SOURCE_CONFIG_FILE="$PATCH_REPO/config.json"
SOURCE_DECKS_DIR="$PATCH_REPO/decks/"

DEST_SHOPS_DIR="$FORK_REPO/forge-gui/res/adventure/Shandalar/world"
DEST_ENEMIES_DIR="$FORK_REPO/forge-gui/res/adventure/common/world"
DEST_CONFIG_DIR="$FORK_REPO/forge-gui/res/adventure/common"
DEST_DECKS_DIR="$FORK_REPO/forge-gui/res/adventure/common/decks"

# Ensure directories exist
mkdir -p "$DEST_SHOPS_DIR"
mkdir -p "$DEST_ENEMIES_DIR"
mkdir -p "$DEST_CONFIG_DIR"
mkdir -p "$DEST_DECKS_DIR"

# Copy files to fork
execute cp -r "$SOURCE_DECKS_DIR"/* "$DEST_DECKS_DIR/"
check_success
execute cp "$SOURCE_CONFIG_FILE" "$DEST_CONFIG_DIR/config.json"
check_success
execute cp "$SOURCE_SHOPS_FILE" "$DEST_SHOPS_DIR/shops.json"
check_success
execute cp "$SOURCE_ENEMIES_FILE" "$DEST_ENEMIES_DIR/enemies.json"
check_success

# Commit changes in fork
cd "$FORK_REPO"
check_success
execute git add "$DEST_DECKS_DIR"
execute git add "$DEST_CONFIG_DIR/config.json"
execute git add "$DEST_SHOPS_DIR/shops.json"
execute git add "$DEST_ENEMIES_DIR/enemies.json"
execute git commit -m "Apply Old School Shandalar patch updates"
check_success
execute git push origin master
check_success

echo "Repositories have been successfully updated!"
```

Make the script executable with `chmod +x update_repos.sh` and run it when you need to update both repositories.
