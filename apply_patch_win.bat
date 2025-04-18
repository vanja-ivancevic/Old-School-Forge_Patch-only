@echo off
title Old School Forge Patch Installer
color 17
cls

echo =====================================================
echo      OLD SCHOOL FORGE PATCH INSTALLER (Windows)
echo =====================================================
echo.

:: Check for Admin rights and self-elevate if needed
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo      *** Admin rights required. Requesting elevation... ***
    echo.
    goto UACPrompt
) else (
    goto GotAdmin
)

:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
exit /B

:GotAdmin
if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
pushd "%CD%"
CD /D "%~dp0"

:: Get the script directory
set SCRIPT_DIR=%~dp0
set PATCH_FOLDER=%~n0
for %%I in ("%SCRIPT_DIR%.") do set PATCH_FOLDER=%%~nI
set PATCH_DATA_ROOT=%SCRIPT_DIR%
:: Go up one level from the script directory to find the game root
pushd "%SCRIPT_DIR%.."
set GAME_ROOT=%CD%
popd

echo Installer Location: %SCRIPT_DIR%
echo Forge Game Location: %GAME_ROOT%
echo.
echo IMPORTANT: This will patch your Forge installation to use
echo            Old-School cards only in the Shandalar campaign.

:: Remove trailing backslash if present from SCRIPT_DIR for cleaner paths
if "%GAME_ROOT:~-1%"=="\" set GAME_ROOT=%GAME_ROOT:~0,-1%
if "%PATCH_DATA_ROOT:~-1%"=="\" set PATCH_DATA_ROOT=%PATCH_DATA_ROOT:~0,-1%

:: Ask for confirmation
echo.
set /p CONFIRM=Ready to install the patch? (Y/N): 
if /i "%CONFIRM%" NEQ "Y" goto :CANCELLED

:: Make backup directory
set BACKUP_DIR=%GAME_ROOT%\old_school_backup_%date:~10,4%%date:~4,2%%date:~7,2%
echo.
echo Creating backup directory: %BACKUP_DIR%
mkdir "%BACKUP_DIR%" 2>nul

:: --- Define Source Paths (directly in patch directory) ---
set SOURCE_SHOPS_FILE=%PATCH_DATA_ROOT%\shops\shops.json
set SOURCE_ENEMIES_FILE=%PATCH_DATA_ROOT%\rewards\enemies.json
set SOURCE_CONFIG_FILE=%PATCH_DATA_ROOT%\config.json
set SOURCE_DECKS_DIR=%PATCH_DATA_ROOT%\decks\

:: --- Define Destination Paths (within game structure) ---
set DEST_SHOPS_DIR=%GAME_ROOT%\res\adventure\Shandalar\world
set DEST_ENEMIES_DIR=%GAME_ROOT%\res\adventure\common\world
set DEST_CONFIG_DIR=%GAME_ROOT%\res\adventure\common
set DEST_DECKS_DIR=%GAME_ROOT%\res\adventure\common\decks

:: Initialize counters
set FILES_COPIED=0
set DECK_FILES_COPIED=0
set BACKUP_FILES=0
set ERRORS_FOUND=0

:: --- Backup section ---
:backup_file
    set SRC_FILE=%~1
    set BACKUP_SUBDIR=%~2
    
    if not exist "%SRC_FILE%" goto :eof
    
    :: Create backup subdirectory if needed
    set FULL_BACKUP_DIR=%BACKUP_DIR%\%BACKUP_SUBDIR%
    if not exist "%FULL_BACKUP_DIR%" (
        mkdir "%FULL_BACKUP_DIR%" >nul 2>&1
    )
    
    :: Copy file to backup
    copy /Y "%SRC_FILE%" "%FULL_BACKUP_DIR%\" >nul 2>&1
    if not errorlevel 1 (
        set /a BACKUP_FILES+=1
    )
    goto :eof

:: Backup important files
echo.
echo [1/5] Creating backups of original files...
call :backup_file "%DEST_SHOPS_DIR%\shops.json" "Shandalar\world"
call :backup_file "%DEST_ENEMIES_DIR%\enemies.json" "common\world"
call :backup_file "%DEST_CONFIG_DIR%\config.json" "common"

:: Backup decks directory (only backing up .dck files to save space)
echo     Backing up original deck files...
for /r "%DEST_DECKS_DIR%" %%F in (*.dck) do (
    set REL_PATH=%%~dpF
    set REL_PATH=!REL_PATH:%DEST_DECKS_DIR%\=!
    call :backup_file "%%F" "common\decks\!REL_PATH!"
)
echo     [✓] %BACKUP_FILES% files backed up to %BACKUP_DIR%

:: --- Function-like section for copying files ---
:copy_file
    set SRC_FILE=%~1
    set DEST_DIR=%~2
    set FILENAME=%~nx1

    echo.
    echo [Copying File] %FILENAME%
    if not exist "%SRC_FILE%" (
        echo     [✗] ERROR: Source file not found: %SRC_FILE%
        set ERRORS_FOUND=1
        goto :eof
    )
    :: Ensure destination directory exists
    if not exist "%DEST_DIR%" (
        echo     Creating directory: %DEST_DIR%
        md "%DEST_DIR%" > nul 2>&1
        if errorlevel 1 (
            echo     [✗] ERROR: Could not create destination directory: %DEST_DIR%
            set ERRORS_FOUND=1
            goto :eof
        )
    )
    :: Copy and overwrite (/Y suppresses overwrite prompt)
    copy /Y "%SRC_FILE%" "%DEST_DIR%\" > nul
    if errorlevel 1 (
        echo     [✗] ERROR copying %FILENAME% to %DEST_DIR%\
        set ERRORS_FOUND=1
    ) else (
        echo     [✓] Copied successfully.
        set /a FILES_COPIED+=1
    )
    goto :eof

:: --- Function-like section for copying decks ---
:copy_decks
    set SRC_ROOT=%~1
    set DEST_ROOT=%~2
    set FILE_COUNT=0

    echo.
    echo [Copying Decks] from %SRC_ROOT%...
    if not exist "%SRC_ROOT%" (
        echo     [✗] ERROR: Source decks directory not found: %SRC_ROOT%
        set ERRORS_FOUND=1
        goto :eof
    )

    :: Ensure destination root exists
     if not exist "%DEST_ROOT%" (
        echo     Creating directory: %DEST_ROOT%
        md "%DEST_ROOT%" > nul 2>&1
         if errorlevel 1 (
            echo     [✗] ERROR: Could not create destination decks directory: %DEST_ROOT%
            set ERRORS_FOUND=1
            goto :eof
        )
    )

    :: Count files in source directory
    set FILE_COUNT=0
    for /r "%SRC_ROOT%" %%F in (*) do set /a FILE_COUNT+=1
    
    :: Progress indicator
    echo     Processing %FILE_COUNT% deck files...
    
    :: Use xcopy to copy directory contents recursively
    :: /E - Copies directories and subdirectories, including empty ones.
    :: /I - Assumes destination is a directory if it doesn't exist.
    :: /Y - Suppresses prompting to confirm you want to overwrite an existing destination file.
    :: /Q - Does not display file names while copying. Remove for verbose output.
    :: /R - Overwrites read-only files.
    :: /H - Copies hidden and system files also.
    xcopy "%SRC_ROOT%\*" "%DEST_ROOT%\" /E /I /Y /R /H > nul
    if errorlevel 1 (
        echo     [✗] ERROR copying decks with xcopy. Check permissions or paths.
        set ERRORS_FOUND=1
    ) else (
        set DECK_FILES_COPIED=%FILE_COUNT%
        echo     [✓] Successfully copied %FILE_COUNT% deck files.
    )
    goto :eof


:: --- Perform Patching ---
echo.
echo [2/5] Patching shops.json...
call :copy_file "%SOURCE_SHOPS_FILE%" "%DEST_SHOPS_DIR%"

echo.
echo [3/5] Patching enemies.json...
call :copy_file "%SOURCE_ENEMIES_FILE%" "%DEST_ENEMIES_DIR%"

echo.
echo [4/5] Patching config.json...
call :copy_file "%SOURCE_CONFIG_FILE%" "%DEST_CONFIG_DIR%"

echo.
echo [5/5] Patching decks...
call :copy_decks "%SOURCE_DECKS_DIR%" "%DEST_DECKS_DIR%"

:: --- Calculate total files copied ---
set /a TOTAL_FILES_COPIED=%FILES_COPIED%+%DECK_FILES_COPIED%

:: --- Summary ---
echo.
echo =====================================================
echo                INSTALLATION SUMMARY
echo =====================================================
echo.
echo Files backed up: %BACKUP_FILES%
echo Files installed: %TOTAL_FILES_COPIED%
echo.

if %ERRORS_FOUND% equ 0 (
    color 2F
    echo [✓] PATCH INSTALLED SUCCESSFULLY!
    echo.
    echo     You can now start Forge and enjoy your
    echo     old-school Shandalar adventure!
) else (
    color 4F
    echo [✗] INSTALLATION COMPLETED WITH ERRORS
    echo.
    echo     Please check the messages above for details.
    echo     You may need to manually copy some files.
)

echo.
echo If you need to restore your original files, you can find
echo them in the backup directory:
echo %BACKUP_DIR%
echo.
echo =====================================================
goto :END

:CANCELLED
echo.
echo Installation cancelled. No changes were made.
echo.

:END
echo.
echo Press any key to exit...
pause >nul