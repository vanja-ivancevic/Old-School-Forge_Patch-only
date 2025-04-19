# Old-School Shandalar Forge Conversion Patch

This patch updates Forge's Shandalar campaign to only use old-border cards (from Alpha through Scourge - May 2003). It modifies:
- Card restrictions to only allow old-border sets
- Enemy decks for an authentic old-school experience
- Shop inventories 
- Rewards and configurations

## Important Links

- **[Standalone Fork Repository](https://github.com/vanja-ivancevic/Forge-Old-School-Shandalar)**: For a complete, ready-to-play version of the Old-School Shandalar experience
- **[Original Forge Repository](https://github.com/Card-Forge/forge)**: The main Forge project this patch is based on

All enemy decks have been reimagined for this old-school experience! The initial decklists were developed by a complex multi-AI-agent framework, and continue to be refined through playtesting. At least 30-40 decks have been manually reviewed and improved - including all the boss decks.

**Tested Version:** This patch has been tested and is intended for **forge-2.0.03**. Compatibility with other versions is not guaranteed.

## Features

- Boosters available in shops for all old-border sets (except Alpha, Beta, Unlimited and Revised)
- Power 9 cards are extremely rare and only obtainable from bosses
- Dual lands are challenging but satisfying to acquire
- Authentic old-school Magic feeling with only pre-modern frame cards

## Quick Start

For the fastest way to start playing, download the complete standalone version from the [Standalone Fork Repository](https://github.com/vanja-ivancevic/Forge-Old-School-Shandalar).

## How to Install (Patch Only)

If you prefer to apply this patch to an existing Forge installation:

### Option 1: Using Installation Scripts (Recommended)

1. **Download:** Download the `.zip` file from the latest release on the [Releases Page](https://github.com/vanja-ivancevic/Old-School-Forge/releases).

2. **Extract:** Extract the ZIP file into your main Forge game directory (the folder that contains the `forge.jar` file or Forge executable and the `res` folder).

3. **Run the Installation Script:**
   
   **For Windows Users:**
   - Double-click the `apply_patch_win.bat` file
   - A command window will open showing the patching progress
   - When finished, press any key to close the window

   **For Mac/Linux Users:**
   - Open Terminal
   - Navigate to the extracted folder using: `cd "path/to/extracted/folder"`
   - Make the script executable: `chmod +x apply_patch_mac.sh`
   - Run the script: `./apply_patch_mac.sh`

4. **Launch Forge:** Start Forge and begin a new Shandalar adventure game!

### Option 2: Manual Installation

If you prefer to install manually or encounter any issues with the scripts, follow these steps:

1. **Download and Extract:** Download and extract the ZIP file to any location.

2. **Copy Files:** You'll need to copy the following files to your Forge installation:

   - Copy `config.json` to: `YOUR_FORGE_FOLDER/res/adventure/common/`
   - Copy all contents of the `decks` folder to: `YOUR_FORGE_FOLDER/res/adventure/common/decks/`
   - Copy `rewards/enemies.json` to: `YOUR_FORGE_FOLDER/res/adventure/common/world/`
   - Copy `shops/shops.json` to: `YOUR_FORGE_FOLDER/res/adventure/Shandalar/world/`

   Note: Replace `YOUR_FORGE_FOLDER` with the actual path to your Forge installation.

## Troubleshooting

- **Script fails to run:** Make sure you have proper permissions to write to your Forge directory.
- **Mac users:** If you see "Cannot be opened because the developer cannot be verified" message, right-click the script and select "Open" instead of double-clicking.
- **Files not copied:** Try the manual installation method instead.
- **Game doesn't load:** Verify you've installed the patch on a compatible version of Forge.

## Development Status

✅ Completed:
- Global set and card restrictions
- Enemy decks (All processed, playtest feedback welcome!)
- Basic rewards
- Shop inventories
- Drafting (Jumpstarts still show up, but can't be played)

🔄 In Progress: 
- Special rewards
- Balance adjustments based on player feedback

## Repository Maintenance

This repository contains the patch files, while the standalone version is maintained in a separate fork. To manage both repositories, use the included `update_repos.sh` script which will:

1. Update the fork with upstream changes
2. Apply patch changes to the fork
3. Keep both repositories in sync

Run the script with `./update_repos.sh` from this directory.

## Feedback and Issues

Please report any bugs or share your feedback on the [GitHub Issues Page](https://github.com/vanja-ivancevic/Old-School-Forge/issues/).

Happy dueling in the old-school Multiverse!

<img width="1457" alt="image" src="https://github.com/user-attachments/assets/7b7837fa-3fba-49d4-b8df-9b9d2b4c1c59" />
