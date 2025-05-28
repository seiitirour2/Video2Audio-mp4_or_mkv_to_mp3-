@echo off
setlocal

REM ffmpegがインストールされているか確認
ffmpeg -version >nul 2>&1
if errorlevel 1 (
    echo ffmpeg is not installed or not found in PATH.
    echo Please install ffmpeg and ensure it is added to your PATH.
    goto :eof
)

echo Found ffmpeg.

REM 動画ファイル用のカウンターを初期化
set video_found=0

echo Searching for .mp4 and .mkv files in the current directory...

REM .mp4 ファイルを処理
for %%F in (*.mp4) do (
    echo Converting "%%F" to MP3...
    REM 現在のコマンドは可変ビットレート(VBR)で高音質のMP3を生成します (-q:a 0)。
    REM 固定ビットレート(CBR)に変更したい場合は、 "-q:a 0" の部分を置き換えてください。
    REM 例:
    REM - 標準音質 (128kbps): -b:a 128k
    REM - 高音質 (192kbps): -b:a 192k
    REM - 最高音質 (320kbps): -b:a 320k
    REM 例: ffmpeg -i "%%F" -vn -b:a 192k "%%~nF.mp3"
    ffmpeg -i "%%F" -vn -q:a 0 "%%~nF.mp3"
    if errorlevel 1 (
        echo Failed to convert "%%F".
    ) else (
        echo Successfully converted "%%F" to "%%~nF.mp3".
    )
    set video_found=1
)

REM .mkv ファイルを処理
for %%F in (*.mkv) do (
    echo Converting "%%F" to MP3...
    REM 現在のコマンドは可変ビットレート(VBR)で高音質のMP3を生成します (-q:a 0)。
    REM 固定ビットレート(CBR)に変更したい場合は、 "-q:a 0" の部分を置き換えてください。
    REM 例:
    REM - 標準音質 (128kbps): -b:a 128k
    REM - 高音質 (192kbps): -b:a 192k
    REM - 最高音質 (320kbps): -b:a 320k
    REM 例: ffmpeg -i "%%F" -vn -b:a 192k "%%~nF.mp3"
    ffmpeg -i "%%F" -vn -q:a 0 "%%~nF.mp3"
    if errorlevel 1 (
        echo Failed to convert "%%F".
    ) else (
        echo Successfully converted "%%F" to "%%~nF.mp3".
    )
    set video_found=1
)

REM 動画ファイルが処理されたか確認
if %video_found%==0 (
    echo No .mp4 or .mkv files found in the current directory.
) else (
    echo All found video files have been processed.
)

endlocal
echo Conversion process finished.
goto :eof
