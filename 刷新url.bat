@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ===== 请修改为你的 GitHub RAW 前缀 =====
set "RAW_BASE=https://raw.githubusercontent.com/Psimoo/GTNL_2.9_Server_Autoupdate/refs/heads/main/mods/"
:: ========================================

echo 正在更新 mods 文件夹中 JAR 文件的 URL...

if not exist "mods" (
    echo 错误：mods 文件夹不存在
    pause
    exit /b 1
)

:: 遍历所有 .jar 文件
for %%f in ("mods\*.jar") do (
    set "jarfile=%%f"
    set "namefull=%%~nf"
    set "jarname=%%~nxf"

    :: 提取基础名：取第一个连字符之前的部分（如果没有连字符，则取整个文件名）
    for /f "usebackq delims=" %%a in (`powershell -Command "&{$n='!namefull!'; $i=$n.IndexOf('-'); if($i -gt 0){$n.Substring(0,$i)}else{$n}}"`) do set "basename=%%a"

    set "metafile=mods\!basename!.pw.toml"
    set "new_url=%RAW_BASE%!jarname!"

    if exist "!metafile!" (
        echo 更新: !metafile! -> !new_url!
        :: 使用 PowerShell 正则替换 url 行（兼容 PowerShell 5.1）
        powershell -Command "(Get-Content '!metafile!' -Raw) -replace '(?<=url = \")[^\"]*', '!new_url!' | Set-Content '!metafile!' -NoNewline"
    ) else (
        echo 警告: 未找到对应的元数据文件 !metafile!，请手动创建。
    )
)

:: 运行 packwiz refresh --build 重新生成所有哈希值
echo.
echo 正在重新生成所有文件的哈希值...
packwiz refresh --build
if errorlevel 1 (
    echo packwiz refresh --build 失败，请确保 packwiz 已安装并在 PATH 中。
    pause
    exit /b 1
)

echo.
echo 完成！现在可以使用 git add/commit/push 提交更改。
echo 注意：请先确保新的 JAR 文件已经推送到 GitHub，否则 RAW 链接会 404。
pause