#!/usr/bin/env bash
# ClaudeExchange - Instalador Linux/macOS
# Correr: curl -fsSL https://raw.githubusercontent.com/stringao/claudeexchange-distro/master/install.sh | bash
#      ou: wget -qO- https://raw.githubusercontent.com/stringao/claudeexchange-distro/master/install.sh | bash

set -euo pipefail

APP_NAME="ClaudeExchange"
BASE_URL="https://github.com/stringao/claudeexchange-distro/releases/latest/download"
INSTALL_DIR="$HOME/.local/bin"

echo "A instalar $APP_NAME..."

# Deteção de OS e arquitetura
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

case "$OS" in
    linux)
        case "$ARCH" in
            x86_64|amd64) BINARY="ClaudeExchange-linux-x64" ;;
            *)            echo "Arquitetura nao suportada: $ARCH"; exit 1 ;;
        esac
        ;;
    darwin)
        case "$ARCH" in
            arm64|aarch64) BINARY="ClaudeExchange-macos-arm64" ;;
            *)             echo "Arquitetura nao suportada: $ARCH"; exit 1 ;;
        esac
        ;;
    *)
        echo "Sistema operativo nao suportado: $OS"
        echo "Para Windows use o install.ps1"
        exit 1
        ;;
esac

echo "Plataforma detetada: $OS $ARCH"

# Criar pasta de instalacao
mkdir -p "$INSTALL_DIR"

# Descarregar
DOWNLOAD_URL="$BASE_URL/$BINARY"
DEST="$INSTALL_DIR/$APP_NAME"

echo "A descarregar $DOWNLOAD_URL..."
if command -v curl &>/dev/null; then
    curl -fSL -o "$DEST" "$DOWNLOAD_URL"
elif command -v wget &>/dev/null; then
    wget -q -O "$DEST" "$DOWNLOAD_URL"
else
    echo "Erro: necessita de curl ou wget"
    exit 1
fi

chmod +x "$DEST"

# Atualizar PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    SHELL_RC="$HOME/.bashrc"
    if [[ -f "$HOME/.zshrc" ]] && [[ "$SHELL" == */zsh ]]; then
        SHELL_RC="$HOME/.zshrc"
    fi
    echo "" >> "$SHELL_RC"
    echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$SHELL_RC"
    export PATH="$PATH:$INSTALL_DIR"
    echo "PATH atualizado em $SHELL_RC"
fi

# Criar atalho no desktop (se ainda nao existir)
DESKTOP_DIR="$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Desktop")"
SHORTCUT_PATH="$DESKTOP_DIR/$APP_NAME.desktop"
if [[ ! -f "$SHORTCUT_PATH" ]]; then
    if [[ -d "$DESKTOP_DIR" ]]; then
        cat > "$SHORTCUT_PATH" <<DESKTOP
[Desktop Entry]
Type=Application
Name=$APP_NAME
Exec=$DEST
Terminal=false
Categories=Utility;
DESKTOP
        chmod +x "$SHORTCUT_PATH"
        echo "Atalho criado no desktop"
    fi
fi

echo ""
echo "$APP_NAME instalado com sucesso!"
echo "Executavel: $DEST"
echo "Reinicie o terminal e execute: $APP_NAME"
