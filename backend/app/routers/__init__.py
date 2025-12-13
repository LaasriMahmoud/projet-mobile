from .auth import router as auth_router
from .offres import router as offres_router
from .candidatures import router as candidatures_router
from .admin import router as admin_router
from .profile import router as profile_router

__all__ = ["auth_router", "offres_router", "candidatures_router", "admin_router", "profile_router"]
