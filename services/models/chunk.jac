"""Chunk node - represents a text chunk from a document.

Each chunk is a retrievable unit with its embedding and metadata.
"""

node Chunk {
    has id: str;
    has content: str;
    has page_num: int = 0;
    has chunk_index: int = 0;
    has metadata: dict = {};
}
