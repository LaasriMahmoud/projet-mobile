from sqlalchemy.orm import Session
from app.database import SessionLocal, engine
from app.models import Offre, OffreStatus, User, UserRole
from app.utils.auth import get_password_hash

def seed_offers():
    db = SessionLocal()
    try:
        # Ensure admin exists
        admin = db.query(User).filter(User.email == "admin@school.com").first()
        if not admin:
            admin = User(
                email="admin@school.com",
                username="admin",
                hashed_password=get_password_hash("admin123"),
                role=UserRole.ADMIN,
                is_active=True
            )
            db.add(admin)
            db.commit()
            db.refresh(admin)
            print("Admin user created")
        
        # Check if offers exist
        if db.query(Offre).count() == 0:
            offers = [
                Offre(
                    titre="Licence Informatique",
                    description="Formation complète en développement logiciel, algorithmique et bases de données.",
                    type_formation="Licence",
                    duree="3 ans",
                    conditions="Baccalauréat Scientifique ou Technique",
                    status=OffreStatus.VALIDATED,
                    admin_id=admin.id
                ),
                Offre(
                    titre="Master Intelligence Artificielle",
                    description="Spécialisation en Machine Learning, Deep Learning et Data Science.",
                    type_formation="Master",
                    duree="2 ans",
                    conditions="Licence en Informatique ou Mathématiques",
                    status=OffreStatus.VALIDATED,
                    admin_id=admin.id
                ),
                Offre(
                    titre="DUT Génie Logiciel",
                    description="Formation technique rapide pour devenir développeur web et mobile.",
                    type_formation="DUT",
                    duree="2 ans",
                    conditions="Baccalauréat toutes séries",
                    status=OffreStatus.VALIDATED,
                    admin_id=admin.id
                )
            ]
            
            db.add_all(offers)
            db.commit()
            print(f"Successfully added {len(offers)} sample offers!")
        else:
            print("Offers already exist in database")
            
    except Exception as e:
        print(f"Error seeding data: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    seed_offers()
