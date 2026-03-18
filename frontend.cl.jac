"""Main frontend routing for AnyGPT."""

import from "@jac/runtime" { Router, Routes, Route }
import from "@mantine/core" { MantineProvider, createTheme }
import from .pages.ChatPage { ChatPage }

import "@mantine/core/styles.css";


"""Main app component with routing."""
def:pub app() -> any {
    theme = createTheme({
        "primaryColor": "orange",
        "defaultRadius": "md",
        "fontFamily": "Inter, -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, sans-serif"
    });

    return <MantineProvider theme={theme} defaultColorScheme="light">
        <Router>
            <Routes>
                <Route path="/" element={<ChatPage />} />
            </Routes>
        </Router>
    </MantineProvider>;
}
