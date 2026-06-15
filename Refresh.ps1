# Refresh.ps1
param(
    [string]$RawBase = "https://raw.githubusercontent.com/Psimoo/GTNL_2.9_Server_Autoupdate/refs/heads/main/mods/"
)

# 切换到脚本所在目录
Set-Location (Split-Path -Parent $MyInvocation.MyCommand.Path)

$packwizExe = Join-Path (Get-Location) "packwiz.exe"
if (-not (Test-Path $packwizExe)) {
    Write-Host "Error: packwiz.exe not found in current directory ($(Get-Location))" -ForegroundColor Red
    Write-Host "Please place packwiz.exe in the same folder as this script." -ForegroundColor Yellow
    exit 1
}

Write-Host "Using packwiz at: $packwizExe" -ForegroundColor Gray

Write-Host "Updating URLs in .pw.toml files..." -ForegroundColor Cyan

$modsDir = Join-Path (Get-Location) "mods"
if (-not (Test-Path $modsDir)) {
    Write-Host "Error: mods folder not found" -ForegroundColor Red
    exit 1
}

foreach ($jarFile in Get-ChildItem "$modsDir\*.jar") {
    $jarName = $jarFile.Name
    $baseName = $jarFile.BaseName
    $hyphenIndex = $baseName.IndexOf('-')
    if ($hyphenIndex -gt 0) {
        $baseName = $baseName.Substring(0, $hyphenIndex)
    }
    $metaFile = Join-Path $modsDir "$baseName.pw.toml"
    $newUrl = $RawBase + $jarName

    if (Test-Path $metaFile) {
        Write-Host "Updating: $metaFile -> $newUrl"
        $content = Get-Content $metaFile -Raw
        $newContent = $content -replace '(?<=url\s*=\s*")[^"]*', $newUrl
        Set-Content $metaFile -Value $newContent -NoNewline
    } else {
        Write-Host "Warning: Missing metadata file $metaFile" -ForegroundColor Yellow
    }
}

Write-Host "`nRunning packwiz refresh --build..." -ForegroundColor Cyan
& $packwizExe refresh --build
if ($LASTEXITCODE -ne 0) {
    Write-Host "packwiz refresh --build failed" -ForegroundColor Red
    exit 1
}

Write-Host "`nDone. Now you can git add/commit/push." -ForegroundColor Green
Write-Host "Note: Make sure the new JAR files have been pushed to GitHub first." -ForegroundColor Yellow