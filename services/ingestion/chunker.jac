"""Chunker interface + RecursiveChunker implementation.

Phase 1: RecursiveCharacterTextSplitter with metadata enrichment.
Phase 2: Wrap with ContextualChunker (LLM-generated context preambles).
"""

import os;
import from langchain_text_splitters {RecursiveCharacterTextSplitter}
import from langchain_core.documents {Document}


"""Split documents into chunks using RecursiveCharacterTextSplitter."""
def chunk_documents(documents: list, chunk_size: int = 800, chunk_overlap: int = 100) -> list {
    text_splitter = RecursiveCharacterTextSplitter(
        chunk_size=chunk_size,
        chunk_overlap=chunk_overlap,
        length_function=len,
        is_separator_regex=False
    );
    chunks = text_splitter.split_documents(documents);
    return assign_chunk_ids(chunks);
}


"""Assign unique IDs and enrich chunk content with metadata."""
def assign_chunk_ids(chunks: list) -> list {
    last_page_id = None;
    current_chunk_index = 0;

    for chunk in chunks {
        source = chunk.metadata.get('source');
        page = chunk.metadata.get('page');

        if page is None {
            current_page_id = f'{source}:0';
        } else {
            current_page_id = f'{source}:{page}';
        }

        if current_page_id == last_page_id {
            current_chunk_index += 1;
        } else {
            current_chunk_index = 0;
        }

        chunk_id = f'{current_page_id}:{current_chunk_index}';
        last_page_id = current_page_id;

        chunk.metadata['id'] = chunk_id;
        chunk.metadata['original_content'] = chunk.page_content;
        chunk.page_content = enrich_with_metadata(chunk);
    }

    return chunks;
}


"""Enrich chunk content with metadata prefix for better semantic matching."""
def enrich_with_metadata(chunk: Document) -> str {
    source = os.path.basename(chunk.metadata.get('source', 'unknown'));
    page = chunk.metadata.get('page');
    chunk_id = chunk.metadata.get('id', '');

    metadata_prefix = f"Source: {source}";
    if page is not None {
        metadata_prefix += f", Page: {page}";
    }
    if chunk_id {
        metadata_prefix += f", ChunkID: {chunk_id}";
    }

    return f"{metadata_prefix}\n\n{chunk.page_content}";
}
