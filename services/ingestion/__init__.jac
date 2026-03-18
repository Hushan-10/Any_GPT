"""Ingestion module - Document ingestion pipeline.

Components:
- file_store: FileStore interface + LocalFileStore (save/load/delete/list files)
- loaders: DocumentLoader implementations (PDF, DOCX, MD, TXT, code)
- chunker: Chunker with RecursiveCharacterTextSplitter + metadata enrichment
"""

import from .file_store {save_file, load_file, delete_file, list_files, validate_file}
import from .loaders {load_document, load_docx, load_all_from_directory, supported_types}
import from .chunker {chunk_documents, assign_chunk_ids, enrich_with_metadata}
