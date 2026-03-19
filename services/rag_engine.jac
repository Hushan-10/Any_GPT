"""AnyGPT RAG Engine - Orchestrates ingestion and retrieval modules.

The RagEngine is the central coordinator that delegates to:
- ingestion/ modules for file loading, chunking, and metadata enrichment
- retrieval/ modules for vector search, reranking, and result formatting

Phase 1: Single tenant with user-uploaded documents.
Phase 2+: Swap to Qdrant/pgvector, add contextual chunking, RAPTOR, etc.
"""

import os;
import json;
import time;
import shutil;
import from langchain_community.document_loaders {PyPDFLoader, DirectoryLoader}
import from langchain_community.document_loaders.text {TextLoader}
import from langchain_text_splitters {RecursiveCharacterTextSplitter}
import from langchain_core.documents {Document}
import from langchain_openai {OpenAIEmbeddings}
import from langchain_community.vectorstores {FAISS}
import from sentence_transformers {CrossEncoder}

# Import from ingestion module
import from services.ingestion.loaders {load_document, load_all_from_directory}
import from services.ingestion.chunker {chunk_documents}
import from services.ingestion.file_store {validate_file, list_files, save_file, delete_file}

# Import from retrieval module
import from services.retrieval.vector_store {
    get_embedding_function,
    create_index,
    add_to_index,
    load_index,
    search_index,
    cleanup_index
}
import from services.retrieval.reranker {init_reranker, rerank}
import from services.retrieval.retriever {retrieve, format_results}


"""Load AnyGPT configuration from JSON file."""
def load_config() -> dict {
    try {
        config_path = os.path.join(os.path.dirname(__file__), "..", "config", "anygpt.json");
        config_path = os.path.normpath(config_path);
        with open(config_path, 'r', encoding='utf-8') as f {
            return json.load(f);
        }
    } except Exception as e {
        print(f"Error loading config: {e}");
        return {
            "mode": "single_tenant",
            "storage": {"backend": "local", "data_root": "./anygpt-data"},
            "chunking": {"chunk_size": 800, "chunk_overlap": 100},
            "retrieval": {"initial_k": 30, "reranker_model": "cross-encoder/ms-marco-MiniLM-L6-v2", "top_n": 7}
        };
    }
}

"""Get or create the tenant data directory, optionally scoped to a user."""
def get_tenant_dir(config: dict, tenant_id: str = "default", user_id: str = "") -> str {
    data_root = config.get("storage", {}).get("data_root", "./anygpt-data");
    if user_id {
        tenant_dir = os.path.join(data_root, "tenants", tenant_id, "users", user_id);
    } else {
        tenant_dir = os.path.join(data_root, "tenants", tenant_id);
    }
    os.makedirs(os.path.join(tenant_dir, "uploads"), exist_ok=True);
    os.makedirs(os.path.join(tenant_dir, "faiss_index"), exist_ok=True);
    return tenant_dir;
}


"""Sanitize a user email/username into a safe directory name."""
def sanitize_user_id(user_email: str) -> str {
    return user_email.replace("@", "_at_").replace(".", "_").replace(" ", "_").lower();
}

obj RagEngine {
    has config: dict;
    has tenant_id: str = "default";
    has user_id: str = "";
    has shared_cross_encoder: CrossEncoder = None;
    has tenant_dir: str = "";
    has uploads_dir: str = "";
    has faiss_path: str = "";
    has chunk_size: int = 800;
    has chunk_overlap: int = 100;
    has initial_k: int = 30;
    has top_n: int = 7;
    has cross_encoder_model: str = "cross-encoder/ms-marco-MiniLM-L6-v2";
    has vectorstore: FAISS = None;
    has cross_encoder: CrossEncoder = None;
    has use_reranking: bool = True;

    def postinit {
        # Set up paths — scoped to user if user_id is provided
        self.tenant_dir = get_tenant_dir(self.config, self.tenant_id, self.user_id);
        self.uploads_dir = os.path.join(self.tenant_dir, "uploads");
        self.faiss_path = os.path.join(self.tenant_dir, "faiss_index");

        # Read config values
        chunking = self.config.get("chunking", {});
        self.chunk_size = chunking.get("chunk_size", 800);
        self.chunk_overlap = chunking.get("chunk_overlap", 100);

        retrieval_config = self.config.get("retrieval", {});
        self.initial_k = retrieval_config.get("initial_k", 30);
        self.top_n = retrieval_config.get("top_n", 7);
        self.cross_encoder_model = retrieval_config.get("reranker_model", "cross-encoder/ms-marco-MiniLM-L6-v2");

        # Reuse shared CrossEncoder if provided (avoids reloading ~80MB model per user)
        if self.shared_cross_encoder is not None {
            self.cross_encoder = self.shared_cross_encoder;
        } else {
            self.cross_encoder = init_reranker(self.cross_encoder_model);
        }
        if self.cross_encoder is None {
            self.use_reranking = False;
        }

        # Load existing FAISS index or build from uploaded documents
        self.vectorstore = load_index(self.faiss_path);
        if self.vectorstore is None {
            embeddings = get_embedding_function();
            if embeddings is not None {
                documents = load_all_from_directory(self.uploads_dir);
                if len(documents) > 0 {
                    chunks = chunk_documents(documents, self.chunk_size, self.chunk_overlap);
                    self.vectorstore = create_index(chunks, self.faiss_path);
                } else {
                    print("No documents found. Upload documents to get started.");
                }
            } else {
                print("OPENAI_API_KEY not set. Embeddings unavailable.");
            }
        }

        user_label = f" (user: {self.user_id})" if self.user_id else "";
        print(f"RAG Engine initialized for tenant: {self.tenant_id}{user_label}");
    }

    """Ingest a single file: load, chunk, embed, add to index."""
    def ingest_file(file_path: str) -> dict {
        try {
            documents = load_document(file_path);
            if len(documents) == 0 {
                return {"success": False, "error": "No content extracted", "chunk_count": 0};
            }
            chunks = chunk_documents(documents, self.chunk_size, self.chunk_overlap);
            self.vectorstore = add_to_index(chunks, self.faiss_path, self.vectorstore);
            return {"success": True, "chunk_count": len(chunks)};
        } except Exception as e {
            print(f"Error ingesting {file_path}: {e}");
            return {"success": False, "error": str(e), "chunk_count": 0};
        }
    }

    """Rebuild the entire index from all uploaded documents."""
    def rebuild_index {
        documents = load_all_from_directory(self.uploads_dir);
        if len(documents) > 0 {
            chunks = chunk_documents(documents, self.chunk_size, self.chunk_overlap);
            self.vectorstore = create_index(chunks, self.faiss_path);
        } else {
            self.vectorstore = None;
            cleanup_index(self.faiss_path);
            print("No documents to index - index files cleaned up");
        }
    }

    """Main search function used by the chat system."""
    def search(query: str) -> str {
        print(f'Searching RAG Engine with query: {query}');

        results = retrieve(
            query=query,
            vectorstore=self.vectorstore,
            cross_encoder=self.cross_encoder,
            initial_k=self.initial_k,
            top_n=self.top_n,
            use_reranking=self.use_reranking
        );

        return format_results(results);
    }

    """Get index statistics."""
    def get_stats() -> dict {
        upload_files = [];
        if os.path.exists(self.uploads_dir) {
            for (root_dir, dirs, files) in os.walk(self.uploads_dir) {
                for f in files {
                    upload_files.append(f);
                }
            }
        }

        has_index = self.vectorstore is not None;

        return {
            "tenant_id": self.tenant_id,
            "document_count": len(upload_files),
            "documents": upload_files,
            "has_index": has_index,
            "uploads_dir": self.uploads_dir
        };
    }
}
