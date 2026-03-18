"""Main chat page for AnyGPT - document upload + RAG chat."""

import from react { useEffect }
import from "@mantine/core" { ScrollArea }
import from "@tabler/icons-react" { IconFiles, IconX, IconMenu2 }
import from ..hooks.useChat { useChat }
import from ..components.ChatMessage { ChatMessage }
import from ..components.ChatInput { ChatInput }
import from ..components.Sidebar { Sidebar }
import from ..components.FileUpload { FileUpload }
import from ..components.DocumentList { DocumentList }


"""Main AnyGPT chat page combining sidebar, chat area, and document panel."""
def:pub ChatPage() -> any {
    has sidebarOpen: bool = False;
    has docPanelOpen: bool = True;

    BG = "#ffffff";
    SURFACE = "#f9fafb";
    BORDER = "#e5e7eb";
    TEXT = "#111827";
    TEXT_SECONDARY = "#4b5563";
    MUTED = "#9ca3af";
    ORANGE = "#f97316";

    chat = useChat();

    useEffect(lambda -> None {
        styleId = "chat-animations";
        if not document.getElementById(styleId) {
            style = document.createElement("style");
            style.id = styleId;
            style.textContent = """
                @keyframes fadeIn {
                    from { opacity: 0; transform: translateY(10px); }
                    to { opacity: 1; transform: translateY(0); }
                }
                @keyframes dotBounce {
                    0%, 60%, 100% { transform: translateY(0); }
                    30% { transform: translateY(-4px); }
                }
                @keyframes spin {
                    from { transform: rotate(0deg); }
                    to { transform: rotate(360deg); }
                }
            """;
            document.head.appendChild(style);
        }
    }, []);

    def toggleSidebar() -> None {
        sidebarOpen = not sidebarOpen;
    }

    def toggleDocPanel() -> None {
        docPanelOpen = not docPanelOpen;
    }

    hasMessages = chat.messages.length > 0;

    loadingIndicator = <div style={{
        "paddingTop": "16px",
        "paddingBottom": "16px",
        "paddingLeft": "8px",
        "paddingRight": "8px",
        "animation": "fadeIn 0.3s ease"
    }}>
        <div style={{"display": "flex", "alignItems": "center", "gap": "8px"}}>
            <div style={{"display": "flex", "gap": "4px", "alignItems": "flex-end"}}>
                {[0, 1, 2].map(lambda i: int -> any {
                    delays = ["0s", "0.15s", "0.3s"];
                    return <div
                        key={i}
                        style={{
                            "width": "6px",
                            "height": "6px",
                            "borderRadius": "50%",
                            "backgroundColor": ORANGE,
                            "animation": "dotBounce 1.1s ease-in-out infinite",
                            "animationDelay": delays[i]
                        }}
                    />;
                })}
            </div>
            <span style={{"fontSize": "14px", "color": MUTED, "marginLeft": "8px"}}>
                Thinking...
            </span>
        </div>
    </div>;

    messageItems = chat.messages.map(lambda msg: any, idx: int -> any {
        isLastUser = msg.isUser;
        return <div
            key={msg.id}
            ref={(chat.latestUserMsgRef if isLastUser else None)}
            style={{"animation": "fadeIn 0.3s ease"}}
        >
            <ChatMessage
                message={msg.content}
                isUser={msg.isUser}
                timestamp={msg.timestamp}
            />
        </div>;
    });

    mainContent = None;
    if hasMessages {
        mainContent = <ScrollArea
            style={{"flex": "1", "paddingLeft": "16px", "paddingRight": "16px"}}
            type="scroll"
        >
            <div style={{
                "maxWidth": "768px",
                "margin": "0 auto",
                "paddingTop": "16px",
                "paddingBottom": "16px"
            }}>
                <div style={{"display": "flex", "flexDirection": "column", "gap": "8px"}}>
                    {messageItems}
                    {(loadingIndicator if chat.isLoading else None)}
                </div>
                <div ref={chat.messagesEndRef} />
            </div>
        </ScrollArea>;
    } else {
        mainContent = <div style={{
            "flex": "1",
            "display": "flex",
            "flexDirection": "column",
            "alignItems": "center",
            "justifyContent": "center",
            "paddingLeft": "16px",
            "paddingRight": "16px"
        }}>
            <div style={{
                "maxWidth": "768px",
                "width": "100%",
                "display": "flex",
                "flexDirection": "column",
                "alignItems": "center"
            }}>
                <div style={{
                    "width": "72px",
                    "height": "72px",
                    "borderRadius": "20px",
                    "background": "rgba(249,115,22,0.08)",
                    "display": "flex",
                    "alignItems": "center",
                    "justifyContent": "center",
                    "fontSize": "36px",
                    "marginBottom": "24px"
                }}>
                    🤖
                </div>
                <h1 style={{
                    "fontSize": "28px",
                    "color": TEXT,
                    "fontWeight": "600",
                    "marginBottom": "8px",
                    "textAlign": "center"
                }}>
                    How can I help you today?
                </h1>
                <p style={{
                    "fontSize": "14px",
                    "color": MUTED,
                    "marginBottom": "36px",
                    "textAlign": "center"
                }}>
                    Upload documents and ask questions to get AI-powered answers with source citations.
                </p>
                <div style={{"width": "100%"}}>
                    <ChatInput
                        onSendMessage={chat.handleSendMessage}
                        disabled={False}
                        placeholder="Ask a question about your uploaded documents..."
                        isLoading={chat.isLoading}
                        onStop={chat.handleStopGeneration}
                    />
                    <div style={{
                        "display": "flex",
                        "gap": "12px",
                        "marginTop": "12px",
                        "flexWrap": "wrap",
                        "justifyContent": "center"
                    }}>
                        {[
                            "Summarize the uploaded documents",
                            "What are the key points?",
                            "Explain the main concepts"
                        ].map(lambda text: str -> any {
                            return <button
                                key={text}
                                onClick={lambda -> None { chat.handleSendMessage(text); }}
                                style={{
                                    "padding": "8px 16px",
                                    "border": "1px solid " + BORDER,
                                    "borderRadius": "20px",
                                    "background": BG,
                                    "color": TEXT_SECONDARY,
                                    "cursor": "pointer",
                                    "fontSize": "13px",
                                    "transition": "all 0.2s ease"
                                }}
                                onMouseEnter={lambda e: any -> None {
                                    e.target.style.background = "rgba(249,115,22,0.06)";
                                    e.target.style.borderColor = "rgba(249,115,22,0.3)";
                                    e.target.style.color = ORANGE;
                                }}
                                onMouseLeave={lambda e: any -> None {
                                    e.target.style.background = BG;
                                    e.target.style.borderColor = BORDER;
                                    e.target.style.color = TEXT_SECONDARY;
                                }}
                            >
                                {text}
                            </button>;
                        })}
                    </div>
                </div>
            </div>
        </div>;
    }

    mobileMenuButton = <button
        onClick={toggleSidebar}
        style={{
            "position": "fixed",
            "top": "8px",
            "left": "8px",
            "zIndex": "40",
            "display": "flex",
            "alignItems": "center",
            "justifyContent": "center",
            "width": "40px",
            "height": "40px",
            "border": "1px solid " + BORDER,
            "borderRadius": "8px",
            "background": BG,
            "color": TEXT,
            "cursor": "pointer"
        }}
    >
        <IconMenu2 size={20} />
    </button>;

    docButtonLabel = ("Hide Documents" if docPanelOpen else "Documents");
    headerBar = <div style={{
        "display": "flex",
        "alignItems": "center",
        "justifyContent": "space-between",
        "padding": "10px 16px",
        "borderBottom": "1px solid " + BORDER,
        "background": BG,
        "flexShrink": "0"
    }}>
        <div style={{"display": "flex", "alignItems": "center", "gap": "10px"}}>
            <span style={{"fontSize": "24px"}}>🤖</span>
            <span style={{"fontSize": "18px", "fontWeight": "700", "color": TEXT}}>AnyGPT</span>
        </div>
        <button
            onClick={toggleDocPanel}
            style={{
                "display": "flex",
                "alignItems": "center",
                "gap": "6px",
                "padding": "6px 14px",
                "border": (("1px solid " + ORANGE if docPanelOpen else "1px solid " + BORDER)),
                "borderRadius": "8px",
                "background": (("rgba(249,115,22,0.06)" if docPanelOpen else BG)),
                "color": (ORANGE if docPanelOpen else MUTED),
                "cursor": "pointer",
                "fontSize": "13px",
                "transition": "all 0.2s ease"
            }}
        >
            {((<IconX size={14} />) if docPanelOpen else (<IconFiles size={14} />))}
            <span>{docButtonLabel}</span>
        </button>
    </div>;

    docPanelElement = None;
    if docPanelOpen {
        docPanelElement = <div style={{
            "width": "320px",
            "flexShrink": "0",
            "borderLeft": "1px solid " + BORDER,
            "background": SURFACE,
            "display": "flex",
            "flexDirection": "column",
            "overflow": "hidden"
        }}>
            <div style={{
                "padding": "14px 16px",
                "borderBottom": "1px solid " + BORDER,
                "flexShrink": "0"
            }}>
                <span style={{"fontSize": "13px", "fontWeight": "600", "color": MUTED, "textTransform": "uppercase", "letterSpacing": "0.5px"}}>
                    Document Management
                </span>
            </div>
            <div style={{"padding": "16px", "overflowY": "auto", "flex": "1"}}>
                <div style={{"marginBottom": "20px"}}>
                    <FileUpload
                        onUpload={chat.handleUploadDocument}
                        isUploading={chat.isUploading}
                    />
                </div>
                <DocumentList
                    documents={chat.documents}
                    onDelete={chat.handleDeleteDocument}
                    onRefresh={chat.handleRefreshDocuments}
                />
            </div>
        </div>;
    }

    chatContainerStyle = {
        "flex": "1",
        "display": "flex",
        "flexDirection": "column",
        "minWidth": "0",
        "overflow": "hidden"
    };

    return <div style={{"display": "flex", "height": "100vh", "background": BG}}>
        <Sidebar
            isOpen={sidebarOpen}
            onToggle={toggleSidebar}
            onNewChat={chat.handleNewChat}
            chatSessions={chat.chatSessions}
            currentSessionId={chat.sessionId}
            onLoadSession={chat.handleLoadSession}
            onDeleteSession={chat.handleDeleteSession}
            isLoading={chat.isLoading}
            documentCount={chat.documents.length}
        />

        <div style={{"flex": "1", "display": "flex", "overflow": "hidden"}}>
            <div style={chatContainerStyle}>
                {mobileMenuButton}
                {headerBar}
                {mainContent}
                {(
                    <ChatInput
                        onSendMessage={chat.handleSendMessage}
                        disabled={False}
                        placeholder="Ask a question about your uploaded documents..."
                        isLoading={chat.isLoading}
                        onStop={chat.handleStopGeneration}
                    />
                    if hasMessages else None
                )}
            </div>
            {docPanelElement}
        </div>
    </div>;
}
