"""Tenant node - represents a data tenant in the system.

Phase 1: Single default tenant (no auth required).
Phase 2+: Multi-tenant with per-tenant isolation.
"""

node Tenant {
    has id: str;
    has name: str = "default";
    has config: dict = {};
    has created_at: str = "";
}
