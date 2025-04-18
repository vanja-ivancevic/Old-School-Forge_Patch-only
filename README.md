# Old-School Shandalar Forge Conversion Patch

This patch updates various decks, enemy rewards, shop inventories, and configuration files for the Shandalar campaign in Forge to be limited to only old-border editions up to 27. May 2003 (Scourge).

**Note:** This is a patch for the main Forge Shandalar adventure game, which can be found here: [https://github.com/Card-Forge/forge](https://github.com/Card-Forge/forge)

All enemy decks have been modified to fit this old-school experience! The initial decklist were developed by a complex multi-AI-agent framework, but I'm pretty satisfied with the result and am enjoying my first "old-border only" playthrough. I make minor changes to the enemy decklists when I notice something.

Boosters are available in the shops for all sets except Alpha, Beta, Unlimited and Revised. Getting power 9 is VERY difficult, as only bosses have them. Getting dual lands is less difficult, but still feels like an achievement at the moment.

**Tested Version:** This patch has been tested and is intended for **forge-2.0.03**. Compatibility with other versions is not guaranteed.

## Checklist:

Done:
- Global set and card restrictions

In progress: 
- Enemy Decks (All processed, but playtesting needed)
- Rewards
- Shops

Todo:
- Drafts
- Special Rewards
- Java hardcoded scripts

## How to Install

### Option 1: Manual Installation (Recommended)
!!! Applying the patch through the executables likely doesn't work properly yet. I recommend to just copy and replace the enemies.json, shops.json, config.json and all the deck folders in your respective game's /res/... folders.

Config.json (set restrictions): /res/adventure/common

Decks folder: /res/adventure/common

Enemies.json: /res/adventure/common/world

Shops.json: /res/adventure/Shandalar/world

### Option 2: Using Scripts (Currently being tested)
1.  **Download:** Download the `.zip` file attached to the latest release from the [Releases Page](https://github.com/vanja-ivancevic/Old-School-Forge/releases).
2.  **Unzip:** Unzip the downloaded file. This will create a folder named something like `Old-School-Forge-vX.Y.Z`.
3.  **Copy Folder:** Copy this entire unzipped folder into your main Forge game directory (the one containing the `res` folder).
4.  **Navigate & Run Script:**
    *   **On Windows:**
        *   Open Command Prompt or PowerShell.
        *   Navigate *into* the patch folder you just copied using the `cd` command.
        *   Run the script by typing: `apply_patch_win.bat` and press Enter.
    *   **On macOS/Linux:**
        *   Open a Terminal window.
        *   Navigate *into* the patch folder you just copied using the `cd` command.
        *   Make the script executable (only needed once): `chmod +x apply_patch_mac.sh`
        *   Run the script: `./apply_patch_mac.sh` (or `sh apply_patch_mac.sh`)
5.  **Verify:** The script will print messages indicating which files and folders are being copied. Check for any error messages.
6.  **Launch Forge:** Start Forge and launch a new game.

---

*For known issues or to report new ones, please check the [GitHub Issues Page](/https://github.com/vanja-ivancevic/Old-School-Forge/issues/).*

<img width="1457" alt="image" src="https://github.com/user-attachments/assets/7b7837fa-3fba-49d4-b8df-9b9d2b4c1c59" />
