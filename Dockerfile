# LightRAG from main branch (includes workspace isolation PR #2369)
# Simplified Dockerfile for Render deployment
#
# To use on Render:
# 1. Create a new Web Service
# 2. Connect to a repo containing this Dockerfile (or use "Docker" as build type)
# 3. Set environment variables for your LLM provider (OPENAI_API_KEY, etc.)

FROM python:3.12-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install Rust (required for some dependencies)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Set working directory
WORKDIR /app

# Clone and install LightRAG from main branch
RUN git clone --depth 1 https://github.com/HKUDS/LightRAG.git /app/lightrag

WORKDIR /app/lightrag

# Install LightRAG with all dependencies
RUN pip install --no-cache-dir -e ".[api]"

# Create data directories
RUN mkdir -p /data/rag_storage /data/inputs

# Environment variables
ENV RAG_DIR=/data/rag_storage
ENV LIGHTRAG_KV_STORAGE=JsonKVStorage
ENV LIGHTRAG_VECTOR_STORAGE=NanoVectorDBStorage
ENV LIGHTRAG_GRAPH_STORAGE=NetworkXStorage

# Expose port
EXPOSE 9621

# Run LightRAG API server using the correct entry point
CMD ["lightrag-server", "--host", "0.0.0.0", "--port", "9621"]
