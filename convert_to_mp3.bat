@echo off
setlocal

REM Check if ffmpeg is installed
ffmpeg -version >nul 2>&1
if errorlevel 1 (
    echo ffmpeg is not installed or not found in PATH.
    echo Please install ffmpeg and ensure it is added to your PATH.
    goto :eof
)

echo Found ffmpeg.

REM Initialize a counter for video files
set video_found=0

echo Searching for .mp4 and .mkv files in the current directory...

REM Process .mp4 files
for %%F in (*.mp4) do (
    echo Converting "%%F" to MP3...
    ffmpeg -i "%%F" -vn -q:a 0 "%%~nF.mp3"
    if errorlevel 1 (
        echo Failed to convert "%%F".
    ) else (
        echo Successfully converted "%%F" to "%%~nF.mp3".
    )
    set video_found=1
)

REM Process .mkv files
for %%F in (*.mkv) do (
    echo Converting "%%F" to MP3...
    ffmpeg -i "%%F" -vn -q:a 0 "%%~nF.mp3"
    if errorlevel 1 (
        echo Failed to convert "%%F".
    ) else (
        echo Successfully converted "%%F" to "%%~nF.mp3".
    )
    set video_found=1
)

REM Check if any video files were processed
if %video_found%==0 (
    echo No .mp4 or .mkv files found in the current directory.
) else (
    echo All found video files have been processed.
)

endlocal
echo Conversion process finished.
goto :eof
