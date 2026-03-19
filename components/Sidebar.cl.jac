"""Sidebar component — modern, ChatGPT/DeepSeek inspired, orange theme."""

import from react { useState }
import from "@mantine/core" {
    Box,
    Stack,
    Group,
    Text,
    ActionIcon,
    ScrollArea,
    Tooltip,
    UnstyledButton
}
import from "@mantine/hooks" { useMediaQuery }
import from "@tabler/icons-react" {
    IconPlus,
    IconX,
    IconChevronLeft,
    IconChevronRight,
    IconTrash,
    IconMessage,
    IconFiles,
    IconSparkles,
    IconLogout,
    IconUser
}


"""Sidebar with chat history, new-chat button, and document badge."""
def:pub Sidebar(
    isOpen: bool,
    onToggle: any,
    onNewChat: any,
    chatSessions: list = [],
    currentSessionId: str = "",
    onLoadSession: any = None,
    onDeleteSession: any = None,
    isLoading: bool = False,
    documentCount: int = 0,
    username: str = "User",
    onLogout: any = None
) -> any {
    isDesktop = useMediaQuery("(min-width: 1024px)");
    shouldShow = isDesktop or isOpen;
    has isExpanded: bool = True;

    BG = "#F9F9F9";
    BORDER = "#F0F0F0";
    BORDER_ORANGE = "#FFE5D9";
    TEXT = "#1A1A1A";
    MUTED = "#6B7280";
    ORANGE = "#FF6B35";
    HOVER_BG = "#FFF5F0";

    def toggleExpanded() -> None {
        isExpanded = not isExpanded;
    }

    sidebarWidth = (268 if isExpanded else 64);

    mobileOverlay = None;
    if isOpen and not isDesktop {
        mobileOverlay = <Box
            style={{
                "position": "fixed",
                "inset": "0",
                "background": "rgba(0,0,0,0.2)",
                "zIndex": "40",
                "backdropFilter": "blur(2px)"
            }}
            onClick={onToggle}
        />;
    }

    sidebarStyle = {
        "position": "fixed",
        "left": "0",
        "top": "0",
        "height": "100vh",
        "width": String(sidebarWidth) + "px",
        "background": BG,
        "borderRight": "1px solid " + BORDER,
        "zIndex": "50",
        "transition": "all 0.2s ease",
        "transform": (("translateX(0)" if shouldShow else "translateX(-100%)"))
    };

    logoSection = <Box style={{"padding": "16px", "borderBottom": "1px solid " + BORDER}}>
        <Group justify="space-between" align="center" wrap="nowrap">
            {(
                <Group gap={10} align="center" wrap="nowrap">
                    <Box style={{
                        "width": "38px",
                        "height": "38px",
                        "borderRadius": "10px",
                        "background": "linear-gradient(135deg, #FF6B35 0%, #FF8C5A 100%)",
                        "display": "flex",
                        "alignItems": "center",
                        "justifyContent": "center",
                        "fontSize": "18px",
                        "boxShadow": "0 2px 8px rgba(255,107,53,0.25)",
                        "flexShrink": "0"
                    }}>
                        <IconSparkles size={20} color="#ffffff" />
                    </Box>
                    <Box style={{"lineHeight": "1.2"}}>
                        <Text fw={700} style={{
                            "fontSize": "17px",
                            "color": TEXT,
                            "letterSpacing": "-0.3px"
                        }}>
                            AnyGPT
                        </Text>
                        <Text style={{
                            "fontSize": "11px",
                            "color": MUTED,
                            "marginTop": "1px"
                        }}>
                            Document Intelligence
                        </Text>
                    </Box>
                </Group>
                if isExpanded
                else
                <Tooltip label="AnyGPT" position="right">
                    <Box mx="auto" style={{
                        "width": "38px",
                        "height": "38px",
                        "borderRadius": "10px",
                        "background": "linear-gradient(135deg, #FF6B35 0%, #FF8C5A 100%)",
                        "display": "flex",
                        "alignItems": "center",
                        "justifyContent": "center",
                        "fontSize": "18px",
                        "boxShadow": "0 2px 8px rgba(255,107,53,0.25)"
                    }}>
                        <IconSparkles size={20} color="#ffffff" />
                    </Box>
                </Tooltip>
            )}
            <Group gap={4} align="center" wrap="nowrap">
                <Tooltip label={("Collapse" if isExpanded else "Expand")} position="right">
                    <ActionIcon
                        onClick={toggleExpanded}
                        variant="subtle"
                        size="sm"
                        radius="md"
                        visibleFrom="lg"
                        style={{"color": MUTED}}
                    >
                        {((<IconChevronLeft size={18} />) if isExpanded else (<IconChevronRight size={18} />))}
                    </ActionIcon>
                </Tooltip>
                <ActionIcon
                    onClick={onToggle}
                    variant="subtle"
                    size="sm"
                    radius="md"
                    hiddenFrom="lg"
                    style={{"color": MUTED}}
                >
                    <IconX size={18} />
                </ActionIcon>
            </Group>
        </Group>
    </Box>;

    newChatBtn = None;
    if isExpanded {
        newChatBtn = <Box px="md" py="sm">
            <button
                onClick={onNewChat}
                disabled={isLoading}
                style={{
                    "width": "100%",
                    "height": "42px",
                    "borderRadius": "10px",
                    "border": "none",
                    "background": "linear-gradient(135deg, #FF6B35 0%, #FF8C5A 100%)",
                    "color": "#ffffff",
                    "fontSize": "14px",
                    "fontWeight": "600",
                    "cursor": (("not-allowed" if isLoading else "pointer")),
                    "display": "flex",
                    "alignItems": "center",
                    "justifyContent": "center",
                    "gap": "8px",
                    "transition": "all 0.2s ease",
                    "boxShadow": "0 2px 8px rgba(255,107,53,0.2)",
                    "opacity": (("0.6" if isLoading else "1"))
                }}
                onMouseEnter={lambda e: any -> None {
                    if not isLoading {
                        e.currentTarget.style.boxShadow = "0 4px 14px rgba(255,107,53,0.35)";
                        e.currentTarget.style.transform = "translateY(-1px)";
                    }
                }}
                onMouseLeave={lambda e: any -> None {
                    e.currentTarget.style.boxShadow = "0 2px 8px rgba(255,107,53,0.2)";
                    e.currentTarget.style.transform = "translateY(0)";
                }}
            >
                <IconPlus size={16} />
                <span>New Chat</span>
            </button>
        </Box>;
    } else {
        newChatBtn = <Box py="sm" style={{"display": "flex", "justifyContent": "center"}}>
            <Tooltip label="New Chat" position="right">
                <ActionIcon
                    onClick={onNewChat}
                    disabled={isLoading}
                    variant="subtle"
                    size="lg"
                    radius="md"
                    style={{"color": ORANGE}}
                >
                    <IconPlus size={20} />
                </ActionIcon>
            </Tooltip>
        </Box>;
    }

    docBadge = None;
    if isExpanded {
        docBadge = <Box px="md" pb="xs">
            <Group gap="xs" style={{
                "background": HOVER_BG,
                "padding": "8px 12px",
                "borderRadius": "8px",
                "border": "1px solid " + BORDER_ORANGE
            }}>
                <IconFiles size={14} color={ORANGE} />
                <Text size="xs" c={MUTED} fw={500}>
                    {documentCount} document{(("s" if documentCount != 1 else ""))} indexed
                </Text>
            </Group>
        </Box>;
    } else {
        docBadge = <Box pb="xs" style={{"display": "flex", "justifyContent": "center"}}>
            <Tooltip label={String(documentCount) + " documents indexed"} position="right">
                <Box style={{
                    "width": "36px",
                    "height": "36px",
                    "borderRadius": "8px",
                    "background": HOVER_BG,
                    "border": "1px solid " + BORDER_ORANGE,
                    "display": "flex",
                    "alignItems": "center",
                    "justifyContent": "center"
                }}>
                    <IconFiles size={16} color={ORANGE} />
                </Box>
            </Tooltip>
        </Box>;
    }

    sessionsContent = None;
    if isExpanded {
        if chatSessions.length > 0 {
            sessionsContent = <Stack gap={2}>
                {chatSessions.map(lambda session: any -> any {
                    isCurrentSession = session.id == currentSessionId;
                    bgVal = "transparent";
                    if isCurrentSession {
                        bgVal = HOVER_BG;
                    }
                    borderVal = "1px solid transparent";
                    if isCurrentSession {
                        borderVal = "1px solid " + BORDER_ORANGE;
                    }
                    return <UnstyledButton
                        key={session.id}
                        onClick={lambda -> None {
                            if not isLoading and onLoadSession {
                                onLoadSession(session.id);
                            }
                        }}
                        className="sidebar-session-item"
                        style={{
                            "display": "flex",
                            "alignItems": "center",
                            "gap": "8px",
                            "padding": "9px 12px",
                            "borderRadius": "8px",
                            "width": "100%",
                            "background": bgVal,
                            "color": (TEXT if isCurrentSession else MUTED),
                            "opacity": (("0.5" if isLoading else "1")),
                            "cursor": (("not-allowed" if isLoading else "pointer")),
                            "transition": "all 0.2s ease",
                            "border": borderVal
                        }}
                        onMouseEnter={lambda e: any -> None {
                            if not isCurrentSession {
                                e.currentTarget.style.background = HOVER_BG;
                            }
                            deleteBtn = e.currentTarget.querySelector(".session-delete-btn");
                            if deleteBtn {
                                deleteBtn.style.opacity = "1";
                            }
                        }}
                        onMouseLeave={lambda e: any -> None {
                            if not isCurrentSession {
                                e.currentTarget.style.background = "transparent";
                            }
                            deleteBtn = e.currentTarget.querySelector(".session-delete-btn");
                            if deleteBtn {
                                deleteBtn.style.opacity = "0";
                            }
                        }}
                    >
                        <IconMessage size={14} color={(ORANGE if isCurrentSession else MUTED)} style={{"flexShrink": "0"}} />
                        <Text
                            size="sm"
                            style={{
                                "flex": "1",
                                "overflow": "hidden",
                                "textOverflow": "ellipsis",
                                "whiteSpace": "nowrap",
                                "fontSize": "13px"
                            }}
                            c={(TEXT if isCurrentSession else MUTED)}
                        >
                            {session.title}
                        </Text>
                        <ActionIcon
                            onClick={lambda e: any -> None {
                                e.stopPropagation();
                                if not isLoading and onDeleteSession {
                                    onDeleteSession(session.id);
                                }
                            }}
                            disabled={isLoading}
                            variant="subtle"
                            color="red"
                            size="xs"
                            radius="sm"
                            className="session-delete-btn"
                            style={{
                                "opacity": "0",
                                "transition": "opacity 0.15s ease",
                                "flexShrink": "0"
                            }}
                        >
                            <IconTrash size={12} />
                        </ActionIcon>
                    </UnstyledButton>;
                })}
            </Stack>;
        } else {
            sessionsContent = <Box py="xl" style={{"textAlign": "center"}}>
                <IconMessage size={28} color="#E5E7EB" style={{"margin": "0 auto 8px"}} />
                <Text size="xs" c={MUTED}>No conversations yet</Text>
            </Box>;
        }
    }

    chatSessionsList = None;
    if isExpanded {
        chatSessionsList = <Box px="md" style={{"flex": "1", "overflow": "hidden"}}>
            <Text size="xs" fw={600} c={MUTED} tt="uppercase" mb="sm"
                style={{"letterSpacing": "0.5px", "fontSize": "11px"}}>
                Recent Chats
            </Text>
            <ScrollArea style={{"height": "calc(100% - 24px)"}} type="scroll">
                {sessionsContent}
            </ScrollArea>
        </Box>;
    } else {
        chatSessionsList = <Box style={{"flex": "1"}} />;
    }

    statusBar = None;
    if isExpanded {
        statusBar = <Box px="md" py="sm" style={{"borderTop": "1px solid " + BORDER}}>
            <Group gap="xs" justify="space-between" style={{
                "padding": "8px 12px",
                "borderRadius": "8px",
                "background": HOVER_BG
            }}>
                <Group gap="xs">
                    <Box style={{
                        "width": "28px",
                        "height": "28px",
                        "borderRadius": "50%",
                        "background": "linear-gradient(135deg, #FF6B35 0%, #FF8C5A 100%)",
                        "display": "flex",
                        "alignItems": "center",
                        "justifyContent": "center",
                        "flexShrink": "0"
                    }}>
                        <IconUser size={14} color="#ffffff" />
                    </Box>
                    <Text size="xs" c={TEXT} fw={500} style={{
                        "maxWidth": "120px",
                        "overflow": "hidden",
                        "textOverflow": "ellipsis",
                        "whiteSpace": "nowrap"
                    }}>
                        {username}
                    </Text>
                </Group>
                <Tooltip label="Sign out" position="top">
                    <ActionIcon
                        onClick={onLogout}
                        variant="subtle"
                        size="sm"
                        radius="md"
                        style={{"color": MUTED}}
                    >
                        <IconLogout size={16} />
                    </ActionIcon>
                </Tooltip>
            </Group>
        </Box>;
    } else {
        statusBar = <Box py="sm" style={{"display": "flex", "justifyContent": "center", "borderTop": "1px solid " + BORDER}}>
            <Tooltip label={"Sign out (" + username + ")"} position="right">
                <ActionIcon
                    onClick={onLogout}
                    variant="subtle"
                    size="lg"
                    radius="md"
                    style={{"color": MUTED}}
                >
                    <IconLogout size={20} />
                </ActionIcon>
            </Tooltip>
        </Box>;
    }

    return <>
        {mobileOverlay}

        <Box style={sidebarStyle}>
            <Box style={{"display": "flex", "flexDirection": "column", "height": "100%"}}>
                {logoSection}
                {newChatBtn}
                {docBadge}

                <Box style={{"flex": "1", "minHeight": "0"}}>
                    {chatSessionsList}
                </Box>

                {statusBar}
            </Box>
        </Box>

        <Box style={{"width": String(sidebarWidth) + "px", "flexShrink": "0"}} visibleFrom="lg" />
    </>;
}
