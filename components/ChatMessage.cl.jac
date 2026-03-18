"""Chat message component with markdown rendering."""

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
    IconCheck
}

"""Code block with copy button."""
def:pub CodeBlock(language: str, code: str) -> JsxElement {
    has copied: bool = false;

    def handleCopy() -> None {
        navigator.clipboard.writeText(code);
        copied = true;
        setTimeout(lambda { copied = false; }, 2000);
    }

    copyLabel = "Copy code";
    copyColor = "gray";
    copyIcon = <IconCopy size={14} />;
    if copied {
        copyLabel = "Copied!";
        copyColor = "green";
        copyIcon = <IconCheck size={14} />;
    }

    displayLang = language;
    if not displayLang {
        displayLang = "code";
    }

    return <Box my="sm">
        <Paper
            radius="md"
            style={{
                "background": "#1e1e2e",
                "border": "1px solid #e5e7eb",
                "overflow": "hidden"
            }}
        >
            <Group
                justify="space-between"
                px="md"
                py="xs"
                style={{
                    "borderBottom": "1px solid rgba(255,255,255,0.08)",
                    "background": "#2d2d3f"
                }}
            >
                <Text size="xs" c="gray.5" ff="monospace">
                    {displayLang}
                </Text>
                <Tooltip label={copyLabel} position="left">
                    <ActionIcon
                        onClick={handleCopy}
                        variant="subtle"
                        color={copyColor}
                        size="sm"
                    >
                        {copyIcon}
                    </ActionIcon>
                </Tooltip>
            </Group>
            <Box px="md" py="sm" style={{"overflowX": "auto"}}>
                <pre style={{
                    "margin": "0",
                    "padding": "0",
                    "fontSize": "13px",
                    "lineHeight": "1.6",
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

"""Chat message component."""
def:pub ChatMessage(message: str, isUser: bool, timestamp: any = null) -> JsxElement {

    ORANGE = "#f97316";
    TEXT = "#111827";
    TEXT_SECONDARY = "#374151";

    if isUser {
        return <Box py="4px" px="xs" style={{"animation": "fadeIn 0.3s ease"}}>
            <Group justify="flex-end">
                <div style={{
                    "padding": "12px 16px",
                    "maxWidth": "80%",
                    "background": "#f3f4f6",
                    "border": "none",
                    "borderRadius": "20px"
                }}>
                    <Text size="sm" c={TEXT} style={{"whiteSpace": "pre-wrap", "lineHeight": "1.6"}}>
                        {message}
                    </Text>
                </div>
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
                "background": "rgba(249,115,22,0.08)",
                "color": "#c2410c",
                "padding": "2px 6px",
                "borderRadius": "4px",
                "fontSize": "13px",
                "border": "1px solid rgba(249,115,22,0.15)"
            }}>
                {children}
            </Code>;
        },

        "p": lambda p: any -> any {
            return <Text size="sm" c={TEXT_SECONDARY} my="xs" style={{"lineHeight": "1.7"}}>
                {p.children}
            </Text>;
        },

        "h1": lambda p: any -> any {
            return <Text size="lg" fw={700} c={TEXT} mt="md" mb="xs"
                style={{"borderBottom": "1px solid #e5e7eb", "paddingBottom": "8px"}}>
                {p.children}
            </Text>;
        },

        "h2": lambda p: any -> any {
            return <Text size="md" fw={700} c={TEXT} mt="sm" mb="xs">
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
            return <Text component="li" size="sm" c={TEXT_SECONDARY}
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
                style={{"cursor": "pointer", "color": ORANGE}}
            >
                {p.children}
            </Text>;
        },

        "hr": lambda p: any -> any {
            return <Box my="md" style={{"borderTop": "1px solid #e5e7eb"}} />;
        }
    };

    return <Box py="sm" px="xs" style={{"animation": "fadeIn 0.3s ease"}}>
        <Box style={{"flex": "1", "minWidth": "0"}}>
            <ReactMarkdown components={components}>
                {message}
            </ReactMarkdown>
        </Box>
    </Box>;
}
