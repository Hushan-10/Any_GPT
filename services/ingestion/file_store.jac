"""FileStore interface + LocalFileStore implementation.

Phase 1: Local filesystem storage for uploaded documents.
Phase 2: Swap for S3FileStore via config — same interface.
"""

import os;


"""Save a file to the tenant's uploads directory."""
def save_file(uploads_dir: str, filename: str, file_bytes: bytes) -> str {
    os.makedirs(uploads_dir, exist_ok=True);
    file_path = os.path.join(uploads_dir, filename);
    with open(file_path, 'wb') as f {
        f.write(file_bytes);
    }
    return file_path;
}


"""Load a file from the tenant's uploads directory."""
def load_file(uploads_dir: str, filename: str) -> bytes {
    file_path = os.path.join(uploads_dir, filename);
    with open(file_path, 'rb') as f {
        return f.read();
    }
}


"""Delete a file from the tenant's uploads directory."""
def delete_file(uploads_dir: str, filename: str) -> bool {
    file_path = os.path.join(uploads_dir, filename);
    if os.path.exists(file_path) {
        os.remove(file_path);
        return True;
    }
    return False;
}


"""List all files in the tenant's uploads directory."""
def list_files(uploads_dir: str) -> list[dict] {
    files = [];
    if not os.path.exists(uploads_dir) {
        return files;
    }
    for filename in os.listdir(uploads_dir) {
        file_path = os.path.join(uploads_dir, filename);
        if os.path.isfile(file_path) {
            files.append({
                "filename": filename,
                "file_path": file_path,
                "file_size": os.path.getsize(file_path),
                "modified_at": os.path.getmtime(file_path)
            });
        }
    }
    return files;
}


"""Validate a file before upload (type + size)."""
def validate_file(filename: str, file_bytes: bytes, allowed_extensions: list[str], max_size_mb: int = 50) -> dict {
    ext = os.path.splitext(filename)[1].lower();
    if ext not in allowed_extensions {
        return {
            "valid": False,
            "error": f"File type {ext} not supported. Allowed: {', '.join(allowed_extensions)}"
        };
    }
    max_size = max_size_mb * 1024 * 1024;
    if len(file_bytes) > max_size {
        return {
            "valid": False,
            "error": f"File too large. Max size: {max_size_mb}MB"
        };
    }
    return {"valid": True, "error": ""};
}
