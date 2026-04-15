# ClaudeExchange - Instalador Windows
# Correr no PowerShell: irm https://raw.githubusercontent.com/stringao/claudeexchange-distro/main/install.ps1 | iex

$ErrorActionPreference = "Stop"
$AppName = "ClaudeExchange"
$InstallDir = "$env:LOCALAPPDATA\$AppName"
$BaseDownloadUrl = "https://github.com/stringao/claudeexchange-distro/releases/latest/download"

# Deteção de arquitetura
$Arch = if ($env:PROCESSOR_ARCHITEW6432) {
    switch ($env:PROCESSOR_ARCHITEW6432) {
        "AMD64"  { "x64" }
        "ARM64"  { "arm64" }
        default  { "x64" }
    }
} else {
    switch ($env:PROCESSOR_ARCHITECTURE) {
        "AMD64"  { "x64" }
        "ARM64"  { "arm64" }
        "x86"    { "x86" }
        default  { "x64" }
    }
}

$RemoteName = "ClaudeExchange-windows-$Arch.exe"
$LocalName = "claude-exchange.exe"
$DownloadUrl = "$BaseDownloadUrl/$RemoteName"
$DestPath = Join-Path $InstallDir $LocalName

Write-Host ""
Write-Host "A instalar $AppName..." -ForegroundColor Cyan
Write-Host "Arquitetura detectada: $Arch"

# Criar pasta de instalação
if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir | Out-Null
}

# Descarregar executável
Write-Host "A descarregar $DownloadUrl..."
try {
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $DestPath -UseBasicParsing
} catch {
    Write-Host "Erro ao descarregar: $_" -ForegroundColor Red
    Write-Host "Arquitetura $Arch pode nao estar disponivel." -ForegroundColor Yellow
    exit 1
}

# Adicionar ao PATH do utilizador (se ainda não estiver)
$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($UserPath -notlike "*$InstallDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$UserPath;$InstallDir", "User")
    $env:Path = "$env:Path;$InstallDir"
}

# Criar atalho no Desktop
$DesktopPath = [Environment]::GetFolderPath("Desktop")
$ShortcutPath = Join-Path $DesktopPath "$AppName.lnk"

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = $DestPath
$Shortcut.WorkingDirectory = $InstallDir
$Shortcut.Description = $AppName
$Shortcut.Save()

Write-Host ""
Write-Host "$AppName instalado com sucesso!" -ForegroundColor Green
Write-Host "Executavel : $DestPath"
Write-Host "Atalho     : $ShortcutPath"
Write-Host "Comando    : claude-exchange (reinicie o terminal)" -ForegroundColor Yellow
Write-Host ""
