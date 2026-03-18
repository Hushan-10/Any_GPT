"""Session and Message nodes - represent chat sessions.

Session persists chat history across interactions.
Message is an individual turn in the conversation.
"""

node Message {
    has role: str;       # "user" | "assistant"
    has content: str;
    has sources: list = [];
    has timestamp: str = "";
}
