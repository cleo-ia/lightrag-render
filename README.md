# LightRAG for Render

Custom LightRAG deployment built from the `main` branch to include the latest features, notably:

- **Workspace Isolation** (PR #2369) - Multi-tenant support via `LIGHTRAG-WORKSPACE` header

## Deployment on Render

### 1. Create a new Web Service

1. Go to [Render Dashboard](https://dashboard.render.com)
2. Click "New +" → "Web Service"
3. Connect this repository: `cleo-ia/lightrag-render`
4. Select "Docker" as the build type

### 2. Configure Environment Variables

Set the following environment variables in Render:

```
# Required - LLM Provider
OPENAI_API_KEY=sk-...

# Or for other providers
ANTHROPIC_API_KEY=...
OLLAMA_HOST=...

# Optional - API Security
LIGHTRAG_API_KEY=your-api-key

# Optional - Storage Configuration
RAG_DIR=/data/rag_storage
LIGHTRAG_KV_STORAGE=JsonKVStorage
LIGHTRAG_VECTOR_STORAGE=NanoVectorDBStorage
LIGHTRAG_GRAPH_STORAGE=NetworkXStorage
```

### 3. Configure Resources

- **Instance Type**: At least 1GB RAM recommended
- **Port**: 9621
- **Health Check Path**: `/health`

### 4. Deploy

Click "Create Web Service" and wait for the build to complete.

## API Usage

### Health Check
```bash
curl https://your-service.onrender.com/health
```

### Query with Workspace Isolation
```bash
curl -X POST https://your-service.onrender.com/query \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your-api-key" \
  -H "LIGHTRAG-WORKSPACE: user_123" \
  -d '{"query": "Your question here", "mode": "hybrid"}'
```

## Why this repo?

The official Docker image `ghcr.io/hkuds/lightrag:latest` (v1.4.9.8) was released before PR #2369 was merged. This repo builds from `main` to include workspace isolation support, which is critical for multi-tenant applications like Cleo.

## Updates

To get the latest LightRAG updates, trigger a manual deploy in Render or wait for the next official release that includes workspace isolation.
