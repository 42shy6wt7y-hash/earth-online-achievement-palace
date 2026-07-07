$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$dist = Join-Path $root "dist"
$tempRoot = Join-Path $env:TEMP "eoap-csharp-installer-build"
$payload = Join-Path $tempRoot "payload"
$payloadZip = Join-Path $tempRoot "payload.zip"
$source = Join-Path $PSScriptRoot "windows-installer\EarthOnlineInstaller.cs"
$setup = Join-Path $dist "EarthOnlineAchievementPalace-Setup.exe"
$nodeExe = "C:\Program Files\nodejs\node.exe"
$csc = "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319\csc.exe"

if (-not (Test-Path $nodeExe)) {
  throw "Cannot find node.exe at $nodeExe"
}
if (-not (Test-Path $csc)) {
  throw "Cannot find csc.exe at $csc"
}

Remove-Item -Recurse -Force $dist, $tempRoot -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $payload, $dist | Out-Null

powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "make-windows-icon.ps1")

Copy-Item -LiteralPath (Join-Path $root "server.js") -Destination $payload
Copy-Item -LiteralPath (Join-Path $root "README.md") -Destination $payload
Copy-Item -LiteralPath (Join-Path $root "launch-earth-online-achievement-palace.ps1") -Destination $payload
Copy-Item -LiteralPath (Join-Path $root "public") -Destination $payload -Recurse
Copy-Item -LiteralPath (Join-Path $root "build") -Destination $payload -Recurse
New-Item -ItemType Directory -Force -Path (Join-Path $payload "runtime") | Out-Null
Copy-Item -LiteralPath $nodeExe -Destination (Join-Path $payload "runtime\node.exe")

Compress-Archive -Path (Join-Path $payload "*") -DestinationPath $payloadZip -Force

$icon = Join-Path $root "build\app-icon.ico"
$args = @(
  "/nologo",
  "/target:winexe",
  "/platform:x64",
  "/out:$setup",
  "/win32icon:$icon",
  "/resource:$payloadZip,payload.zip",
  "/reference:System.IO.Compression.FileSystem.dll",
  "/reference:System.Windows.Forms.dll",
  $source
)

& $csc @args

if (-not (Test-Path $setup)) {
  throw "Installer was not created: $setup"
}

Write-Host "Created $setup"
