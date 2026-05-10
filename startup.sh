cat > /app/startup.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

PANEL_PORT="2053"
XRAY_PORT="443"
PANEL_PATH="panel"

mkdir -p /etc/x-ui /var/log/x-ui

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║             🚀 G2RAY - 3X-UI CODESPACE READY 🚀          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

echo "📋 3x-ui Panel:"
echo "   • Local panel:  http://127.0.0.1:${PANEL_PORT}/${PANEL_PATH}/"

if [ -n "${CODESPACE_NAME:-}" ]; then
  echo "   • Codespace:   https://${CODESPACE_NAME}-${PANEL_PORT}.app.github.dev/${PANEL_PATH}/"
  echo ""
  echo "🔗 Xray / VLESS Codespaces endpoint:"
  echo "   • Host/SNI:    ${CODESPACE_NAME}-${XRAY_PORT}.app.github.dev"
  echo "   • Port:        443"
fi

echo ""
echo "🔐 Default lab login:"
echo "   • Username:    admin"
echo "   • Password:    adminadmin"
echo ""
echo "⚠️  Change the panel username/password immediately after login."
echo ""

echo "⚙️ Applying panel settings..."
/usr/local/x-ui/x-ui setting \
  -username "admin" \
  -password "adminadmin" \
  -port "${PANEL_PORT}" \
  -webBasePath "${PANEL_PATH}" || true

echo ""
echo "✨ Starting 3x-ui..."
echo ""

cd /usr/local/x-ui
exec /usr/local/x-ui/x-ui
EOF

chmod +x /app/startup.sh