from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from ..models.offre import OffreStatus


class OffreBase(BaseModel):
    titre: str
    description: str
    type_formation: Optional[str] = None
    duree: Optional[str] = None
    conditions: Optional[str] = None


class OffreCreate(OffreBase):
    pass


class OffreUpdate(BaseModel):
    titre: Optional[str] = None
    description: Optional[str] = None
    type_formation: Optional[str] = None
    duree: Optional[str] = None
    conditions: Optional[str] = None


class OffreResponse(OffreBase):
    id: int
    status: OffreStatus
    admin_id: int
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


class OffreValidation(BaseModel):
    status: OffreStatus  # validated or rejected
    commentaire: Optional[str] = None
