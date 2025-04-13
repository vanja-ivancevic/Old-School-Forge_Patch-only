@echo off
echo Starting Game Patch Script (Windows)...
echo ---------------------------------------------

:: Assume the script is run from the game's root directory.
:: Patch files are expected in a 'patch_files' subdirectory relative to the script.
set SCRIPT_DIR=%~dp0
set PATCH_DATA_ROOT=%SCRIPT_DIR%patch_files
set GAME_ROOT=%SCRIPT_DIR%

:: Remove trailing backslash if present from SCRIPT_DIR for cleaner paths
if "%GAME_ROOT:~-1%"=="\" set GAME_ROOT=%GAME_ROOT:~0,-1%
if "%PATCH_DATA_ROOT:~-1%"=="\" set PATCH_DATA_ROOT=%PATCH_DATA_ROOT:~0,-1%


:: --- Define Source Paths (within patch_files) ---
set SOURCE_SHOPS_FILE=%PATCH_DATA_ROOT%\shops\shops.json
set SOURCE_ENEMIES_FILE=%PATCH_DATA_ROOT%\rewards\enemies.json
set SOURCE_CONFIG_FILE=%PATCH_DATA_ROOT%\config.json
set SOURCE_DECKS_DIR=%PATCH_DATA_ROOT%\decks\updated_decks

:: --- Define Destination Paths (within game structure) ---
set DEST_SHOPS_DIR=%GAME_ROOT%\res\adventure\Shandalar\world
set DEST_ENEMIES_DIR=%GAME_ROOT%\res\adventure\common\world
set DEST_CONFIG_DIR=%GAME_ROOT%\res\adventure\common
set DEST_DECKS_DIR=%GAME_ROOT%\res\adventure\common\decks

:: --- Check if patch_files directory exists ---
if not exist "%PATCH_DATA_ROOT%" (
    echo ERROR: 'patch_files' directory not found at %PATCH_DATA_ROOT%
    echo Please ensure the 'patch_files' folder containing the patch data is in the same directory as this script.
    pause
    exit /b 1
)

set ERRORS_FOUND=0

:: --- Function-like section for copying files ---
:copy_file
    set SRC_FILE=%~1
    set DEST_DIR=%~2
    set FILENAME=%~nx1

    echo.
    echo Processing: %FILENAME%
    if not exist "%SRC_FILE%" (
        echo   ERROR: Source file not found: %SRC_FILE%
        set ERRORS_FOUND=1
        goto :eof
    )
    :: Ensure destination directory exists
    if not exist "%DEST_DIR%" (
        echo   Creating directory: %DEST_DIR%
        md "%DEST_DIR%" > nul 2>&1
        if errorlevel 1 (
            echo   ERROR: Could not create destination directory: %DEST_DIR%
            set ERRORS_FOUND=1
            goto :eof
        )
    )
    :: Copy and overwrite (/Y suppresses overwrite prompt)
    echo   Copying %FILENAME% to %DEST_DIR%\
    copy /Y "%SRC_FILE%" "%DEST_DIR%\" > nul
    if errorlevel 1 (
        echo   ERROR copying %FILENAME% to %DEST_DIR%\
        set ERRORS_FOUND=1
    ) else (
        echo   Copied successfully.
    )
    goto :eof

:: --- Function-like section for copying decks ---
:copy_decks
    set SRC_ROOT=%~1
    set DEST_ROOT=%~2

    echo.
    echo Processing deck subfolders from %SRC_ROOT%...
    if not exist "%SRC_ROOT%" (
        echo   ERROR: Source decks directory not found: %SRC_ROOT%
        set ERRORS_FOUND=1
        goto :eof
    )

    :: Ensure destination root exists
     if not exist "%DEST_ROOT%" (
        echo   Creating directory: %DEST_ROOT%
        md "%DEST_ROOT%" > nul 2>&1
         if errorlevel 1 (
            echo   ERROR: Could not create destination decks directory: %DEST_ROOT%
            set ERRORS_FOUND=1
            goto :eof
        )
    )

    :: Use xcopy to copy directory contents recursively
    :: /E - Copies directories and subdirectories, including empty ones.
    :: /I - Assumes destination is a directory if it doesn't exist.
    :: /Y - Suppresses prompting to confirm you want to overwrite an existing destination file.
    :: /Q - Does not display file names while copying. Remove for verbose output.
    :: /R - Overwrites read-only files.
    :: /H - Copies hidden and system files also.
    echo   Copying deck contents using xcopy...
    xcopy "%SRC_ROOT%\*" "%DEST_ROOT%\" /E /I /Y /R /H > nul
    if errorlevel 1 (
        echo   ERROR copying decks with xcopy. Check permissions or paths. Errorlevel: %errorlevel%
        set ERRORS_FOUND=1
    ) else (
        echo   Successfully copied/updated deck contents.
    )
    goto :eof


:: --- Perform Patching ---
call :copy_file "%SOURCE_SHOPS_FILE%" "%DEST_SHOPS_DIR%"
call :copy_file "%SOURCE_ENEMIES_FILE%" "%DEST_ENEMIES_DIR%"
call :copy_file "%SOURCE_CONFIG_FILE%" "%DEST_CONFIG_DIR%"
call :copy_decks "%SOURCE_DECKS_DIR%" "%DEST_DECKS_DIR%"


:: --- Summary ---
echo.
echo ---------------------------------------------
if %ERRORS_FOUND% equ 0 (
    echo Patch process completed successfully!
) else (
    echo Patch process finished with one or more errors. Please review the messages above.
)

echo.
pause :: Keep window open until user presses a key
exit /b %ERRORS_FOUND%