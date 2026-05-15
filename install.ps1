# ClaudeExchange - Instalador Windows
# Instalar: powershell -c "irm https://raw.githubusercontent.com/stringao/claudeexchange-distro/master/install.ps1 | iex"

# Garantir TLS 1.2 para downloads do GitHub
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ErrorActionPreference = "Stop"
$AppName = "ClaudeExchange"
$InstallDir = "$env:LOCALAPPDATA\$AppName"
$BaseURL = "https://github.com/stringao/claudeexchange-distro/releases/latest/download"

Write-Host "A instalar $AppName..." -ForegroundColor Cyan

# Deteção de arquitetura
$Arch = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString().ToLower()
switch ($Arch) {
    "x64"   { $Binary = "ClaudeExchange-windows-x64.exe" }
    "x86"   { $Binary = "ClaudeExchange-windows-x86.exe" }
    "arm64" { $Binary = "ClaudeExchange-windows-arm64.exe" }
    default {
        Write-Host "Arquitetura nao suportada: $Arch" -ForegroundColor Red
        exit 1
    }
}

Write-Host "Arquitetura detetada: $Arch"

# Criar pasta de instalacao
if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir | Out-Null
}

# Descarregar executavel
$DownloadUrl = "$BaseURL/$Binary"
$ExeName = "$AppName.exe"
$DestPath = Join-Path $InstallDir $ExeName

Write-Host "A descarregar $DownloadUrl..."
try {
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $DestPath -UseBasicParsing
} catch {
    Write-Host "Erro ao descarregar: $_" -ForegroundColor Red
    exit 1
}

# Adicionar ao PATH do utilizador (se ainda nao estiver)
$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($UserPath -notlike "*$InstallDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$UserPath;$InstallDir", "User")
    $env:Path = "$env:Path;$InstallDir"
}

# Criar atalho no desktop (se ainda nao existir)
$DesktopPath = [Environment]::GetFolderPath("Desktop")
$ShortcutPath = Join-Path $DesktopPath "$AppName.lnk"
if (-not (Test-Path $ShortcutPath)) {
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = $DestPath
    $Shortcut.WorkingDirectory = $InstallDir
    $Shortcut.Description = $AppName
    $Shortcut.Save()
    Write-Host "Atalho criado no desktop"
}

Write-Host ""
Write-Host "$AppName instalado com sucesso!" -ForegroundColor Green
Write-Host "Executavel: $DestPath"
Write-Host "Reinicie o terminal e execute: ClaudeExchange" -ForegroundColor Yellow
