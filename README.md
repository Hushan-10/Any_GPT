# AnyGPT

Upload your documents. Get an AI assistant that answers from them.

AnyGPT is the evolution of JacGPT — a platform where users upload their documents (PDFs, DOCX, Markdown, code files) and get a fully customized AI assistant backed by a cutting-edge RAG pipeline. Built on the Jaseci stack.

---

## What This Demo Does (Phase 1 MVP)

> **TL;DR**: Drop your docs → ask questions → get answers with source citations.

```
┌─────────────────────────────────────────────────────────┐
│  YOU                                                    │
│  1. Upload a PDF, Markdown, or DOCX file                │
│  2. Ask a question in plain English                     │
│  3. Get an AI answer citing exact pages/sections        │
└─────────────────────────────────────────────────────────┘
```

**Phase 1 boundaries:**
- Single user / no login required (demo mode)
- Upload docs via drag-and-drop UI or REST API
- RAG search: FAISS vector similarity + CrossEncoder reranking
- LLM answer generation via ReAct tool-calling (GPT-4.1-mini)
- SSE-streamed responses with source attribution
- Local filesystem storage + local FAISS index
- Fully extendable to multi-tenant, S3, Qdrant, advanced RAG (see roadmap)

---

## How JacGPT (Predecessor) Works

Before diving into AnyGPT's design, here's how JacGPT handles document storage and retrieval:

### Document Storage
- **Source docs** are stored on the local filesystem (`services/docs/`) — synced daily from the Jaseci repo via GitHub Actions
- **Vector index** uses FAISS, persisted as `index.faiss` + `index.pkl` in `services/faiss_index/`
- **Embeddings** are generated using `OpenAIEmbeddings` (OpenAI API)
- **Doc link embeddings** are pre-computed with `SentenceTransformer('all-MiniLM-L6-v2')` and stored in `all_section_links.json`

### RAG Retrieval Pipeline
1. **Load**: `PyPDFDirectoryLoader` (PDFs) + `DirectoryLoader` with `TextLoader` (Markdown)
2. **Chunk**: `RecursiveCharacterTextSplitter` — 800 chars, 100 overlap
3. **Enrich metadata**: Each chunk gets a unique ID (`source:page:chunk_index`) and metadata preamble
4. **Embed + Index**: OpenAI embeddings → FAISS index
5. **Retrieve**: FAISS similarity search → top 30 candidates
6. **Rerank**: `CrossEncoder('cross-encoder/ms-marco-MiniLM-L6-v2')` → top 7 results
7. **Generate**: Results fed to LLM (`gpt-4.1-mini`) via ReAct tool-calling pattern

### Limitations (Why AnyGPT)
- Single-tenant, hardcoded to Jac documentation only
- No user document upload — docs are developer-managed
- No tenant isolation, no per-user vector stores
- No multimodal ingestion (images in PDFs are lost)
- No contextual chunking (naive splitting loses document context)
- No hierarchical summarization (can't synthesize across long docs)

---

## AnyGPT Architecture

### Design Principles
1. **Tenant isolation from day one** — even in single-user mode, data flows through tenant boundaries so multi-tenancy is a config change, not a rewrite
2. **Pluggable storage backends** — local filesystem for demo, S3/MinIO for production
3. **Pluggable vector stores** — FAISS for demo, Qdrant/pgvector for production
4. **Progressive RAG enhancement** — start with solid retrieval+reranking, layer in contextual chunking, RAPTOR, Self-RAG, ColPali later
5. **Graph-native** — Jac's Object-Spatial Programming model structures all entities (tenants, documents, chunks) as graph nodes

---

### System Architecture

```
Phase 1 (Demo/MVP)                         Phase 2+ (Ultimate Goal)
========================                    ===================================

┌──────────────────────┐                    ┌──────────────────────────────────┐
│    Chat UI (Jac      │                    │  Per-Tenant Branded UI           │
│    Client + Mantine) │                    │  Config Dashboard (Enterprise)   │
│                      │                    │  Desktop App (Tauri + Jac)       │
│  - Upload widget     │                    │  Embeddable Widget               │
│  - Chat interface    │                    │  REST API per tenant             │
│  - Doc viewer        │                    │                                  │
└──────────┬───────────┘                    └──────────────┬───────────────────┘
           │                                               │
           ▼                                               ▼
┌──────────────────────┐                    ┌──────────────────────────────────┐
│   API Layer          │                    │   API Gateway (per-tenant)       │
│   (Jac Server)       │                    │   + Auth + Rate Limiting         │
│                      │                    │                                  │
│  POST /upload        │                    │  Tenant provisioning             │
│  POST /chat          │                    │  API key management              │
│  GET  /documents     │                    │  Usage metering                  │
│  DEL  /documents/:id │                    │                                  │
└──────────┬───────────┘                    └──────────────┬───────────────────┘
           │                                               │
           ▼                                               ▼
┌──────────────────────┐                    ┌──────────────────────────────────┐
│  Orchestration Layer │                    │  Orchestration Layer             │
│  (Jac Walkers)       │                    │  (Jac Walkers)                   │
│                      │                    │                                  │
│  - ingest walker     │                    │  - Agentic RAG orchestrator      │
│  - chat walker       │                    │  - MCP Context Engine            │
│  - manage walker     │                    │  - Auto-Specialize pipeline      │
│                      │                    │  - Tenant Manager                │
└──────────┬───────────┘                    └──────────────┬───────────────────┘
           │                                               │
           ▼                                               ▼
┌──────────────────────┐                    ┌──────────────────────────────────┐
│  RAG Pipeline        │                    │  Knowledge Layer                 │
│                      │                    │                                  │
│  - PDF/MD/DOCX       │                    │  - Contextual Retrieval          │
│    parsing           │                    │    + Self-RAG                    │
│  - Recursive         │                    │  - ColPali (multimodal)          │
│    chunking          │                    │  - Hybrid Search + Rerank        │
│  - Embedding         │                    │  - RAPTOR hierarchical           │
│  - FAISS retrieval   │                    │    summaries                     │
│  - CrossEncoder      │                    │  - Corrective RAG                │
│    reranking         │                    │  - Agentic sub-task              │
│                      │                    │    decomposition                 │
└──────────┬───────────┘                    └──────────────┬───────────────────┘
           │                                               │
           ▼                                               ▼
┌──────────────────────┐                    ┌──────────────────────────────────┐
│  Storage Layer       │                    │  Storage Layer                   │
│                      │                    │                                  │
│  Local filesystem    │                    │  Object Store (S3/MinIO)         │
│  + FAISS index       │                    │  + Qdrant / pgvector             │
│  (per-tenant dirs)   │                    │  + PostgreSQL (metadata)         │
└──────────────────────┘                    └──────────────────────────────────┘
```

---

### Complete Data Flow: Upload → Answer

This diagram shows the full lifecycle of a document from upload through to a chat answer.

```
                         ╔══════════════════╗
                         ║   USER UPLOADS   ║
                         ║  report.pdf      ║
                         ╚════════╤═════════╝
                                  │  POST /upload (multipart/form-data)
                                  ▼
                    ┌─────────────────────────┐
                    │   File Validator         │
                    │  • Check type (PDF/MD/   │
                    │    DOCX/TXT/code)        │
                    │  • Check size (≤50MB)    │
                    └────────────┬────────────┘
                                 │ valid file
                                 ▼
                    ┌─────────────────────────┐
                    │   File Store             │
                    │  Phase 1: local disk     │
                    │  anygpt-data/tenants/    │
                    │  default/uploads/        │──── raw file saved
                    │                          │
                    │  Phase 2: S3/MinIO       │
                    └────────────┬────────────┘
                                 │ file path
                                 ▼
                    ┌─────────────────────────┐
                    │   Document Loader        │
                    │  PDF  → PyPDFLoader      │
                    │  DOCX → python-docx      │
                    │  MD   → TextLoader       │
                    │  Code → TextLoader +     │
                    │         lang metadata    │
                    │                          │
                    │  Phase 2: ColPali        │
                    │  (VLM multimodal)        │
                    └────────────┬────────────┘
                                 │ list[DocumentPage]
                                 ▼
                    ┌─────────────────────────┐
                    │   Chunker                │
                    │  RecursiveCharacter      │
                    │  TextSplitter            │
                    │  • chunk_size: 800       │
                    │  • overlap: 100          │
                    │  • ID: src:page:idx      │
                    │  • metadata enrichment   │
                    │                          │
                    │  Phase 2: Contextual     │
                    │  chunking (LLM preambles)│
                    └────────────┬────────────┘
                                 │ list[Chunk]
                                 ▼
                    ┌─────────────────────────┐
                    │   Embedder               │
                    │  OpenAI                  │
                    │  text-embedding-3-small  │
                    │  → 1536-dim vectors      │
                    │                          │
                    │  Phase 2: + BM25 sparse  │
                    │  + ColBERT late-interact │
                    └────────────┬────────────┘
                                 │ list[EmbeddedChunk]
                                 ▼
                    ┌─────────────────────────┐
                    │   Index Writer           │
                    │  FAISS (per-tenant)      │
                    │  anygpt-data/tenants/    │
                    │  default/faiss_index/    │
                    │  • index.faiss           │
                    │  • index.pkl             │
                    │                          │
                    │  Phase 2: Qdrant /       │
                    │  pgvector                │
                    └─────────────────────────┘
                          "indexing" → "ready"
                                  │
                                  ▼  (async status update on Document node)

            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

                         ╔══════════════════╗
                         ║   USER ASKS      ║
                         ║ "What does it    ║
                         ║  say about Q3?"  ║
                         ╚════════╤═════════╝
                                  │  POST /chat (SSE stream)
                                  ▼
                    ┌─────────────────────────┐
                    │   Query Preprocessor     │
                    │  Phase 1: pass-through   │
                    │  Phase 2: expansion,     │
                    │  sub-task decomposition  │
                    └────────────┬────────────┘
                                 │ query string
                                 ▼
                    ┌─────────────────────────┐
                    │   Retriever              │
                    │  Embed query →           │
                    │  FAISS similarity search │
                    │  k=30 candidates         │
                    │                          │
                    │  Phase 2: Hybrid         │
                    │  (dense + BM25 + ColBERT)│
                    │  + RAPTOR tree traversal │
                    └────────────┬────────────┘
                                 │ 30 candidates
                                 ▼
                    ┌─────────────────────────┐
                    │   Reranker               │
                    │  CrossEncoder            │
                    │  ms-marco-MiniLM-L6-v2   │
                    │  → top 7 chunks          │
                    │                          │
                    │  Phase 2: + Corrective   │
                    │  RAG confidence scoring  │
                    └────────────┬────────────┘
                                 │ 7 scored chunks
                                 ▼
                    ┌─────────────────────────┐
                    │   Generator (LLM)        │
                    │  gpt-4.1-mini            │
                    │  ReAct tool-calling      │
                    │  • Thinks & reasons      │
                    │  • Calls search_docs()   │
                    │  • Streams answer tokens │
                    │  • Cites sources         │
                    │                          │
                    │  Phase 2: Self-RAG       │
                    │  reflection + agentic    │
                    │  multi-step reasoning    │
                    └────────────┬────────────┘
                                 │ SSE token stream
                                 ▼
                         ╔══════════════════╗
                         ║  STREAMED ANSWER ║
                         ║  + source pages  ║
                         ╚══════════════════╝
```

---

### Graph Structure (Jac Object-Spatial Programming)

The core data model is a graph. Every entity is a node, relationships are edges. This is native to Jac and makes the system naturally extensible.

```
Root
 │
 ├──[has_tenant]──► Tenant (id, name, config, created_at)
 │                    │
 │                    ├──[has_document]──► Document (id, filename, file_type,
 │                    │                     status, uploaded_at, metadata)
 │                    │                       │
 │                    │                       └──[has_chunk]──► Chunk (id, content,
 │                    │                                          embedding, page_num,
 │                    │                                          chunk_index, metadata)
 │                    │
 │                    ├──[has_session]──► Session (id, chat_history, created_at)
 │                    │                    │
 │                    │                    └──[has_message]──► Message (role, content,
 │                    │                                         sources, timestamp)
 │                    │
 │                    └──[has_collection]──► Collection (id, name, description)
 │                                            │
 │                                            └──[contains_doc]──► Document
 │
 └──[has_config]──► SystemConfig (models, storage_backend, vector_backend)
```

**Phase 1 (demo):** Single default tenant, no auth required.
**Phase 2+:** Multi-tenant with auth, each tenant fully isolated.

---

### Single-Tenant vs Multi-Tenant Modes

Both modes share the exact same code path. Tenancy is a **config switch**, not an architectural change.

#### Mode A — Single-Tenant (Phase 1 Demo)
```
ANYGPT_MODE=single_tenant
```

```
Incoming request
      │
      ▼
┌───────────────────────┐
│  ingest / chat walker │
│                       │
│  tenant_id = "default"│  ← hardcoded, no auth needed
│  (always the same)    │
└──────────┬────────────┘
           │
           ▼
  anygpt-data/
  └── tenants/
      └── default/          ← single shared directory
          ├── uploads/
          ├── faiss_index/
          └── metadata.json
```

**When to use:** Local demos, personal assistants, single-team tools.

---

#### Mode B — Multi-Tenant (Phase 2+)
```
ANYGPT_MODE=multi_tenant
```

```
Incoming request
      │
      ▼
┌───────────────────────┐
│   Auth Middleware      │
│  • Validate JWT/API key│
│  • Extract tenant_id   │
└──────────┬────────────┘
           │ tenant_id = "acme_corp_a1b2"
           ▼
┌───────────────────────┐
│  Tenant Manager Walker │
│  • Validate tenant     │
│  • Load tenant config  │
│  • Apply rate limits   │
└──────────┬────────────┘
           │
           ▼
  anygpt-data/
  └── tenants/
      ├── default/
      ├── acme_corp_a1b2/   ← fully isolated per tenant
      │   ├── uploads/
      │   ├── faiss_index/
      │   └── metadata.json
      └── beta_startup_c3d4/
          ├── uploads/
          ├── faiss_index/
          └── metadata.json
```

**Extension path:** To enable multi-tenancy, add:
1. Auth middleware walker (JWT / API key validation)
2. Tenant provisioning walker (`POST /tenants`)
3. Rate limit + usage metering on the API layer
4. No changes needed to ingestion or RAG code — `tenant_id` is already threaded through all interfaces

**When to use:** SaaS product, enterprise deployments, white-label solutions.

---

### Component Design

#### 1. Document Ingestion Pipeline

```
User Upload (PDF/DOCX/MD/TXT/code)
       │
       ▼
┌─────────────────┐
│  File Validator  │  ── Check type, size, scan for issues
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  File Store      │  ── Save raw file to tenant's directory
│                  │     Phase 1: local fs (uploads/{tenant_id}/)
│                  │     Phase 2: S3/MinIO
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Document Loader │  ── Extract text from file format
│                  │     PDF:  PyPDFLoader / PyMuPDF
│                  │     DOCX: python-docx
│                  │     MD:   TextLoader
│                  │     Code: TextLoader with language metadata
│                  │     Phase 2: ColPali for multimodal PDFs
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Chunker         │  ── Split into retrievable units
│                  │     Phase 1: RecursiveCharacterTextSplitter
│                  │              (800 chars, 100 overlap)
│                  │     Phase 2: Contextual chunking
│                  │              (LLM-generated context preambles)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Embedder        │  ── Generate vector embeddings
│                  │     Phase 1: OpenAI text-embedding-3-small
│                  │     Phase 2: + BM25 sparse index
│                  │              + ColBERT late-interaction
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Index Writer    │  ── Persist to vector store
│                  │     Phase 1: FAISS (per-tenant index)
│                  │     Phase 2: Qdrant/pgvector
└─────────────────┘
```

#### 2. Retrieval Pipeline

```
User Query
    │
    ▼
┌────────────────────┐
│  Query Preprocessor│  ── Phase 2: query expansion, decomposition
│                    │     Phase 1: pass-through
└────────┬───────────┘
         │
         ▼
┌────────────────────┐
│  Retriever         │  ── Fetch candidate chunks
│                    │     Phase 1: FAISS similarity search (k=30)
│                    │     Phase 2: Hybrid (dense + sparse + ColBERT)
│                    │              + RAPTOR tree traversal
└────────┬───────────┘
         │
         ▼
┌────────────────────┐
│  Reranker          │  ── Score and filter results
│                    │     Phase 1: CrossEncoder ms-marco-MiniLM-L6-v2
│                    │              top_n=7
│                    │     Phase 2: + Corrective RAG confidence scoring
└────────┬───────────┘
         │
         ▼
┌────────────────────┐
│  Generator         │  ── Produce answer with citations
│                    │     Phase 1: LLM with ReAct tool-calling
│                    │     Phase 2: Self-RAG reflection loop
│                    │              + agentic multi-step reasoning
└────────────────────┘
```

#### 3. Storage Layout

```
anygpt-data/                              # DATA_ROOT (env var)
├── tenants/
│   ├── default/                          # Phase 1: single default tenant
│   │   ├── uploads/                      # Raw uploaded files
│   │   │   ├── report.pdf
│   │   │   ├── guide.md
│   │   │   └── notes.docx
│   │   ├── faiss_index/                  # Vector index for this tenant
│   │   │   ├── index.faiss
│   │   │   └── index.pkl
│   │   └── metadata.json                 # Tenant config + document registry
│   │
│   ├── tenant_abc123/                    # Phase 2: per-tenant isolation
│   │   ├── uploads/
│   │   ├── faiss_index/
│   │   └── metadata.json
│   │
│   └── tenant_def456/
│       └── ...
│
└── config/
    └── anygpt.json                       # Global config
```

---

### Tech Stack

| Layer | Phase 1 | Phase 2+ |
|-------|---------|----------|
| **Language** | Jac (Jaseci ecosystem) | Jac |
| **Frontend** | Jac Client (`.cl.jac`) + Mantine UI | + branded themes, Tauri desktop app |
| **Backend** | Jac walkers + jac-cloud | + jac-scale (Kubernetes) |
| **LLM** | OpenAI GPT-4.1-mini (byllm) | Configurable, auto-specialized SLM |
| **Embeddings** | OpenAI `text-embedding-3-small` | + BM25 sparse, ColBERT late-interaction |
| **Multimodal** | — | ColPali / ColQwen (VLM-based PDF ingestion) |
| **Vector Store** | FAISS (local file) | Qdrant / pgvector |
| **Object Store** | Local filesystem | S3 / MinIO |
| **Metadata DB** | JSON file per tenant | PostgreSQL |
| **Document Loading** | PyPDF, TextLoader, python-docx | + ColPali (no OCR needed) |
| **Chunking** | RecursiveCharacterTextSplitter | + Contextual chunking (LLM preambles) |
| **Reranking** | CrossEncoder `ms-marco-MiniLM-L6-v2` | + Corrective RAG |
| **RAG Pattern** | ReAct tool-calling | + Self-RAG, RAPTOR, agentic decomposition |
| **Deployment** | `docker compose up` | Kubernetes via `jac-scale` |
| **Auth** | None (single-tenant demo) | JWT / API keys per tenant |

---

### API Design

#### Phase 1 Endpoints

```
# Document Management
POST   /upload                     Upload document(s) to tenant's store
GET    /documents                  List all documents for current tenant
GET    /documents/{doc_id}         Get document metadata + status
DELETE /documents/{doc_id}         Remove document and its chunks from index

# Chat / Query
POST   /chat                       Send message, get RAG-augmented response (SSE stream)
GET    /sessions                   List chat sessions
GET    /sessions/{session_id}      Get session chat history
DELETE /sessions/{session_id}      Delete a session

# Index Management
POST   /reindex                    Force re-index all documents for tenant
GET    /index/status               Get indexing status (doc count, chunk count, etc.)
```

#### Request/Response Examples

**Upload:**
```json
// POST /upload
// Content-Type: multipart/form-data
// Body: file=@report.pdf

// Response 200:
{
  "document_id": "doc_a1b2c3",
  "filename": "report.pdf",
  "file_type": "pdf",
  "status": "indexing",        // "indexing" → "ready" | "failed"
  "page_count": 42,
  "chunk_count": null,         // populated after indexing completes
  "uploaded_at": "2026-03-17T10:00:00Z"
}
```

**Chat:**
```json
// POST /chat
// Content-Type: application/json
{
  "message": "What does the report say about Q3 revenue?",
  "session_id": "sess_x1y2z3"   // optional, creates new if omitted
}

// Response: SSE stream
// event: message
// data: {"type": "source", "chunks": [{"content": "...", "source": "report.pdf", "page": 12, "score": 0.94}]}
//
// event: message
// data: {"type": "token", "content": "According"}
// data: {"type": "token", "content": " to"}
// ...
// event: message
// data: {"type": "done", "sources": ["report.pdf:12", "report.pdf:15"]}
```

---

### Configuration

```json
// config/anygpt.json
{
  "mode": "single_tenant",               // "single_tenant" | "multi_tenant"

  "storage": {
    "backend": "local",                  // "local" | "s3"
    "data_root": "./anygpt-data",
    "max_file_size_mb": 50,
    "allowed_extensions": [".pdf", ".md", ".txt", ".docx", ".py", ".js", ".ts", ".jac"]
  },

  "vector_store": {
    "backend": "faiss",                  // "faiss" | "qdrant" | "pgvector"
    "embedding_model": "text-embedding-3-small",
    "embedding_dimensions": 1536
  },

  "chunking": {
    "strategy": "recursive",            // "recursive" | "contextual" (phase 2)
    "chunk_size": 800,
    "chunk_overlap": 100
  },

  "retrieval": {
    "initial_k": 30,
    "reranker_model": "cross-encoder/ms-marco-MiniLM-L6-v2",
    "top_n": 7
  },

  "llm": {
    "model": "gpt-4.1-mini",
    "method": "ReAct",
    "max_react_iterations": 5,
    "temperature": 0.1
  },

  "server": {
    "host": "0.0.0.0",
    "port": 8000
  }
}
```

---

### Abstraction Interfaces (for pluggability)

The key to extensibility is defining clean interfaces at each layer boundary. Phase 1 implements the simplest version of each; later phases swap in advanced implementations without changing the orchestration code.

```
# Pseudocode interfaces (implemented as Jac abilities/objects)

# --- File Store ---
interface FileStore:
    save(tenant_id, filename, file_bytes) -> file_path
    load(tenant_id, filename) -> file_bytes
    delete(tenant_id, filename) -> bool
    list(tenant_id) -> list[FileMetadata]

# Phase 1: LocalFileStore (reads/writes to anygpt-data/tenants/{id}/uploads/)
# Phase 2: S3FileStore (same interface, backed by S3/MinIO)


# --- Document Loader ---
interface DocumentLoader:
    load(file_path, file_type) -> list[DocumentPage]
    supported_types() -> list[str]

# Phase 1: TextDocLoader (PyPDF + TextLoader + python-docx)
# Phase 2: ColPaliLoader (VLM-based multimodal, treats PDFs as screenshots)


# --- Chunker ---
interface Chunker:
    chunk(pages: list[DocumentPage]) -> list[Chunk]

# Phase 1: RecursiveChunker (RecursiveCharacterTextSplitter)
# Phase 2: ContextualChunker (wraps RecursiveChunker + LLM context preambles)


# --- Vector Store ---
interface VectorStore:
    add(tenant_id, chunks: list[Chunk]) -> None
    search(tenant_id, query_embedding, k) -> list[ScoredChunk]
    delete_by_doc(tenant_id, doc_id) -> None
    tenant_stats(tenant_id) -> IndexStats

# Phase 1: FAISSStore (per-tenant index.faiss + index.pkl)
# Phase 2: QdrantStore or PgVectorStore (managed, scalable)


# --- Reranker ---
interface Reranker:
    rerank(query, candidates: list[ScoredChunk], top_n) -> list[ScoredChunk]

# Phase 1: CrossEncoderReranker (ms-marco-MiniLM-L6-v2)
# Phase 2: + CorrectiveRAGReranker (confidence-gated fallback)


# --- Retriever (orchestrates Vector Store + Reranker) ---
interface Retriever:
    retrieve(tenant_id, query, top_n) -> list[ScoredChunk]

# Phase 1: SimpleRetriever (embed → FAISS search → CrossEncoder rerank)
# Phase 2: HybridRetriever (dense + sparse + ColBERT → merge → rerank)
#           + RAPTORRetriever (hierarchical tree traversal)
```

---

### Phase 1 → Ultimate Goal Extension Points

| Component | Phase 1 (Demo) | What to swap / add |
|-----------|----------------|-------------------|
| **Tenancy** | Single `default` tenant, no auth | Add auth middleware walker, tenant provisioning endpoint, per-tenant API keys |
| **File Storage** | `LocalFileStore` (local disk) | Swap for `S3FileStore` via config — same interface, zero orchestration changes |
| **Vector Store** | `FAISSStore` (per-tenant `.faiss` files) | Swap for `QdrantStore` or `PgVectorStore` via config — same interface |
| **Document Loading** | PyPDF + TextLoader (text-only) | Add `ColPaliLoader` alongside existing loaders — VLM processes text + images |
| **Chunking** | `RecursiveChunker` | Wrap with `ContextualChunker` that prepends LLM-generated context preambles |
| **Retrieval** | Dense only (FAISS similarity) | Add BM25 sparse + ColBERT late-interaction as parallel retrievers, merge results |
| **Reranking** | CrossEncoder | Add Corrective RAG confidence scoring as post-reranking filter |
| **Summarization** | None | Add RAPTOR: cluster chunks with GMMs, recursively summarize, build tree index |
| **Generation** | ReAct with single tool (`search_docs`) | Add Self-RAG reflection loop, agentic sub-task decomposition, MCP tool integration |
| **Frontend** | Single chat UI with upload | Per-tenant branded UI, config dashboard, embeddable widget |
| **API** | Single shared endpoint set | Per-tenant API gateway with rate limiting, usage metering, API key auth |
| **External Data** | Documents only | MCP server exposing doc stores as Resources; connect external DBs/APIs/wikis as MCP servers |
| **Deployment** | `docker compose up` | Kubernetes via `jac-scale`, horizontal scaling |
| **Model** | OpenAI GPT-4.1-mini | Auto-specialize small language model fine-tuned on tenant's data |

---

### Project Structure (Phase 1)

```
Any-GPT/
├── README.md                              # This file
├── main.jac                               # Entry point
├── jac.toml                               # Jac project config + dependencies
├── Dockerfile                             # Container build
├── docker-compose.yml                     # Single-command deployment
├── .env.example                           # Required environment variables
├── .gitignore
│
├── config/
│   └── anygpt.json                        # System configuration
│
├── services/                              # Backend (Jac server-side)
│   ├── __init__.jac                       # Module init
│   │
│   ├── models/                            # Graph nodes and data types
│   │   ├── __init__.jac
│   │   ├── tenant.jac                     # Tenant node
│   │   ├── document.jac                   # Document node
│   │   ├── chunk.jac                      # Chunk node
│   │   └── session.jac                    # Session + Message nodes
│   │
│   ├── ingestion/                         # Document ingestion pipeline
│   │   ├── __init__.jac
│   │   ├── file_store.jac                 # FileStore interface + LocalFileStore
│   │   ├── loaders.jac                    # DocumentLoader implementations
│   │   ├── chunker.jac                    # Chunker interface + RecursiveChunker
│   │   └── ingest_walker.jac              # Orchestrates upload → chunk → embed → index
│   │
│   ├── retrieval/                         # RAG retrieval pipeline
│   │   ├── __init__.jac
│   │   ├── vector_store.jac               # VectorStore interface + FAISSStore
│   │   ├── reranker.jac                   # Reranker interface + CrossEncoderReranker
│   │   ├── retriever.jac                  # Retriever (orchestrates search + rerank)
│   │   └── rag_walker.jac                 # Chat walker: query → retrieve → generate
│   │
│   ├── server.jac                         # API endpoints (upload, chat, documents)
│   └── server.impl.jac                    # Endpoint implementations
│
├── frontend.cl.jac                        # Frontend routing
│
├── components/                            # Frontend (Jac client-side)
│   ├── ChatMessage.cl.jac
│   ├── ChatInput.cl.jac
│   ├── FileUpload.cl.jac                  # Drag-and-drop upload widget
│   ├── DocumentList.cl.jac                # Uploaded docs sidebar
│   └── Sidebar.cl.jac
│
├── pages/
│   ├── ChatPage.cl.jac                    # Main chat + upload page
│   └── DocumentsPage.cl.jac              # Document management page
│
├── hooks/
│   └── useChat.cl.jac                     # Chat state + SSE streaming
│
└── tests/
    ├── test_ingestion.jac                 # Ingestion pipeline tests
    ├── test_retrieval.jac                 # Retrieval pipeline tests
    └── e2e_test.mjs                       # End-to-end browser tests
```

---

### Deployment

#### Development (local)
```bash
# Prerequisites: Python 3.11+, Node.js 18+, Jac installed
pip install jac

# Clone and setup
git clone https://github.com/RavimalRanathunga/Any-GPT.git
cd Any-GPT
cp .env.example .env   # Add your OPENAI_API_KEY

# Run
jac serve main.jac
# → Backend:  http://localhost:8000
# → Frontend: http://localhost:3000
```

#### Docker (demo — recommended)
```bash
docker compose up
# → App available at http://localhost:8000
# → Data persisted in ./anygpt-data/ volume
```

```yaml
# docker-compose.yml
services:
  anygpt:
    build: .
    ports:
      - "8000:8000"
    volumes:
      - ./anygpt-data:/app/anygpt-data          # Persist uploads + indices
    environment:
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - ANYGPT_MODE=single_tenant                # Switch to multi_tenant for Phase 2
      - ANYGPT_DATA_ROOT=/app/anygpt-data
```

---

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `OPENAI_API_KEY` | Yes | — | OpenAI API key for embeddings + LLM |
| `ANYGPT_MODE` | No | `single_tenant` | `single_tenant` or `multi_tenant` |
| `ANYGPT_DATA_ROOT` | No | `./anygpt-data` | Root directory for all data |
| `ANYGPT_MODEL` | No | `gpt-4.1-mini` | LLM model for generation |
| `ANYGPT_EMBEDDING_MODEL` | No | `text-embedding-3-small` | Embedding model |
| `ANYGPT_MAX_FILE_SIZE_MB` | No | `50` | Max upload file size in MB |
| `ANYGPT_PORT` | No | `8000` | Server port |

---

### Roadmap

#### Phase 1 Scope (This Implementation)

| Milestone | Deliverable | Status |
|-----------|-------------|--------|
| **1.0 — Core MVP** | Upload docs (PDF/MD/DOCX/TXT/code), FAISS indexing, CrossEncoder reranking, ReAct chat with SSE streaming, source citations, single-tenant local storage | In Progress |
| **1.1 — Multi-tenant** | JWT/API key auth middleware, tenant provisioning walker, per-tenant isolation (same storage + vector code, config switch only) | Planned |

#### Phase 2+ Scope (Ultimate Goal)

| Milestone | Deliverable |
|-----------|-------------|
| **1.2 — Advanced RAG** | Contextual chunking (LLM preambles), RAPTOR hierarchical summaries, hybrid search (dense + BM25 + ColBERT), Self-RAG reflection loop, Corrective RAG evaluator |
| **1.3 — MCP Integration** | AnyGPT MCP server exposing doc stores as Resources + search as Tools; external data source connectors (DBs, APIs, wikis); Streamable HTTP + STDIO transports |
| **1.4 — Per-Tenant UI & API** | Auto-generated branded chat UI per tenant, REST API endpoint per tenant, embeddable iframe/web-component widget |
| **1.5 — Open Source Launch** | Dockerized single-command deploy (`jac start`), full documentation, quickstart guide, community contribution guidelines |
| **2.0 — Enterprise** | Config dashboard, auto-specialize SLM (fine-tuned on tenant data), desktop app (Tauri + Jac), on-prem tooling, white-label UI |

#### Ultimate Goal Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                     AnyGPT Platform                                 │
├──────────────┬──────────────┬───────────────┬───────────────────────┤
│  Tenant UI   │ Config       │  API Gateway  │  Desktop App          │
│  (per-user   │ Dashboard    │  (per-tenant  │  (Tauri + Jac)        │
│   branded)   │ (enterprise) │   endpoints)  │                       │
├──────────────┴──────────────┴───────────────┴───────────────────────┤
│                     Orchestration Layer (Jac Walkers)               │
│  ┌──────────┐  ┌──────────────┐  ┌───────────┐  ┌───────────────┐  │
│  │ Agentic  │  │ MCP Context  │  │ Auto-     │  │ Tenant        │  │
│  │ RAG      │  │ Engine       │  │ Specialize│  │ Manager       │  │
│  └──────────┘  └──────────────┘  └───────────┘  └───────────────┘  │
├─────────────────────────────────────────────────────────────────────┤
│                     Knowledge Layer                                 │
│  ┌──────────────┐  ┌────────────┐  ┌──────────┐  ┌─────────────┐  │
│  │ Contextual   │  │ ColPali    │  │ Hybrid   │  │ RAPTOR       │  │
│  │ Retrieval    │  │ (Multimodal│  │ Search   │  │ (Hierarchical│  │
│  │ + Self-RAG   │  │  Retrieval)│  │ + Rerank │  │  Summaries)  │  │
│  └──────────────┘  └────────────┘  └──────────┘  └─────────────┘  │
├─────────────────────────────────────────────────────────────────────┤
│                     Storage Layer                                   │
│       pgvector / Qdrant          │     Object Store (S3/MinIO)      │
└─────────────────────────────────────────────────────────────────────┘
```

---

### License

TBD
