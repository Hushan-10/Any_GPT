"""AnyGPT Backend Server - Walkers and Nodes.

Provides: document upload/management, RAG-augmented chat, session management.
Built on JacGPT patterns adapted for user-uploaded documents.
"""

import os;
import json;
import time;
import from byllm.lib {Model}
import from dotenv {load_dotenv}
import from services.rag_engine {RagEngine, load_config, sanitize_user_id}
import from services.ingestion.file_store {validate_file, save_file, delete_file}
import from datetime {datetime}

with entry {
    load_dotenv(override=True);
}

# Load configuration
glob config: dict = load_config();
glob model_name: str = os.environ.get("ANYGPT_MODEL", config.get("llm", {}).get("model", "gpt-4.1-mini"));
glob llm = Model(model_name=model_name);

# Initialize global RAG engine (loads CrossEncoder model at startup)
glob rag_engine: RagEngine = RagEngine(config=config, tenant_id="default");

# Per-user RAG engine cache: user_email -> RagEngine (lazy-loaded, shares CrossEncoder)
glob user_rag_engines: dict = {};
# Mutable request context so search_docs routes to the correct user's engine
glob request_ctx: dict = {"user_email": ""};

"""Get or create a per-user RAG engine, sharing the global CrossEncoder."""
def get_user_rag_engine(user_email: str) -> RagEngine {
    if not user_email {
        return rag_engine;
    }
    if user_email not in user_rag_engines {
        safe_id = sanitize_user_id(user_email);
        user_rag_engines[user_email] = RagEngine(
            config=config,
            tenant_id="default",
            user_id=safe_id,
            shared_cross_encoder=rag_engine.cross_encoder
        );
    }
    return user_rag_engines[user_email];
}


# ========== Graph Nodes ==========

node Session {
    has id: str;
    has user_email: str = "";
    has chat_history: list[dict] = [];
    has status: str = "active";
    has created_at: str = "";
    has updated_at: str = "";

    can chat with interact entry;
}

node ChatNode {
    def respond(message: str, chat_history: list[dict]) -> str by llm(
        method="ReAct",
        max_react_iterations=5,
        temperature=0.1,
        stream=True,
        logging=True,
        tools=[search_docs]
    );

    can chat with interact entry;
}


# ========== RAG Tool ==========

"""Search uploaded documents using the current user's RAG engine."""
def search_docs(query: str) -> str {
    user_email = request_ctx.get("user_email", "");
    engine = get_user_rag_engine(user_email);
    results = engine.search(query=query);
    return results;
}


# ========== Chat Walker ==========

walker :pub interact {
    has message: str;
    has session_id: str;
    has user_email: str = "";
    has chat_history: list[dict] = [];

    obj __specs__ {
        static has methods: list = ["post"];
        static has auth: bool = True;
    }

    can init_session with Root entry {
        # Set request context so search_docs uses the correct user's RAG engine
        request_ctx["user_email"] = self.user_email;

        all_sessions = [-->(?:Session)];
        found_session = None;
        for session in all_sessions {
            if session.id == self.session_id and session.user_email == self.user_email {
                found_session = session;
                break;
            }
        }
        if found_session {
            visit found_session;
        } else {
            now = datetime.now().isoformat();
            session_node = here ++> Session(
                id=self.session_id,
                user_email=self.user_email,
                chat_history=[],
                created_at=now,
                updated_at=now
            );
            visit session_node;
        }
    }
}


# ========== Session Walkers ==========

walker :pub get_session {
    has session_id: str;
    has user_email: str = "";

    obj __specs__ {
        static has methods: list = ["post"];
        static has auth: bool = True;
    }

    can get_chat_history with Root entry;
    can return_history with Session entry;
}

walker :pub new_session {
    has session_id: str = "";
    has user_email: str = "";

    obj __specs__ {
        static has methods: list = ["post"];
        static has auth: bool = True;
    }

    can create_session with Root entry;
}

walker :pub close_session {
    has session_id: str;
    has user_email: str = "";

    obj __specs__ {
        static has methods: list = ["post"];
        static has auth: bool = True;
    }

    can close_session_db with Root entry {
        all_sessions = [-->(?:Session)];
        for session in all_sessions {
            if session.id == self.session_id and session.user_email == self.user_email {
                session.status = "closed";
                session.updated_at = datetime.now().isoformat();
                break;
            }
        }
        report {
            "session_id": self.session_id,
            "status": "closed"
        };
    }
}


# ========== Document Management Walkers ==========

walker :pub upload_document {
    """Upload a document file. Expects base64-encoded file content."""
    has filename: str;
    has file_content: str;
    has user_email: str = "";

    obj __specs__ {
        static has methods: list = ["post"];
        static has auth: bool = True;
    }

    can handle_upload with Root entry {
        import base64;

        try {
            file_bytes = base64.b64decode(self.file_content);

            # Validate file type and size using ingestion module
            allowed = config.get("storage", {}).get("allowed_extensions",
                [".pdf", ".md", ".txt", ".docx", ".py", ".js", ".ts", ".jac"]);
            max_size_mb = config.get("storage", {}).get("max_file_size_mb", 50);
            validation = validate_file(self.filename, file_bytes, allowed, max_size_mb);

            if not validation["valid"] {
                report {
                    "success": False,
                    "error": validation["error"]
                };
                return;
            }

            # Get user-scoped RAG engine
            user_engine = get_user_rag_engine(self.user_email);

            # Save file to user's uploads directory
            file_path = save_file(user_engine.uploads_dir, self.filename, file_bytes);

            # Ingest into user's vector index
            result = user_engine.ingest_file(file_path);
            ext = os.path.splitext(self.filename)[1].lower();
            doc_id = f"doc_{int(time.time())}";

            report {
                "success": True,
                "document_id": doc_id,
                "filename": self.filename,
                "file_type": ext.lstrip("."),
                "status": ("ready" if result["success"] else "failed"),
                "chunk_count": result.get("chunk_count", 0),
                "error": result.get("error", ""),
                "uploaded_at": datetime.now().isoformat()
            };
        } except Exception as e {
            report {
                "success": False,
                "error": str(e)
            };
        }
    }
}

walker :pub list_documents {
    """List all uploaded documents for the authenticated user."""
    has user_email: str = "";

    obj __specs__ {
        static has methods: list = ["get", "post"];
        static has auth: bool = True;
    }

    can get_documents with Root entry {
        user_engine = get_user_rag_engine(self.user_email);
        stats = user_engine.get_stats();
        documents = [];

        uploads_dir = user_engine.uploads_dir;
        if os.path.exists(uploads_dir) {
            for filename in os.listdir(uploads_dir) {
                file_path = os.path.join(uploads_dir, filename);
                if os.path.isfile(file_path) {
                    file_size = os.path.getsize(file_path);
                    ext = os.path.splitext(filename)[1].lower();
                    mod_time = os.path.getmtime(file_path);

                    documents.append({
                        "filename": filename,
                        "file_type": ext.lstrip("."),
                        "file_size": file_size,
                        "uploaded_at": datetime.fromtimestamp(mod_time).isoformat()
                    });
                }
            }
        }

        report {
            "success": True,
            "documents": documents,
            "total": len(documents),
            "has_index": stats["has_index"]
        };
    }
}

walker :pub delete_document {
    """Delete a document and rebuild the user's index."""
    has filename: str;
    has user_email: str = "";

    obj __specs__ {
        static has methods: list = ["post"];
        static has auth: bool = True;
    }

    can remove_document with Root entry {
        user_engine = get_user_rag_engine(self.user_email);

        # Delete file from user's uploads directory
        deleted = delete_file(user_engine.uploads_dir, self.filename);

        if not deleted {
            report {"success": False, "error": "File not found"};
            return;
        }

        # Rebuild user's index without the deleted document
        user_engine.rebuild_index();

        report {
            "success": True,
            "filename": self.filename,
            "message": "Document deleted and index rebuilt"
        };
    }
}

walker :pub reindex {
    """Force re-index all documents for the authenticated user."""
    has user_email: str = "";

    obj __specs__ {
        static has methods: list = ["post"];
        static has auth: bool = True;
    }

    can rebuild with Root entry {
        user_engine = get_user_rag_engine(self.user_email);
        user_engine.rebuild_index();
        stats = user_engine.get_stats();
        report {
            "success": True,
            "message": "Index rebuilt",
            "stats": stats
        };
    }
}

walker :pub index_status {
    """Get indexing status for the authenticated user."""
    has user_email: str = "";

    obj __specs__ {
        static has methods: list = ["get", "post"];
        static has auth: bool = True;
    }

    can get_status with Root entry {
        user_engine = get_user_rag_engine(self.user_email);
        stats = user_engine.get_stats();
        report {
            "success": True,
            "stats": stats
        };
    }
}


# ========== User Session Walker ==========

walker :pub get_user_sessions {
    """Get all sessions for the authenticated user."""
    has user_email: str = "";

    obj __specs__ {
        static has methods: list = ["get", "post"];
        static has auth: bool = True;
    }

    can list_sessions with Root entry {
        all_sessions = [-->(?:Session)];
        sessions = [];
        for session in all_sessions {
            if session.status == "active" and session.user_email == self.user_email and len(session.chat_history) > 0 {
                first_msg = session.chat_history[0].get("content", "New Chat");
                title = first_msg[:50];
                if len(first_msg) > 50 {
                    title = title + "...";
                }
                sessions.append({
                    "id": session.id,
                    "title": title,
                    "created_at": session.created_at,
                    "updated_at": session.updated_at,
                    "message_count": len(session.chat_history)
                });
            }
        }
        sessions.sort(key=lambda s: s.get("updated_at", ""), reverse=True);
        report {
            "success": True,
            "sessions": sessions
        };
    }
}
