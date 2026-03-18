"""Drag-and-drop file upload — clean dashed border, orange icon, hover tint."""

import from react { useRef }
import from "@tabler/icons-react" { IconCloudUpload, IconCheck, IconX }


"""File upload widget with drag-and-drop and click-to-browse."""
def:pub FileUpload(onUpload: any, isUploading: bool = False) -> any {
    has isDragging: bool = False;
    has uploadStatus: str = "";
    has statusMessage: str = "";
    fileInputRef = useRef(None);

    ORANGE = "#FF6B35";
    TEXT = "#1A1A1A";
    MUTED = "#6B7280";
    ALLOWED = ".pdf,.md,.txt,.docx,.py,.js,.ts,.jac";

    async def processFile(file: any) -> None {
        result = await onUpload(file);
        if result.success {
            uploadStatus = "success";
            statusMessage = file.name + " uploaded successfully";
            setTimeout(lambda -> None {
                uploadStatus = "";
                statusMessage = "";
            }, 3000);
        } else {
            uploadStatus = "error";
            statusMessage = result.error or "Upload failed";
        }
    }

    def handleDrop(e: any) -> None {
        e.preventDefault();
        isDragging = False;
        files = e.dataTransfer.files;
        if files.length > 0 and not isUploading {
            processFile(files[0]);
        }
    }

    def handleDragOver(e: any) -> None {
        e.preventDefault();
        isDragging = True;
    }

    def handleDragLeave(e: any) -> None {
        isDragging = False;
    }

    def handleClick() -> None {
        if fileInputRef.current and not isUploading {
            fileInputRef.current.click();
        }
    }

    borderColor = "#E5E7EB";
    bgColor = "#FFFFFF";
    if isDragging {
        borderColor = ORANGE;
        bgColor = "#FFF5F0";
    } elif uploadStatus == "success" {
        borderColor = "#22c55e";
        bgColor = "#f0fdf4";
    } elif uploadStatus == "error" {
        borderColor = "#ef4444";
        bgColor = "#fef2f2";
    }

    iconEl = <IconCloudUpload size={28} color={ORANGE} />;
    if isUploading {
        iconEl = <div style={{
            "width": "28px",
            "height": "28px",
            "borderRadius": "50%",
            "border": "2.5px solid " + ORANGE,
            "borderTopColor": "transparent",
            "animation": "spin 0.8s linear infinite"
        }} />;
    } elif uploadStatus == "success" {
        iconEl = <IconCheck size={28} color="#22c55e" />;
    } elif uploadStatus == "error" {
        iconEl = <IconX size={28} color="#ef4444" />;
    }

    titleText = "Drop files here or click to browse";
    if isUploading { titleText = "Uploading..."; }
    elif uploadStatus == "success" { titleText = "Upload complete!"; }
    elif uploadStatus == "error" { titleText = "Upload failed"; }

    subtitleEl = <p style={{"color": MUTED, "fontSize": "12px", "margin": "0"}}>
        PDF, DOCX, Markdown, Text, Code files
    </p>;
    if statusMessage {
        subtitleColor = ("#22c55e" if uploadStatus == "success" else "#ef4444");
        subtitleEl = <p style={{"color": subtitleColor, "fontSize": "12px", "margin": "0", "fontWeight": "500"}}>
            {statusMessage}
        </p>;
    }

    return <div>
        <input
            ref={fileInputRef}
            type="file"
            accept={ALLOWED}
            onChange={lambda e: any -> None {
                files = e.target.files;
                if files.length > 0 {
                    processFile(files[0]);
                }
            }}
            style={{"display": "none"}}
        />
        <div
            onClick={handleClick}
            onDrop={handleDrop}
            onDragOver={handleDragOver}
            onDragLeave={handleDragLeave}
            style={{
                "border": "2px dashed " + borderColor,
                "borderRadius": "12px",
                "padding": "28px 20px",
                "textAlign": "center",
                "cursor": (("not-allowed" if isUploading else "pointer")),
                "background": bgColor,
                "transition": "all 0.2s ease"
            }}
            onMouseEnter={lambda e: any -> None {
                if not isUploading and not uploadStatus {
                    e.currentTarget.style.borderColor = ORANGE;
                    e.currentTarget.style.background = "#FFF5F0";
                }
            }}
            onMouseLeave={lambda e: any -> None {
                if not isUploading and not uploadStatus {
                    e.currentTarget.style.borderColor = "#E5E7EB";
                    e.currentTarget.style.background = "#FFFFFF";
                }
            }}
        >
            <div style={{
                "display": "flex",
                "flexDirection": "column",
                "alignItems": "center",
                "gap": "10px"
            }}>
                <div style={{
                    "width": "48px",
                    "height": "48px",
                    "borderRadius": "12px",
                    "background": "#FFF5F0",
                    "display": "flex",
                    "alignItems": "center",
                    "justifyContent": "center"
                }}>
                    {iconEl}
                </div>
                <div>
                    <p style={{
                        "color": TEXT,
                        "fontSize": "14px",
                        "fontWeight": "500",
                        "margin": "0 0 4px 0"
                    }}>
                        {titleText}
                    </p>
                    {subtitleEl}
                </div>
            </div>
        </div>
    </div>;
}
