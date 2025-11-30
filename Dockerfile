# LightRAG from main branch (includes workspace isolation PR #2369)
# Simplified Dockerfile for Render deployment
#
# API available at: /docs (Swagger UI), /health, /query, /insert, etc.

FROM python:3.12-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    pkg-config \
    supervisor \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# Install Rust (required for some dependencies)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Set working directory
WORKDIR /app

# Clone LightRAG from main branch
RUN git clone --depth 1 https://github.com/HKUDS/LightRAG.git /app/lightrag

WORKDIR /app/lightrag

# Install LightRAG with all dependencies
RUN pip install --no-cache-dir -e ".[api]"

# Create data directories
RUN mkdir -p /data/rag_storage /data/inputs

# Copy nginx config
RUN rm -f /etc/nginx/sites-enabled/default
COPY nginx.conf /etc/nginx/sites-enabled/default

# Copy supervisor config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Environment variables
ENV RAG_DIR=/data/rag_storage
ENV LIGHTRAG_KV_STORAGE=JsonKVStorage
ENV LIGHTRAG_VECTOR_STORAGE=NanoVectorDBStorage
ENV LIGHTRAG_GRAPH_STORAGE=NetworkXStorage

# Expose port (nginx proxies to API)
EXPOSE 9621

# Run supervisor to manage API and nginx
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
