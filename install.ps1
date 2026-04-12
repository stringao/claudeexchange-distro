# ClaudeExchange - Instalador Windows
# Correr no PowerShell: irm https://raw.githubusercontent.com/stringao/claudeexchange-distro/main/install.ps1 | iex

$ErrorActionPreference = "Stop"
$AppName = "ClaudeExchange"
$InstallDir = "$env:LOCALAPPDATA\$AppName"
$ExeName = "claude-exchange.exe"

Write-Host "A instalar $AppName..." -ForegroundColor Cyan

# Criar pasta de instalação
if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir | Out-Null
}

# Descarregar executável
$DownloadUrl = "https://github.com/stringao/claudeexchange-distro/releases/latest/download/$ExeName"
$DestPath = Join-Path $InstallDir $ExeName

Write-Host "A descarregar $DownloadUrl..."
try {
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $DestPath -UseBasicParsing
} catch {
    Write-Host "Erro ao descarregar: $_" -ForegroundColor Red
    exit 1
}

# Adicionar ao PATH do utilizador (se ainda não estiver)
$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($UserPath -notlike "*$InstallDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$UserPath;$InstallDir", "User")
    $env:Path = "$env:Path;$InstallDir"
}

Write-Host ""
Write-Host "$AppName instalado com sucesso!" -ForegroundColor Green
Write-Host "Executavel: $DestPath"
Write-Host "Reinicie o terminal e execute: claude-exchange" -ForegroundColor Yellow
