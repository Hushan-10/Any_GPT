"""Document loader implementations.

Phase 1: PyPDFLoader, TextLoader, python-docx.
Phase 2: Add ColPaliLoader for VLM-based multimodal PDF ingestion.
"""

import os;
import from langchain_community.document_loaders {PyPDFLoader}
import from langchain_community.document_loaders.text {TextLoader}
import from langchain_core.documents {Document}


"""Load a single document file based on its extension."""
def load_document(file_path: str) -> list {
    ext = os.path.splitext(file_path)[1].lower();

    if ext == '.pdf' {
        loader = PyPDFLoader(file_path);
        return loader.load();
    } elif ext in ['.md', '.txt', '.py', '.js', '.ts', '.jac'] {
        loader = TextLoader(file_path, encoding="utf-8");
        return loader.load();
    } elif ext == '.docx' {
        return load_docx(file_path);
    } else {
        print(f"Unsupported file type: {ext}");
        return [];
    }
}


"""Load a DOCX file using python-docx."""
def load_docx(file_path: str) -> list {
    try {
        import docx;
        doc = docx.Document(file_path);
        text = "\n".join([para.text for para in doc.paragraphs if para.text.strip()]);
        return [Document(page_content=text, metadata={"source": file_path})];
    } except Exception as e {
        print(f"Error loading DOCX {file_path}: {e}");
        return [];
    }
}


"""Load all documents from a directory."""
def load_all_from_directory(directory: str) -> list {
    documents = [];
    if not os.path.exists(directory) {
        return documents;
    }

    for (root_dir, dirs, files) in os.walk(directory) {
        for filename in files {
            file_path = os.path.join(root_dir, filename);
            try {
                docs = load_document(file_path);
                documents.extend(docs);
            } except Exception as e {
                print(f"Error loading {filename}: {e}");
            }
        }
    }

    print(f"Total documents loaded: {len(documents)}");
    return documents;
}


"""Get supported file extensions."""
def supported_types() -> list[str] {
    return [".pdf", ".md", ".txt", ".docx", ".py", ".js", ".ts", ".jac"];
}
