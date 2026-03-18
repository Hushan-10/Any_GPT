"""AnyGPT Server Implementation - Chat logic and walker implementations."""

import json;
import from datetime {datetime}


# Collect full response from the LLM generator (jac start dev server does not support SSE)
def collect_chat_response(response_generator: any, visitor: any) -> dict {
    response = "";
    sources: list = [];
    for event in response_generator {
        if event.event_type == "chunk" {
            response += event.data.get("content", "");
        } elif event.event_type == "source" {
            sources.append(event.data);
        }
    }

    session_node = ([root-->(?:Session)](?id==visitor.session_id))[0];
    session_node.chat_history.append({"role": "assistant", "content": response});
    session_node.updated_at = datetime.now().isoformat();

    return {
        "response": response,
        "sources": sources,
        "session_id": visitor.session_id
    };
}


sem ChatNode.respond = """
You are AnyGPT, a helpful AI assistant that answers questions based on the user's uploaded documents.

ROUTING RULES - decide BEFORE responding:

1. CASUAL messages (greetings like "hi", "hello", "thanks", or general chitchat):
   - Reply naturally. Do NOT call search_docs.
   - Mention that you can help with their uploaded documents.

2. DOCUMENT-RELATED questions (anything about content, summaries, topics, or analysis):
   - You MUST call search_docs with a relevant query.
   - Base your answer STRICTLY on the returned results.
   - ALWAYS cite source: "According to [filename], page [N]..." or "From [filename]:..."
   - If search_docs returns no results or irrelevant results, say: "I could not find information about that in your uploaded documents."
   - If no documents are uploaded, tell the user to upload documents first.
   - Try different query keywords if initial results are insufficient.

3. GENERAL KNOWLEDGE questions (clearly unrelated to uploaded documents):
   - Answer from your general knowledge WITHOUT calling search_docs.

OUTPUT FORMAT:
- Use markdown: headings, bullet points, bold for key terms.
- Keep answers concise but thorough.
- Always attribute information to the source document when using search results.
""";


impl ChatNode.chat {
    print("Entering ChatNode - generating response");
    result = collect_chat_response(
        self.respond(message=visitor.message, chat_history=visitor.chat_history),
        visitor
    );
    report result;
}


impl Session.chat {
    print("=== New chat message received in session:", self.id);

    # Save user message to chat history
    self.chat_history.append({"role": "user", "content": visitor.message});
    self.updated_at = datetime.now().isoformat();
    visitor.chat_history = self.chat_history;

    # Visit ChatNode - create if needed
    visit [-->](?:ChatNode) else {
        chat_node = root ++> ChatNode();
        visit chat_node;
    }
}


impl get_session.get_chat_history {
    all_sessions = [-->(?:Session)];
    for session in all_sessions {
        if session.id == self.session_id {
            visit session;
            return;
        }
    }
    report {"chat_history": [], "session_id": self.session_id, "found": False, "success": True};
}


impl get_session.return_history {
    report {
        "chat_history": here.chat_history,
        "session_id": here.id,
        "found": True,
        "success": True
    };
}


impl new_session.create_session {
    if not self.session_id {
        import time;
        self.session_id = f"session_{int(time.time())}";
    }

    now = datetime.now().isoformat();

    session_node = here ++> Session(
        id=self.session_id,
        chat_history=[],
        created_at=now,
        updated_at=now
    );

    report {
        "success": True,
        "session_id": self.session_id,
        "status": "created",
        "chat_history": []
    };
}
