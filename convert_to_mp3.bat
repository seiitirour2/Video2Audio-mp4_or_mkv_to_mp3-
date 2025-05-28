@echo off
setlocal enabledelayedexpansion

REM ffmpegがインストールされているか確認
ffmpeg -version >nul 2>&1
if errorlevel 1 (
    echo ffmpeg is not installed or not found in PATH.
    echo Please install ffmpeg and ensure it is added to your PATH.
    goto :eof
)

echo Found ffmpeg.

REM --- Enhanced Bitrate Input Logic Start ---
REM デフォルトの品質設定
set FFMPEG_QUALITY_OPTION=-q:a 2
set QUALITY_DESC=デフォルトVBR高音質 (-q:a 2)

REM ユーザーに品質設定の入力を促す
echo 品質を指定できます。数値で入力してください。
echo 0-9: VBRモード (数値が小さいほど高品質)
echo 10以上: CBRモード (kbps単位のビットレート)
echo 何も入力せずにEnterキーを押すと、「!QUALITY_DESC!」が使用されます。
set /p USER_BITRATE="希望する品質を入力 (0-9 VBR, 10+ CBR, Enterでデフォルト): "

if not defined USER_BITRATE (
    REM ユーザーが何も入力しなかった場合 (Ctrl+ZなどでEOFになった場合など) - 通常はEnterで空文字列になる
    REM この分岐は主に USER_BITRATE 変数が「定義されていない」状態をキャッチ
    REM 通常のEnterでは USER_BITRATE は空文字列 "" となり、次の if "%USER_BITRATE%"=="" で処理される
    echo 入力がありませんでした。!QUALITY_DESC! を使用します。
) else if "%USER_BITRATE%"=="" (
    REM ユーザーがEnterキーのみを押した場合
    echo 入力がありませんでした。!QUALITY_DESC! を使用します。
) else (
    REM ユーザーが何かしら入力した場合
    set IS_VALID_INPUT=0

    REM シングルデジット (0-9) VBR のチェック
    echo "%USER_BITRATE%" | findstr /R "^[0-9]$" >nul
    if not errorlevel 1 (
        set FFMPEG_QUALITY_OPTION=-q:a %USER_BITRATE%
        set QUALITY_DESC=VBR設定 (-q:a %USER_BITRATE%)
        set IS_VALID_INPUT=1
    )

    REM シングルデジットでなかった場合、CBR (10以上の数値) のチェック
    if !IS_VALID_INPUT!==0 (
        echo "%USER_BITRATE%" | findstr /R "^[1-9][0-9]*$" >nul
        if not errorlevel 1 (
            REM 数値であることを確認できたので、10以上かどうかの追加チェックは不要
            REM (シングルデジットは既に除外されているため)
            set FFMPEG_QUALITY_OPTION=-b:a %USER_BITRATE%k
            set QUALITY_DESC=CBR設定 (%USER_BITRATE%kbps)
            set IS_VALID_INPUT=1
        )
    )

    REM 有効な入力でなかった場合
    if !IS_VALID_INPUT!==0 (
        echo 不正な入力「%USER_BITRATE%」です。!QUALITY_DESC! を使用します。
    )
)

echo !QUALITY_DESC! を使用します。
REM --- Enhanced Bitrate Input Logic End ---


REM 動画ファイル用のカウンターを初期化
set video_found=0

echo Searching for .mp4 and .mkv files in the current directory...

REM .mp4 ファイルを処理
for %%F in (*.mp4) do (
    echo Converting "%%F" to MP3...
    REM スクリプト冒頭のプロンプトで入力された値に基づいて品質オプションが決定されます。
    REM - 入力なし (Enterのみ): デフォルトのVBR中音質 (-q:a 2) を使用します。
    REM - 0～9の数値を入力: VBRモードとして扱われ、-q:a [入力値] となります (例: 5 を入力すると -q:a 5)。
    REM - 10以上の数値を入力: CBRモードとして扱われ、-b:a [入力値]k となります (例: 90 を入力すると -b:a 90k、128 を入力すると -b:a 128k)。
    REM - 不正な入力の場合: デフォルトのVBR中音質 (-q:a 2) が使用されます。
    REM
    REM 以下はffmpegで直接使えるオプションの一般的な例です (参考):
    REM VBR (可変ビットレート) オプション (数値が小さいほど高品質):
    REM   -q:a 0 (高音質)
    REM   -q:a 5 (中音質)
    REM CBR (固定ビットレート) オプション:
    REM   -b:a 128k (標準音質)
    REM   -b:a 192k (高音質)
    REM   -b:a 320k (最高音質)
    REM   -b:a 90k (カスタム例)
    REM   使用例: ffmpeg -i "%%F" -vn -b:a 90k "%%~nF.mp3"
    ffmpeg -i "%%F" -vn !FFMPEG_QUALITY_OPTION! "%%~nF.mp3"
    if errorlevel 1 (
        echo Failed to convert "%%F".
    ) else (
        echo Successfully converted "%%F" to "%%~nF.mp3" using !FFMPEG_QUALITY_OPTION!.
    )
    set video_found=1
)

REM .mkv ファイルを処理
for %%F in (*.mkv) do (
    echo Converting "%%F" to MP3...
    REM スクリプト冒頭のプロンプトで入力された値に基づいて品質オプションが決定されます。
    REM - 入力なし (Enterのみ): デフォルトのVBR中音質 (-q:a 2) を使用します。
    REM - 0～9の数値を入力: VBRモードとして扱われ、-q:a [入力値] となります (例: 5 を入力すると -q:a 5)。
    REM - 10以上の数値を入力: CBRモードとして扱われ、-b:a [入力値]k となります (例: 90 を入力すると -b:a 90k、128 を入力すると -b:a 128k)。
    REM - 不正な入力の場合: デフォルトのVBR中音質 (-q:a 2) が使用されます。
    REM
    REM 以下はffmpegで直接使えるオプションの一般的な例です (参考):
    REM VBR (可変ビットレート) オプション (数値が小さいほど高品質):
    REM   -q:a 0 (高音質)
    REM   -q:a 5 (中音質)
    REM CBR (固定ビットレート) オプション:
    REM   -b:a 128k (標準音質)
    REM   -b:a 192k (高音質)
    REM   -b:a 320k (最高音質)
    REM   -b:a 90k (カスタム例)
    REM   使用例: ffmpeg -i "%%F" -vn -b:a 90k "%%~nF.mp3"
    ffmpeg -i "%%F" -vn !FFMPEG_QUALITY_OPTION! "%%~nF.mp3"
    if errorlevel 1 (
        echo Failed to convert "%%F".
    ) else (
        echo Successfully converted "%%F" to "%%~nF.mp3" using !FFMPEG_QUALITY_OPTION!.
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
