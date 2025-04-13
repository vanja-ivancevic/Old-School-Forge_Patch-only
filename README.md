# Old-School Shandalar Forge Conversion Patch

This patch updates various decks, enemy rewards, shop inventories, and configuration files for the Shandalar campaign in Forge to be limited to only old-border editions up to 27. May 2003 (Scourge).

All enemy decks have been modified to fit this old-school experience! The initial decklist were developed by a complex multi-AI-agent framework, but I'm pretty satisfied with the result and am enjoying my first "old-border only" playthrough. I make minor changes to the enemy decklists when I notice something.

Boosters are available in the shops for all sets except Alpha, Beta, Unlimited and Revised. Getting power 9 is VERY difficult, as only bosses have them. Getting dual lands is less difficult, but still feels like an achievement at the moment.

**Tested Version:** This patch has been tested and is intended for **forge-2.0.03**. Compatibility with other versions is not guaranteed.

## How to Install

!!! Applying the patch through the executables likely doesn't work properly yet. I recommend to just copy and replace the enemies.json, shops.json, config.json and all the deck folders in your respective game's /res/... folders.

1.  **Download:** Download the `.zip` file attached to the latest release from the [Releases Page](https://github.com/vanja-ivancevic/Old-School-Forge/releases).
2.  **Extract:** Extract the contents of the downloaded `.zip` file directly into your main Forge game directory. This is the directory that contains the `res` folder. After extraction, you should see `apply_patch_mac.sh`, `apply_patch_win.bat`, and a `patch_files` folder alongside your existing Forge files and folders.
3.  **Run the Correct Script:**
    *   **On Windows:** Double-click the `apply_patch_win.bat` file. Follow any prompts that appear.
    *   **On macOS/Linux:**
        *   Open a Terminal window in your Forge game directory.
        *   Make the script executable by running: `chmod +x apply_patch_mac.sh`
        *   Run the script: `./apply_patch_mac.sh`
4.  **Verify:** The script will print messages indicating which files and folders are being copied. Check for any error messages.
5.  **Launch Forge:** Start Forge and enjoy the updated Shandalar experience!


---

*For known issues or to report new ones, please check the [GitHub Issues Page](/https://github.com/vanja-ivancevic/Old-School-Forge/issues/).*

<img width="1457" alt="image" src="https://github.com/user-attachments/assets/7b7837fa-3fba-49d4-b8df-9b9d2b4c1c59" />
