from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models.user import User
from ..models.candidature import Candidature, CandidatureStatus
from ..models.semester_grade import SemesterGrade, DiplomaType
from ..utils.dependencies import get_current_user, require_role
from ..models.user import UserRole
from datetime import datetime

router = APIRouter(prefix="/candidatures", tags=["candidatures-grades"])


@router.get("/my-candidatures")
async def get_my_candidatures(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get all candidatures for the current user
    """
    if current_user.role != UserRole.CANDIDAT:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only candidates can view their candidatures"
        )
    
    candidatures = db.query(Candidature).filter(
        Candidature.candidat_id == current_user.id
    ).all()
    
    result = []
    for cand in candidatures:
        grades = db.query(SemesterGrade).filter(
            SemesterGrade.candidature_id == cand.id
        ).all()
        
        result.append({
            "id": cand.id,
            "offre_id": cand.offre_id,
            "offre_titre": cand.offre.titre if cand.offre else None,
            "nom": cand.nom,
            "prenom": cand.prenom,
            "status": cand.status.value,
            "commentaire": cand.commentaire,
            "created_at": cand.created_at.isoformat() if cand.created_at else None,
            "grades_count": len(grades),
            "grades": [{
                "id": g.id,
                "semester_number": g.semester_number,
                "average": g.average,
                "academic_year": g.academic_year
            } for g in grades]
        })
    
    return result


@router.post("/{candidature_id}/grades")
async def add_semester_grade(
    candidature_id: int,
    semester_number: int,
    diploma_type: str,
    academic_year: str,
    average: float,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Add a semester grade to a candidature
    """
    # Check candidature exists and belongs to user
    candidature = db.query(Candidature).filter(
        Candidature.id == candidature_id,
        Candidature.candidat_id == current_user.id
    ).first()
    
    if not candidature:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Candidature not found"
        )
    
    # Check if grade already exists for this semester
    existing = db.query(SemesterGrade).filter(
        SemesterGrade.candidature_id == candidature_id,
        SemesterGrade.semester_number == semester_number
    ).first()
    
    if existing:
        # Update existing
        existing.average = average
        existing.academic_year = academic_year
        existing.updated_at = datetime.utcnow()
    else:
        # Create new
        new_grade = SemesterGrade(
            candidature_id=candidature_id,
            diploma_type=DiplomaType(diploma_type),
            semester_number=semester_number,
            academic_year=academic_year,
            average=average
        )
        db.add(new_grade)
    
    db.commit()
    
    return {"message": "Grade added successfully"}


@router.post("/{candidature_id}/submit-grades")
async def submit_grades(
    candidature_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Mark candidature as submitted after filling all grades
    Changes status from INCOMPLETE to SUBMITTED
    """
    candidature = db.query(Candidature).filter(
        Candidature.id == candidature_id,
        Candidature.candidat_id == current_user.id
    ).first()
    
    if not candidature:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Candidature not found"
        )
    
    # Check if there are grades
    grades_count = db.query(SemesterGrade).filter(
        SemesterGrade.candidature_id == candidature_id
    ).count()
    
    if grades_count == 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Vous devez ajouter au moins une note avant de soumettre"
        )
    
    # Change status from INCOMPLETE to SUBMITTED
    if candidature.status == CandidatureStatus.INCOMPLETE:
        candidature.status = CandidatureStatus.SUBMITTED
        candidature.updated_at = datetime.utcnow()
        db.commit()
    
    return {"message": "Candidature soumise avec succès", "status": candidature.status.value}


@router.delete("/grades/{grade_id}")
async def delete_grade(
    grade_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Delete a semester grade"""
    grade = db.query(SemesterGrade).filter(SemesterGrade.id == grade_id).first()
    
    if not grade:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Grade not found"
        )
    
    # Check ownership
    candidature = db.query(Candidature).filter(
        Candidature.id == grade.candidature_id,
        Candidature.candidat_id == current_user.id
    ).first()
    
    if not candidature:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized"
        )
    
    db.delete(grade)
    db.commit()
    
    return {"message": "Grade deleted"}
