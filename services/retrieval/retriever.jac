"""Retriever - orchestrates Vector Store search + Reranker.

Phase 1: SimpleRetriever (embed -> FAISS search -> CrossEncoder rerank).
Phase 2: HybridRetriever (dense + sparse + ColBERT -> merge -> rerank).
"""

import os;
import from .vector_store {search_index}
import from .reranker {rerank}


"""Search and rerank documents, returning formatted results.

This is the main retrieval function that:
1. Searches the FAISS vector store for candidate chunks (k=initial_k)
2. Reranks candidates using CrossEncoder (top_n results)
3. Formats results with source attribution
"""
def retrieve(
    query: str,
    vectorstore: any,
    cross_encoder: any = None,
    initial_k: int = 30,
    top_n: int = 7,
    use_reranking: bool = True
) -> list {
    # Step 1: Vector similarity search
    results = search_index(vectorstore, query, k=initial_k);

    if len(results) == 0 {
        return [];
    }

    # Step 2: Rerank with CrossEncoder
    if use_reranking and cross_encoder is not None {
        results = rerank(query, results, cross_encoder, top_n=top_n);
    }

    return results;
}


"""Format retrieval results into a readable string for the LLM."""
def format_results(results: list) -> str {
    if len(results) == 0 {
        return "No relevant documents found. Please upload documents first.";
    }

    summary = "";
    for (idx, (doc, score)) in enumerate(results, 1) {
        source = os.path.basename(doc.metadata.get('source', 'unknown'));
        page = doc.metadata.get('page', 'N/A');
        original_content = doc.metadata.get('original_content', doc.page_content);
        summary += f"[Source: {source}, Page: {page}, Relevance: {score:.4f}]\n{original_content}\n\n";
    }

    return summary;
}
