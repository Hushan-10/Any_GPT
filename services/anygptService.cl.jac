"""Service layer for communicating with the AnyGPT backend via fetch API."""


"""Call a walker endpoint via fetch and extract the last report."""
async def callWalker(walkerName: str, payload: any = None) -> any {
    body = payload or {};
    response = await fetch(
        "/walker/" + walkerName,
        {
            "method": "POST",
            "headers": {"Content-Type": "application/json"},
            "body": JSON.stringify(body)
        }
    );
    result = await response.json();
    if result.ok and result.data and result.data.reports and result.data.reports.length > 0 {
        return result.data.reports[result.data.reports.length - 1];
    }
    if result.error {
        raise Exception(result.error.message or "Walker call failed");
    }
    return {};
}


"""Generate a unique session ID."""
def:pub generateSessionId() -> str {
    timestamp = Date.now();
    randomStr = Math.random().toString(36).substring(2, 9);
    return "session_" + String(timestamp) + "_" + randomStr;
}


"""Create a new chat session on the backend."""
async def:pub createSession(sessionId: str = "") -> any {
    if not sessionId {
        sessionId = generateSessionId();
    }
    try {
        result = await callWalker("new_session", {"session_id": sessionId});
        return {
            "success": True,
            "session_id": result.session_id or sessionId,
            "status": result.status or "created",
            "chat_history": result.chat_history or []
        };
    } except Exception as e {
        console.error("createSession error:", e);
        return {"success": False, "error": String(e), "session_id": sessionId};
    }
}


"""Get an existing session's chat history."""
async def:pub getSession(sessionId: str) -> any {
    try {
        result = await callWalker("get_session", {"session_id": sessionId});
        return {
            "success": True,
            "session_id": result.session_id or sessionId,
            "chat_history": result.chat_history or [],
            "found": result.found or False
        };
    } except Exception as e {
        console.error("getSession error:", e);
        return {"success": False, "error": String(e), "chat_history": [], "found": False};
    }
}


"""Send a message and get the response, simulating streaming word-by-word."""
async def:pub sendMessage(message: str, sessionId: str, onChunk: any = None, onEvent: any = None, abortSignal: any = None) -> any {
    try {
        response = await fetch(
            "/walker/interact",
            {
                "method": "POST",
                "headers": {"Content-Type": "application/json"},
                "body": JSON.stringify({
                    "message": message,
                    "session_id": sessionId
                }),
                "signal": abortSignal
            }
        );

        if not response.ok {
            raise Exception("Server returned " + String(response.status));
        }

        json = await response.json();
        result = {};
        if json.ok and json.data and json.data.reports and json.data.reports.length > 0 {
            result = json.data.reports[json.data.reports.length - 1];
        }

        fullResponse = result.response or "";
        if onChunk and fullResponse {
            words = fullResponse.split(" ");
            await Reflect.construct(Promise, [lambda resolve: any -> None {
                idx = 0;
                def feedNext() -> None {
                    if idx < words.length {
                        chunk = words[idx];
                        if idx < words.length - 1 {
                            chunk = chunk + " ";
                        }
                        onChunk(chunk);
                        idx = idx + 1;
                        setTimeout(feedNext, 18);
                    } else {
                        resolve(None);
                    }
                }
                feedNext();
            }]);
        }

        if onEvent {
            onEvent({"type": "done", "data": result});
        }

        return {"success": True};
    } except Exception as e {
        errorName = e.name if e.name else "";
        if errorName == "AbortError" {
            return {"success": False, "aborted": True};
        }
        console.error("sendMessage error:", e);
        return {"success": False, "error": String(e)};
    }
}


"""Upload a document to the backend (base64 encoded)."""
async def:pub uploadDocument(file: any) -> any {
    try {
        arrayBuffer = await file.arrayBuffer();
        uint8 = Reflect.construct(Uint8Array, [arrayBuffer]);

        binary = "";
        chunkSize = 8192;
        i = 0;
        while i < uint8.length {
            end = Math.min(i + chunkSize, uint8.length);
            slice = uint8.subarray(i, end);
            binary = binary + String.fromCharCode.apply(None, slice);
            i = i + chunkSize;
        }
        base64Content = btoa(binary);

        result = await callWalker("upload_document", {
            "filename": file.name,
            "file_content": base64Content
        });

        return {
            "success": result.success or False,
            "filename": result.filename or file.name,
            "chunk_count": result.chunk_count or 0,
            "error": result.error or ""
        };
    } except Exception as e {
        console.error("uploadDocument error:", e);
        return {"success": False, "error": String(e)};
    }
}


"""List all uploaded documents."""
async def:pub listDocuments() -> any {
    try {
        result = await callWalker("list_documents", {});
        return {
            "success": result.success or False,
            "documents": result.documents or [],
            "total": result.total or 0,
            "has_index": result.has_index or False
        };
    } except Exception as e {
        console.error("listDocuments error:", e);
        return {"success": False, "documents": [], "total": 0};
    }
}


"""Delete a document by filename."""
async def:pub deleteDocument(filename: str) -> any {
    try {
        result = await callWalker("delete_document", {"filename": filename});
        return {
            "success": result.success or False,
            "error": result.error or ""
        };
    } except Exception as e {
        console.error("deleteDocument error:", e);
        return {"success": False, "error": String(e)};
    }
}
