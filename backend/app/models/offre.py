from sqlalchemy import Column, Integer, String, Text, Boolean, DateTime, Enum, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
import enum
from ..database import Base


class OffreStatus(str, enum.Enum):
    PENDING = "pending"
    VALIDATED = "validated"
    REJECTED = "rejected"


class Offre(Base):
    __tablename__ = "offres"
    
    id = Column(Integer, primary_key=True, index=True)
    titre = Column(String(255), nullable=False)
    description = Column(Text, nullable=False)
    type_formation = Column(String(100))  # Licence, Master, Doctorat, etc.
    duree = Column(String(50))  # "2 ans", "3 ans", etc.
    conditions = Column(Text)
    status = Column(Enum(OffreStatus), default=OffreStatus.VALIDATED, nullable=False)  # Admin creates validated offers by default
    admin_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relations
    admin = relationship("User", back_populates="offres")
    candidatures = relationship("Candidature", back_populates="offre", cascade="all, delete-orphan")
