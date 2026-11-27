# Crea claves únicas para este computador (API de ZAP y Grafana). No van en el ZIP ni en Git.
$ErrorActionPreference = 'Stop'
$folder = Join-Path $PSScriptRoot 'secrets'
if (-not (Test-Path -LiteralPath $folder)) { New-Item -ItemType Directory -Path $folder | Out-Null }

function New-Secret([string]$name) {
    $path = Join-Path $folder ($name + '.txt')
    if (Test-Path -LiteralPath $path) { return }
    $bytes = New-Object byte[] 24
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    try { $rng.GetBytes($bytes) } finally { $rng.Dispose() }
    $value = ([System.BitConverter]::ToString($bytes)).Replace('-', '').ToLowerInvariant()
    Set-Content -LiteralPath $path -Value $value -Encoding Ascii -NoNewline
}

New-Secret 'zap_api_key'
New-Secret 'grafana_password'
Write-Host 'Claves locales preparadas en secrets/.'
