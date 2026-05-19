$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$port = 7357
$hostName = '127.0.0.1'

$chromePaths = @(
  'C:\Program Files\Google\Chrome\Application\chrome.exe',
  'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe',
  'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe',
  'C:\Program Files\Microsoft\Edge\Application\msedge.exe'
)

$browser = $chromePaths | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $browser) {
  Write-Error 'No se encontro Chrome ni Edge instalados en las rutas esperadas.'
}

Get-Process chrome, msedge, dart, flutter -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

Push-Location $projectRoot
try {
  Start-Process powershell -ArgumentList @(
    '-NoExit',
    '-Command',
    "Set-Location '$projectRoot'; flutter run -d web-server --web-hostname $hostName --web-port $port"
  )

  $url = "http://${hostName}:$port"
  $ready = $false

  for ($i = 0; $i -lt 45; $i++) {
    Start-Sleep -Seconds 1
    try {
      $response = Invoke-WebRequest $url -UseBasicParsing -TimeoutSec 2
      if ($response.StatusCode -ge 200) {
        $ready = $true
        break
      }
    } catch {
    }
  }

  if (-not $ready) {
    Write-Error "Flutter web-server no respondio en $url."
  }

  Start-Process $browser $url
  Write-Host "App abierta en $url"
} finally {
  Pop-Location
}
