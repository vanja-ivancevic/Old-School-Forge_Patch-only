# Old School Shandalar Repository Management

This guide helps you maintain both your fork of the main Forge repository and your patch repository.

## Repository Structure

- **Main Fork**: Your fork of the official Forge repository
- **Patch Repository**: Repository containing your custom decks and modifications

## Setup

Ensure both repositories are properly cloned:

```bash
# Clone your patch repository (if not already done)
git clone https://github.com/vanja-ivancevic/Old-School-Forge.git

# Setup the fork repository
mkdir -p fresh_clone
cd fresh_clone
git clone https://github.com/vanja-ivancevic/forge-full-oldschool.git
```

## Using the Update Script

The `update_repos.sh` script handles all repository management tasks in one place:

### Basic Update

To update both repositories (syncing from upstream and applying changes):

```bash
./update_repos.sh
```

### Quick Workflow for Editing Files

When you've made changes and want to commit them to both repositories:

```bash
./update_repos.sh -c "Your commit message here"
```

This will:
1. Commit and push your changes to the patch repository
2. Update your fork from upstream
3. Apply your patches to the fork
4. Push the changes to your fork

### Skip Upstream Update

If you've made changes and don't need to update from upstream:

```bash
./update_repos.sh -s -c "Your commit message here"
```

### Help

For all available options:

```bash
./update_repos.sh -h
```

## Script Options

| Option | Description |
|--------|-------------|
| `-c, --commit "message"` | Commit changes with the given message |
| `-s, --skip-upstream` | Skip updating from upstream |
| `-h, --help` | Show help message |

## What the Script Does

1. **Commit changes** to patch repository (if `-c` option is used)
2. **Update fork** from upstream (unless `-s` option is used)
3. **Apply changes** from patch repository to fork
4. **Commit and push** changes to fork
5. **Sync back** any changes to ensure both repositories are in sync

## File Structure

The script manages these files between repositories:

| Patch Repository | Fork Repository |
|------------------|-----------------|
| decks/starter/*.dck | forge-gui/res/adventure/common/decks/starter/ |
| decks/standard/*.dck | forge-gui/res/adventure/common/decks/standard/ |
| decks/miniboss/*.dck | forge-gui/res/adventure/common/decks/miniboss/ |
| decks/boss/*.dck | forge-gui/res/adventure/common/decks/boss/ |
| config.json | forge-gui/res/adventure/common/config.json |
| shops/shops.json | forge-gui/res/adventure/Shandalar/world/shops.json |
| rewards/enemies.json | forge-gui/res/adventure/common/world/enemies.json |
| draft/blocks.txt | forge-gui/res/blockdata/blocks.txt |
