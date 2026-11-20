param([string]$Accion = "lanzar")

# ============================================================
#  app.ps1 - Lanzador rapido de la App Medident (SIEMPRE release)
#
#  Uso:
#      app            -> build web release + servidor + ventana Chrome
#      app estado     -> que esta corriendo + como matarlo
#      app stop       -> mata el servidor que dejo en fondo
#      app watch      -> al guardar, recompila y recarga sola
#      app limpiar    -> cierra SOLO la ventana propia de la App
#
#  Estrategia copiada de Tenderos (que ya funciona estable):
#   - flutter build web --release --no-wasm-dry-run  (evita crashes CanvasKit)
#   - servidor Python con Cache-Control: no-cache    (evita JS viejo)
#   - Chrome con perfil DEDICADO (nunca tu Chrome personal)
# ============================================================

$URL          = "http://localhost:5174"
$Raiz         = Split-Path -Parent $MyInvocation.MyCommand.Path
$ServidorPy   = Join-Path $Raiz "servidor_app.py"
$WatchPidFile = Join-Path $Raiz "app_watch.pid"
$WebJs        = Join-Path $Raiz "build\web\main.dart.js"

$AppProfileDir = Join-Path $env:LOCALAPPDATA "MedidentApp\chrome-profile"
$NavPidFile    = Join-Path $env:LOCALAPPDATA "MedidentApp\todos.pid"

# ------------------------------------------------------------
#  Utilidades
# ------------------------------------------------------------

function Test-Servidor {
    try {
        $r = Invoke-WebRequest -Uri $URL -UseBasicParsing -TimeoutSec 4
        return ($r.StatusCode -eq 200)
    } catch { return $false }
}

function Get-Servidor5174 {
    try {
        $conn = Get-NetTCPConnection -LocalPort 5174 -State Listen -ErrorAction Stop |
            Select-Object -First 1
        if (-not $conn) { return $null }
        return Get-CimInstance Win32_Process -Filter "ProcessId=$($conn.OwningProcess)" -ErrorAction SilentlyContinue
    } catch { return $null }
}

function Get-FuenteMasReciente {
    $fuentes = @()
    foreach ($p in @("lib", "web", "assets", "pubspec.yaml", "pubspec.lock")) {
        $full = Join-Path $Raiz $p
        if (Test-Path -LiteralPath $full) {
            $item = Get-Item -LiteralPath $full
            if ($item.PSIsContainer) {
                $fuentes += Get-ChildItem -LiteralPath $full -Recurse -File -ErrorAction SilentlyContinue
            } else {
                $fuentes += $item
            }
        }
    }
    if ($fuentes.Count -eq 0) { return $null }
    return ($fuentes | Sort-Object LastWriteTime -Descending | Select-Object -First 1).LastWriteTime
}

function Test-SalidaVieja([string]$salida) {
    if (-not (Test-Path -LiteralPath $salida)) { return $true }
    $nuevo = Get-FuenteMasReciente
    if ($null -eq $nuevo) { return $false }
    return ($nuevo -gt (Get-Item -LiteralPath $salida).LastWriteTime)
}

function Invoke-BuildWeb {
    Write-Host " Compilando release (flutter build web --release --no-wasm-dry-run)..." -ForegroundColor Cyan
    Push-Location $Raiz
    & flutter build web --release --no-wasm-dry-run | Out-Host
    $code = $LASTEXITCODE
    Pop-Location
    return $code
}

# ------------------------------------------------------------
#  Servidor web (5174) sin cache
# ------------------------------------------------------------

function Start-ServidorSinCache {
    Start-Process python -ArgumentList "`"$ServidorPy`"" -WorkingDirectory $Raiz -WindowStyle Hidden
    Start-Sleep -Seconds 2
    if (Test-Servidor) {
        Write-Host " Servidor LEVANTADO en 5174 (build\web, sin cache)." -ForegroundColor Green
        Write-Host "   -> Para matar este servicio:  app stop" -ForegroundColor Yellow
        return $true
    }
    return $false
}

function Ensure-Servidor {
    if (Test-Servidor) {
        $srv = Get-Servidor5174
        if ($srv -and $srv.CommandLine -match "servidor_app\.py") { return $true }
        if ($srv) {
            Write-Host " Servidor viejo detectado (con cache). Reiniciando..." -ForegroundColor Yellow
            Stop-Process -Id $srv.ProcessId -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 1
        }
    }
    if (Test-Servidor) { return $true }
    return (Start-ServidorSinCache)
}

# ------------------------------------------------------------
#  Navegador: SOLO la ventana PROPIA de la App (perfil dedicado)
# ------------------------------------------------------------

function Test-PerfilApp([string]$cmd) {
    if ([string]::IsNullOrWhiteSpace($cmd)) { return $false }
    return ($cmd.IndexOf($AppProfileDir, [System.StringComparison]::OrdinalIgnoreCase) -ge 0)
}

function Get-NavegadorApp {
    $res = @()
    try {
        $procs = Get-CimInstance Win32_Process -ErrorAction Stop |
            Where-Object {
                ($_.Name -match '^(chrome|msedge)\.exe$') -and (Test-PerfilApp $_.CommandLine)
            }
        foreach ($p in $procs) {
            $gp = Get-Process -Id $p.ProcessId -ErrorAction SilentlyContinue
            if ($gp -and -not [string]::IsNullOrWhiteSpace($gp.MainWindowTitle)) {
                $res += $gp
            }
        }
    } catch {}
    return $res
}

function Get-RutaNavegador {
    $candidatos = @(
        "C:\Program Files\Google\Chrome\Application\chrome.exe",
        "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
        "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
        "C:\Program Files\Microsoft\Edge\Application\msedge.exe"
    )
    foreach ($c in $candidatos) { if (Test-Path -LiteralPath $c) { return $c } }
    return $null
}

function Open-Navegador([string]$Url) {
    $ruta = Get-RutaNavegador
    if (-not $ruta) {
        Write-Host " No hay Chrome/Edge instalado. Abre: $Url" -ForegroundColor Red
        return $false
    }
    New-Item -ItemType Directory -Force -Path $AppProfileDir | Out-Null
    $argumentos = @(
        "--user-data-dir=$AppProfileDir",
        "--new-window",
        "--no-first-run",
        "--no-default-browser-check",
        $Url
    )
    Start-Process $ruta -ArgumentList $argumentos | Out-Null
    for ($i = 0; $i -lt 20; $i++) {
        Start-Sleep -Milliseconds 500
        $p = @(Get-NavegadorApp)
        if ($p.Count -gt 0) {
            Set-Content -LiteralPath $NavPidFile -Value "$($p[0].Id)" -Encoding ASCII
            $nombre = if ($ruta -match "chrome") { "Chrome" } else { "Edge" }
            Write-Host " Ventana PROPIA de la App abierta en $nombre (perfil dedicado)." -ForegroundColor Green
            Write-Host "   (Tu Chrome personal no se toca.)" -ForegroundColor Gray
            return $true
        }
    }
    Write-Host " Abri el navegador pero no pude confirmar la ventana propia." -ForegroundColor Yellow
    return $false
}

function Invoke-RecargarVentana($proc) {
    try {
        $shell = New-Object -ComObject WScript.Shell
        if (-not $shell.AppActivate($proc.Id)) { return $false }
        Start-Sleep -Milliseconds 600
        $v = Get-Date -Format 'HHmmss'
        $shell.SendKeys("^l")
        Start-Sleep -Milliseconds 250
        $shell.SendKeys("$URL/?v=app-$v")
        Start-Sleep -Milliseconds 250
        $shell.SendKeys("{ENTER}")
        Start-Sleep -Milliseconds 400
        return $true
    } catch { return $false }
}

# ------------------------------------------------------------
#  Web: build si hay cambios + servidor + recarga/ventana
# ------------------------------------------------------------

function Update-Web {
    if (Test-SalidaVieja $WebJs) {
        $code = Invoke-BuildWeb
        if ($code -ne 0) {
            Write-Host " BUILD WEB FALLO (codigo $code). NO se relanza la version vieja." -ForegroundColor Red
            return $false
        }
        Write-Host " Build web RELEASE actualizado." -ForegroundColor Green
    } else {
        Write-Host " Build web ya incluye los ultimos cambios." -ForegroundColor Green
    }

    if (-not (Ensure-Servidor)) {
        Write-Host " El servidor NO arranco. Revisa python / build\web / servidor_app.py." -ForegroundColor Red
        return $false
    }

    $procs = @(Get-NavegadorApp)
    if ($procs.Count -gt 1) {
        foreach ($extra in ($procs | Select-Object -Skip 1)) {
            Stop-Process -Id $extra.Id -Force -ErrorAction SilentlyContinue
        }
        $procs = @($procs[0])
        Write-Host " Ventanas extra de la App cerradas." -ForegroundColor Gray
    }
    if ($procs.Count -gt 0) {
        $recargadas = 0
        foreach ($p in $procs) {
            if (Invoke-RecargarVentana $p) {
                $recargadas++
                Write-Host " Ventana propia recargada (build nuevo)." -ForegroundColor Green
            }
        }
        if ($recargadas -gt 0) { return $true }
        Write-Host " No pude recargar sola. Recarga manual: $URL" -ForegroundColor Yellow
        return $true
    }
    $v = "app-" + (Get-Date -Format "HHmmss")
    return (Open-Navegador "$URL/?v=$v")
}

# ------------------------------------------------------------
#  Servicios en fondo
# ------------------------------------------------------------

function Get-WatchPid {
    if (-not (Test-Path -LiteralPath $WatchPidFile)) { return 0 }
    $txt = (Get-Content -LiteralPath $WatchPidFile -Raw -ErrorAction SilentlyContinue).Trim()
    if ($txt -match '^\d+$') { return [int]$txt }
    return 0
}

function Test-WatchVivo {
    $pidW = Get-WatchPid
    if ($pidW -le 0) { return $false }
    $proc = Get-CimInstance Win32_Process -Filter "ProcessId=$pidW" -ErrorAction SilentlyContinue
    if (-not $proc) { return $false }
    if ($proc.CommandLine -notmatch "app\.ps1") { return $false }
    return $true
}

function Show-Servicios {
    $hay = $false
    if (Test-Servidor) {
        $hay = $true
        Write-Host "   - SERVIDOR web 5174 (servidor_app.py) -> matar: app stop" -ForegroundColor Gray
    }
    if (Test-WatchVivo) {
        $hay = $true
        Write-Host "   - WATCH (auto-update) PID $(Get-WatchPid) -> matar: Ctrl+C | app stop" -ForegroundColor Gray
    }
    if (-not $hay) { Write-Host "   - Ningun servicio nuestro corriendo." -ForegroundColor Gray }
}

function Invoke-Stop {
    $algo = $false
    $pidW = Get-WatchPid
    if ($pidW -gt 0) {
        $proc = Get-CimInstance Win32_Process -Filter "ProcessId=$pidW" -ErrorAction SilentlyContinue
        if ($proc -and $proc.CommandLine -match "app\.ps1") {
            Stop-Process -Id $pidW -Force -ErrorAction SilentlyContinue
            Write-Host " WATCH (PID $pidW) MATADO." -ForegroundColor Green
            $algo = $true
        }
        Remove-Item -LiteralPath $WatchPidFile -Force -ErrorAction SilentlyContinue
    }
    $srv = Get-Servidor5174
    if ($srv -and $srv.CommandLine -match "servidor_app\.py") {
        Stop-Process -Id $srv.ProcessId -Force -ErrorAction SilentlyContinue
        Write-Host " SERVIDOR 5174 MATADO." -ForegroundColor Green
        $algo = $true
    }
    if (-not $algo) {
        Write-Host " Nada que matar: no hay servicios nuestros corriendo." -ForegroundColor Yellow
    }
    Write-Host " (No se tocan: chrome, dart ni flutter - son tuyos/IDE)." -ForegroundColor Gray
    exit 0
}

# ------------------------------------------------------------
#  ACCIONES
# ------------------------------------------------------------

function Invoke-Estado {
    $srv = Test-Servidor
    $ventanas = @(Get-NavegadorApp)
    Write-Host ""
    Write-Host "================ ESTADO (App Medident) ================" -ForegroundColor Cyan
    if ($srv) { Write-Host " SERVIDOR 5174            : VIVO" -ForegroundColor Green }
    else      { Write-Host " SERVIDOR 5174            : APAGADO" -ForegroundColor Red }
    if ($ventanas.Count -gt 0) {
        Write-Host " VENTANA App (perfil propio): $($ventanas.Count)" -ForegroundColor Green
        foreach ($p in $ventanas) { Write-Host "   - [$($p.ProcessName)] $($p.MainWindowTitle)" -ForegroundColor Gray }
    } else {
        Write-Host " VENTANA App (perfil propio): NINGUNA" -ForegroundColor Yellow
    }
    if (Test-SalidaVieja $WebJs) { Write-Host " BUILD WEB                 : DESACTUALIZADO (hay cambios)" -ForegroundColor Yellow }
    else                          { Write-Host " BUILD WEB                 : al dia" -ForegroundColor Green }
    Write-Host "======================================================" -ForegroundColor Cyan
    Write-Host " SERVICIOS EN FONDO y como matarlos:" -ForegroundColor Cyan
    Show-Servicios
    Write-Host " COMANDOS: app | app estado | app stop | app watch | app limpiar" -ForegroundColor Cyan
    exit 0
}

function Invoke-Lanzar {
    Write-Host ""
    Write-Host " Lanzando Medident (release) en Chrome con perfil dedicado..." -ForegroundColor Cyan
    Update-Web | Out-Null
    Write-Host ""
    Write-Host " SERVICIOS EN FONDO y como matarlos:" -ForegroundColor Cyan
    Show-Servicios
    Write-Host " COMANDOS: app | app estado | app stop | app watch | app limpiar" -ForegroundColor Cyan
    exit 0
}

function Invoke-Watch {
    if (Test-WatchVivo) {
        Write-Host " Ya hay un WATCH corriendo (PID $(Get-WatchPid))." -ForegroundColor Yellow
        Write-Host " Para matarlo: app stop" -ForegroundColor Yellow
        exit 1
    }
    Set-Content -LiteralPath $WatchPidFile -Value "$PID" -Encoding ASCII
    Write-Host ""
    Write-Host " WATCH ACTIVO (cada 5 s): al guardar, actualiza sola la release" -ForegroundColor Green
    Write-Host " PARA MATARLO: Ctrl+C en ESTA ventana | o 'app stop' en otra." -ForegroundColor Yellow
    Update-Web | Out-Null
    try {
        while ($true) {
            Start-Sleep -Seconds 5
            try {
                $hayVentana = @(Get-NavegadorApp).Count -gt 0
                $webCorr = ((Test-Servidor) -or $hayVentana)
                if ($webCorr -and (Test-SalidaVieja $WebJs)) {
                    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Cambios -> build web + recarga." -ForegroundColor Cyan
                    if ((Invoke-BuildWeb) -eq 0) { Update-Web | Out-Null }
                }
            } catch {
                Write-Host " watch (error transitorio): $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
    } finally {
        Remove-Item -LiteralPath $WatchPidFile -Force -ErrorAction SilentlyContinue
        Write-Host " WATCH detenido. Servicios restantes:" -ForegroundColor Gray
        Show-Servicios
    }
    exit 0
}

function Invoke-Limpiar {
    $procs = @(Get-NavegadorApp)
    if ($procs.Count -eq 0) {
        Write-Host " No hay ventana propia de la App que limpiar (tu Chrome no se toca)." -ForegroundColor Green
    } else {
        Write-Host " Se cerraran SOLO los $($procs.Count) proceso(s) del perfil PROPIO de la App." -ForegroundColor Yellow
        Write-Host " Tu Chrome personal NO se toca." -ForegroundColor Green
        $ok = Read-Host " Confirmar? (S/N)"
        if ($ok -match "^[Ss]") {
            foreach ($p in $procs) { Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue }
            Remove-Item -LiteralPath $NavPidFile -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 1
            Write-Host " Ventana de la App cerrada. 'app' vuelve a abrir UNA ventana propia." -ForegroundColor Green
        } else {
            Write-Host " Cancelado. Nada se cerro." -ForegroundColor Gray
        }
    }
    exit 0
}

switch ($Accion.ToLower()) {
    "lanzar"   { Invoke-Lanzar }
    "relanzar" { Invoke-Lanzar }
    "estado"   { Invoke-Estado }
    "stop"     { Invoke-Stop }
    "parar"    { Invoke-Stop }
    "watch"    { Invoke-Watch }
    "vigilar"  { Invoke-Watch }
    "limpiar"  { Invoke-Limpiar }
    default {
        Write-Host " Accion no reconocida: $Accion" -ForegroundColor Red
        Write-Host " Usa: app [lanzar|estado|stop|watch|limpiar]" -ForegroundColor Red
        exit 1
    }
}
