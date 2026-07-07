$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Windows.Forms

$appName = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String("5Zyw55CDb25saW5l5oiQ5bCx5Lit5b+D"))
$installRoot = Join-Path $env:LOCALAPPDATA "Programs\EarthOnlineAchievementPalace"
$dataRoot = Join-Path $env:LOCALAPPDATA "EarthOnlineAchievementPalace"
$payloadZip = Join-Path $PSScriptRoot "payload.zip"
$desktop = [Environment]::GetFolderPath("DesktopDirectory")
$shortcutPath = Join-Path $desktop "$appName.lnk"

New-Item -ItemType Directory -Force -Path $installRoot | Out-Null
New-Item -ItemType Directory -Force -Path $dataRoot | Out-Null

if (Test-Path $installRoot) {
  Remove-Item -Path $installRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $installRoot | Out-Null
Expand-Archive -LiteralPath $payloadZip -DestinationPath $installRoot -Force

$launcher = Join-Path $installRoot "launch-earth-online-achievement-palace.ps1"
$icon = Join-Path $installRoot "build\app-icon.ico"

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
$shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$launcher`""
$shortcut.WorkingDirectory = $installRoot
$shortcut.IconLocation = $icon
$shortcut.Description = $appName
$shortcut.Save()

$startMenuDir = Join-Path ([Environment]::GetFolderPath("Programs")) $appName
New-Item -ItemType Directory -Force -Path $startMenuDir | Out-Null
$startShortcut = $shell.CreateShortcut((Join-Path $startMenuDir "$appName.lnk"))
$startShortcut.TargetPath = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
$startShortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$launcher`""
$startShortcut.WorkingDirectory = $installRoot
$startShortcut.IconLocation = $icon
$startShortcut.Description = $appName
$startShortcut.Save()

$doneMessage = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String("5a6J6KOF5a6M5oiQ44CC5qGM6Z2i5bey5Yib5bu65b+r5o235pa55byP77yM5oiQ5bCx5qGj5qGI5Lya5L+d5a2Y5Zyo77ya"))
[System.Windows.Forms.MessageBox]::Show("$doneMessage`n$dataRoot", $appName) | Out-Null
