from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import Offre, User, UserRole, OffreStatus
from ..schemas import OffreCreate, OffreUpdate, OffreResponse
from ..utils import get_current_user

router = APIRouter(prefix="/offres", tags=["Offres"])


@router.get("/", response_model=List[OffreResponse])
async def get_offres(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get list of offres.
    ADMIN sees all.
    CANDIDAT sees only VALIDATED offers.
    """
    query = db.query(Offre)
    
    if current_user.role == UserRole.CANDIDAT:
        query = query.filter(Offre.status == OffreStatus.VALIDATED)
    
    offres = query.offset(skip).limit(limit).all()
    return offres


@router.get("/{offre_id}", response_model=OffreResponse)
async def get_offre(
    offre_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get details of a specific offre"""
    offre = db.query(Offre).filter(Offre.id == offre_id).first()
    
    if not offre:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Offre not found"
        )
    
    if current_user.role == UserRole.CANDIDAT and offre.status != OffreStatus.VALIDATED:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="This offre is not available"
        )
    
    return offre


@router.post("/", response_model=OffreResponse, status_code=status.HTTP_201_CREATED)
async def create_offre(
    offre_data: OffreCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Create a new offre (ADMIN only)
    """
    if current_user.role != UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only admins can create offres"
        )
    
    new_offre = Offre(
        **offre_data.model_dump(),
        admin_id=current_user.id,
        status=OffreStatus.VALIDATED  # Admins create validated offers by default
    )
    
    db.add(new_offre)
    db.commit()
    db.refresh(new_offre)
    
    return new_offre


@router.put("/{offre_id}", response_model=OffreResponse)
async def update_offre(
    offre_id: int,
    offre_data: OffreUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Update an offre (ADMIN only)
    """
    if current_user.role != UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only admins can update offres"
        )

    offre = db.query(Offre).filter(Offre.id == offre_id).first()
    
    if not offre:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Offre not found"
        )
    
    # Update fields
    for field, value in offre_data.model_dump(exclude_unset=True).items():
        setattr(offre, field, value)
    
    db.commit()
    db.refresh(offre)
    
    return offre


@router.delete("/{offre_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_offre(
    offre_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Delete an offre (ADMIN only)
    """
    if current_user.role != UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only admins can delete offres"
        )

    offre = db.query(Offre).filter(Offre.id == offre_id).first()
    
    if not offre:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Offre not found"
        )
    
    db.delete(offre)
    db.commit()
    
    return None
