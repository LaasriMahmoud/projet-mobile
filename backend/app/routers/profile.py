from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Form
from sqlalchemy.orm import Session
from typing import Optional
from datetime import date, datetime
import os
import shutil

from ..database import get_db
from ..models import StudentProfile, ProfileStatus, User
from ..schemas import StudentProfileCreate, StudentProfileUpdate, StudentProfileResponse
from ..utils import get_current_user, ocr_service

router = APIRouter(prefix="/profile", tags=["Student Profile"])

UPLOAD_DIR = "uploads/profiles"
os.makedirs(UPLOAD_DIR, exist_ok=True)


@router.post("/complete", response_model=StudentProfileResponse, status_code=status.HTTP_201_CREATED)
async def complete_profile(
    nom: str = Form(...),
    prenom: str = Form(...),
    date_naissance: date = Form(...),
    telephone: Optional[str] = Form(None),
    adresse: Optional[str] = Form(None),
    cin_image: UploadFile = File(...),
    bac_image: UploadFile = File(...),
    releve_notes: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Complete student profile with personal info and documents.
    Triggers OCR verification automatically.
    """
    # Check if profile already exists
    existing_profile = db.query(StudentProfile).filter(
        StudentProfile.user_id == current_user.id
    ).first()
    
    if existing_profile and existing_profile.profile_status == ProfileStatus.VERIFIED:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Votre profil est déjà vérifié. Utilisez la mise à jour si nécessaire."
        )
    
    # Save uploaded files
    cin_path = os.path.join(UPLOAD_DIR, f"cin_{current_user.id}_{cin_image.filename}")
    bac_path = os.path.join(UPLOAD_DIR, f"bac_{current_user.id}_{bac_image.filename}")
    releve_path = os.path.join(UPLOAD_DIR, f"releve_{current_user.id}_{releve_notes.filename}")
    
    with open(cin_path, "wb") as buffer:
        shutil.copyfileobj(cin_image.file, buffer)
    
    with open(bac_path, "wb") as buffer:
        shutil.copyfileobj(bac_image.file, buffer)
    
    with open(releve_path, "wb") as buffer:
        shutil.copyfileobj(releve_notes.file, buffer)
    
    # Run OCR verification
    try:
        cin_data = ocr_service.verify_cin(cin_path)
        bac_data = ocr_service.verify_bac(bac_path)
        releve_data = ocr_service.verify_releve_notes(releve_path)
        
        # Auto-verify if OCR successful (can be changed to manual review)
        profile_status = ProfileStatus.VERIFIED
        verified_at = datetime.utcnow()
    except Exception as e:
        # If OCR fails, set to pending for manual review
        cin_data = {"error": str(e)}
        bac_data = {}
        releve_data = {}
        profile_status = ProfileStatus.PENDING
        verified_at = None
    
    # Create or update profile
    if existing_profile:
        existing_profile.nom = nom
        existing_profile.prenom = prenom
        existing_profile.date_naissance = date_naissance
        existing_profile.telephone = telephone
        existing_profile.adresse = adresse
        existing_profile.cin_image_path = cin_path
        existing_profile.bac_image_path = bac_path
        existing_profile.releve_notes_path = releve_path
        existing_profile.cin_data = cin_data
        existing_profile.bac_data = bac_data
        existing_profile.releve_data = releve_data
        existing_profile.profile_status = profile_status
        existing_profile.verified_at = verified_at
        existing_profile.updated_at = datetime.utcnow()
        db.commit()
        db.refresh(existing_profile)
        return existing_profile
    else:
        new_profile = StudentProfile(
            user_id=current_user.id,
            nom=nom,
            prenom=prenom,
            date_naissance=date_naissance,
            telephone=telephone,
            adresse=adresse,
            cin_image_path=cin_path,
            bac_image_path=bac_path,
            releve_notes_path=releve_path,
            cin_data=cin_data,
            bac_data=bac_data,
            releve_data=releve_data,
            profile_status=profile_status,
            verified_at=verified_at
        )
        db.add(new_profile)
        db.commit()
        db.refresh(new_profile)
        return new_profile


@router.get("/me", response_model=StudentProfileResponse)
async def get_my_profile(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get current user's profile"""
    profile = db.query(StudentProfile).filter(
        StudentProfile.user_id == current_user.id
    ).first()
    
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profil non trouvé. Veuillez compléter votre profil."
        )
    
    return profile


@router.get("/status")
async def get_profile_status(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Check if profile is complete and verified"""
    profile = db.query(StudentProfile).filter(
        StudentProfile.user_id == current_user.id
    ).first()
    
    if not profile:
        return {
            "has_profile": False,
            "status": ProfileStatus.INCOMPLETE,
            "can_apply": False,
            "message": "Veuillez compléter votre profil pour postuler aux offres."
        }
    
    return {
        "has_profile": True,
        "status": profile.profile_status,
        "can_apply": profile.profile_status == ProfileStatus.VERIFIED,
        "message": {
            ProfileStatus.INCOMPLETE: "Profil incomplet",
            ProfileStatus.PENDING: "Documents en cours de vérification",
            ProfileStatus.VERIFIED: "Profil vérifié - Vous pouvez postuler",
            ProfileStatus.REJECTED: f"Profil rejeté: {profile.rejection_reason or 'Raison non spécifiée'}"
        }.get(profile.profile_status, "Statut inconnu")
    }


@router.put("/update", response_model=StudentProfileResponse)
async def update_profile(
    profile_update: StudentProfileUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update student profile (personal info only, not documents)"""
    profile = db.query(StudentProfile).filter(
        StudentProfile.user_id == current_user.id
    ).first()
    
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profil non trouvé"
        )
    
    # Update fields if provided
    if profile_update.nom is not None:
        profile.nom = profile_update.nom
    if profile_update.prenom is not None:
        profile.prenom = profile_update.prenom
    if profile_update.date_naissance is not None:
        profile.date_naissance = profile_update.date_naissance
    if profile_update.telephone is not None:
        profile.telephone = profile_update.telephone
    if profile_update.adresse is not None:
        profile.adresse = profile_update.adresse
    
    profile.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(profile)
    
    return profile
