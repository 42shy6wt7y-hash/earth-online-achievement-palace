$ErrorActionPreference = "Stop"

$appRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$node = Join-Path $appRoot "runtime\node.exe"
$server = Join-Path $appRoot "server.js"
$logDir = Join-Path $env:LOCALAPPDATA "EarthOnlineAchievementPalace\logs"
$archiveDir = Join-Path $env:LOCALAPPDATA "EarthOnlineAchievementPalace\achievement-archive"
$portFile = Join-Path $logDir "port.txt"
$defaultPort = 3317
$portRange = 3317..3399

New-Item -ItemType Directory -Force -Path $logDir | Out-Null
New-Item -ItemType Directory -Force -Path $archiveDir | Out-Null

function Test-AppServer([int]$Port) {
  $response = $null
  try {
    $request = [System.Net.WebRequest]::Create("http://127.0.0.1:$Port/api/achievements")
    $request.Method = "GET"
    $request.Timeout = 250
    $request.ReadWriteTimeout = 250
    $response = $request.GetResponse()
    return $true
  } catch {
    return $false
  } finally {
    if ($response) { $response.Close() }
  }
}

function Test-PortAvailable([int]$Port) {
  $listener = $null
  try {
    $address = [System.Net.IPAddress]::Parse("127.0.0.1")
    $listener = [System.Net.Sockets.TcpListener]::new($address, $Port)
    $listener.Start()
    return $true
  } catch {
    return $false
  } finally {
    if ($listener) { $listener.Stop() }
  }
}

function Save-Port([int]$Port) {
  Set-Content -LiteralPath $portFile -Value ([string]$Port) -Encoding ASCII
}

$port = $null

if (Test-Path $portFile) {
  $savedPortText = (Get-Content -LiteralPath $portFile -Raw -ErrorAction SilentlyContinue).Trim()
  $savedPort = 0
  if ([int]::TryParse($savedPortText, [ref]$savedPort) -and $portRange -contains $savedPort -and (Test-AppServer $savedPort)) {
    $port = $savedPort
  }
}

if (-not $port) {
  if (Test-AppServer $defaultPort) {
    $port = $defaultPort
  } elseif (Test-PortAvailable $defaultPort) {
    $port = $defaultPort
  }
}

if (-not $port) {
  foreach ($candidate in $portRange) {
    if (Test-AppServer $candidate) {
      $port = $candidate
      break
    }
    if (Test-PortAvailable $candidate) {
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
  for ($i = 0; $i -lt 60; $i++) {
    if (Test-AppServer $port) { break }
    Start-Sleep -Milliseconds 100
  }
}

Save-Port $port
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
