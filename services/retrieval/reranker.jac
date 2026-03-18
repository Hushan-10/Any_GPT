"""Reranker interface + CrossEncoderReranker implementation.

Phase 1: CrossEncoder ms-marco-MiniLM-L6-v2 reranking.
Phase 2: Add Corrective RAG confidence-gated fallback.
"""

import from sentence_transformers {CrossEncoder}


"""Initialize a CrossEncoder reranker model."""
def init_reranker(model_name: str = "cross-encoder/ms-marco-MiniLM-L6-v2") -> any {
    try {
        cross_encoder = CrossEncoder(model_name);
        print(f"CrossEncoder reranking enabled: {model_name}");
        return cross_encoder;
    } except Exception as e {
        print(f"Warning: Failed to load CrossEncoder: {e}");
        return None;
    }
}


"""Rerank search results using CrossEncoder.

Takes (document, score) pairs from vector search and reranks them
using the CrossEncoder model for better relevance ordering.
"""
def rerank(query: str, documents: list, cross_encoder: any, top_n: int = 7) -> list {
    if cross_encoder is None or len(documents) == 0 {
        return documents;
    }

    try {
        docs_only = [doc for (doc, _) in documents];
        pairs = [
            (query, doc.metadata.get('original_content', doc.page_content))
            for doc in docs_only
        ];

        scores = cross_encoder.predict(
            pairs,
            show_progress_bar=False,
            batch_size=30,
            convert_to_numpy=True,
            convert_to_tensor=False
        );

        doc_score_pairs = list(zip(docs_only, scores));
        results = sorted(doc_score_pairs, key=lambda x: -float(x[1]));

        if top_n is not None {
            results = results[:top_n];
        }

        return results;
    } except Exception as e {
        print(f"Error during reranking: {e}");
        return documents;
    }
}
