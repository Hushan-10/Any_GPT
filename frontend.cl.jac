"""Main frontend routing for AnyGPT — orange theme."""

import from "@jac/runtime" { Router, Routes, Route }
import from "@mantine/core" { MantineProvider, createTheme }
import from .pages.ChatPage { ChatPage }

import "@mantine/core/styles.css";


"""App root with Mantine provider and routing."""
def:pub app() -> any {
    theme = createTheme({
        "primaryColor": "orange",
        "defaultRadius": "md",
        "fontFamily": "Inter, -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, sans-serif",
        "headings": {
            "fontFamily": "Inter, -apple-system, BlinkMacSystemFont, Segoe UI, sans-serif",
            "fontWeight": "700"
        },
        "colors": {
            "orange": [
                "#FFF5F0",
                "#FFE5D9",
                "#FFD0BC",
                "#FFB899",
                "#FF9E74",
                "#FF8C5A",
                "#FF6B35",
                "#E85D2C",
                "#CC4F22",
                "#A6401C"
            ]
        }
    });

    return <MantineProvider theme={theme} defaultColorScheme="light">
        <Router>
            <Routes>
                <Route path="/" element={<ChatPage />} />
            </Routes>
        </Router>
    </MantineProvider>;
}
