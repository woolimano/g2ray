FROM debian:bookworm-slim

WORKDIR /app

# Install dependencies with clear output
RUN echo "📦 Installing system dependencies..." && \
    apt-get update && apt-get install -y --no-install-recommends \
    bash curl wget tar tzdata openssl ca-certificates procps iproute2 net-tools lsof sqlite3 \
    && echo "✅ Dependencies installed successfully" \
    && rm -rf /var/lib/apt/lists/*

COPY install-3x-ui.sh /app/install-3x-ui.sh
COPY startup.sh /app/startup.sh

RUN echo "⚙️ Installing 3x-ui..." && \
    chmod +x /app/install-3x-ui.sh /app/startup.sh && \
    /app/install-3x-ui.sh && \
    echo "✅ 3x-ui installation completed successfully"

# 2053 = 3x-ui panel
# 443  = Xray inbound you create in the panel
EXPOSE 2053 443

CMD ["/app/startup.sh"]
