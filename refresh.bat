@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ===== 请修改为你的 GitHub RAW 前缀 =====
set "RAW_URL_PREFIX=https://raw.githubusercontent.com/Psimoo/GTNL_2.9_Server_Autoupdate/refs/heads/main/mods/
:: ====================================

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

    :: 提取基础名：去掉最后一个连字符及其后面的版本号
    for /f "usebackq delims=" %%a in (`powershell -Command "&{$n='!namefull!'; $i=$n.LastIndexOf('-'); if($i -ge 0){$n.Substring(0,$i)}else{$n}}"`) do set "basename=%%a"

    set "metafile=mods\!basename!.pw.toml"
    echo 处理: !jarfile!  -> 基础名: !basename!

    :: 生成新的 download.url
    set "download_url=%RAW_URL_PREFIX%!jarname!"

    :: 检查元数据文件是否存在
    if exist "!metafile!" (
        echo 更新 URL: !metafile!
        :: 使用 PowerShell 仅更新 download.url 字段
        powershell -Command "&{$f='!metafile!'; $c=Get-Content $f -Raw | ConvertFrom-Toml; $c.download.url='!download_url!'; $c | ConvertTo-Toml | Set-Content $f}"
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
pause