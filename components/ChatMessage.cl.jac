"""Chat message component — user bubbles in orange, AI in light gray, with markdown."""

import from react { useState }
import from "react-markdown" { default as ReactMarkdown }
import from "@mantine/core" {
    Box,
    Group,
    Text,
    Paper,
    ActionIcon,
    Tooltip,
    Code
}
import from "@tabler/icons-react" {
    IconCopy,
    IconCheck,
    IconUser,
    IconSparkles
}

"""Code block with syntax label and copy button."""
def:pub CodeBlock(language: str, code: str) -> JsxElement {
    has copied: bool = false;

    def handleCopy() -> None {
        navigator.clipboard.writeText(code);
        copied = true;
        setTimeout(lambda -> None { copied = false; }, 2000);
    }

    displayLang = language;
    if not displayLang {
        displayLang = "code";
    }

    copyIcon = <IconCopy size={14} />;
    copyLabel = "Copy code";
    if copied {
        copyIcon = <IconCheck size={14} />;
        copyLabel = "Copied!";
    }

    return <Box my="sm">
        <Paper
            radius="md"
            style={{
                "background": "#1e1e2e",
                "border": "1px solid #F0F0F0",
                "overflow": "hidden"
            }}
        >
            <Group
                justify="space-between"
                px="md"
                py={6}
                style={{
                    "borderBottom": "1px solid rgba(255,255,255,0.06)",
                    "background": "#272736"
                }}
            >
                <Text size="xs" c="gray.5" ff="monospace" style={{"fontSize": "11px"}}>
                    {displayLang}
                </Text>
                <Tooltip label={copyLabel} position="left">
                    <ActionIcon
                        onClick={handleCopy}
                        variant="subtle"
                        color={("green" if copied else "gray")}
                        size="xs"
                    >
                        {copyIcon}
                    </ActionIcon>
                </Tooltip>
            </Group>
            <Box px="md" py="sm" style={{"overflowX": "auto"}}>
                <pre style={{
                    "margin": "0",
                    "fontSize": "13px",
                    "lineHeight": "1.65",
                    "fontFamily": "JetBrains Mono, Consolas, Monaco, monospace",
                    "whiteSpace": "pre-wrap",
                    "wordBreak": "break-word",
                    "color": "#e4e4e7"
                }}>
                    <code>{code}</code>
                </pre>
            </Box>
        </Paper>
    </Box>;
}

"""Single chat message — user (right, orange) or AI (left, gray)."""
def:pub ChatMessage(message: str, isUser: bool, timestamp: any = null) -> JsxElement {

    TEXT = "#1A1A1A";
    TEXT_BODY = "#374151";
    ORANGE = "#FF6B35";

    if isUser {
        return <Box py="6px" style={{"animation": "fadeIn 0.25s ease"}}>
            <Group justify="flex-end" align="flex-start" gap={10} wrap="nowrap">
                <Box style={{
                    "padding": "12px 18px",
                    "maxWidth": "75%",
                    "background": "linear-gradient(135deg, #FF6B35 0%, #FF8C5A 100%)",
                    "borderRadius": "18px 18px 4px 18px",
                    "boxShadow": "0 1px 4px rgba(255,107,53,0.15)"
                }}>
                    <Text size="sm" style={{
                        "whiteSpace": "pre-wrap",
                        "lineHeight": "1.6",
                        "color": "#ffffff"
                    }}>
                        {message}
                    </Text>
                </Box>
                <Box style={{
                    "width": "30px",
                    "height": "30px",
                    "borderRadius": "50%",
                    "background": "linear-gradient(135deg, #FF6B35 0%, #FF8C5A 100%)",
                    "display": "flex",
                    "alignItems": "center",
                    "justifyContent": "center",
                    "flexShrink": "0",
                    "marginTop": "2px"
                }}>
                    <IconUser size={14} color="#ffffff" />
                </Box>
            </Group>
        </Box>;
    }

    components = {
        "code": lambda p: any -> any {
            className = p.className or "";
            children = p.children;
            isInline = not className.includes("language-");

            language = "";
            if className.includes("language-") {
                parts = className.split("language-");
                if parts.length > 1 {
                    language = parts[1].split(" ")[0];
                }
            }

            codeContent = String(children);
            if codeContent.endsWith("\n") {
                codeContent = codeContent.slice(0, -1);
            }

            if not isInline and language {
                return <CodeBlock language={language} code={codeContent} />;
            }

            return <Code style={{
                "background": "rgba(255,107,53,0.08)",
                "color": "#c2410c",
                "padding": "2px 6px",
                "borderRadius": "4px",
                "fontSize": "13px",
                "border": "1px solid rgba(255,107,53,0.12)"
            }}>
                {children}
            </Code>;
        },

        "p": lambda p: any -> any {
            return <Text size="sm" c={TEXT_BODY} my="xs" style={{"lineHeight": "1.7"}}>
                {p.children}
            </Text>;
        },

        "h1": lambda p: any -> any {
            return <Text size="lg" fw={700} c={TEXT} mt="md" mb="xs"
                style={{"borderBottom": "1px solid #F0F0F0", "paddingBottom": "8px", "letterSpacing": "-0.3px"}}>
                {p.children}
            </Text>;
        },

        "h2": lambda p: any -> any {
            return <Text size="md" fw={700} c={TEXT} mt="sm" mb="xs" style={{"letterSpacing": "-0.2px"}}>
                {p.children}
            </Text>;
        },

        "h3": lambda p: any -> any {
            return <Text size="sm" fw={700} c={TEXT} mt="sm" mb="xs">
                {p.children}
            </Text>;
        },

        "ul": lambda p: any -> any {
            return <Box component="ul" my="xs" pl="md" style={{"listStyleType": "disc"}}>
                {p.children}
            </Box>;
        },

        "ol": lambda p: any -> any {
            return <Box component="ol" my="xs" pl="md" style={{"listStyleType": "decimal"}}>
                {p.children}
            </Box>;
        },

        "li": lambda p: any -> any {
            return <Text component="li" size="sm" c={TEXT_BODY}
                style={{"lineHeight": "1.7", "marginBottom": "4px"}}>
                {p.children}
            </Text>;
        },

        "strong": lambda p: any -> any {
            return <strong style={{"fontWeight": "700", "color": TEXT}}>
                {p.children}
            </strong>;
        },

        "a": lambda p: any -> any {
            return <Text
                component="a"
                href={p.href}
                target="_blank"
                rel="noopener noreferrer"
                td="none"
                span
                style={{"cursor": "pointer", "color": ORANGE, "fontWeight": "500"}}
            >
                {p.children}
            </Text>;
        },

        "hr": lambda p: any -> any {
            return <Box my="md" style={{"borderTop": "1px solid #F0F0F0"}} />;
        },

        "blockquote": lambda p: any -> any {
            return <Box my="sm" pl="md" style={{
                "borderLeft": "3px solid #FF6B35",
                "background": "#FFF5F0",
                "padding": "10px 14px",
                "borderRadius": "0 8px 8px 0"
            }}>
                {p.children}
            </Box>;
        }
    };

    return <Box py="6px" style={{"animation": "fadeIn 0.25s ease"}}>
        <Group align="flex-start" gap={10} wrap="nowrap">
            <Box style={{
                "width": "30px",
                "height": "30px",
                "borderRadius": "50%",
                "background": "linear-gradient(135deg, #FF6B35 0%, #FF8C5A 100%)",
                "display": "flex",
                "alignItems": "center",
                "justifyContent": "center",
                "flexShrink": "0",
                "marginTop": "2px"
            }}>
                <IconSparkles size={14} color="#ffffff" />
            </Box>
            <Box style={{
                "flex": "1",
                "minWidth": "0",
                "background": "#F5F5F5",
                "borderRadius": "4px 18px 18px 18px",
                "padding": "14px 18px"
            }}>
                <ReactMarkdown components={components}>
                    {message}
                </ReactMarkdown>
            </Box>
        </Group>
    </Box>;
}
