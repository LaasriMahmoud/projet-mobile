from sqlalchemy import Column, Integer, String, Date, DateTime, JSON, Enum, ForeignKey, Text
from sqlalchemy.orm import relationship
from datetime import datetime
import enum
from ..database import Base


class ProfileStatus(str, enum.Enum):
    INCOMPLETE = "incomplete"      # Profil non rempli
    PENDING = "pending"           # Documents soumis, en attente OCR
    VERIFIED = "verified"         # Profil vérifié et complet
    REJECTED = "rejected"         # Documents rejetés


class StudentProfile(Base):
    __tablename__ = "student_profiles"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    
    # Informations personnelles
    nom = Column(String(100), nullable=False)
    prenom = Column(String(100), nullable=False)
    date_naissance = Column(Date, nullable=False)
    telephone = Column(String(20))
    adresse = Column(Text)
    
    # Documents - chemins des fichiers
    cin_image_path = Column(String(255))
    bac_image_path = Column(String(255))
    releve_notes_path = Column(String(255))
    
    # Type de diplôme en cours
    current_diploma = Column(String(50), nullable=True)  # Will be migrated to enum later
    
    # Données OCR extraites
    cin_data = Column(JSON)
    bac_data = Column(JSON)
    releve_data = Column(JSON)
    
    # Statut de vérification
    profile_status = Column(Enum(ProfileStatus), default=ProfileStatus.INCOMPLETE, nullable=False)
    verified_at = Column(DateTime, nullable=True)
    rejection_reason = Column(Text, nullable=True)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relations
    user = relationship("User", back_populates="student_profile")
