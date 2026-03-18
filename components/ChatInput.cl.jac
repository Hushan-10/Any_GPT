"""Chat input — floating rounded bar with orange send button."""

import from react { useRef, useEffect }
import from "@tabler/icons-react" {
    IconSend2,
    IconPlayerStop,
    IconPaperclip
}

"""Chat input with auto-expanding textarea, paperclip icon, and send/stop button."""
def:pub ChatInput(
    onSendMessage: any,
    disabled: bool = False,
    placeholder: str = "Ask a question about your documents...",
    isLoading: bool = False,
    onStop: any = None,
    onAttach: any = None
) -> any {
    has inputValue: str = "";
    has isFocused: bool = False;
    textareaRef = useRef(None);

    useEffect(lambda -> None {
        if textareaRef.current {
            textareaRef.current.style.height = "auto";
            scrollHeight = textareaRef.current.scrollHeight;
            newHeight = Math.max(52, Math.min(scrollHeight, 180));
            textareaRef.current.style.height = String(newHeight) + "px";
        }
    }, [inputValue]);

    def handleSubmit(e: any) -> None {
        e.preventDefault();
        if inputValue.trim() and not disabled and not isLoading {
            onSendMessage(inputValue.trim());
            inputValue = "";
            if textareaRef.current {
                textareaRef.current.style.height = "52px";
            }
        }
    }

    def handleKeyDown(e: any) -> None {
        if e.key == "Enter" and not e.shiftKey {
            e.preventDefault();
            handleSubmit(e);
        }
    }

    canSend = inputValue.trim() and not disabled and not isLoading;

    borderColor = "#F0F0F0";
    shadowVal = "0 2px 12px rgba(0,0,0,0.04)";
    if isFocused {
        borderColor = "#FFE5D9";
        shadowVal = "0 2px 20px rgba(255,107,53,0.1)";
    }

    sendBtnBg = "linear-gradient(135deg, #FF6B35 0%, #FF8C5A 100%)";
    sendBtnIcon = <IconSend2 size={16} />;
    sendBtnOpacity = "1";
    if isLoading {
        sendBtnBg = "#6B7280";
        sendBtnIcon = <IconPlayerStop size={16} />;
    } elif not canSend {
        sendBtnOpacity = "0.35";
    }

    return <div style={{
        "padding": "12px 16px 20px",
        "background": "#FFFFFF"
    }}>
        <form onSubmit={handleSubmit} style={{"maxWidth": "768px", "margin": "0 auto"}}>
            <div style={{
                "position": "relative",
                "background": "#FFFFFF",
                "borderRadius": "26px",
                "border": "1px solid " + borderColor,
                "boxShadow": shadowVal,
                "transition": "all 0.2s ease",
                "display": "flex",
                "alignItems": "flex-end"
            }}>
                {(
                    <button
                        type="button"
                        onClick={onAttach}
                        style={{
                            "background": "none",
                            "border": "none",
                            "color": "#9CA3AF",
                            "cursor": "pointer",
                            "padding": "0",
                            "display": "flex",
                            "alignItems": "center",
                            "justifyContent": "center",
                            "width": "40px",
                            "height": "52px",
                            "flexShrink": "0",
                            "marginLeft": "8px",
                            "transition": "color 0.2s ease"
                        }}
                        onMouseEnter={lambda e: any -> None {
                            e.currentTarget.style.color = "#FF6B35";
                        }}
                        onMouseLeave={lambda e: any -> None {
                            e.currentTarget.style.color = "#9CA3AF";
                        }}
                    >
                        <IconPaperclip size={18} />
                    </button>
                    if onAttach else None
                )}
                <textarea
                    ref={textareaRef}
                    value={inputValue}
                    onChange={lambda e: any -> None { inputValue = e.target.value; }}
                    onKeyDown={handleKeyDown}
                    onFocus={lambda -> None { isFocused = True; }}
                    onBlur={lambda -> None { isFocused = False; }}
                    placeholder={placeholder}
                    disabled={disabled and not isLoading}
                    rows={1}
                    style={{
                        "flex": "1",
                        "minHeight": "52px",
                        "maxHeight": "180px",
                        "border": "none",
                        "background": "transparent",
                        "padding": "14px 8px 14px 18px",
                        "fontSize": "15px",
                        "lineHeight": "1.6",
                        "color": "#1A1A1A",
                        "resize": "none",
                        "outline": "none",
                        "fontFamily": "Inter, system-ui, -apple-system, sans-serif",
                        "overflow": "auto"
                    }}
                />
                <div style={{
                    "padding": "0 10px 0 4px",
                    "display": "flex",
                    "alignItems": "center",
                    "height": "52px",
                    "flexShrink": "0"
                }}>
                    <button
                        type={(("button" if isLoading else "submit"))}
                        onClick={(onStop if isLoading else None)}
                        disabled={not canSend and not isLoading}
                        style={{
                            "width": "36px",
                            "height": "36px",
                            "borderRadius": "50%",
                            "border": "none",
                            "background": sendBtnBg,
                            "color": "#ffffff",
                            "display": "flex",
                            "alignItems": "center",
                            "justifyContent": "center",
                            "cursor": ((("pointer" if canSend or isLoading else "not-allowed"))),
                            "transition": "all 0.2s ease",
                            "opacity": sendBtnOpacity,
                            "padding": "0",
                            "boxShadow": "0 2px 6px rgba(255,107,53,0.2)"
                        }}
                        onMouseEnter={lambda e: any -> None {
                            if canSend or isLoading {
                                e.currentTarget.style.transform = "scale(1.08)";
                                e.currentTarget.style.boxShadow = "0 3px 12px rgba(255,107,53,0.3)";
                            }
                        }}
                        onMouseLeave={lambda e: any -> None {
                            e.currentTarget.style.transform = "scale(1)";
                            e.currentTarget.style.boxShadow = "0 2px 6px rgba(255,107,53,0.2)";
                        }}
                    >
                        {sendBtnIcon}
                    </button>
                </div>
            </div>
        </form>
    </div>;
}
