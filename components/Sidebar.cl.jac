"""Sidebar component for AnyGPT - chat history + document count."""

import from react { useState }
import from "@mantine/core" {
    Box,
    Stack,
    Group,
    Text,
    Button,
    ActionIcon,
    ScrollArea,
    Tooltip,
    Divider,
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
    IconFiles
}


"""Sidebar with chat history and document count."""
def:pub Sidebar(
    isOpen: bool,
    onToggle: any,
    onNewChat: any,
    chatSessions: list = [],
    currentSessionId: str = "",
    onLoadSession: any = None,
    onDeleteSession: any = None,
    isLoading: bool = False,
    documentCount: int = 0
) -> any {
    isDesktop = useMediaQuery("(min-width: 1024px)");
    shouldShow = isDesktop or isOpen;
    has isExpanded: bool = True;

    BG = "#f9fafb";
    BORDER = "#e5e7eb";
    TEXT = "#111827";
    TEXT_SECONDARY = "#4b5563";
    MUTED = "#9ca3af";
    ORANGE = "#f97316";

    def toggleExpanded() -> None {
        isExpanded = not isExpanded;
    }

    sidebarWidth = (260 if isExpanded else 60);

    mobileOverlay = None;
    if isOpen and not isDesktop {
        mobileOverlay = <Box
            style={{
                "position": "fixed",
                "inset": "0",
                "background": "rgba(0,0,0,0.3)",
                "zIndex": "40"
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
        "transition": "all 0.25s ease",
        "transform": (("translateX(0)" if shouldShow else "translateX(-100%)"))
    };

    logoSection = <Box style={{"padding": "14px", "borderBottom": "1px solid " + BORDER}}>
        <Group justify="space-between" align="center" wrap="nowrap">
            {(
                <Group gap="sm" align="center" wrap="nowrap">
                    <Box style={{
                        "width": "44px",
                        "height": "44px",
                        "borderRadius": "12px",
                        "background": "rgba(249,115,22,0.08)",
                        "display": "flex",
                        "alignItems": "center",
                        "justifyContent": "center",
                        "fontSize": "22px"
                    }}>
                        🤖
                    </Box>
                    <Box style={{"lineHeight": "1.1"}}>
                        <Text fw={700} style={{"fontSize": "18px", "color": TEXT}}>AnyGPT</Text>
                        <Text style={{"fontSize": "12px", "color": MUTED, "marginTop": "2px"}}>
                            AI from your documents
                        </Text>
                    </Box>
                </Group>
                if isExpanded
                else
                <Box mx="auto" style={{
                    "width": "44px",
                    "height": "44px",
                    "borderRadius": "12px",
                    "background": "rgba(249,115,22,0.08)",
                    "display": "flex",
                    "alignItems": "center",
                    "justifyContent": "center",
                    "fontSize": "22px"
                }}>
                    🤖
                </Box>
            )}
            <Group gap="xs" align="center" wrap="nowrap">
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

    newChatButton = <Box px="md" py="sm">
        <Button
            onClick={onNewChat}
            disabled={isLoading}
            fullWidth={True}
            radius="md"
            variant="outline"
            styles={{
                "root": {
                    "background": "#ffffff",
                    "borderColor": BORDER,
                    "color": TEXT,
                    "height": "44px"
                }
            }}
        >
            <Group justify="center" gap="sm" style={{"width": "100%"}}>
                <IconPlus size={16} />
                {(<Text fw={600} style={{"color": TEXT, "fontSize": "14px"}}>New Chat</Text>) if isExpanded else None}
            </Group>
        </Button>
    </Box>;

    docBadge = None;
    if isExpanded {
        docBadge = <Box px="md" pb="xs">
            <Group gap="xs" style={{
                "background": "rgba(249,115,22,0.06)",
                "padding": "8px 12px",
                "borderRadius": "8px",
                "border": "1px solid rgba(249,115,22,0.15)"
            }}>
                <IconFiles size={14} color={ORANGE} />
                <Text size="xs" c={MUTED}>
                    {documentCount} document{(("s" if documentCount != 1 else ""))} indexed
                </Text>
            </Group>
        </Box>;
    }

    sessionsContent = <Text size="sm" c={MUTED} ta="center" py="lg">No chat history yet</Text>;
    if isExpanded and chatSessions.length > 0 {
        sessionsContent = <Stack gap={4}>
            {chatSessions.map(lambda session: any -> any {
                isCurrentSession = session.id == currentSessionId;
                return <UnstyledButton
                    key={session.id}
                    onClick={lambda -> None {
                        if not isLoading and onLoadSession {
                            onLoadSession(session.id);
                        }
                    }}
                    style={{
                        "display": "flex",
                        "alignItems": "center",
                        "gap": "8px",
                        "padding": "8px 12px",
                        "borderRadius": "8px",
                        "width": "100%",
                        "background": (("rgba(249,115,22,0.06)" if isCurrentSession else "transparent")),
                        "color": (TEXT if isCurrentSession else TEXT_SECONDARY),
                        "opacity": (("0.5" if isLoading else "1")),
                        "cursor": (("not-allowed" if isLoading else "pointer")),
                        "transition": "all 0.2s ease"
                    }}
                >
                    <IconMessage size={14} color={MUTED} />
                    <Text
                        size="sm"
                        style={{
                            "flex": "1",
                            "overflow": "hidden",
                            "textOverflow": "ellipsis",
                            "whiteSpace": "nowrap"
                        }}
                        c={(TEXT if isCurrentSession else TEXT_SECONDARY)}
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
                        style={{"opacity": "0.75"}}
                    >
                        <IconTrash size={12} />
                    </ActionIcon>
                </UnstyledButton>;
            })}
        </Stack>;
    }

    chatSessionsList = None;
    if isExpanded {
        chatSessionsList = <Box px="md" style={{"flex": "1", "overflow": "hidden"}}>
            <Text size="xs" fw={600} c={MUTED} tt="uppercase" mb="sm">Recent Chats</Text>
            <ScrollArea style={{"height": "100%"}} type="scroll">
                {sessionsContent}
            </ScrollArea>
        </Box>;
    } else {
        chatSessionsList = <Box style={{"flex": "1"}} />;
    }

    statusBar = None;
    if isExpanded {
        statusBar = <Box px="md" pb="md">
            <Group gap="xs" style={{
                "background": "#ffffff",
                "padding": "8px 12px",
                "borderRadius": "8px",
                "border": "1px solid " + BORDER
            }}>
                <Box style={{
                    "width": "8px",
                    "height": "8px",
                    "borderRadius": "50%",
                    "background": "#22c55e"
                }} />
                <Text size="xs" c={MUTED}>Ready</Text>
            </Group>
        </Box>;
    }

    return <>
        {mobileOverlay}

        <Box style={sidebarStyle}>
            <Box style={{"display": "flex", "flexDirection": "column", "height": "100%"}}>
                {logoSection}
                {newChatButton}
                {docBadge}

                <Box style={{"flex": "1", "minHeight": "0"}}>
                    {chatSessionsList}
                </Box>

                <Box>
                    <Divider color={BORDER} />
                    {statusBar}
                </Box>
            </Box>
        </Box>

        <Box style={{"width": String(sidebarWidth) + "px", "flexShrink": "0"}} visibleFrom="lg" />
    </>;
}
