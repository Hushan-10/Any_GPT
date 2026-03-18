"""Retrieval module - RAG retrieval pipeline.

Components:
- vector_store: VectorStore interface + FAISSStore (create/search/cleanup index)
- reranker: CrossEncoder reranking (ms-marco-MiniLM-L6-v2)
- retriever: Orchestrates vector search + reranking into formatted results
"""

import from .vector_store {get_embedding_function, create_index, add_to_index, load_index, search_index, cleanup_index}
import from .reranker {init_reranker, rerank}
import from .retriever {retrieve, format_results}
