"""Protected route wrapper for authentication."""

import from "@jac/runtime" { Navigate, jacIsLoggedIn }


"""Wrap routes that require authentication."""
def:pub ProtectedRoute(p: any) -> any {
    if not jacIsLoggedIn() {
        return <Navigate to="/login" />;
    }
    return p.children;
}
