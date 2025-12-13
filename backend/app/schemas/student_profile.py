from pydantic import BaseModel, Field, EmailStr
from datetime import date, datetime
from typing import Optional
from ..models.student_profile import ProfileStatus


# Base schema
class StudentProfileBase(BaseModel):
    nom: str = Field(..., min_length=1, max_length=100)
    prenom: str = Field(..., min_length=1, max_length=100)
    date_naissance: date
    telephone: Optional[str] = Field(None, max_length=20)
    adresse: Optional[str] = None


# Schema for creating profile
class StudentProfileCreate(StudentProfileBase):
    pass


# Schema for updating profile
class StudentProfileUpdate(BaseModel):
    nom: Optional[str] = Field(None, min_length=1, max_length=100)
    prenom: Optional[str] = Field(None, min_length=1, max_length=100)
    date_naissance: Optional[date] = None
    telephone: Optional[str] = Field(None, max_length=20)
    adresse: Optional[str] = None


# Schema for response
class StudentProfileResponse(StudentProfileBase):
    id: int
    user_id: int
    cin_image_path: Optional[str] = None
    bac_image_path: Optional[str] = None
    releve_notes_path: Optional[str] = None
    cin_data: Optional[dict] = None
    bac_data: Optional[dict] = None
    releve_data: Optional[dict] = None
    profile_status: ProfileStatus
    verified_at: Optional[datetime] = None
    rejection_reason: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
