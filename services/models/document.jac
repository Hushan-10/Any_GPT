"""Document node - represents an uploaded document.

Tracks the document lifecycle from upload through indexing.
"""

node Document {
    has id: str;
    has filename: str;
    has file_type: str;
    has status: str = "indexing";  # "indexing" | "ready" | "failed"
    has chunk_count: int = 0;
    has page_count: int = 0;
    has file_size: int = 0;
    has uploaded_at: str = "";
    has metadata: dict = {};
}
