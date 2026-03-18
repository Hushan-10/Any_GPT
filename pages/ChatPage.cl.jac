"""Main chat page — pure white center, sidebar left, doc panel right."""

import from react { useEffect }
import from "@mantine/core" { ScrollArea }
import from "@tabler/icons-react" {
    IconFiles,
    IconX,
    IconMenu2,
    IconSparkles,
    IconFileSearch,
    IconBulb,
    IconListDetails
}
import from ..hooks.useChat { useChat }
import from ..components.ChatMessage { ChatMessage }
import from ..components.ChatInput { ChatInput }
import from ..components.Sidebar { Sidebar }
import from ..components.FileUpload { FileUpload }
import from ..components.DocumentList { DocumentList }


"""AnyGPT chat page with sidebar, chat area, and document panel."""
def:pub ChatPage() -> any {
    has sidebarOpen: bool = False;
    has docPanelOpen: bool = True;

    BG = "#FFFFFF";
    SURFACE = "#F9F9F9";
    BORDER = "#F0F0F0";
    BORDER_ORANGE = "#FFE5D9";
    TEXT = "#1A1A1A";
    TEXT_SECONDARY = "#4B5563";
    MUTED = "#6B7280";
    ORANGE = "#FF6B35";
    HOVER_BG = "#FFF5F0";

    chat = useChat();

    useEffect(lambda -> None {
        styleId = "chat-animations";
        if not document.getElementById(styleId) {
            style = document.createElement("style");
            style.id = styleId;
            style.textContent = """
                @keyframes fadeIn {
                    from { opacity: 0; transform: translateY(8px); }
                    to { opacity: 1; transform: translateY(0); }
                }
                @keyframes dotBounce {
                    0%, 60%, 100% { transform: translateY(0); }
                    30% { transform: translateY(-5px); }
                }
                @keyframes spin {
                    from { transform: rotate(0deg); }
                    to { transform: rotate(360deg); }
                }
                @keyframes pulse {
                    0%, 100% { opacity: 1; }
                    50% { opacity: 0.5; }
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
        "padding": "12px 0",
        "animation": "fadeIn 0.25s ease"
    }}>
        <div style={{
            "display": "flex",
            "alignItems": "center",
            "gap": "12px",
            "padding": "14px 18px",
            "background": "#F5F5F5",
            "borderRadius": "4px 16px 16px 16px",
            "maxWidth": "200px"
        }}>
            <div style={{"display": "flex", "gap": "4px", "alignItems": "flex-end"}}>
                {[0, 1, 2].map(lambda i: int -> any {
                    delays = ["0s", "0.15s", "0.3s"];
                    return <div
                        key={i}
                        style={{
                            "width": "7px",
                            "height": "7px",
                            "borderRadius": "50%",
                            "backgroundColor": ORANGE,
                            "animation": "dotBounce 1.1s ease-in-out infinite",
                            "animationDelay": delays[i]
                        }}
                    />;
                })}
            </div>
            <span style={{"fontSize": "13px", "color": MUTED, "fontWeight": "500"}}>
                Thinking...
            </span>
        </div>
    </div>;

    messageItems = chat.messages.map(lambda msg: any, idx: int -> any {
        isLastUser = msg.isUser;
        return <div
            key={msg.id}
            ref={(chat.latestUserMsgRef if isLastUser else None)}
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
            style={{"flex": "1", "padding": "0 20px"}}
            type="scroll"
        >
            <div style={{
                "maxWidth": "768px",
                "margin": "0 auto",
                "paddingTop": "20px",
                "paddingBottom": "12px"
            }}>
                <div style={{"display": "flex", "flexDirection": "column", "gap": "4px"}}>
                    {messageItems}
                    {(loadingIndicator if chat.isLoading else None)}
                </div>
                <div ref={chat.messagesEndRef} />
            </div>
        </ScrollArea>;
    } else {
        suggestionChips = [
            {"icon": <IconFileSearch size={15} color={ORANGE} />, "text": "Summarize the uploaded documents"},
            {"icon": <IconBulb size={15} color={ORANGE} />, "text": "What are the key points?"},
            {"icon": <IconListDetails size={15} color={ORANGE} />, "text": "Explain the main concepts"}
        ];

        mainContent = <div style={{
            "flex": "1",
            "display": "flex",
            "flexDirection": "column",
            "alignItems": "center",
            "justifyContent": "center",
            "padding": "20px"
        }}>
            <div style={{
                "maxWidth": "640px",
                "width": "100%",
                "display": "flex",
                "flexDirection": "column",
                "alignItems": "center"
            }}>
                <div style={{
                    "width": "72px",
                    "height": "72px",
                    "borderRadius": "20px",
                    "background": "linear-gradient(135deg, #FF6B35 0%, #FF8C5A 100%)",
                    "display": "flex",
                    "alignItems": "center",
                    "justifyContent": "center",
                    "marginBottom": "28px",
                    "boxShadow": "0 8px 28px rgba(255,107,53,0.2)"
                }}>
                    <IconSparkles size={32} color="#ffffff" />
                </div>
                <h1 style={{
                    "fontSize": "28px",
                    "color": TEXT,
                    "fontWeight": "700",
                    "marginBottom": "8px",
                    "textAlign": "center",
                    "letterSpacing": "-0.5px",
                    "lineHeight": "1.2",
                    "fontFamily": "Inter, system-ui, -apple-system, sans-serif",
                    "margin": "0 0 8px 0"
                }}>
                    How can I help you today?
                </h1>
                <p style={{
                    "fontSize": "15px",
                    "color": MUTED,
                    "marginBottom": "40px",
                    "textAlign": "center",
                    "lineHeight": "1.5",
                    "margin": "0 0 40px 0"
                }}>
                    Upload documents and ask questions to get AI-powered answers with source citations.
                </p>

                <div style={{"width": "100%", "maxWidth": "600px"}}>
                    <ChatInput
                        onSendMessage={chat.handleSendMessage}
                        disabled={False}
                        placeholder="Ask a question about your documents..."
                        isLoading={chat.isLoading}
                        onStop={chat.handleStopGeneration}
                    />
                    <div style={{
                        "display": "flex",
                        "gap": "10px",
                        "marginTop": "16px",
                        "flexWrap": "wrap",
                        "justifyContent": "center",
                        "padding": "0 16px"
                    }}>
                        {suggestionChips.map(lambda chip: any -> any {
                            return <button
                                key={chip.text}
                                onClick={lambda -> None { chat.handleSendMessage(chip.text); }}
                                style={{
                                    "display": "flex",
                                    "alignItems": "center",
                                    "gap": "8px",
                                    "padding": "9px 18px",
                                    "border": "1px solid " + BORDER_ORANGE,
                                    "borderRadius": "22px",
                                    "background": BG,
                                    "color": TEXT_SECONDARY,
                                    "cursor": "pointer",
                                    "fontSize": "13px",
                                    "fontWeight": "500",
                                    "transition": "all 0.2s ease",
                                    "whiteSpace": "nowrap"
                                }}
                                onMouseEnter={lambda e: any -> None {
                                    e.currentTarget.style.background = "linear-gradient(135deg, #FF6B35 0%, #FF8C5A 100%)";
                                    e.currentTarget.style.borderColor = "transparent";
                                    e.currentTarget.style.color = "#ffffff";
                                    e.currentTarget.style.boxShadow = "0 2px 10px rgba(255,107,53,0.2)";
                                    e.currentTarget.style.transform = "translateY(-1px)";
                                }}
                                onMouseLeave={lambda e: any -> None {
                                    e.currentTarget.style.background = BG;
                                    e.currentTarget.style.borderColor = BORDER_ORANGE;
                                    e.currentTarget.style.color = TEXT_SECONDARY;
                                    e.currentTarget.style.boxShadow = "none";
                                    e.currentTarget.style.transform = "translateY(0)";
                                }}
                            >
                                {chip.icon}
                                <span>{chip.text}</span>
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
            "top": "12px",
            "left": "12px",
            "zIndex": "40",
            "display": "flex",
            "alignItems": "center",
            "justifyContent": "center",
            "width": "38px",
            "height": "38px",
            "border": "1px solid " + BORDER,
            "borderRadius": "10px",
            "background": BG,
            "color": TEXT,
            "cursor": "pointer",
            "boxShadow": "0 1px 4px rgba(0,0,0,0.04)",
            "transition": "all 0.2s ease"
        }}
        onMouseEnter={lambda e: any -> None {
            e.currentTarget.style.borderColor = BORDER_ORANGE;
            e.currentTarget.style.background = HOVER_BG;
        }}
        onMouseLeave={lambda e: any -> None {
            e.currentTarget.style.borderColor = BORDER;
            e.currentTarget.style.background = BG;
        }}
    >
        <IconMenu2 size={18} />
    </button>;

    docButtonLabel = ("Hide" if docPanelOpen else "Documents");
    headerBar = <div style={{
        "display": "flex",
        "alignItems": "center",
        "justifyContent": "flex-end",
        "padding": "10px 16px",
        "borderBottom": "1px solid " + BORDER,
        "background": BG,
        "flexShrink": "0"
    }}>
        <button
            onClick={toggleDocPanel}
            style={{
                "display": "flex",
                "alignItems": "center",
                "gap": "6px",
                "padding": "7px 14px",
                "border": (("1px solid " + ORANGE if docPanelOpen else "1px solid " + BORDER)),
                "borderRadius": "10px",
                "background": (("rgba(255,107,53,0.06)" if docPanelOpen else BG)),
                "color": (ORANGE if docPanelOpen else MUTED),
                "cursor": "pointer",
                "fontSize": "13px",
                "fontWeight": "500",
                "transition": "all 0.2s ease"
            }}
            onMouseEnter={lambda e: any -> None {
                if not docPanelOpen {
                    e.currentTarget.style.background = HOVER_BG;
                    e.currentTarget.style.borderColor = BORDER_ORANGE;
                    e.currentTarget.style.color = ORANGE;
                }
            }}
            onMouseLeave={lambda e: any -> None {
                if not docPanelOpen {
                    e.currentTarget.style.background = BG;
                    e.currentTarget.style.borderColor = BORDER;
                    e.currentTarget.style.color = MUTED;
                }
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
                "padding": "16px",
                "borderBottom": "1px solid " + BORDER,
                "flexShrink": "0",
                "display": "flex",
                "alignItems": "center",
                "gap": "8px"
            }}>
                <IconFiles size={16} color={ORANGE} />
                <span style={{
                    "fontSize": "14px",
                    "fontWeight": "600",
                    "color": TEXT,
                    "letterSpacing": "-0.2px"
                }}>
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
        "overflow": "hidden",
        "background": BG
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
                        placeholder="Ask a question about your documents..."
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
