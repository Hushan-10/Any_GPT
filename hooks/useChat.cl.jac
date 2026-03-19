"""Chat hook for managing chat state, sessions, and document uploads."""

import from react { useState, useEffect, useRef }
import from "@jac/runtime" { jacIsLoggedIn }
import from ..services.anygptService {
    createSession,
    getSession,
    sendMessage,
    generateSessionId,
    uploadDocument,
    listDocuments,
    deleteDocument,
    getUserSessions
}
import from ..hooks.useAuth { getUsernameFromToken }


"""Hook for managing chat state, sessions, and documents."""
def:pub useChat() -> any {
    has messages: list = [];
    has sessionId: str = "";
    has isLoading: bool = False;
    has isUploading: bool = False;
    has documents: list = [];
    has chatSessions: list = [];

    messagesEndRef = useRef(None);
    firstChunkRef = useRef(False);
    prevMessageCountRef = useRef(0);
    latestUserMsgRef = useRef(None);
    abortControllerRef = useRef(None);

    # On mount: load sessions from server, init session, load documents
    useEffect(lambda -> None {
        async def loadUserData() -> None {
            currentUser = getUsernameFromToken();
            # Load sessions from server (persisted across logins)
            serverResult = await getUserSessions(currentUser);
            if serverResult.success and serverResult.sessions.length > 0 {
                serverSessions = [];
                for s in serverResult.sessions {
                    serverSessions.push({
                        "id": s.id,
                        "title": s.title or "New Chat",
                        "createdAt": s.created_at or String(Date.now())
                    });
                }
                chatSessions = lambda prev: any -> any { return serverSessions; };
                localStorage.setItem("anygpt_sessions", JSON.stringify(serverSessions));
            } else {
                chatSessions = lambda prev: any -> any { return []; };
            }
            await initSession();
            setTimeout(lambda -> None { handleRefreshDocuments(); }, 500);
        }
        loadUserData();
    }, []);

    # Scroll latest user message to top when new messages are added
    useEffect(lambda -> None {
        currentCount = messages.length;
        if currentCount > prevMessageCountRef.current {
            setTimeout(lambda -> None {
                if latestUserMsgRef.current {
                    latestUserMsgRef.current.scrollIntoView({"behavior": "smooth", "block": "start"});
                }
            }, 100);
        }
        prevMessageCountRef.current = currentCount;
    }, [messages]);

    async def initSession() -> None {
        newSessionId = generateSessionId();
        currentUser = getUsernameFromToken();
        result = await createSession(newSessionId, currentUser);
        if result.success {
            sessionId = result.session_id;
        } else {
            sessionId = newSessionId;
        }
    }

    async def handleSendMessage(content: str) -> None {
        if not content.trim() or isLoading {
            return;
        }

        isFirstMessage = messages.filter(lambda m: any -> bool { return m.isUser; }).length == 0;
        isLoading = True;

        userMessage = {
            "id": "msg_" + String(Date.now()),
            "content": content.trim(),
            "isUser": True,
            "timestamp": Date()
        };
        messages = lambda prev: any -> any { return prev.concat([userMessage]); };

        if isFirstMessage {
            updateSessionTitle(content.trim());
        }

        try {
            abortControllerRef.current = Reflect.construct(AbortController, []);

            # Get user email for session tracking
            userEmail = getUsernameFromToken();

            # Create empty bot message for SSE streaming
            botMessageId = "msg_" + String(Date.now()) + "_bot";
            botMessage = {
                "id": botMessageId,
                "content": "",
                "isUser": False,
                "timestamp": Date()
            };
            messages = lambda prev: any -> any { return prev.concat([botMessage]); };

            firstChunkRef.current = False;

            def onChunk(chunk: str) -> None {
                if not firstChunkRef.current {
                    firstChunkRef.current = True;
                    isLoading = False;
                }

                messages = lambda prev: any -> any {
                    updatedMessages = [];
                    for m in prev {
                        if m.id == botMessageId {
                            updatedMessage = {
                                "id": m.id,
                                "content": m.content + chunk,
                                "isUser": m.isUser,
                                "timestamp": m.timestamp
                            };
                            updatedMessages.push(updatedMessage);
                        } else {
                            updatedMessages.push(m);
                        }
                    }
                    return updatedMessages;
                };
            }

            def onEvent(event: any) -> None {
                0;
            }

            result = await sendMessage(content.trim(), sessionId, userEmail, onChunk, onEvent, abortControllerRef.current.signal);

            if not result.success {
                if result.aborted {
                    messages = lambda prev: any -> any {
                        return prev.filter(lambda m: any -> bool { return m.id != botMessageId; });
                    };
                } else {
                    messages = lambda prev: any -> any {
                        return prev.map(lambda m: any -> any {
                            if m.id == botMessageId {
                                return {
                                    "id": m.id,
                                    "content": "Sorry, I encountered an error. Please try again.",
                                    "isUser": m.isUser,
                                    "timestamp": m.timestamp
                                };
                            }
                            return m;
                        });
                    };
                }
            }
        } except Exception as e {
            console.error("Send message error:", e);
            errorMessage = {
                "id": "msg_" + String(Date.now()) + "_err",
                "content": "Sorry, something went wrong. Please try again.",
                "isUser": False,
                "timestamp": Date()
            };
            messages = lambda prev: any -> any { return prev.concat([errorMessage]); };
            isLoading = False;
        } finally {
            abortControllerRef.current = None;
            isLoading = False;
        }
    }

    def updateSessionTitle(firstMessage: str) -> None {
        title = firstMessage.substring(0, 50);
        if firstMessage.length > 50 {
            title = title + "...";
        }
        existingIndex = chatSessions.findIndex(lambda s: any -> bool { return s.id == sessionId; });
        if existingIndex < 0 {
            newSession = {
                "id": sessionId,
                "title": title,
                "createdAt": String(Date.now())
            };
            chatSessions = lambda prev: any -> any {
                updated = [newSession].concat(prev);
                localStorage.setItem("anygpt_sessions", JSON.stringify(updated));
                return updated;
            };
        }
    }

    async def handleNewChat() -> None {
        messages = [];
        await initSession();
    }

    async def handleLoadSession(loadSessionId: str) -> None {
        isLoading = True;
        try {
            currentUser = getUsernameFromToken();
            result = await getSession(loadSessionId, currentUser);
            if result.success and result.found {
                sessionId = loadSessionId;
                newMessages = [];
                for historyItem in result.chat_history {
                    msg = {
                        "id": "msg_" + String(Date.now()) + "_" + String(Math.random()),
                        "content": historyItem.content,
                        "isUser": historyItem.role == "user",
                        "timestamp": Date()
                    };
                    newMessages.push(msg);
                }
                messages = lambda prev: any -> any { return newMessages; };
            }
        } except Exception as e {
            console.error("Error loading session:", e);
        } finally {
            isLoading = False;
        }
    }

    def handleDeleteSession(deleteSessionId: str) -> None {
        chatSessions = lambda prev: any -> any {
            updated = prev.filter(lambda s: any -> bool { return s.id != deleteSessionId; });
            localStorage.setItem("anygpt_sessions", JSON.stringify(updated));
            return updated;
        };
        if deleteSessionId == sessionId {
            handleNewChat();
        }
    }

    def handleStopGeneration() -> None {
        if abortControllerRef.current {
            try {
                abortControllerRef.current.abort();
            } except Exception as e {
                console.error("Error aborting:", e);
            }
            abortControllerRef.current = None;
        }
        isLoading = False;
    }

    async def handleUploadDocument(file: any) -> any {
        isUploading = True;
        try {
            currentUser = getUsernameFromToken();
            result = await uploadDocument(file, currentUser);
            if result.success {
                # Wait briefly for server to finish indexing before refresh
                await Reflect.construct(Promise, [lambda resolve: any -> None {
                    setTimeout(resolve, 1000);
                }]);
            }
            await handleRefreshDocuments();
            return result;
        } except Exception as e {
            console.error("Upload error:", e);
            return {"success": False, "error": String(e)};
        } finally {
            isUploading = False;
        }
    }

    async def handleRefreshDocuments() -> None {
        try {
            currentUser = getUsernameFromToken();
            result = await listDocuments(currentUser);
            if result.success {
                newDocs = result.documents or [];
                documents = lambda prev: any -> any { return newDocs; };
            }
        } except Exception as e {
            console.error("Error loading documents:", e);
        }
    }

    async def handleDeleteDocument(filename: str) -> None {
        try {
            currentUser = getUsernameFromToken();
            result = await deleteDocument(filename, currentUser);
            if result.success {
                # Optimistically remove from UI immediately
                documents = lambda prev: any -> any {
                    return prev.filter(lambda d: any -> bool { return d.filename != filename; });
                };
            }
            # Also refresh from server for consistency
            await handleRefreshDocuments();
        } except Exception as e {
            console.error("Delete document error:", e);
        }
    }

    return {
        "messages": messages,
        "sessionId": sessionId,
        "isLoading": isLoading,
        "isUploading": isUploading,
        "documents": documents,
        "chatSessions": chatSessions,
        "messagesEndRef": messagesEndRef,
        "latestUserMsgRef": latestUserMsgRef,
        "handleSendMessage": handleSendMessage,
        "handleNewChat": handleNewChat,
        "handleLoadSession": handleLoadSession,
        "handleDeleteSession": handleDeleteSession,
        "handleStopGeneration": handleStopGeneration,
        "handleUploadDocument": handleUploadDocument,
        "handleRefreshDocuments": handleRefreshDocuments,
        "handleDeleteDocument": handleDeleteDocument
    };
}
