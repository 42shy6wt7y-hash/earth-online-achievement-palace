$ErrorActionPreference = "Stop"

$appRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$node = Join-Path $appRoot "runtime\node.exe"
$server = Join-Path $appRoot "server.js"
$logDir = Join-Path $env:LOCALAPPDATA "EarthOnlineAchievementPalace\logs"
$archiveDir = Join-Path $env:LOCALAPPDATA "EarthOnlineAchievementPalace\achievement-archive"

New-Item -ItemType Directory -Force -Path $logDir | Out-Null
New-Item -ItemType Directory -Force -Path $archiveDir | Out-Null

function Test-AppServer([int]$Port) {
  try {
    $response = Invoke-RestMethod -Uri "http://127.0.0.1:$Port/api/achievements" -Method Get -TimeoutSec 1
    return $null -ne $response
  } catch {
    return $false
  }
}

$port = $null
foreach ($candidate in 3317..3399) {
  if (Test-AppServer $candidate) {
    $port = $candidate
    break
  }
}

if (-not $port) {
  foreach ($candidate in 3317..3399) {
    $existing = Get-NetTCPConnection -LocalPort $candidate -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $existing) {
      $port = $candidate
      break
    }
  }
}

if (-not $port) {
  throw "No available local port between 3317 and 3399."
}

if (-not (Test-AppServer $port)) {
  $env:ARCHIVE_DIR = $archiveDir
  $env:PORT = [string]$port
  Start-Process -FilePath $node -ArgumentList "`"$server`"" -WorkingDirectory $appRoot -WindowStyle Hidden -RedirectStandardOutput (Join-Path $logDir "server.log") -RedirectStandardError (Join-Path $logDir "server-error.log")
  Start-Sleep -Milliseconds 900
}

$url = "http://127.0.0.1:$port"

$browserCandidates = @(
  (Join-Path $env:ProgramFiles "Google\Chrome\Application\chrome.exe"),
  (Join-Path ${env:ProgramFiles(x86)} "Google\Chrome\Application\chrome.exe"),
  (Join-Path $env:ProgramFiles "Microsoft\Edge\Application\msedge.exe"),
  (Join-Path ${env:ProgramFiles(x86)} "Microsoft\Edge\Application\msedge.exe")
) | Where-Object { $_ -and (Test-Path $_) }

if ($browserCandidates.Count -gt 0) {
  Start-Process -FilePath $browserCandidates[0] -ArgumentList $url
} else {
  Start-Process -FilePath "rundll32.exe" -ArgumentList "url.dll,FileProtocolHandler $url"
}
