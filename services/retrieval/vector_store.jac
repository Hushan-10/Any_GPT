"""VectorStore interface + FAISSStore implementation.

Phase 1: FAISS per-tenant index (index.faiss + index.pkl).
Phase 2: Swap for QdrantStore or PgVectorStore via config.
"""

import os;
import from langchain_openai {OpenAIEmbeddings}
import from langchain_community.vectorstores {FAISS}


"""Get OpenAI embedding function."""
def get_embedding_function() -> any {
    api_key = os.getenv('OPENAI_API_KEY', '');
    if not api_key {
        print("Warning: OPENAI_API_KEY not set.");
        return None;
    }
    return OpenAIEmbeddings();
}


"""Create a new FAISS index from document chunks."""
def create_index(chunks: list, faiss_path: str) -> any {
    if len(chunks) == 0 {
        print("No documents to index");
        return None;
    }

    print(f"Creating FAISS index with {len(chunks)} chunks");
    embeddings = get_embedding_function();
    if embeddings is None {
        return None;
    }

    vectorstore = FAISS.from_documents(chunks, embeddings);
    vectorstore.save_local(faiss_path);
    print(f"FAISS index saved to {faiss_path}");
    return vectorstore;
}


"""Add chunks to an existing FAISS index, or create new if none exists."""
def add_to_index(chunks: list, faiss_path: str, vectorstore: any = None) -> any {
    if vectorstore is None {
        return create_index(chunks, faiss_path);
    }

    if len(chunks) > 0 {
        print(f"Adding {len(chunks)} chunks to FAISS index");
        vectorstore.add_documents(chunks);
        vectorstore.save_local(faiss_path);
        print("FAISS index updated");
    }
    return vectorstore;
}


"""Load an existing FAISS index from disk."""
def load_index(faiss_path: str) -> any {
    embeddings = get_embedding_function();
    faiss_index_file = os.path.join(faiss_path, "index.faiss");

    if os.path.exists(faiss_index_file) and embeddings is not None {
        print(f"Loading existing FAISS index from {faiss_path}");
        return FAISS.load_local(
            faiss_path,
            embeddings,
            allow_dangerous_deserialization=True
        );
    }
    return None;
}


"""Search the FAISS index for similar documents."""
def search_index(vectorstore: any, query: str, k: int = 30) -> list {
    if vectorstore is None {
        print("FAISS index not initialized. Upload documents first.");
        return [];
    }
    return vectorstore.similarity_search_with_score(query, k=k);
}


"""Remove FAISS index files from disk."""
def cleanup_index(faiss_path: str) -> None {
    index_file = os.path.join(faiss_path, "index.faiss");
    pkl_file = os.path.join(faiss_path, "index.pkl");
    if os.path.exists(index_file) {
        os.remove(index_file);
    }
    if os.path.exists(pkl_file) {
        os.remove(pkl_file);
    }
    print("FAISS index files cleaned up");
}
