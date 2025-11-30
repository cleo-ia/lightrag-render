# LightRAG from main branch (includes workspace isolation PR #2369)
# With WebUI for debugging
#
# To use on Render:
# 1. Create a new Web Service
# 2. Connect to this repo
# 3. Set environment variables for your LLM provider (OPENAI_API_KEY, etc.)

FROM python:3.12-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    pkg-config \
    unzip \
    supervisor \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# Install Rust (required for some dependencies)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"

# Set working directory
WORKDIR /app

# Clone LightRAG from main branch
RUN git clone --depth 1 https://github.com/HKUDS/LightRAG.git /app/lightrag

WORKDIR /app/lightrag

# Install LightRAG with all dependencies
RUN pip install --no-cache-dir -e ".[api]"

# Build WebUI
WORKDIR /app/lightrag/lightrag_webui
RUN bun install --frozen-lockfile || bun install
RUN bun run build

# Create data directories
RUN mkdir -p /data/rag_storage /data/inputs

# Copy nginx config
RUN rm /etc/nginx/sites-enabled/default
COPY nginx.conf /etc/nginx/sites-enabled/default

# Copy supervisor config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Environment variables
ENV RAG_DIR=/data/rag_storage
ENV LIGHTRAG_KV_STORAGE=JsonKVStorage
ENV LIGHTRAG_VECTOR_STORAGE=NanoVectorDBStorage
ENV LIGHTRAG_GRAPH_STORAGE=NetworkXStorage

# Expose port (nginx will proxy both API and WebUI)
EXPOSE 9621

# Run supervisor to manage both services
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
