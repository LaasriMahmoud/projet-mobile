from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import User, Offre, UserRole, OffreStatus
from ..schemas import UserResponse, UserUpdate, OffreResponse, OffreValidation
from ..utils import get_current_user
from datetime import datetime

router = APIRouter(prefix="/admin", tags=["Admin"])


def check_admin(current_user: User = Depends(get_current_user)):
    """Ensure current user is admin"""
    if current_user.role != UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin access required"
        )
    return current_user


@router.get("/users", response_model=List[UserResponse])
async def get_all_users(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    admin: User = Depends(check_admin)
):
    """
    Get all users (ADMIN only)
    """
    users = db.query(User).offset(skip).limit(limit).all()
    return users


@router.put("/users/{user_id}/status", response_model=UserResponse)
async def update_user_status(
    user_id: int,
    is_active: bool,
    db: Session = Depends(get_db),
    admin: User = Depends(check_admin)
):
    """
    Activate or deactivate a user (ADMIN only)
    """
    user = db.query(User).filter(User.id == user_id).first()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    user.is_active = is_active
    db.commit()
    db.refresh(user)
    
    return user


@router.get("/offres/pending", response_model=List[OffreResponse])
async def get_pending_offres(
    db: Session = Depends(get_db),
    admin: User = Depends(check_admin)
):
    """
    Get all offres pending validation (ADMIN only)
    """
    pending_offres = db.query(Offre).filter(
        Offre.status == OffreStatus.PENDING
    ).all()
    
    return pending_offres


@router.get("/offres/all", response_model=List[OffreResponse])
async def get_all_offres(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    admin: User = Depends(check_admin)
):
    """
    Get all offres regardless of status (ADMIN only)
    """
    offres = db.query(Offre).offset(skip).limit(limit).all()
    return offres


@router.put("/offres/{offre_id}/validate", response_model=OffreResponse)
async def validate_offre(
    offre_id: int,
    validation: OffreValidation,
    db: Session = Depends(get_db),
    admin: User = Depends(check_admin)
):
    """
    Validate or reject an offre (ADMIN only)
    
    - **status**: "validated" or "rejected"
    """
    offre = db.query(Offre).filter(Offre.id == offre_id).first()
    
    if not offre:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Offre not found"
        )
    
    if validation.status not in [OffreStatus.VALIDATED, OffreStatus.REJECTED]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Status must be 'validated' or 'rejected'"
        )
    
    offre.status = validation.status
    db.commit()
    db.refresh(offre)
    
    return offre


@router.delete("/users/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_user(
    user_id: int,
    db: Session = Depends(get_db),
    admin: User = Depends(check_admin)
):
    """
    Delete a user (ADMIN only)
    Warning: This will cascade delete all related data
    """
    user = db.query(User).filter(User.id == user_id).first()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    # Prevent admin from deleting themselves
    if user.id == admin.id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot delete your own account"
        )
    
    db.delete(user)
    db.commit()
    
    return None


# ===== NEW ENDPOINTS FOR STUDENT ANALYTICS =====

@router.get("/students")
async def get_all_students(
    skip: int = 0,
    limit: int = 50,
    db: Session = Depends(get_db),
    admin: User = Depends(check_admin)
):
    """
    Get all CANDIDAT users
    - Shows basic user information
    - No dependency on student_profiles table
    """
    try:
        # Query for CANDIDAT users only
        users = db.query(User).filter(User.role == UserRole.CANDIDAT).offset(skip).limit(limit).all()
        
        # Build simple response
        result = []
        for user in users:
            result.append({
                "id": user.id,
                "user_id": user.id,
                "nom": user.username,  # Using username as nom
                "prenom": "",
                "email": user.email,
                "current_diploma": None,
                "profile_status": "registered",
                "global_average": 0,
                "total_semesters": 0,
                "created_at": user.created_at
            })
        
        return result
    except Exception as e:
        print(f"Error in get_all_students: {str(e)}")
        import traceback
        traceback.print_exc()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error fetching students: {str(e)}"
        )




@router.get("/students/{student_id}/grades")
async def get_student_grades(
    student_id: int,
    db: Session = Depends(get_db),
    admin: User = Depends(check_admin)
):
    """
    Get detailed semester grades for a specific student
    Returns all semesters with grades, diploma info, and statistics
    """
    from ..models import StudentProfile, SemesterGrade
    from sqlalchemy import func
    
    # Get student profile
    student = db.query(StudentProfile).filter(StudentProfile.id == student_id).first()
    if not student:
        raise HTTPException(status_code=404, detail="Student not found")
    
    # Get all semester grades
    grades = db.query(SemesterGrade).filter(
        SemesterGrade.student_profile_id == student_id
    ).order_by(SemesterGrade.semester_number).all()
    
    # Calculate statistics
    global_avg = 0
    if grades:
        valid_grades = [g.average for g in grades if g.average is not None]
        if valid_grades:
            global_avg = sum(valid_grades) / len(valid_grades)
    
    return {
        "student_info": {
            "id": student.id,
            "nom": student.nom,
            "prenom": student.prenom,
            "email": student.user.email,
            "current_diploma": student.current_diploma,
            "profile_status": student.profile_status.value
        },
        "diploma_type": grades[0].diploma_type.value if grades else student.current_diploma,
        "semesters": [
            {
                "id": g.id,
                "semester_number": g.semester_number,
                "academic_year": g.academic_year,
                "average": g.average,
                "grades_detail": g.grades_detail,
                "is_validated": g.is_validated,
                "created_at": g.created_at
            }
            for g in grades
        ],
        "statistics": {
            "total_semesters": len(grades),
            "global_average": round(global_avg, 2),
            "validated_semesters": len([g for g in grades if g.is_validated])
        }
    }


@router.get("/statistics")
async def get_statistics(
    db: Session = Depends(get_db),
    admin: User = Depends(check_admin)
):
    """
    Get global statistics about students and grades
    """
    from sqlalchemy import func
    from ..models import StudentProfile, SemesterGrade, ProfileStatus
    
    # Total students
    total_students = db.query(StudentProfile).count()
    
    # Verified profiles
    verified_profiles = db.query(StudentProfile).filter(
        StudentProfile.profile_status == ProfileStatus.VERIFIED
    ).count()
    
    # Students by diploma
    by_diploma = db.query(
        StudentProfile.current_diploma,
        func.count(StudentProfile.id)
    ).filter(
        StudentProfile.current_diploma.isnot(None)
    ).group_by(StudentProfile.current_diploma).all()
    
    # Average by diploma
    avg_by_diploma = db.query(
        StudentProfile.current_diploma,
        func.avg(SemesterGrade.average)
    ).join(
        SemesterGrade, StudentProfile.id == SemesterGrade.student_profile_id
    ).filter(
        StudentProfile.current_diploma.isnot(None),
        SemesterGrade.average.isnot(None)
    ).group_by(StudentProfile.current_diploma).all()
    
    return {
        "total_students": total_students,
        "verified_profiles": verified_profiles,
        "pending_verification": total_students - verified_profiles,
        "students_by_diploma": {d: count for d, count in by_diploma} if by_diploma else {},
        "average_by_diploma": {d: round(float(avg), 2) for d, avg in avg_by_diploma} if avg_by_diploma else {}
    }


# Candidature Management
@router.get("/candidatures")
async def get_all_candidatures(
    status_filter: str = None,
    skip: int = 0,
    limit: int = 50,
    db: Session = Depends(get_db),
    admin: User = Depends(check_admin)
):
    """
    Get all candidatures for admin review
    Can filter by status: incomplete, submitted, in_review, accepted, rejected
    """
    from ..models.candidature import Candidature, CandidatureStatus
    from ..models.semester_grade import SemesterGrade
    
    query = db.query(Candidature)
    
    if status_filter:
        try:
            status_enum = CandidatureStatus(status_filter)
            query = query.filter(Candidature.status == status_enum)
        except ValueError:
            pass
    
    candidatures = query.offset(skip).limit(limit).all()
    
    result = []
    for cand in candidatures:
        grades = db.query(SemesterGrade).filter(
            SemesterGrade.candidature_id == cand.id
        ).all()
        
        avg_total = sum(g.average for g in grades if g.average) / len(grades) if grades else 0
        
        result.append({
            "id": cand.id,
            "candidat_id": cand.candidat_id,
            "candidat_nom": cand.nom,
            "candidat_prenom": cand.prenom,
            "candidat_email": cand.candidat.email if cand.candidat else None,
            "offre_id": cand.offre_id,
            "offre_titre": cand.offre.titre if cand.offre else None,
            "status": cand.status.value,
            "commentaire": cand.commentaire,
            "created_at": cand.created_at.isoformat() if cand.created_at else None,
            "grades_count": len(grades),
            "average_total": round(avg_total, 2) if avg_total > 0 else None,
            "cin_verification": cand.cin_data.get("verification") if cand.cin_data else None,
            "bac_verification": cand.bac_data.get("verification") if cand.bac_data else None
        })
    
    return result


@router.put("/candidatures/{candidature_id}/status")
async def update_candidature_status(
    candidature_id: int,
    new_status: str,
    commentaire: str = None,
    db: Session = Depends(get_db),
    admin: User = Depends(check_admin)
):
    """
    Update candidature status (accept or reject)
    new_status: 'accepted' or 'rejected' or 'in_review'
    """
    from ..models.candidature import Candidature, CandidatureStatus
    
    candidature = db.query(Candidature).filter(Candidature.id == candidature_id).first()
    
    if not candidature:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Candidature not found"
        )
    
    try:
        status_enum = CandidatureStatus(new_status)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid status: {new_status}. Must be one of: accepted, rejected, in_review"
        )
    
    candidature.status = status_enum
    if commentaire:
        candidature.commentaire = commentaire
    candidature.updated_at = datetime.utcnow()
    
    db.commit()
    db.refresh(candidature)
    
    return {
        "message": f"Candidature {new_status}",
        "candidature_id": candidature.id,
        "status": candidature.status.value,
        "commentaire": candidature.commentaire
    }


@router.get("/candidatures/{candidature_id}")
async def get_candidature_details(
    candidature_id: int,
    db: Session = Depends(get_db),
    admin: User = Depends(check_admin)
):
    """
    Get detailed information about a specific candidature including all grades
    """
    from ..models.candidature import Candidature
    from ..models.semester_grade import SemesterGrade
    
    candidature = db.query(Candidature).filter(Candidature.id == candidature_id).first()
    
    if not candidature:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Candidature not found"
        )
    
    grades = db.query(SemesterGrade).filter(
        SemesterGrade.candidature_id == candidature_id
    ).order_by(SemesterGrade.semester_number).all()
    
    return {
        "id": candidature.id,
        "candidat": {
            "id": candidature.candidat_id,
            "email": candidature.candidat.email if candidature.candidat else None,
            "nom": candidature.nom,
            "prenom": candidature.prenom,
            "telephone": candidature.telephone,
            "date_naissance": candidature.date_naissance
        },
        "offre": {
            "id": candidature.offre_id,
            "titre": candidature.offre.titre if candidature.offre else None,
            "type_formation": candidature.offre.type_formation if candidature.offre else None
        },
        "status": candidature.status.value,
        "commentaire": candidature.commentaire,
        "created_at": candidature.created_at.isoformat() if candidature.created_at else None,
        "updated_at": candidature.updated_at.isoformat() if candidature.updated_at else None,
        "grades": [{
            "id": g.id,
            "semester_number": g.semester_number,
            "average": g.average,
            "academic_year": g.academic_year,
            "diploma_type": g.diploma_type.value if g.diploma_type else None
        } for g in grades],
        "verification": {
            "cin": candidature.cin_data.get("verification") if candidature.cin_data else None,
            "bac": candidature.bac_data.get("verification") if candidature.bac_data else None
        }
    }
