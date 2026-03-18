"""Chat input component with auto-expanding textarea."""

import from react { useRef, useEffect }
import from "@tabler/icons-react" {
    IconSend,
    IconPlayerStop
}

"""Chat input with auto-expanding textarea and send/stop button."""
def:pub ChatInput(
    onSendMessage: any,
    disabled: bool = False,
    placeholder: str = "Ask a question about your uploaded documents...",
    isLoading: bool = False,
    onStop: any = None
) -> any {
    has inputValue: str = "";
    has isFocused: bool = False;
    textareaRef = useRef(None);

    useEffect(lambda -> None {
        if textareaRef.current {
            textareaRef.current.style.height = "auto";
            scrollHeight = textareaRef.current.scrollHeight;
            newHeight = Math.max(60, Math.min(scrollHeight, 200));
            textareaRef.current.style.height = String(newHeight) + "px";
        }
    }, [inputValue]);

    def handleSubmit(e: any) -> None {
        e.preventDefault();
        if inputValue.trim() and not disabled and not isLoading {
            onSendMessage(inputValue.trim());
            inputValue = "";
            if textareaRef.current {
                textareaRef.current.style.height = "60px";
            }
        }
    }

    def handleKeyDown(e: any) -> None {
        if e.key == "Enter" and not e.shiftKey {
            e.preventDefault();
            handleSubmit(e);
        }
    }

    def handleInputChange(e: any) -> None {
        inputValue = e.target.value;
    }

    canSend = inputValue.trim() and not disabled and not isLoading;

    borderColor = "#d1d5db";
    boxShadowValue = "none";
    if isFocused {
        borderColor = "#f97316";
        boxShadowValue = "0 0 0 2px rgba(249, 115, 22, 0.15)";
    }

    buttonBg = "linear-gradient(135deg, #f97316 0%, #ea580c 100%)";
    buttonIcon = <IconSend size={16} />;
    buttonOpacity = "1";
    if isLoading {
        buttonBg = "#6b7280";
        buttonIcon = <IconPlayerStop size={16} />;
    } elif not canSend {
        buttonOpacity = "0.4";
    }

    return <div style={{
        "paddingTop": "8px",
        "paddingLeft": "12px",
        "paddingRight": "12px",
        "paddingBottom": "16px"
    }}>
        <form onSubmit={handleSubmit} style={{"maxWidth": "768px", "margin": "0 auto"}}>
            <div style={{"position": "relative"}}>
                <textarea
                    ref={textareaRef}
                    value={inputValue}
                    onChange={handleInputChange}
                    onKeyDown={handleKeyDown}
                    onFocus={lambda -> None { isFocused = True; }}
                    onBlur={lambda -> None { isFocused = False; }}
                    placeholder={placeholder}
                    disabled={disabled and not isLoading}
                    style={{
                        "width": "100%",
                        "minHeight": "60px",
                        "maxHeight": "200px",
                        "borderRadius": "30px",
                        "padding": "16px 64px 16px 20px",
                        "fontSize": "16px",
                        "lineHeight": "1.625",
                        "background": "#ffffff",
                        "border": "1px solid " + borderColor,
                        "color": "#111827",
                        "resize": "none",
                        "outline": "none",
                        "transition": "all 300ms ease",
                        "fontFamily": "system-ui, -apple-system, sans-serif",
                        "boxShadow": boxShadowValue,
                        "overflow": "auto"
                    }}
                    onMouseEnter={lambda e: any -> None {
                        if not isFocused {
                            e.currentTarget.style.borderColor = "rgba(249, 115, 22, 0.4)";
                        }
                    }}
                    onMouseLeave={lambda e: any -> None {
                        if not isFocused {
                            e.currentTarget.style.borderColor = "#d1d5db";
                        }
                    }}
                />
                <button
                    type={(("button" if isLoading else "submit"))}
                    onClick={(onStop if isLoading else None)}
                    disabled={not canSend and not isLoading}
                    style={{
                        "position": "absolute",
                        "right": "12px",
                        "bottom": "50%",
                        "transform": "translateY(50%)",
                        "width": "40px",
                        "height": "40px",
                        "borderRadius": "50%",
                        "border": "none",
                        "background": buttonBg,
                        "color": "#ffffff",
                        "display": "flex",
                        "alignItems": "center",
                        "justifyContent": "center",
                        "cursor": ((("pointer" if canSend or isLoading else "not-allowed"))),
                        "transition": "all 300ms ease",
                        "opacity": buttonOpacity,
                        "padding": "0"
                    }}
                    onMouseEnter={lambda e: any -> None {
                        if canSend or isLoading {
                            e.currentTarget.style.transform = "translateY(50%) scale(1.05)";
                            e.currentTarget.style.boxShadow = "0 0 20px rgba(249, 115, 22, 0.3)";
                        }
                    }}
                    onMouseLeave={lambda e: any -> None {
                        e.currentTarget.style.transform = "translateY(50%) scale(1)";
                        e.currentTarget.style.boxShadow = "none";
                    }}
                >
                    {buttonIcon}
                </button>
            </div>
        </form>
    </div>;
}
