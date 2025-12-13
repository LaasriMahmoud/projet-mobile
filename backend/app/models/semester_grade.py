from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, JSON, Enum, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
import enum
from ..database import Base


class DiplomaType(str, enum.Enum):
    LICENCE = "licence"          # 6 semestres (S1-S6)
    MASTER = "master"            # 4 semestres (M1S1, M1S2, M2S1, M2S2)
    DEUST = "deust"              # 4 semestres (S1-S4)
    DUT = "dut"                  # 4 semestres (S1-S4)
    DOCTORAT = "doctorat"        # Années (A1-A3+)


class SemesterGrade(Base):
    __tablename__ = "semester_grades"
    
    id = Column(Integer, primary_key=True, index=True)
    candidature_id = Column(Integer, ForeignKey("candidatures.id"), nullable=False)
    
    # Type de diplôme
    diploma_type = Column(Enum(DiplomaType), nullable=False)
    semester_number = Column(Integer, nullable=False)  # 1, 2, 3, etc.
    academic_year = Column(String(10))  # "2023-2024"
    
    # Notes
    average = Column(Float)  # Moyenne générale du semestre
    grades_detail = Column(JSON)  # {"Math": 15.5, "Physique": 14.0, ...}
    
    # Documents
    transcript_path = Column(String(255))  # Chemin vers le relevé scanné
    ocr_data = Column(JSON)  # Données OCR extraites
    
    # Validation
    is_validated = Column(Boolean, default=False)
    validated_by = Column(Integer, ForeignKey("users.id"), nullable=True)
    validated_at = Column(DateTime, nullable=True)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relations
    candidature = relationship("Candidature", back_populates="semester_grades")
    validator = relationship("User", foreign_keys=[validated_by])
