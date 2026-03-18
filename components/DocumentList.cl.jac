"""Document list — file items with orange icon, size, and hover-reveal delete."""

import from "@tabler/icons-react" { IconTrash, IconFileText, IconRefresh }


"""Document list with file icon, name, meta, and delete-on-hover."""
def:pub DocumentList(
    documents: list = [],
    onDelete: any = None,
    onRefresh: any = None
) -> any {
    TEXT = "#1A1A1A";
    MUTED = "#6B7280";
    BORDER = "#F0F0F0";
    ORANGE = "#FF6B35";
    HOVER_BG = "#FFF5F0";

    def formatFileSize(bytes: int) -> str {
        if bytes < 1024 { return String(bytes) + " B"; }
        elif bytes < 1048576 { return String(Math.round(bytes / 1024)) + " KB"; }
        else { return String(Math.round(bytes / 1048576 * 10) / 10) + " MB"; }
    }

    return <div>
        <div style={{
            "display": "flex",
            "justifyContent": "space-between",
            "alignItems": "center",
            "marginBottom": "10px"
        }}>
            <div style={{
                "display": "flex",
                "alignItems": "center",
                "gap": "6px"
            }}>
                <span style={{
                    "color": MUTED,
                    "fontSize": "11px",
                    "fontWeight": "600",
                    "textTransform": "uppercase",
                    "letterSpacing": "0.5px"
                }}>
                    Documents
                </span>
                <span style={{
                    "background": "linear-gradient(135deg, #FF6B35 0%, #FF8C5A 100%)",
                    "color": "#FFFFFF",
                    "fontSize": "10px",
                    "fontWeight": "700",
                    "padding": "1px 7px",
                    "borderRadius": "10px",
                    "minWidth": "18px",
                    "textAlign": "center"
                }}>
                    {documents.length}
                </span>
            </div>
            {(
                <button
                    onClick={lambda -> None { if onRefresh { onRefresh(); } }}
                    title="Refresh"
                    style={{
                        "background": "transparent",
                        "border": "none",
                        "color": MUTED,
                        "cursor": "pointer",
                        "padding": "4px",
                        "display": "flex",
                        "alignItems": "center",
                        "transition": "color 0.2s ease"
                    }}
                    onMouseEnter={lambda e: any -> None {
                        e.currentTarget.style.color = ORANGE;
                    }}
                    onMouseLeave={lambda e: any -> None {
                        e.currentTarget.style.color = MUTED;
                    }}
                >
                    <IconRefresh size={14} />
                </button>
                if onRefresh else None
            )}
        </div>

        {(
            <div style={{
                "textAlign": "center",
                "padding": "24px 0"
            }}>
                <IconFileText size={32} color="#E5E7EB" style={{"margin": "0 auto 8px"}} />
                <p style={{
                    "color": MUTED,
                    "fontSize": "13px",
                    "margin": "0"
                }}>
                    No documents yet
                </p>
            </div>
            if documents.length == 0
            else
            <div style={{"display": "flex", "flexDirection": "column", "gap": "4px"}}>
                {documents.map(lambda doc: any -> any {
                    return <div
                        key={doc.filename}
                        className="doc-list-item"
                        style={{
                            "display": "flex",
                            "alignItems": "center",
                            "gap": "10px",
                            "padding": "10px 12px",
                            "background": "#FFFFFF",
                            "borderRadius": "10px",
                            "border": "1px solid " + BORDER,
                            "transition": "all 0.2s ease",
                            "cursor": "default"
                        }}
                        onMouseEnter={lambda e: any -> None {
                            e.currentTarget.style.background = HOVER_BG;
                            e.currentTarget.style.borderColor = "#FFE5D9";
                            deleteBtn = e.currentTarget.querySelector(".doc-delete-btn");
                            if deleteBtn {
                                deleteBtn.style.opacity = "1";
                            }
                        }}
                        onMouseLeave={lambda e: any -> None {
                            e.currentTarget.style.background = "#FFFFFF";
                            e.currentTarget.style.borderColor = BORDER;
                            deleteBtn = e.currentTarget.querySelector(".doc-delete-btn");
                            if deleteBtn {
                                deleteBtn.style.opacity = "0";
                            }
                        }}
                    >
                        <div style={{
                            "width": "32px",
                            "height": "32px",
                            "borderRadius": "8px",
                            "background": "#FFF5F0",
                            "display": "flex",
                            "alignItems": "center",
                            "justifyContent": "center",
                            "flexShrink": "0"
                        }}>
                            <IconFileText size={16} color={ORANGE} />
                        </div>
                        <div style={{"flex": "1", "minWidth": "0"}}>
                            <p style={{
                                "color": TEXT,
                                "fontSize": "13px",
                                "fontWeight": "500",
                                "margin": "0",
                                "overflow": "hidden",
                                "textOverflow": "ellipsis",
                                "whiteSpace": "nowrap"
                            }}>
                                {doc.filename}
                            </p>
                            <p style={{"color": MUTED, "fontSize": "11px", "margin": "2px 0 0 0"}}>
                                {doc.file_type.toUpperCase()} {formatFileSize(doc.file_size)}
                            </p>
                        </div>
                        {(
                            <button
                                onClick={lambda -> None { if onDelete { onDelete(doc.filename); } }}
                                title="Delete document"
                                className="doc-delete-btn"
                                style={{
                                    "background": "transparent",
                                    "border": "none",
                                    "color": "#ef4444",
                                    "cursor": "pointer",
                                    "padding": "4px",
                                    "opacity": "0",
                                    "flexShrink": "0",
                                    "display": "flex",
                                    "alignItems": "center",
                                    "transition": "opacity 0.15s ease"
                                }}
                            >
                                <IconTrash size={14} />
                            </button>
                            if onDelete else None
                        )}
                    </div>;
                })}
            </div>
        )}
    </div>;
}
