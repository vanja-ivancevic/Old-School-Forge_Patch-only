#!/bin/bash

# Console colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
CHECK_MARK="${GREEN}✓${NC}"
CROSS_MARK="${RED}✗${NC}"

# Title and header
clear
echo -e "${BLUE}======================================================${NC}"
echo -e "${BLUE}      OLD SCHOOL FORGE PATCH INSTALLER (macOS/Linux)  ${NC}"
echo -e "${BLUE}======================================================${NC}"
echo

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PATCH_FOLDER="$(basename "$SCRIPT_DIR")"
PATCH_DATA_ROOT="$SCRIPT_DIR" # Use the patch directory directly
GAME_ROOT="$( dirname "$SCRIPT_DIR" )" # Game root is the parent directory of the script's directory

echo -e "Installer Location: ${YELLOW}$SCRIPT_DIR${NC}"
echo -e "Forge Game Location: ${YELLOW}$GAME_ROOT${NC}"
echo
echo -e "IMPORTANT: This will patch your Forge installation to use"
echo -e "           Old-School cards only in the Shandalar campaign."
echo

# Check for sudo/root if needed
check_permissions() {
    # Try writing to the destination to see if we have permissions
    local test_file="$GAME_ROOT/os_forge_permission_test"
    if touch "$test_file" 2>/dev/null; then
        rm "$test_file"
        return 0
    else
        echo -e "${YELLOW}Warning: You might not have write permissions to the Forge directory.${NC}"
        echo -e "This script may need administrator privileges to complete the installation."
        echo -e "If you see permission errors, please run the script with 'sudo'."
        echo
        return 1
    fi
}

# Ask for confirmation
read -p "Ready to install the patch? (y/n): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo -e "\nInstallation cancelled. No changes were made."
    exit 0
fi

# Create backup directory
BACKUP_DIR="$GAME_ROOT/old_school_backup_$(date +%Y%m%d_%H%M%S)"
echo
echo -e "Creating backup directory: ${YELLOW}$BACKUP_DIR${NC}"
mkdir -p "$BACKUP_DIR"

# --- Define Source Paths (directly in patch directory) ---
SOURCE_SHOPS_FILE="$PATCH_DATA_ROOT/shops/shops.json"
SOURCE_ENEMIES_FILE="$PATCH_DATA_ROOT/rewards/enemies.json"
SOURCE_CONFIG_FILE="$PATCH_DATA_ROOT/config.json"
SOURCE_BLOCKS_FILE="$PATCH_DATA_ROOT/draft/blocks.txt"
SOURCE_DECKS_DIR="$PATCH_DATA_ROOT/decks/"

# --- Define Destination Paths (within game structure) ---
DEST_SHOPS_DIR="$GAME_ROOT/res/adventure/Shandalar/world"
DEST_ENEMIES_DIR="$GAME_ROOT/res/adventure/common/world"
DEST_CONFIG_DIR="$GAME_ROOT/res/adventure/common"
DEST_BLOCKS_DIR="$GAME_ROOT/res/blockdata"
DEST_DECKS_DIR="$GAME_ROOT/res/adventure/common/decks"

# Initialize counters
files_copied=0
deck_files_copied=0
backup_files=0
errors_found=0

# --- Function to backup a file ---
backup_file() {
    local src=$1
    local backup_subdir=$2
    local filename=$(basename "$src")
    
    if [ ! -f "$src" ]; then
        return 0
    fi
    
    # Create backup subdirectory if needed
    local full_backup_dir="$BACKUP_DIR/$backup_subdir"
    mkdir -p "$full_backup_dir"
    
    # Copy file to backup
    cp -f "$src" "$full_backup_dir/"
    if [ $? -eq 0 ]; then
        backup_files=$((backup_files + 1))
        return 0
    else
        return 1
    fi
}

# --- Function to copy file with feedback ---
copy_file() {
    local src=$1
    local dest_dir=$2
    local filename=$(basename "$src")
    local dest_path="$dest_dir/$filename"

    echo -e "${YELLOW}[Copying File]${NC} $filename"
    if [ ! -f "$src" ]; then
        echo -e "  $CROSS_MARK ERROR: Source file not found: $src"
        return 1
    fi
    # Ensure destination directory exists
    mkdir -p "$dest_dir"
    if [ $? -ne 0 ]; then
        echo -e "  $CROSS_MARK ERROR: Could not create destination directory: $dest_dir"
        return 1
    fi
    # Copy and overwrite
    cp -f "$src" "$dest_path"
    if [ $? -eq 0 ]; then
        echo -e "  $CHECK_MARK Copied successfully."
        files_copied=$((files_copied + 1))
        return 0
    else
        echo -e "  $CROSS_MARK ERROR copying $filename to $dest_dir/"
        return 1
    fi
}

# --- Function to copy deck subfolders ---
copy_decks() {
    local src_root=$1
    local dest_root=$2
    local overall_success=0 # 0 for success, 1 for error
    local file_count=0

    echo -e "${YELLOW}[Copying Decks]${NC} from $src_root..."
    if [ ! -d "$src_root" ]; then
        echo -e "  $CROSS_MARK ERROR: Source decks directory not found: $src_root"
        return 1
    fi

    # Ensure destination root exists
    mkdir -p "$dest_root"
    if [ $? -ne 0 ]; then
        echo -e "  $CROSS_MARK ERROR: Could not create destination decks directory: $dest_root"
        return 1
    fi

    # Count files before copying
    if [ -d "$src_root" ]; then
        file_count=$(find "$src_root" -type f | wc -l)
        file_count=$(echo $file_count | tr -d '[:space:]')
    fi
    
    echo -e "  Processing $file_count deck files..."

    # Copy contents recursively, force overwrite
    # The '.' ensures we copy the *contents* of src_root, not the folder itself
    cp -R -f "$src_root/." "$dest_root/"
    if [ $? -ne 0 ]; then
       echo -e "  $CROSS_MARK ERROR copying decks with cp."
       overall_success=1
    else
        deck_files_copied=$file_count
        echo -e "  $CHECK_MARK Successfully copied $file_count deck files."
    fi

    return $overall_success
}

# --- Perform Backups ---
echo
echo -e "${BLUE}[1/6] Creating backups of original files...${NC}"
backup_file "$DEST_SHOPS_DIR/shops.json" "Shandalar/world"
backup_file "$DEST_ENEMIES_DIR/enemies.json" "common/world"
backup_file "$DEST_CONFIG_DIR/config.json" "common"
backup_file "$DEST_BLOCKS_DIR/blocks.txt" "blockdata"

# Backup deck files
echo "    Backing up original deck files..."
if [ -d "$DEST_DECKS_DIR" ]; then
    find "$DEST_DECKS_DIR" -name "*.dck" -type f | while read file; do
        rel_path=$(dirname "${file#$DEST_DECKS_DIR/}")
        backup_file "$file" "common/decks/$rel_path"
    done
fi
echo -e "    $CHECK_MARK $backup_files files backed up to $BACKUP_DIR"

# --- Perform Patching ---
check_permissions

echo
echo -e "${BLUE}[2/6] Patching shops.json...${NC}"
copy_file "$SOURCE_SHOPS_FILE" "$DEST_SHOPS_DIR" || errors_found=1

echo
echo -e "${BLUE}[3/6] Patching enemies.json...${NC}"
copy_file "$SOURCE_ENEMIES_FILE" "$DEST_ENEMIES_DIR" || errors_found=1

echo
echo -e "${BLUE}[4/6] Patching config.json...${NC}"
copy_file "$SOURCE_CONFIG_FILE" "$DEST_CONFIG_DIR" || errors_found=1

echo
echo -e "${BLUE}[5/6] Patching blocks.txt...${NC}"
copy_file "$SOURCE_BLOCKS_FILE" "$DEST_BLOCKS_DIR" || errors_found=1

echo
echo -e "${BLUE}[6/6] Patching decks...${NC}"
copy_decks "$SOURCE_DECKS_DIR" "$DEST_DECKS_DIR" || errors_found=1

# --- Calculate total files copied ---
total_files_copied=$((files_copied + deck_files_copied))

# --- Summary ---
echo
echo -e "${BLUE}======================================================${NC}"
echo -e "${BLUE}                INSTALLATION SUMMARY                  ${NC}"
echo -e "${BLUE}======================================================${NC}"
echo
echo -e "Files backed up: ${YELLOW}$backup_files${NC}"
echo -e "Files installed: ${YELLOW}$total_files_copied${NC}"
echo

if [ $errors_found -eq 0 ]; then
    echo -e "$CHECK_MARK ${GREEN}PATCH INSTALLED SUCCESSFULLY!${NC}"
    echo
    echo -e "    You can now start Forge and enjoy your"
    echo -e "    old-school Shandalar adventure!"
else
    echo -e "$CROSS_MARK ${RED}INSTALLATION COMPLETED WITH ERRORS${NC}"
    echo
    echo -e "    Please check the messages above for details."
    echo -e "    You may need to manually copy some files."
fi

echo
echo -e "If you need to restore your original files, you can find"
echo -e "them in the backup directory:"
echo -e "${YELLOW}$BACKUP_DIR${NC}"
echo
echo -e "${BLUE}======================================================${NC}"

exit $errors_found