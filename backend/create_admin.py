from app.database import SessionLocal
from app.models import User, UserRole
from app.utils import get_password_hash

def create_admin():
    db = SessionLocal()
    try:
        # Check if admin exists
        admin_email = "admin@school.com"
        existing_admin = db.query(User).filter(User.email == admin_email).first()
        
        if existing_admin:
            print(f"Admin user {admin_email} already exists.")
            # Update password just in case (optional, but good for reset)
            existing_admin.hashed_password = get_password_hash("admin123")
            db.commit()
            print("Admin password updated to 'admin123'")
        else:
            new_admin = User(
                email=admin_email,
                username="admin",
                hashed_password=get_password_hash("admin123"),
                role=UserRole.ADMIN,
                is_active=True
            )
            db.add(new_admin)
            db.commit()
            print(f"Admin user created: {admin_email} / admin123")
            
    except Exception as e:
        print(f"Error creating admin: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    create_admin()
