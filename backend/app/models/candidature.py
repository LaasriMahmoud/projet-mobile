from sqlalchemy import Column, Integer, String, Text, DateTime, Enum, ForeignKey, JSON
from sqlalchemy.orm import relationship
from datetime import datetime
import enum
from ..database import Base


class CandidatureStatus(str, enum.Enum):
    INCOMPLETE = "incomplete"  # Notes not filled
    SUBMITTED = "submitted"  # Notes filled, awaiting admin review
    IN_REVIEW = "in_review"
    ACCEPTED = "accepted"
    REJECTED = "rejected"


class Candidature(Base):
    __tablename__ = "candidatures"
    
    id = Column(Integer, primary_key=True, index=True)
    candidat_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    offre_id = Column(Integer, ForeignKey("offres.id"), nullable=False)
    
    # Informations personnelles
    nom = Column(String(100), nullable=False)
    prenom = Column(String(100), nullable=False)
    date_naissance = Column(String(50))
    telephone = Column(String(20))
    
    # Documents
    cin_image_path = Column(String(500))
    bac_image_path = Column(String(500))
    
    # Données OCR extraites
    cin_data = Column(JSON)  # {text_extracted, verified_fields, confidence}
    bac_data = Column(JSON)  # {text_extracted, verified_fields, confidence}
    
    # Statut et commentaires
    status = Column(Enum(CandidatureStatus), default=CandidatureStatus.INCOMPLETE, nullable=False)
    commentaire = Column(Text)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relations
    candidat = relationship("User", back_populates="candidatures")
    offre = relationship("Offre", back_populates="candidatures")
    semester_grades = relationship("SemesterGrade", back_populates="candidature", cascade="all, delete-orphan")

