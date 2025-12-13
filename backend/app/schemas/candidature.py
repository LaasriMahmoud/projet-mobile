from pydantic import BaseModel
from typing import Optional, Dict, Any
from datetime import datetime
from ..models.candidature import CandidatureStatus


class CandidatureBase(BaseModel):
    nom: str
    prenom: str
    date_naissance: Optional[str] = None
    telephone: Optional[str] = None


class CandidatureCreate(CandidatureBase):
    offre_id: int


class CandidatureResponse(CandidatureBase):
    id: int
    candidat_id: int
    offre_id: int
    cin_image_path: Optional[str] = None
    bac_image_path: Optional[str] = None
    cin_data: Optional[Dict[str, Any]] = None
    bac_data: Optional[Dict[str, Any]] = None
    status: CandidatureStatus
    commentaire: Optional[str] = None
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


class CandidatureUpdate(BaseModel):
    status: Optional[CandidatureStatus] = None
    commentaire: Optional[str] = None


class OCRVerifyResponse(BaseModel):
    success: bool
    extracted_text: str
    confidence: float
    verified_fields: Dict[str, Any]
