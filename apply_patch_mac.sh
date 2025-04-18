#!/bin/bash

echo "Starting Game Patch Script (macOS/Linux)..."
echo "---------------------------------------------"

# Assume the script is run from *within* the extracted patch folder (e.g., Old-School-Forge-v1.1)
# which has been copied into the game's root directory.
# Patch files are expected in a 'patch_files' subdirectory relative to the script.
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &amp;> /dev/null &amp;&amp; pwd )"
PATCH_DATA_ROOT="$SCRIPT_DIR/patch_files"
GAME_ROOT="$( dirname "$SCRIPT_DIR" )" # Game root is the parent directory of the script's directory

# --- Define Source Paths (within patch_files) ---
SOURCE_SHOPS_FILE="$PATCH_DATA_ROOT/shops/shops.json"
SOURCE_ENEMIES_FILE="$PATCH_DATA_ROOT/rewards/enemies.json"
SOURCE_CONFIG_FILE="$PATCH_DATA_ROOT/config.json"
SOURCE_DECKS_DIR="$PATCH_DATA_ROOT/decks/"

# --- Define Destination Paths (within game structure) ---
DEST_SHOPS_DIR="$GAME_ROOT/res/adventure/Shandalar/world"
DEST_ENEMIES_DIR="$GAME_ROOT/res/adventure/common/world"
DEST_CONFIG_DIR="$GAME_ROOT/res/adventure/common"
DEST_DECKS_DIR="$GAME_ROOT/res/adventure/common/decks"

# --- Check if patch_files directory exists ---
if [ ! -d "$PATCH_DATA_ROOT" ]; then
    echo "ERROR: 'patch_files' directory not found at $PATCH_DATA_ROOT"
    echo "Please ensure the 'patch_files' folder containing the patch data is in the same directory as this script (inside the folder you copied from the release zip)."
    exit 1
fi

# --- Function to copy file with feedback ---
copy_file() {
    local src=$1
    local dest_dir=$2
    local filename=$(basename "$src")
    local dest_path="$dest_dir/$filename"

    echo "Processing: $filename"
    if [ ! -f "$src" ]; then
        echo "  ERROR: Source file not found: $src"
        return 1
    fi
    # Ensure destination directory exists
    mkdir -p "$dest_dir"
    if [ $? -ne 0 ]; then
        echo "  ERROR: Could not create destination directory: $dest_dir"
        return 1
    fi
    # Copy and overwrite
    cp -f "$src" "$dest_path"
    if [ $? -eq 0 ]; then
        echo "  Copied: $filename -> $dest_dir/"
        return 0
    else
        echo "  ERROR copying $filename to $dest_dir/"
        return 1
    fi
}

# --- Function to copy deck subfolders ---
copy_decks() {
    local src_root=$1
    local dest_root=$2
    local overall_success=0 # 0 for success, 1 for error

    echo "Processing deck subfolders from $src_root..."
    if [ ! -d "$src_root" ]; then
        echo "  ERROR: Source decks directory not found: $src_root"
        return 1
    fi

    # Ensure destination root exists
    mkdir -p "$dest_root"
    if [ $? -ne 0 ]; then
        echo "  ERROR: Could not create destination decks directory: $dest_root"
        return 1
    fi

    # Use cp -R for simplicity and guaranteed overwrite behavior matching shutil.copytree
     echo "  Using cp -R to copy decks..."
     # Copy contents recursively, force overwrite
     # The '.' ensures we copy the *contents* of src_root, not the folder itself
     cp -R -f "$src_root/." "$dest_root/"
     if [ $? -ne 0 ]; then
        echo "  ERROR copying decks with cp."
        overall_success=1
    else
         echo "  Successfully copied/updated deck contents."
    fi

    return $overall_success
}


# --- Perform Patching ---
errors_found=0

echo -e "\n1. Patching shops.json..."
copy_file "$SOURCE_SHOPS_FILE" "$DEST_SHOPS_DIR" || errors_found=1

echo -e "\n2. Patching enemies.json..."
copy_file "$SOURCE_ENEMIES_FILE" "$DEST_ENEMIES_DIR" || errors_found=1

echo -e "\n3. Patching config.json..."
copy_file "$SOURCE_CONFIG_FILE" "$DEST_CONFIG_DIR" || errors_found=1

echo -e "\n4. Patching decks..."
copy_decks "$SOURCE_DECKS_DIR" "$DEST_DECKS_DIR" || errors_found=1


# --- Summary ---
echo -e "\n---------------------------------------------"
if [ $errors_found -eq 0 ]; then
    echo "Patch process completed successfully!"
else
    echo "Patch process finished with one or more errors. Please review the messages above."
fi

exit $errors_found