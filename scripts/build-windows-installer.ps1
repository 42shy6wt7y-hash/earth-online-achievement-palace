$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$dist = Join-Path $root "dist"
$tempRoot = Join-Path $env:TEMP "eoap-installer-build"
$payload = Join-Path $tempRoot "payload"
$work = Join-Path $tempRoot "iexpress"
$setup = Join-Path $tempRoot "EarthOnlineAchievementPalace-Setup.exe"
$finalSetup = Join-Path $dist "EarthOnlineAchievementPalace-Setup.exe"
$sed = Join-Path $work "installer.sed"
$nodeExe = "C:\Program Files\nodejs\node.exe"

if (-not (Test-Path $nodeExe)) {
  throw "Cannot find node.exe at $nodeExe"
}

Remove-Item -Recurse -Force $dist, $tempRoot -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $payload, $work | Out-Null

powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "make-windows-icon.ps1")

Copy-Item -LiteralPath (Join-Path $root "server.js") -Destination $payload
Copy-Item -LiteralPath (Join-Path $root "README.md") -Destination $payload
Copy-Item -LiteralPath (Join-Path $root "launch-earth-online-achievement-palace.ps1") -Destination $payload
Copy-Item -LiteralPath (Join-Path $root "public") -Destination $payload -Recurse
Copy-Item -LiteralPath (Join-Path $root "build") -Destination $payload -Recurse
New-Item -ItemType Directory -Force -Path (Join-Path $payload "runtime") | Out-Null
Copy-Item -LiteralPath $nodeExe -Destination (Join-Path $payload "runtime\node.exe")

$payloadZip = Join-Path $work "payload.zip"
Compress-Archive -Path (Join-Path $payload "*") -DestinationPath $payloadZip -Force

Copy-Item -LiteralPath (Join-Path $PSScriptRoot "installer-template\install.cmd") -Destination $work
Copy-Item -LiteralPath (Join-Path $PSScriptRoot "installer-template\install.ps1") -Destination $work

$workEsc = $work.Replace("\", "\\")
$setupEsc = $setup.Replace("\", "\\")

@"
[Version]
Class=IEXPRESS
SEDVersion=3

[Options]
PackagePurpose=InstallApp
ShowInstallProgramWindow=0
HideExtractAnimation=1
UseLongFileName=1
InsideCompressed=0
CAB_FixedSize=0
CAB_ResvCodeSigning=0
RebootMode=N
InstallPrompt=
DisplayLicense=
FinishMessage=
TargetName=$setupEsc
FriendlyName=EarthOnlineAchievementPalace
AppLaunched=install.cmd
PostInstallCmd=<None>
AdminQuietInstCmd=
UserQuietInstCmd=
SourceFiles=SourceFiles

[Strings]
FILE0="install.cmd"
FILE1="install.ps1"
FILE2="payload.zip"

[SourceFiles]
SourceFiles0=$workEsc

[SourceFiles0]
%FILE0%=
%FILE1%=
%FILE2%=
"@ | Set-Content -LiteralPath $sed -Encoding ASCII

& "$env:SystemRoot\System32\iexpress.exe" /N /Q $sed
$iexpressExitCode = $LASTEXITCODE
Start-Sleep -Milliseconds 500

if (-not (Test-Path $setup)) {
  throw "Installer was not created: $setup. IExpress exit code: $iexpressExitCode"
}

New-Item -ItemType Directory -Force -Path $dist | Out-Null
Copy-Item -LiteralPath $setup -Destination $finalSetup -Force

Write-Host "Created $finalSetup"
