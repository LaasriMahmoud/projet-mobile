from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Form
from sqlalchemy.orm import Session
from typing import List, Optional
import os
import shutil
from datetime import datetime
from ..database import get_db
from ..models import Candidature, User, Offre, UserRole, OffreStatus
from ..schemas import CandidatureCreate, CandidatureResponse, OCRVerifyResponse
from ..utils import get_current_user, ocr_service

router = APIRouter(prefix="/candidatures", tags=["Candidatures"])

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)


@router.post("/", response_model=CandidatureResponse, status_code=status.HTTP_201_CREATED)
async def submit_candidature(
    offre_id: int = Form(...),
    nom: str = Form(...),
    prenom: str = Form(...),
    date_naissance: Optional[str] = Form(None),
    telephone: Optional[str] = Form(None),
    cne: str = Form(...),
    mention: str = Form(...),
    cin_image: UploadFile = File(...),
    bac_image: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Submit a candidature (CANDIDAT only)
    Upload CIN and Baccalauréat images for OCR verification
    """
    try:
        if current_user.role != UserRole.CANDIDAT:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only candidates can submit candidatures"
            )
        
        # Check if offre exists and is validated
        offre = db.query(Offre).filter(Offre.id == offre_id).first()
        if not offre:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Offre not found"
            )
        
        if offre.status != OffreStatus.VALIDATED:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Cannot apply to non-validated offre"
            )
        
        # Check if already applied
        existing = db.query(Candidature).filter(
            Candidature.candidat_id == current_user.id,
            Candidature.offre_id == offre_id
        ).first()
        
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="You have already applied to this offre"
            )
        
        # Save uploaded files
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        cin_filename = f"cin_{current_user.id}_{timestamp}_{cin_image.filename}"
        bac_filename = f"bac_{current_user.id}_{timestamp}_{bac_image.filename}"
        
        cin_path = os.path.join(UPLOAD_DIR, cin_filename)
        bac_path = os.path.join(UPLOAD_DIR, bac_filename)
        
        with open(cin_path, "wb") as buffer:
            shutil.copyfileobj(cin_image.file, buffer)
        
        with open(bac_path, "wb") as buffer:
            shutil.copyfileobj(bac_image.file, buffer)
        
        # Perform OCR verification
        cin_ocr_result = ocr_service.verify_cin(cin_path)
        bac_ocr_result = ocr_service.verify_baccalaureat(bac_path)
        
        # Perform verification comparison
        verification_result = ocr_service.verify_candidature_data(
            provided_data={
                "nom": nom,
                "prenom": prenom,
                "cne": cne,
                "mention": mention
            },
            cin_ocr=cin_ocr_result,
            bac_ocr=bac_ocr_result
        )
        
        # Check verification status and reject if data doesn't match
        overall_status = verification_result.get("overall_status")
        
        if overall_status == "no_match":
            # Build detailed error message
            error_details = []
            
            cin_verif = verification_result.get("cin_verification", {})
            for field, data in cin_verif.items():
                if isinstance(data, dict) and not data.get("match"):
                    error_details.append(
                        f"CIN - {field}: fourni '{data.get('provided')}' != extrait '{data.get('extracted')}'"
                    )
            
            bac_verif = verification_result.get("bac_verification", {})
            for field, data in bac_verif.items():
                if isinstance(data, dict) and not data.get("match"):
                    error_details.append(
                        f"BAC - {field}: fourni '{data.get('provided')}' != extrait '{data.get('extracted')}'"
                    )
            
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Les informations fournies ne correspondent pas aux documents: {'; '.join(error_details)}"
            )
        
        elif overall_status == "partial_match":
            # Build warning message for partial match
            error_details = []
            
            cin_verif = verification_result.get("cin_verification", {})
            for field, data in cin_verif.items():
                if isinstance(data, dict) and not data.get("match"):
                    error_details.append(
                        f"{field.upper()}: fourni '{data.get('provided')}' != extrait '{data.get('extracted')}'"
                    )
            
            bac_verif = verification_result.get("bac_verification", {})
            for field, data in bac_verif.items():
                if isinstance(data, dict) and not data.get("match"):
                    error_details.append(
                        f"{field.upper()}: fourni '{data.get('provided')}' != extrait '{data.get('extracted')}'"
                    )
            
            if error_details:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Certaines informations ne correspondent pas: {'; '.join(error_details)}"
                )
        
        # Create candidature with verification results (only if verification passed)
        new_candidature = Candidature(
            candidat_id=current_user.id,
            offre_id=offre_id,
            nom=nom,
            prenom=prenom,
            date_naissance=date_naissance,
            telephone=telephone,
            cin_image_path=cin_path,
            bac_image_path=bac_path,
            cin_data={**cin_ocr_result, "verification": verification_result.get("cin_verification")},
            bac_data={**bac_ocr_result, "verification": verification_result.get("bac_verification")}
        )
        
        db.add(new_candidature)
        db.commit()
        db.refresh(new_candidature)
        
        return new_candidature
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error submitting candidature: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"An error occurred while processing your application: {str(e)}"
        )


@router.post("/verify", response_model=OCRVerifyResponse)
async def verify_document(
    document: UploadFile = File(...),
    document_type: str = Form(...),  # "cin" or "bac"
    current_user: User = Depends(get_current_user)
):
    """
    Verify a single document using OCR (for testing purposes)
    
    - **document_type**: Either "cin" or "bac"
    """
    # Save temporary file
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    temp_filename = f"temp_{document_type}_{current_user.id}_{timestamp}_{document.filename}"
    temp_path = os.path.join(UPLOAD_DIR, temp_filename)
    
    with open(temp_path, "wb") as buffer:
        shutil.copyfileobj(document.file, buffer)
    
    # Perform OCR based on document type
    if document_type.lower() == "cin":
        result = ocr_service.verify_cin(temp_path)
    elif document_type.lower() == "bac":
        result = ocr_service.verify_baccalaureat(temp_path)
    else:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid document_type. Must be 'cin' or 'bac'"
        )
    
    # Clean up temporary file
    try:
        os.remove(temp_path)
    except:
        pass
    
    return OCRVerifyResponse(**result)


@router.get("/me", response_model=List[CandidatureResponse])
async def get_my_candidatures(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get all candidatures submitted by current user (CANDIDAT only)
    """
    if current_user.role != UserRole.CANDIDAT:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only candidates can view their candidatures"
        )
    
    candidatures = db.query(Candidature).filter(
        Candidature.candidat_id == current_user.id
    ).all()
    
    return candidatures


@router.get("/offre/{offre_id}", response_model=List[CandidatureResponse])
async def get_candidatures_for_offre(
    offre_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get all candidatures for a specific offre
    RECRUTEUR: Only for their own offres
    ADMIN: For all offres
    """
    offre = db.query(Offre).filter(Offre.id == offre_id).first()
    
    if not offre:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Offre not found"
        )
    
    # Check permissions
    if current_user.role == UserRole.RECRUTEUR and offre.recruteur_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only view candidatures for your own offres"
        )
    
    if current_user.role == UserRole.CANDIDAT:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Candidates cannot view other candidatures"
        )
    
    candidatures = db.query(Candidature).filter(
        Candidature.offre_id == offre_id
    ).all()
    
    return candidatures
