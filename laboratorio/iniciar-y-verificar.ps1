# Inicia el laboratorio del examen y comprueba que cada servicio responda.
# Si algo falla, muestra una pista y devuelve un código de error.
# 'Continue': Docker escribe su avance por stderr y eso no debe detener el script (se revisa $LASTEXITCODE).
$ErrorActionPreference = 'Continue'
Set-Location -LiteralPath $PSScriptRoot

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error 'Docker no está instalado o no está disponible en la terminal.'
    exit 1
}
docker info *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Error 'Docker Desktop no está iniciado. Ábrelo y vuelve a ejecutar este archivo.'
    exit 1
}

& (Join-Path $PSScriptRoot 'preparar-secretos.ps1')
Write-Host 'Iniciando el laboratorio. La primera vez descarga ~3 GB y puede tardar 5 a 10 minutos...'
docker compose up -d --build
if ($LASTEXITCODE -ne 0) {
    Write-Error 'No se pudo iniciar el laboratorio. Revisa el mensaje de Docker mostrado arriba.'
    exit 1
}

# Si el puerto 3000 o 9090 ya está ocupado en tu equipo, define EV3_GRAFANA_PORT / EV3_PROM_PORT antes de iniciar.
$grafanaPort = if ($env:EV3_GRAFANA_PORT) { $env:EV3_GRAFANA_PORT } else { '3000' }
$promPort = if ($env:EV3_PROM_PORT) { $env:EV3_PROM_PORT } else { '9090' }
$checks = @(
    @{ Name = 'Jenkins';    Url = 'http://localhost:8080/login' },
    @{ Name = 'Prometheus'; Url = "http://localhost:$promPort/-/ready" },
    @{ Name = 'Grafana';    Url = "http://localhost:$grafanaPort/api/health" }
)
$deadline = (Get-Date).AddMinutes(5)
do {
    $pending = @()
    foreach ($check in $checks) {
        try {
            $r = Invoke-WebRequest -Uri $check.Url -TimeoutSec 5 -UseBasicParsing
            if ($r.StatusCode -ne 200) { $pending += $check.Name }
        } catch { $pending += $check.Name }
    }
    # ZAP no publica puertos: se comprueba desde el contenedor de Jenkins por la red interna.
    # (Sin comillas dobles dentro de sh -c: PowerShell 5.1 las rompe al pasarlas a docker.)
    docker compose exec -T jenkins sh -c 'curl -fsS http://zap:8080/JSON/core/view/version/?apikey=$(cat /run/secrets/zap_api_key)' *> $null
    if ($LASTEXITCODE -ne 0) { $pending += 'OWASP ZAP' }
    if ($pending.Count -eq 0) { break }
    Write-Host ('Esperando: ' + ($pending -join ', '))
    Start-Sleep -Seconds 10
} while ((Get-Date) -lt $deadline)

Write-Host ''
docker compose ps
Write-Host ''
if ($pending.Count -eq 0) {
    # Grafana conserva su base de datos entre reinicios; este comando alinea la clave con secrets/.
    docker compose exec -T grafana sh -c 'grafana cli admin reset-admin-password $(cat /run/secrets/grafana_password) >/dev/null 2>&1'
    Write-Host 'Laboratorio listo.' -ForegroundColor Green
} else {
    Write-Warning ('Aún no responden: ' + ($pending -join ', ') + '. Consulta: docker compose logs --tail=80')
}
Write-Host "Jenkins: http://localhost:8080 | Prometheus: http://localhost:$promPort | Grafana: http://localhost:$grafanaPort"
Write-Host ('Grafana: usuario admin | clave: ' + (Get-Content -LiteralPath (Join-Path $PSScriptRoot 'secrets\grafana_password.txt') -Raw).Trim())
Write-Host 'Clave inicial de Jenkins (solo la primera vez):'
docker compose exec -T jenkins sh -c 'cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo Jenkins ya estaba configurado'
Write-Host 'No compartas la carpeta secrets ni fotos de esta ventana con claves.'
if ($pending.Count -ne 0) { exit 1 }
