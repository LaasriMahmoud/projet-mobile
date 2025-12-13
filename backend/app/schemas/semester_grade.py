from pydantic import BaseModel, Field
from typing import Optional, Dict
from datetime import datetime
from ..models.semester_grade import DiplomaType


# Base schema
class SemesterGradeBase(BaseModel):
    diploma_type: DiplomaType
    semester_number: int = Field(..., ge=1, le=10)
    academic_year: Optional[str] = Field(None, max_length=10)
    average: Optional[float] = Field(None, ge=0, le=20)
    grades_detail: Optional[Dict[str, float]] = None


# Schema for creating
class SemesterGradeCreate(SemesterGradeBase):
    pass


# Schema for updating
class SemesterGradeUpdate(BaseModel):
    average: Optional[float] = Field(None, ge=0, le=20)
    grades_detail: Optional[Dict[str, float]] = None
    is_validated: Optional[bool] = None


# Schema for response
class SemesterGradeResponse(SemesterGradeBase):
    id: int
    student_profile_id: int
    transcript_path: Optional[str] = None
    ocr_data: Optional[dict] = None
    is_validated: bool
    validated_by: Optional[int] = None
    validated_at: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
