"""Document list component showing uploaded documents."""

import from "@tabler/icons-react" { IconTrash, IconFile, IconRefresh }


"""List of uploaded documents with delete actions."""
def:pub DocumentList(
    documents: list = [],
    onDelete: any = None,
    onRefresh: any = None
) -> any {
    TEXT = "#111827";
    TEXT_SECONDARY = "#4b5563";
    MUTED = "#9ca3af";
    BORDER = "#e5e7eb";
    ORANGE = "#f97316";

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
            <span style={{
                "color": MUTED,
                "fontSize": "12px",
                "fontWeight": "600",
                "textTransform": "uppercase",
                "letterSpacing": "0.5px"
            }}>
                Documents ({documents.length})
            </span>
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
                        "alignItems": "center"
                    }}
                >
                    <IconRefresh size={14} />
                </button>
                if onRefresh else None
            )}
        </div>

        {(
            <p style={{
                "color": MUTED,
                "fontSize": "13px",
                "textAlign": "center",
                "padding": "20px 0",
                "margin": "0"
            }}>
                No documents uploaded yet
            </p>
            if documents.length == 0
            else
            <div style={{"display": "flex", "flexDirection": "column", "gap": "6px"}}>
                {documents.map(lambda doc: any -> any {
                    return <div
                        key={doc.filename}
                        style={{
                            "display": "flex",
                            "alignItems": "center",
                            "gap": "10px",
                            "padding": "10px 12px",
                            "background": "#ffffff",
                            "borderRadius": "8px",
                            "border": "1px solid " + BORDER
                        }}
                    >
                        <IconFile size={16} color={ORANGE} />
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
                                {doc.file_type.toUpperCase()} . {formatFileSize(doc.file_size)}
                            </p>
                        </div>
                        {(
                            <button
                                onClick={lambda -> None { if onDelete { onDelete(doc.filename); } }}
                                title="Delete document"
                                style={{
                                    "background": "transparent",
                                    "border": "none",
                                    "color": "#ef4444",
                                    "cursor": "pointer",
                                    "padding": "4px",
                                    "opacity": "0.7",
                                    "flexShrink": "0",
                                    "display": "flex",
                                    "alignItems": "center"
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
