FROM debian:bookworm-slim

WORKDIR /app

ENV DEBIAN_FRONTEND=noninteractive
ENV PANEL_PORT=2053
ENV PANEL_PATH=panel
ENV XRAY_PORT=443

# Install dependencies
RUN echo "📦 Installing system dependencies..." && \
    apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    wget \
    tar \
    unzip \
    tzdata \
    openssl \
    ca-certificates \
    procps \
    iproute2 \
    net-tools \
    lsof \
    sqlite3 \
    jq \
    && echo "✅ Dependencies installed successfully" \
    && rm -rf /var/lib/apt/lists/*

# Install 3x-ui
RUN echo "⚙️ Installing 3x-ui..." && \
    set -eux; \
    XUI_DIR="/usr/local/x-ui"; \
    mkdir -p "$XUI_DIR" /etc/x-ui /var/log/x-ui; \
    ARCH="$(uname -m)"; \
    case "$ARCH" in \
      x86_64|x64|amd64) XUI_ARCH="amd64" ;; \
      aarch64|arm64) XUI_ARCH="arm64" ;; \
      armv7*|armv7) XUI_ARCH="armv7" ;; \
      armv6*|armv6) XUI_ARCH="armv6" ;; \
      armv5*|armv5) XUI_ARCH="armv5" ;; \
      i*86|x86) XUI_ARCH="386" ;; \
      s390x) XUI_ARCH="s390x" ;; \
      *) XUI_ARCH="amd64" ;; \
    esac; \
    echo "Detected architecture: $ARCH -> $XUI_ARCH"; \
    LATEST_TAG="$(curl -fsSL https://api.github.com/repos/MHSanaei/3x-ui/releases/latest | jq -r '.tag_name')"; \
    echo "Latest 3x-ui release: $LATEST_TAG"; \
    cd /tmp; \
    wget -O x-ui.tar.gz "https://github.com/MHSanaei/3x-ui/releases/download/${LATEST_TAG}/x-ui-linux-${XUI_ARCH}.tar.gz"; \
    tar -xzf x-ui.tar.gz; \
    rm -rf "$XUI_DIR"; \
    mkdir -p "$XUI_DIR"; \
    if [ -d "/tmp/x-ui" ]; then \
      cp -a /tmp/x-ui/. "$XUI_DIR/"; \
    else \
      echo "Unexpected 3x-ui archive layout"; \
      ls -la /tmp; \
      exit 1; \
    fi; \
    chmod +x "$XUI_DIR/x-ui" || true; \
    chmod +x "$XUI_DIR/bin/"* || true; \
    ln -sf "$XUI_DIR/x-ui" /usr/local/bin/x-ui; \
    ln -sf "$XUI_DIR/x-ui" /usr/bin/x-ui; \
    rm -rf /tmp/x-ui /tmp/x-ui.tar.gz; \
    echo "✅ 3x-ui installed successfully"

# Create auto-start script
RUN cat > /app/auto-start-3xui.sh <<'EOF'
#!/usr/bin/env bash
set -u

PANEL_PORT="${PANEL_PORT:-2053}"
PANEL_PATH="${PANEL_PATH:-panel}"
XRAY_PORT="${XRAY_PORT:-443}"
LOG_FILE="/tmp/3x-ui.log"

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║              🚀 AUTO STARTING 3X-UI PANEL 🚀             ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

mkdir -p /etc/x-ui /var/log/x-ui /usr/local/x-ui

if [ ! -x /usr/local/x-ui/x-ui ]; then
  echo "❌ /usr/local/x-ui/x-ui was not found or is not executable."
  exit 1
fi

echo "⚙️ Applying panel settings..."
/usr/local/x-ui/x-ui setting \
  -username "admin" \
  -password "adminadmin" \
  -port "${PANEL_PORT}" \
  -webBasePath "${PANEL_PATH}" || true

echo ""
echo "🔎 Checking if 3x-ui is already running..."
if pgrep -f "/usr/local/x-ui/x-ui" >/dev/null 2>&1; then
  echo "✅ 3x-ui process is already running."
else
  echo "▶️ Starting 3x-ui in background..."
  cd /usr/local/x-ui || exit 1

  # First try normal foreground binary in background.
  nohup /usr/local/x-ui/x-ui > "${LOG_FILE}" 2>&1 &
  sleep 3

  # Some builds behave better with explicit 'start'.
  if ! ss -ltnp 2>/dev/null | grep -q ":${PANEL_PORT}"; then
    echo "⚠️ First start attempt did not open port ${PANEL_PORT}; trying x-ui start..."
    nohup /usr/local/x-ui/x-ui start >> "${LOG_FILE}" 2>&1 &
    sleep 3
  fi
fi

echo ""
echo "🔎 Checking listener on port ${PANEL_PORT}..."
if ss -ltnp 2>/dev/null | grep -q ":${PANEL_PORT}"; then
  echo "✅ 3x-ui is listening on port ${PANEL_PORT}"
else
  echo "❌ 3x-ui is NOT listening on port ${PANEL_PORT}"
  echo ""
  echo "Last log lines:"
  tail -n 120 "${LOG_FILE}" 2>/dev/null || true
  exit 1
fi

echo ""
echo "📋 3x-ui Panel:"
echo "   • Local:    http://127.0.0.1:${PANEL_PORT}/${PANEL_PATH}/"

if [ -n "${CODESPACE_NAME:-}" ]; then
  echo "   • Browser:  https://${CODESPACE_NAME}-${PANEL_PORT}.app.github.dev/${PANEL_PATH}/"
  echo ""
  echo "🔗 Xray / VLESS Codespaces endpoint:"
  echo "   • Host/SNI: ${CODESPACE_NAME}-${XRAY_PORT}.app.github.dev"
  echo "   • Port:     443"
fi

echo ""
echo "🔐 Default lab login:"
echo "   • Username: admin"
echo "   • Password: adminadmin"
echo ""
echo "⚠️ Change the username/password immediately after login."
echo ""
EOF

RUN chmod +x /app/auto-start-3xui.sh

# Optional helper script for manual debugging
RUN cat > /app/check-3xui.sh <<'EOF'
#!/usr/bin/env bash
set -u

echo "===== processes ====="
ps aux | grep -E 'x-ui|3x-ui' | grep -v grep || true

echo ""
echo "===== listeners ====="
ss -ltnp | grep -E ':2053|:443' || true

echo ""
echo "===== panel settings ====="
/usr/local/x-ui/x-ui setting -show true || true

echo ""
echo "===== local curl ====="
curl -i --max-time 5 http://127.0.0.1:2053/panel/ || true

echo ""
echo "===== logs ====="
tail -n 120 /tmp/3x-ui.log 2>/dev/null || true
tail -n 120 /tmp/3x-ui-autostart.log 2>/dev/null || true
EOF

RUN chmod +x /app/check-3xui.sh

# 2053 = 3x-ui panel
# 443  = Xray inbound you create in the panel
EXPOSE 2053 443

# This helps if the Docker CMD is honored, but Codespaces/devcontainers
# often keep the container alive through their own command.
CMD ["/app/auto-start-3xui.sh"]