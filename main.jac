"""Backend entry point for AnyGPT application."""

import from services.server {
    Session,
    ChatNode,
    interact,
    new_session,
    get_session,
    close_session,
    upload_document,
    list_documents,
    delete_document,
    reindex,
    index_status,
    get_user_sessions
}


cl {
    import from .frontend { app as ClientApp }

    def:pub app() -> any {
        return <ClientApp />;
    }
}
