#!/usr/bin/env bash
# ClaudeExchange - Instalador macOS
# Correr: curl -fsSL https://raw.githubusercontent.com/stringao/claudeexchange-distro/main/install-macos.sh | bash
set -euo pipefail

APP_NAME="ClaudeExchange"
BASE_URL="https://github.com/stringao/claudeexchange-distro/releases/latest/download"
APP_BUNDLE="${HOME}/Applications/${APP_NAME}.app"

# Deteção de arquitetura
ARCH=$(uname -m)
case "$ARCH" in
    arm64)  SUFFIX="arm64" ;;
    x86_64) SUFFIX="x64" ;;
    *) echo -e "\033[31mArquitetura nao suportada: $ARCH\033[0m"; exit 1 ;;
esac

REMOTE_NAME="ClaudeExchange-macos-${SUFFIX}"
DOWNLOAD_URL="${BASE_URL}/${REMOTE_NAME}"

echo ""
echo -e "\033[36mA instalar ${APP_NAME}...\033[0m"
echo "Arquitetura detectada: ${ARCH} (${SUFFIX})"

# Criar estrutura do .app bundle
mkdir -p "${APP_BUNDLE}/Contents/MacOS"

# Descarregar executável
echo "A descarregar ${DOWNLOAD_URL}..."
if command -v curl &>/dev/null; then
    curl -fsSL "${DOWNLOAD_URL}" -o "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"
elif command -v wget &>/dev/null; then
    wget -q "${DOWNLOAD_URL}" -O "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"
else
    echo -e "\033[31mErro: curl ou wget necessario.\033[0m"
    exit 1
fi

chmod +x "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"

# Criar Info.plist
cat > "${APP_BUNDLE}/Contents/Info.plist" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.claudeexchange.app</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.15</string>
</dict>
</plist>
PLIST

# Criar symlink em ~/.local/bin para uso no terminal
BIN_DIR="${HOME}/.local/bin"
mkdir -p "${BIN_DIR}"
ln -sf "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}" "${BIN_DIR}/claude-exchange"

# Adicionar ao PATH se necessário
if [[ ":${PATH}:" != *":${BIN_DIR}:"* ]]; then
    SHELL_RC=""
    if [[ -f "${HOME}/.zshrc" ]]; then
        SHELL_RC="${HOME}/.zshrc"
    elif [[ -f "${HOME}/.bashrc" ]]; then
        SHELL_RC="${HOME}/.bashrc"
    fi

    if [[ -n "${SHELL_RC}" ]]; then
        if ! grep -q "${BIN_DIR}" "${SHELL_RC}" 2>/dev/null; then
            echo "" >> "${SHELL_RC}"
            echo "export PATH=\"${BIN_DIR}:\$PATH\"" >> "${SHELL_RC}"
            echo -e "\033[33mAdicionado ${BIN_DIR} ao PATH em ${SHELL_RC}\033[0m"
        fi
    else
        echo ""
        echo -e "\033[33mAdicione ao seu shell rc:\033[0m"
        echo "  export PATH=\"${BIN_DIR}:\$PATH\""
        echo ""
    fi
fi

# Criar atalho no Desktop (alias para o .app)
DESKTOP_DIR="${HOME}/Desktop"
if [[ -d "${DESKTOP_DIR}" ]]; then
    osascript -e "tell application \"Finder\"" \
        -e "  make alias file to POSIX file \"${APP_BUNDLE}\" at POSIX file \"${DESKTOP_DIR}\"" \
        -e "end tell" 2>/dev/null || \
    ln -sf "${APP_BUNDLE}" "${DESKTOP_DIR}/${APP_NAME}"
fi

# Remover quarantine (macOS bloqueia apps nao assinados)
xattr -dr com.apple.quarantine "${APP_BUNDLE}" 2>/dev/null || true

# Criar script de desinstalação
UNINSTALL_SCRIPT="${HOME}/.local/share/${APP_NAME}/uninstall.sh"
mkdir -p "$(dirname "${UNINSTALL_SCRIPT}")"
cat > "${UNINSTALL_SCRIPT}" << 'UNINSTALL_EOF'
#!/usr/bin/env bash
set -euo pipefail
APP_NAME="ClaudeExchange"
APP_BUNDLE="${HOME}/Applications/${APP_NAME}.app"
BIN_DIR="${HOME}/.local/bin"
DESKTOP_DIR="${HOME}/Desktop"

echo "A desinstalar ${APP_NAME}..."
rm -f "${BIN_DIR}/claude-exchange"
rm -rf "${APP_BUNDLE}"
rm -f "${DESKTOP_DIR}/${APP_NAME}"
rm -f "${DESKTOP_DIR}/${APP_NAME}.app"
rm -rf "$(dirname "${HOME}/.local/share/${APP_NAME}/uninstall.sh")"
echo "${APP_NAME} desinstalado."
UNINSTALL_EOF
chmod +x "${UNINSTALL_SCRIPT}"

echo ""
echo -e "\033[32m${APP_NAME} instalado com sucesso!\033[0m"
echo "Aplicacao : ${APP_BUNDLE}"
echo "Comando   : claude-exchange (reinicie o terminal)"
echo "Atalho    : ${DESKTOP_DIR}/${APP_NAME}"
echo "Desinstalar: bash ${UNINSTALL_SCRIPT}"
echo ""
