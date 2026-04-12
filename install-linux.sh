#!/usr/bin/env bash
# ClaudeExchange - Instalador Linux
# Correr: curl -fsSL https://raw.githubusercontent.com/stringao/claudeexchange-distro/main/install-linux.sh | bash
set -euo pipefail

APP_NAME="ClaudeExchange"
BINARY_NAME="ClaudeExchange"
INSTALL_DIR="${HOME}/.local/share/${APP_NAME}"
DOWNLOAD_URL="https://github.com/stringao/claudeexchange-distro/releases/latest/download/${BINARY_NAME}"

echo ""
echo -e "\033[36mA instalar ${APP_NAME}...\033[0m"

# Criar pasta de instalação
mkdir -p "${INSTALL_DIR}"

# Descarregar executável
echo "A descarregar ${DOWNLOAD_URL}..."
if command -v curl &>/dev/null; then
    curl -fsSL "${DOWNLOAD_URL}" -o "${INSTALL_DIR}/${BINARY_NAME}"
elif command -v wget &>/dev/null; then
    wget -q "${DOWNLOAD_URL}" -O "${INSTALL_DIR}/${BINARY_NAME}"
else
    echo -e "\033[31mErro: curl ou wget necessário.\033[0m"
    exit 1
fi

chmod +x "${INSTALL_DIR}/${BINARY_NAME}"

# Criar symlink no ~/.local/bin
BIN_DIR="${HOME}/.local/bin"
mkdir -p "${BIN_DIR}"
ln -sf "${INSTALL_DIR}/${BINARY_NAME}" "${BIN_DIR}/claude-exchange"

# Adicionar ao PATH se necessário
if [[ ":${PATH}:" != *":${BIN_DIR}:"* ]]; then
    echo ""
    echo -e "\033[33mAdicione ao seu ~/.bashrc ou ~/.zshrc:\033[0m"
    echo "  export PATH=\"${BIN_DIR}:\$PATH\""
    echo ""
fi

# Criar .desktop entry
DESKTOP_DIR="${HOME}/.local/share/applications"
mkdir -p "${DESKTOP_DIR}"

cat > "${DESKTOP_DIR}/${APP_NAME}.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=${APP_NAME}
Comment=Alternar entre provedores AI no Claude Code
Exec=${INSTALL_DIR}/${BINARY_NAME}
Terminal=false
Categories=Utility;Development;
StartupNotify=true
StartupWMClass=${APP_NAME}
EOF

chmod 644 "${DESKTOP_DIR}/${APP_NAME}.desktop"

if command -v update-desktop-database &>/dev/null; then
    update-desktop-database "${DESKTOP_DIR}" 2>/dev/null || true
fi

# Criar script de desinstalação
cat > "${INSTALL_DIR}/uninstall.sh" << 'UNINSTALL_EOF'
#!/usr/bin/env bash
set -euo pipefail
APP_NAME="ClaudeExchange"
INSTALL_DIR="${HOME}/.local/share/${APP_NAME}"
BIN_DIR="${HOME}/.local/bin"
DESKTOP_FILE="${HOME}/.local/share/applications/${APP_NAME}.desktop"

echo "A desinstalar ${APP_NAME}..."
rm -f "${BIN_DIR}/claude-exchange"
rm -f "${DESKTOP_FILE}"
rm -rf "${INSTALL_DIR}"

if command -v update-desktop-database &>/dev/null; then
    update-desktop-database "$(dirname "${DESKTOP_FILE}")" 2>/dev/null || true
fi
echo "${APP_NAME} desinstalado."
UNINSTALL_EOF
chmod +x "${INSTALL_DIR}/uninstall.sh"

echo ""
echo -e "\033[32m${APP_NAME} instalado com sucesso!\033[0m"
echo "Executável: ${INSTALL_DIR}/${BINARY_NAME}"
echo "Comando   : claude-exchange"
echo "Desinstalar: bash ${INSTALL_DIR}/uninstall.sh"
echo ""
