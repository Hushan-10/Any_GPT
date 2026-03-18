"""Drag-and-drop file upload component."""

import from react { useRef }
import from "@tabler/icons-react" { IconUpload, IconCheck, IconX }


"""Drag-and-drop file upload widget."""
def:pub FileUpload(onUpload: any, isUploading: bool = False) -> any {
    has isDragging: bool = False;
    has uploadStatus: str = "";
    has statusMessage: str = "";
    fileInputRef = useRef(None);

    ORANGE = "#f97316";
    TEXT = "#111827";
    MUTED = "#9ca3af";
    ALLOWED = ".pdf,.md,.txt,.docx,.py,.js,.ts,.jac";

    async def processFile(file: any) -> None {
        result = await onUpload(file);
        if result.success {
            uploadStatus = "success";
            statusMessage = "'" + file.name + "' uploaded!";
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

    def handleInputChange(e: any) -> None {
        files = e.target.files;
        if files.length > 0 {
            processFile(files[0]);
        }
    }

    def handleClick() -> None {
        if fileInputRef.current and not isUploading {
            fileInputRef.current.click();
        }
    }

    borderColor = "#d1d5db";
    bgColor = "#ffffff";
    if isDragging {
        borderColor = ORANGE;
        bgColor = "rgba(249, 115, 22, 0.04)";
    } elif uploadStatus == "success" {
        borderColor = "#22c55e";
    } elif uploadStatus == "error" {
        borderColor = "#ef4444";
    }

    iconEl = <IconUpload size={24} color={ORANGE} />;
    if isUploading {
        iconEl = <div style={{
            "width": "24px",
            "height": "24px",
            "borderRadius": "50%",
            "border": "2px solid " + ORANGE,
            "borderTopColor": "transparent",
            "animation": "spin 1s linear infinite"
        }} />;
    } elif uploadStatus == "success" {
        iconEl = <IconCheck size={24} color="#22c55e" />;
    } elif uploadStatus == "error" {
        iconEl = <IconX size={24} color="#ef4444" />;
    }

    titleText = "Drop file here or click to upload";
    if isUploading { titleText = "Uploading..."; }
    elif uploadStatus == "success" { titleText = "Uploaded successfully!"; }
    elif uploadStatus == "error" { titleText = "Upload failed"; }

    subtitleEl = <p style={{"color": MUTED, "fontSize": "12px", "margin": "0"}}>
        PDF, DOCX, MD, TXT, code files
    </p>;
    if statusMessage {
        subtitleColor = ("#22c55e" if uploadStatus == "success" else "#ef4444");
        subtitleEl = <p style={{"color": subtitleColor, "fontSize": "12px", "margin": "0"}}>
            {statusMessage}
        </p>;
    }

    return <div>
        <input
            ref={fileInputRef}
            type="file"
            accept={ALLOWED}
            onChange={handleInputChange}
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
                "padding": "24px",
                "textAlign": "center",
                "cursor": (("not-allowed" if isUploading else "pointer")),
                "background": bgColor,
                "transition": "all 0.2s ease"
            }}
        >
            <div style={{
                "display": "flex",
                "flexDirection": "column",
                "alignItems": "center",
                "gap": "10px"
            }}>
                {iconEl}
                <div>
                    <p style={{"color": TEXT, "fontSize": "14px", "fontWeight": "500", "margin": "0 0 4px 0"}}>
                        {titleText}
                    </p>
                    {subtitleEl}
                </div>
            </div>
        </div>
    </div>;
}
